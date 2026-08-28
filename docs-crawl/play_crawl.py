#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Crawl magic-api docs with a real headless browser (passes Vercel Security Checkpoint)."""
import os, sys, time
from urllib.parse import urlparse
from playwright.sync_api import sync_playwright

BASE = "https://www.ssssssss.org"
HERE = os.path.dirname(os.path.abspath(__file__))
PAGES_DIR = os.path.join(HERE, "pages")
os.makedirs(PAGES_DIR, exist_ok=True)

SEEDS = [
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

def slug_of(path):
    p = path.strip("/")
    if p.startswith("magic-api/pages/"):
        p = p[len("magic-api/pages/"):]
    return p.strip("/")

def save(page, path):
    slug = slug_of(path)
    fp = os.path.join(PAGES_DIR, slug.replace("/", "__") + ".html")
    if os.path.exists(fp):
        return
    url = BASE + path
    page.goto(url, wait_until="domcontentloaded", timeout=60000)
    # wait out Vercel Security Checkpoint (browser solves the JS challenge)
    deadline = time.time() + 40
    while time.time() < deadline:
        title = page.title()
        if "Security Checkpoint" not in title and "content-wrapper" in page.content():
            break
        time.sleep(1.5)
    html = page.content()
    if "content-wrapper" in html or "theme-default-content" in html:
        open(fp, "w", encoding="utf-8").write(html)
        print(f"[ok] {slug} ({len(html)//1024} KB)")
    else:
        print(f"[warn] {slug} no content (title={page.title()[:40]})")

def main():
    seen, queue, discovered = set(), list(SEEDS), []
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        ctx = browser.new_context(
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                       "(KHTML, like Gecko) Chrome/124.0 Safari/537.36",
            locale="zh-CN",
        )
        page = ctx.new_page()
        # block ad networks to keep things clean + fast
        page.route("**/*", lambda route: route.abort()
                   if any(k in route.request.url for k in ["wwads", "adsbygoogle", "googlesyndication", "makemoney"])
                   else route.continue_())
        for _ in range(4):
            nxt = []
            for path in queue:
                if path in seen:
                    continue
                seen.add(path)
                if path == "/magic-api/":
                    # homepage has few links; just ensure it's loaded, then collect from sub-pages
                    save(page, path)
                    continue
                save(page, path)
                for a in page.query_selector_all("a[href]"):
                    h = a.get_attribute("href") or ""
                    if h.startswith("/magic-api/pages/"):
                        norm = h.rstrip("/") + "/"
                        if norm not in discovered:
                            discovered.append(norm)
                        if norm not in seen:
                            nxt.append(norm)
                time.sleep(0.3)
            queue = nxt
        # fetch any still-missing discovered pages
        for d in discovered:
            if not os.path.exists(os.path.join(PAGES_DIR, slug_of(d).replace("/", "__") + ".html")):
                save(page, d)
                time.sleep(0.3)
        browser.close()
    print(f"[done] discovered {len(discovered)} pages")

if __name__ == "__main__":
    main()
