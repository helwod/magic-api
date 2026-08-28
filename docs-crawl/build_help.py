#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Download magic-api documentation (https://www.ssssssss.org/magic-api/) and produce
a single, self-contained, ad-free offline HTML help document.

Design notes:
- Two phases: CRAWL (save raw page HTML to ./pages/<slug>.html) then BUILD
  (parse cached pages, strip ads, inline images, merge into one HTML).
- Crawl is resumable: pages already on disk are skipped, so a rate-limit ban
  mid-run does not lose progress and a later re-run just fetches the gaps.
- Conservative request rate (small delay + low concurrency) to avoid WAF bans.
"""
import os, re, sys, time, base64, json, concurrent.futures
from urllib.parse import urljoin
import requests
from bs4 import BeautifulSoup

BASE = "https://www.ssssssss.org"
DOC_HOME = BASE + "/magic-api/"
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/124.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
}
HERE = os.path.dirname(os.path.abspath(__file__))
PAGES_DIR = os.path.join(HERE, "pages")
OUT = os.path.join(HERE, "magic-api-help.html")
os.makedirs(PAGES_DIR, exist_ok=True)

SESSION = requests.Session()
SESSION.headers.update(HEADERS)
IMG_CACHE = {}  # abs url -> data uri

GROUP_MAP = {
    "quick": ("指南", "快速入门"),
    "base": ("指南", "基础教程"),
    "security": ("指南", "权限配置"),
    "senior": ("指南", "高级应用"),
    "plugin": ("指南", "插件"),
    "5f9028": ("指南", "插件 / nebula"),
    "module": ("API", "模块"),
    "function": ("API", "函数"),
    "extension": ("API", "扩展"),
    "config": ("配置", "配置"),
    "changelog": ("更新日志", "更新日志"),
    "faq": ("FAQ", "FAQ"),
    "sponsor": ("赞助", "赞助"),
    "group": ("分组", "分组"),
}

def slug_of(path):
    p = path.strip("/")
    if p.startswith("magic-api/pages/"):
        p = p[len("magic-api/pages/"):]
    return p.strip("/")

def page_path(slug):
    return os.path.join(PAGES_DIR, slug + ".html")

def fetch(url, timeout=(10, 30)):
    for _ in range(2):
        try:
            r = SESSION.get(url, timeout=timeout)
            if r.status_code == 200:
                r.encoding = "utf-8"
                return r.text
            if r.status_code in (404, 410):
                return None
        except Exception:
            pass
        time.sleep(1.5)
    return None

def crawl():
    seeds = [
        "/magic-api/",
        "/magic-api/pages/quick/intro/",
        "/magic-api/pages/base/page/",
        "/magic-api/pages/security/login/",
        "/magic-api/pages/senior/interceptor/",
        "/magic-api/pages/plugin/dev/",
        "/magic-api/pages/module/db/",
        "/magic-api/pages/function/aggregation/",
        "/magic-api/pages/extension/object/",
        "/magic-api/pages/config/spring-boot/",
        "/magic-api/pages/changelog/v2/",
        "/magic-api/pages/faq/",
        "/magic-api/pages/sponsor/",
    ]
    seen, queue, discovered = set(), list(seeds), []
    for depth in range(3):
        nxt = []
        for path in queue:
            if path in seen:
                continue
            seen.add(path)
            if os.path.exists(page_path(slug_of(path))) and path != "/magic-api/":
                # already cached; still collect links from cache
                html = open(page_path(slug_of(path)), encoding="utf-8").read()
            else:
                html = fetch(BASE + path)
                if html and path != "/magic-api/":
                    open(page_path(slug_of(path)), "w", encoding="utf-8").write(html)
                time.sleep(0.4)
            if not html:
                continue
            soup = BeautifulSoup(html, "html.parser")
            for a in soup.find_all("a", href=True):
                h = a["href"]
                if h.startswith("/magic-api/pages/"):
                    norm = h.rstrip("/") + "/"
                    if norm not in discovered:
                        discovered.append(norm)
                    if norm not in seen:
                        nxt.append(norm)
        queue = nxt
    # ensure every discovered page is fetched
    todo = [d for d in discovered if not os.path.exists(page_path(slug_of(d)))]
    print(f"[crawl] discovered {len(discovered)} pages, {len(todo)} still to fetch")
    for d in todo:
        html = fetch(BASE + d)
        if html:
            open(page_path(slug_of(d)), "w", encoding="utf-8").write(html)
        else:
            print(f"[crawl][skip] {d} (blocked / 404)")
        time.sleep(0.5)
    return discovered

def inline_images(soup, img_map):
    for img in soup.find_all("img"):
        src = img.get("src") or img.get("data-src")
        if not src:
            img.decompose(); continue
        if src in img_map:
            img["src"] = img_map[src]
        elif src.startswith("data:"):
            pass
        img.attrs.pop("loading", None)
        img.attrs.pop("srcset", None)

def clean_ads(soup):
    for tag in soup.find_all(["script", "ins", "iframe"]):
        blob = (tag.get("src", "") + " " + " ".join(tag.get("class", []) or [])).lower()
        if any(k in blob for k in ["wwads", "adsbygoogle", "makemoney", "googlesyndication", "ca-pub-", "adsystem"]):
            tag.decompose()
    for tag in soup.find_all(class_=True):
        cls = " ".join(tag.get("class", [])).lower()
        if any(k in cls for k in ["wwads", "adsbygoogle", "ad-banner", "advert"]):
            tag.decompose()

def build():
    img_map_path = os.path.join(HERE, "img_map.json")
    img_map = {}
    if os.path.exists(img_map_path):
        try:
            img_map = json.load(open(img_map_path, encoding="utf-8"))
        except Exception:
            img_map = {}
    records = []
    for fn in sorted(os.listdir(PAGES_DIR)):
        if not fn.endswith(".html") or "#" in fn:
            continue
        flat = fn[:-5]
        slug = flat.replace("__", "/")
        html = open(os.path.join(PAGES_DIR, fn), encoding="utf-8").read()
        soup = BeautifulSoup(html, "html.parser")
        clean_ads(soup)
        wrapper = soup.find("div", class_="content-wrapper") or soup.find("div", class_="page")
        if wrapper is None:
            continue
        for junk in wrapper.select(".right-menu-wrapper, .page-edit, .page-nav, .page-slot"):
            junk.decompose()
        h1 = wrapper.find(["h1"])
        title = h1.get_text(strip=True) if h1 else slug
        for a in wrapper.find_all("a", href=True):
            href = a["href"]
            if href.startswith("/magic-api/pages/"):
                a["href"] = "#" + slug_of(href); a.attrs.pop("target", None)
            elif href.startswith("http"):
                a["target"] = "_blank"; a["rel"] = "noopener noreferrer"
        # inline images from the prebuilt map (offline, no network)
        inline_images(wrapper, img_map)
        for s in wrapper.find_all(["script", "style"]):
            s.decompose()
        # remove empty heading if it only held an icon
        if h1 and not h1.get_text(strip=True):
            h1.decompose()
        records.append((slug, title, str(wrapper)))
    order_top = ["指南", "API", "配置", "更新日志", "FAQ", "赞助", "分组", "其他"]
    def grp(slug):
        key = slug.split("/")[0] if slug else "other"
        return GROUP_MAP.get(key, ("其他", "其他"))
    records.sort(key=lambda r: (order_top.index(grp(r[0])[0]) if grp(r[0])[0] in order_top else 99, grp(r[0])[1], r[0]))
    print(f"[build] {len(records)} pages, {len(IMG_CACHE)} images inlined")

    toc = {}
    for slug, title, _ in records:
        top, sub = grp(slug)
        toc.setdefault(top, {}).setdefault(sub, []).append((slug, title))
    toc_html = ['<ul class="toc-top">']
    for top in order_top:
        if top not in toc: continue
        toc_html.append(f'<li class="toc-group"><span class="toc-group-title">{top}</span><ul class="toc-sub">')
        for sub in sorted(toc[top].keys()):
            toc_html.append(f'<li class="toc-sub-title">{sub}<ul>')
            for slug, title in toc[top][sub]:
                toc_html.append(f'<li><a href="#{slug}" class="toc-link">{title}</a></li>')
            toc_html.append('</ul></li>')
        toc_html.append('</ul></li>')
    toc_html.append('</ul>')
    sections_html = "\n".join(
        f'<section id="{slug}" class="doc-page"><a class="anchor" href="#{slug}">#</a>{content}</section>'
        for slug, _, content in records
    )
    doc = TEMPLATE.replace("{{TOC}}", "\n".join(toc_html)).replace("{{SECTIONS}}", sections_html)
    with open(OUT, "w", encoding="utf-8") as f:
        f.write(doc)
    print(f"[done] wrote {OUT} ({os.path.getsize(OUT)/1024:.1f} KB)")

TEMPLATE = r"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>magic-api 帮助文档（离线版，已去除广告）</title>
<style>
:root{--c-bg:#fff;--c-fg:#1f2328;--c-mut:#57606a;--c-brd:#d8dee4;--c-accent:#11a8cd;--c-side:#f6f8fa;--c-code:#f6f8fa;}
*{box-sizing:border-box}
body{margin:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI","PingFang SC","Microsoft YaHei",Helvetica,Arial,sans-serif;color:var(--c-fg);background:var(--c-bg);line-height:1.7;font-size:15px}
a{color:var(--c-accent);text-decoration:none}a:hover{text-decoration:underline}
header.topbar{position:sticky;top:0;z-index:20;display:flex;align-items:center;gap:14px;padding:10px 18px;background:var(--c-accent);color:#fff;box-shadow:0 1px 4px rgba(0,0,0,.1)}
header.topbar h1{font-size:17px;margin:0;font-weight:600}
header.topbar .src{font-size:12px;opacity:.85}
header.topbar input{margin-left:auto;padding:6px 10px;border:1px solid rgba(255,255,255,.5);border-radius:6px;background:rgba(255,255,255,.15);color:#fff;width:260px;outline:none}
header.topbar input::placeholder{color:rgba(255,255,255,.8)}
.layout{display:flex;align-items:flex-start}
nav.sidebar{position:sticky;top:52px;align-self:flex-start;width:300px;max-height:calc(100vh - 52px);overflow:auto;background:var(--c-side);border-right:1px solid var(--c-brd);padding:14px 10px 40px}
.toc-top{list-style:none;margin:0;padding:0}
.toc-group-title{display:block;font-weight:700;margin:14px 0 4px;font-size:14px}
.toc-sub{list-style:none;margin:0;padding:0 0 0 12px}
.toc-sub-title{font-weight:600;color:var(--c-mut);margin:8px 0 2px;font-size:13px}
.toc-sub ul{list-style:none;margin:0;padding:0}
.toc-link{display:block;padding:3px 8px;border-radius:5px;font-size:13px;color:var(--c-fg)}
.toc-link:hover{background:#e9eef2;text-decoration:none}
.toc-link.active{background:var(--c-accent);color:#fff}
main.content{flex:1;min-width:0;padding:24px 40px 80px;max-width:980px}
.doc-page{margin-bottom:36px;padding-bottom:24px;border-bottom:1px solid var(--c-brd)}
.doc-page:target{scroll-margin-top:60px}
.doc-page h1{font-size:26px;margin:0 0 16px;border-bottom:2px solid var(--c-accent);padding-bottom:8px}
.doc-page h2{font-size:21px;margin:28px 0 12px;border-bottom:1px solid var(--c-brd);padding-bottom:6px}
.doc-page h3{font-size:17px;margin:22px 0 10px}
.doc-page p{margin:10px 0}
.doc-page code{background:var(--c-code);padding:2px 5px;border-radius:4px;font-family:"SFMono-Regular",Consolas,Menlo,monospace;font-size:13px}
.doc-page pre{background:#0d1117;color:#e6edf3;padding:14px 16px;border-radius:8px;overflow:auto;font-size:13px;line-height:1.5}
.doc-page pre code{background:none;color:inherit;padding:0}
.doc-page table{border-collapse:collapse;width:100%;margin:14px 0;font-size:14px}
.doc-page th,.doc-page td{border:1px solid var(--c-brd);padding:7px 10px;text-align:left}
.doc-page th{background:var(--c-side)}
.doc-page img{max-width:100%;border:1px solid var(--c-brd);border-radius:6px;margin:10px 0}
.doc-page blockquote{border-left:4px solid var(--c-accent);margin:12px 0;padding:4px 14px;color:var(--c-mut);background:var(--c-side)}
.doc-page ul,.doc-page ol{padding-left:24px}
.anchor{position:absolute;margin-left:-18px;color:var(--c-brd);opacity:0}
.doc-page:hover .anchor{opacity:1}
.footnote{text-align:center;color:var(--c-mut);font-size:12px;padding:20px}
@media (max-width:820px){nav.sidebar{display:none}main.content{padding:18px}}
</style>
</head>
<body>
<header class="topbar">
  <h1>magic-api 帮助文档</h1>
  <span class="src">来源：https://www.ssssssss.org/magic-api/ · 离线版 · 已去除广告</span>
  <input id="search" type="search" placeholder="搜索文档…">
</header>
<div class="layout">
  <nav class="sidebar">{{TOC}}</nav>
  <main class="content" id="content">{{SECTIONS}}</main>
</div>
<div class="footnote">本文档由网页抓取生成，版权归 magic-api 原作者所有。已移除 wwads / Google AdSense 等广告。</div>
<script>
(function(){
  var links=Array.prototype.slice.call(document.querySelectorAll('.toc-link'));
  var sections=Array.prototype.slice.call(document.querySelectorAll('.doc-page'));
  var box=document.getElementById('search');
  box.addEventListener('input',function(){
    var q=this.value.trim().toLowerCase();
    sections.forEach(function(s){s.style.display=(!q||s.textContent.toLowerCase().indexOf(q)!==-1)?'':'none';});
    links.forEach(function(l){var li=l.closest('li');li.style.display=(!q||l.textContent.toLowerCase().indexOf(q)!==-1)?'':'none';});
  });
  function onScroll(){var pos=window.scrollY+80,cur=null;sections.forEach(function(s){if(s.offsetTop<=pos)cur=s.id;});links.forEach(function(l){l.classList.toggle('active',l.getAttribute('href')==='#'+cur);});}
  window.addEventListener('scroll',onScroll,{passive:true});onScroll();
})();
</script>
</body>
</html>
"""

if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "all"
    if mode in ("crawl", "all"):
        crawl()
    if mode in ("build", "all"):
        build()
