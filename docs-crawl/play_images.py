#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Download doc images via the browser (shares Vercel clearance cookie) and dump a url->dataURI map."""
import os, re, json, base64, time
from playwright.sync_api import sync_playwright

HERE = os.path.dirname(os.path.abspath(__file__))
PAGES_DIR = os.path.join(HERE, "pages")
OUT = os.path.join(HERE, "img_map.json")

def collect_urls():
    urls = set()
    for f in os.listdir(PAGES_DIR):
        if "#" in f or not f.endswith(".html"):
            continue
        h = open(os.path.join(PAGES_DIR, f), encoding="utf-8").read()
        for m in re.findall(r'<img[^>]+src="([^"]+)"', h):
            urls.add(m)
    return urls

def main():
    urls = collect_urls()
    print(f"[img] {len(urls)} unique image urls")
    img_map = {}
    with sync_playwright() as p:
        b = p.chromium.launch(headless=True)
        ctx = b.new_context(
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                       "(KHTML, like Gecko) Chrome/124.0 Safari/537.36",
            locale="zh-CN",
        )
        page = ctx.new_page()
        # obtain Vercel clearance cookie
        page.goto("https://www.ssssssss.org/magic-api/pages/quick/intro/", wait_until="domcontentloaded", timeout=60000)
        dl = time.time() + 40
        while time.time() < dl:
            if "Security Checkpoint" not in page.title():
                break
            time.sleep(1.5)
        for u in sorted(urls):
            if u.startswith("data:"):
                img_map[u] = u
                continue
            absu = u if u.startswith("http") else "https://www.ssssssss.org" + u
            try:
                r = ctx.request.get(absu, timeout=30000)
                if r.status == 200 and r.body():
                    mt = r.headers.get("content-type", "image/png").split(";")[0] or "image/png"
                    img_map[u] = "data:%s;base64,%s" % (mt, base64.b64encode(r.body()).decode())
                    print(f"[ok] {u} ({len(r.body())//1024} KB)")
                else:
                    print(f"[skip] {u} status {r.status}")
            except Exception as e:
                print(f"[err] {u} {e}")
        b.close()
    json.dump(img_map, open(OUT, "w"), ensure_ascii=False)
    print(f"[done] wrote {OUT} with {len(img_map)} entries")

if __name__ == "__main__":
    main()
