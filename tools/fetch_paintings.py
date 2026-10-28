#!/usr/bin/env python3
"""Download paintings with descriptions from open museum sources (stage 1).

Cleveland Museum of Art Open Access (CC0) and Art Institute of Chicago
(public-domain paintings; descriptions are CC BY 4.0).
Output: tools/out/paintings/museums_en.json
Usage: python3 tools/fetch_paintings.py
"""
import json, re, time, urllib.parse, urllib.request
from pathlib import Path

OUT = Path(__file__).resolve().parent / "out" / "paintings"
OUT.mkdir(parents=True, exist_ok=True)
UA = {"User-Agent": "washij-research/1.0", "Content-Type": "application/json"}


def get(url, body=None):
    for attempt in range(6):
        try:
            req = urllib.request.Request(url, data=json.dumps(body).encode() if body else None, headers=UA)
            return json.load(urllib.request.urlopen(req, timeout=60))
        except Exception as e:
            if attempt == 5:
                raise
            time.sleep(3 * (attempt + 1))


def clean(t):
    return re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", t or "")).strip()


rows = []
skip = 0
while True:
    d = get("https://openaccess-api.clevelandart.org/api/artworks/?" + urllib.parse.urlencode(
        {"type": "Painting", "has_image": 1, "limit": 100, "skip": skip}))
    if not d["data"]:
        break
    for a in d["data"]:
        desc = clean(a.get("description"))
        if not desc or a.get("share_license_status") != "CC0":
            continue
        cr = (a.get("creators") or [{}])[0]
        rows.append({
            "id": f"cma-{a['id']}", "source": "Cleveland Museum of Art", "title": a.get("title"),
            "artist": cr.get("description"), "date": a.get("creation_date"),
            "medium": a.get("technique"), "dimensions": a.get("measurements"),
            "origin": ", ".join(a.get("culture") or []), "credit": a.get("creditline"),
            "page": a.get("url"), "wikidata": None,
            "image": ((a.get("images") or {}).get("web") or {}).get("url"),
            "description": desc, "licence": "CC0",
        })
    skip += 100
    time.sleep(0.5)
print("cleveland", len(rows))

n0, page = len(rows), 1
fields = ["id", "title", "artist_display", "date_display", "medium_display", "dimensions",
          "place_of_origin", "description", "image_id", "credit_line"]
while True:
    d = get("https://api.artic.edu/api/v1/artworks/search", {
        "query": {"bool": {"must": [{"term": {"classification_title.keyword": "painting"}},
                                    {"term": {"is_public_domain": True}},
                                    {"exists": {"field": "description"}}]}},
        "fields": fields, "limit": 100, "page": page})
    for a in d["data"]:
        desc = clean(a.get("description"))
        if not desc:
            continue
        rows.append({
            "id": f"aic-{a['id']}", "source": "Art Institute of Chicago", "title": a.get("title"),
            "artist": clean(a.get("artist_display")), "date": a.get("date_display"),
            "medium": a.get("medium_display"), "dimensions": a.get("dimensions"),
            "origin": a.get("place_of_origin"), "credit": a.get("credit_line"),
            "page": f"https://www.artic.edu/artworks/{a['id']}", "wikidata": None,
            "image": f"https://www.artic.edu/iiif/2/{a['image_id']}/full/843,/0/default.jpg" if a.get("image_id") else None,
            "description": desc, "licence": "Description CC BY 4.0; public-domain artwork",
        })
    if page >= d["pagination"]["total_pages"] or not d["data"]:
        break
    page += 1
    time.sleep(0.5)
print("chicago", len(rows) - n0)
(OUT / "museums_en.json").write_text(json.dumps(rows, ensure_ascii=False, indent=1), encoding="utf-8")
print("saved", len(rows))
