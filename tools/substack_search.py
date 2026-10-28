#!/usr/bin/env python3
"""Collect public Substack search-result metadata for a query (default: لوحة).

Uses Substack's public search endpoint, one request per second, and saves only
metadata (title, subtitle, author, date, URL, reactions), not article text.
Usage: python3 tools/substack_search.py [query] [max_pages]
"""
import csv, json, sys, time, urllib.parse, urllib.request
from pathlib import Path

query = sys.argv[1] if len(sys.argv) > 1 else "لوحة"
max_pages = int(sys.argv[2]) if len(sys.argv) > 2 else 5
out = Path(__file__).resolve().parent / "out"
out.mkdir(exist_ok=True)

rows, seen = [], set()
for page in range(max_pages):
    url = "https://substack.com/api/v1/post/search?" + urllib.parse.urlencode(
        {"query": query, "page": page, "includePlatformResults": "true"})
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (research script)"})
    try:
        data = json.load(urllib.request.urlopen(req, timeout=20))
    except Exception as e:
        print(f"page {page}: stopped ({e})"); break
    results = data.get("results", [])
    if not results:
        break
    for r in results:
        u = r.get("canonical_url")
        if not u or u in seen:
            continue
        seen.add(u)
        authors = [b.get("name") for b in r.get("publishedBylines", []) if b.get("name")]
        rows.append({
            "title": r.get("title"), "subtitle": r.get("subtitle"),
            "description": r.get("description"),
            "author": ", ".join(authors), "date": r.get("post_date"),
            "url": u, "audience": r.get("audience"),
            "reactions": sum((r.get("reactions") or {}).values()),
        })
    print(f"page {page}: {len(results)} results, {len(rows)} unique so far")
    if not data.get("more", True):
        break
    time.sleep(1)

stem = out / f"substack_{urllib.parse.quote(query)}"
stem.with_suffix(".json").write_text(json.dumps(rows, ensure_ascii=False, indent=1), encoding="utf-8")
if rows:
    with open(stem.with_suffix(".csv"), "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0])); w.writeheader(); w.writerows(rows)
print(f"saved {len(rows)} rows to {stem}.json/.csv")
