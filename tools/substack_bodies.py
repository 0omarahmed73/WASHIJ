#!/usr/bin/env python3
"""Fetch the body text of the free public posts listed by substack_search.py.

Reads tools/out/substack_<query>.json, requests each post once per second from
its publication's public post endpoint, and saves plain text plus author, date
and URL so every text stays attributable. Paywalled posts are skipped.
Usage: python3 tools/substack_bodies.py [query]
"""
import json, sys, time, urllib.parse, urllib.request
from html.parser import HTMLParser
from pathlib import Path

query = sys.argv[1] if len(sys.argv) > 1 else "لوحة"
out = Path(__file__).resolve().parent / "out"
src = out / f"substack_{urllib.parse.quote(query)}.json"
posts = json.loads(src.read_text(encoding="utf-8"))

class Text(HTMLParser):
    BLOCK = {"p", "div", "br", "h1", "h2", "h3", "h4", "li", "blockquote", "figcaption"}
    def __init__(self): super().__init__(); self.parts = []
    def handle_starttag(self, t, a):
        if t in self.BLOCK: self.parts.append("\n")
    def handle_endtag(self, t):
        if t in self.BLOCK: self.parts.append("\n")
    def handle_data(self, d): self.parts.append(d)

def to_text(html):
    p = Text(); p.feed(html or "")
    lines = [l.strip() for l in "".join(p.parts).splitlines()]
    return "\n".join(l for l in lines if l)

result, skipped = [], 0
for i, p in enumerate(posts, 1):
    u = urllib.parse.urlparse(p["url"])
    slug = u.path.rstrip("/").split("/")[-1]
    if p.get("audience") != "everyone" or "/p/" not in u.path:
        skipped += 1; continue
    api = f"{u.scheme}://{u.netloc}/api/v1/posts/{slug}"
    try:
        req = urllib.request.Request(api, headers={"User-Agent": "Mozilla/5.0 (research script)"})
        d = json.load(urllib.request.urlopen(req, timeout=20))
    except Exception as e:
        print(f"{i}: skipped ({e})"); skipped += 1; time.sleep(1); continue
    body = to_text(d.get("body_html"))
    if not body:
        skipped += 1; continue
    result.append({**p, "body": body, "words": len(body.split())})
    print(f"{i}/{len(posts)} ok: {p['title'][:50]!r} ({len(body.split())} words)")
    time.sleep(1)

dst = out / f"substack_{urllib.parse.quote(query)}_bodies.json"
dst.write_text(json.dumps(result, ensure_ascii=False, indent=1), encoding="utf-8")
print(f"saved {len(result)} bodies, skipped {skipped}: {dst}")
