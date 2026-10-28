#!/usr/bin/env python3
"""Build an Arabic-first paintings dataset from Wikidata + Arabic Wikipedia.

Output: tools/out/paintings/wikidata_ar.json
Cache:  tools/out/paintings/raw/wd/  (resumable; reruns reuse cached responses)
"""
import hashlib
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request
import urllib.error

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, "out", "paintings", "wikidata_ar.json")
RAW = os.path.join(ROOT, "out", "paintings", "raw", "wd")
UA = "washij-research/1.0 (0omarahmed.kr@gmail.com)"
SPARQL = "https://query.wikidata.org/sparql"
ARAPI = "https://ar.wikipedia.org/w/api.php"
PAGE = 1000
DETAIL_BATCH = 100
MIN_EXTRACT = 200
LICENCE = "Text CC BY-SA 4.0 (Arabic Wikipedia)"

os.makedirs(RAW, exist_ok=True)
_last = [0.0]


def log(*a):
    print(time.strftime("%H:%M:%S"), *a, flush=True)


def http_get(url, data=None, accept="application/json", tries=8):
    delay = 5
    for attempt in range(tries):
        wait = 1.05 - (time.time() - _last[0])
        if wait > 0:
            time.sleep(wait)
        _last[0] = time.time()
        req = urllib.request.Request(url, data=data, headers={"User-Agent": UA, "Accept": accept})
        try:
            with urllib.request.urlopen(req, timeout=90) as r:
                return r.read().decode("utf-8")
        except urllib.error.HTTPError as e:
            ra = e.headers.get("Retry-After")
            w = int(ra) if ra and ra.isdigit() else delay
            log(f"HTTP {e.code} (attempt {attempt+1}); sleeping {w}s")
            time.sleep(w)
        except Exception as e:  # timeouts, resets
            log(f"error {e!r} (attempt {attempt+1}); sleeping {delay}s")
            time.sleep(delay)
        delay = min(delay * 2, 120)
    raise RuntimeError(f"failed: {url[:120]}")


def cached(key, fetch):
    path = os.path.join(RAW, hashlib.md5(key.encode()).hexdigest() + ".json")
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    obj = fetch()
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False)
    os.replace(tmp, path)
    return obj


def sparql(q):
    def f():
        body = urllib.parse.urlencode({"query": q, "format": "json"}).encode()
        return json.loads(http_get(SPARQL, data=body))
    return cached("sparql:" + q, f)["results"]["bindings"]


def qid_of(uri):
    return uri.rsplit("/", 1)[-1]


def val(b, k):
    return b[k]["value"] if k in b else None


# ---------- Step 1: paintings with arwiki sitelink ----------
def list_paintings():
    out = {}
    off = 0
    while True:
        q = f"""SELECT ?p ?t WHERE {{
  ?p wdt:P31 wd:Q3305213 .
  ?a schema:about ?p ; schema:isPartOf <https://ar.wikipedia.org/> ; schema:name ?t .
}} ORDER BY ?p LIMIT {PAGE} OFFSET {off}"""
        rows = sparql(q)
        for b in rows:
            out.setdefault(qid_of(b["p"]["value"]), b["t"]["value"])
        log(f"list offset={off} rows={len(rows)} total={len(out)}")
        if len(rows) < PAGE:
            break
        off += PAGE
    return out


# ---------- Step 2: details in batched VALUES queries ----------
def fetch_details(qids):
    det = {q: {} for q in qids}

    def add(q, k, v):
        if v is None:
            return
        s = det[q].setdefault(k, [])
        if v not in s:
            s.append(v)

    groups = {
        "core": """OPTIONAL {{ ?p rdfs:label ?lar FILTER(lang(?lar)='ar') }}
  OPTIONAL {{ ?p rdfs:label ?len FILTER(lang(?len)='en') }}
  OPTIONAL {{ ?en schema:about ?p ; schema:isPartOf <https://en.wikipedia.org/> ; schema:name ?entitle }}
  OPTIONAL {{ ?p wdt:P571 ?inc }}
  OPTIONAL {{ ?p wdt:P18 ?img }}
  OPTIONAL {{ ?p wdt:P2048 ?h }}
  OPTIONAL {{ ?p wdt:P2049 ?w }}""",
        "creator": """OPTIONAL {{ ?p wdt:P170 ?c . OPTIONAL {{ ?c rdfs:label ?car FILTER(lang(?car)='ar') }}
     OPTIONAL {{ ?c rdfs:label ?cen FILTER(lang(?cen)='en') }} }}""",
        "medium": """OPTIONAL {{ ?p wdt:P186 ?m . OPTIONAL {{ ?m rdfs:label ?mar FILTER(lang(?mar)='ar') }}
     OPTIONAL {{ ?m rdfs:label ?men FILTER(lang(?men)='en') }} }}""",
        "coll": """OPTIONAL {{ ?p wdt:P195 ?co . OPTIONAL {{ ?co rdfs:label ?coar FILTER(lang(?coar)='ar') }}
     OPTIONAL {{ ?co rdfs:label ?coen FILTER(lang(?coen)='en') }} }}""",
    }
    sel = {
        "core": "?p ?lar ?len ?entitle ?inc ?img ?h ?w",
        "creator": "?p ?car ?cen",
        "medium": "?p ?mar ?men",
        "coll": "?p ?coar ?coen",
    }
    for i in range(0, len(qids), DETAIL_BATCH):
        chunk = qids[i:i + DETAIL_BATCH]
        values = " ".join("wd:" + q for q in chunk)
        for g, body in groups.items():
            q = f"SELECT {sel[g]} WHERE {{ VALUES ?p {{ {values} }}\n  {body.format()} }}"
            for b in sparql(q):
                p = qid_of(b["p"]["value"])
                if g == "core":
                    add(p, "lar", val(b, "lar")); add(p, "len", val(b, "len"))
                    add(p, "entitle", val(b, "entitle")); add(p, "inc", val(b, "inc"))
                    add(p, "img", val(b, "img")); add(p, "h", val(b, "h")); add(p, "w", val(b, "w"))
                elif g == "creator":
                    add(p, "car", val(b, "car")); add(p, "cen", val(b, "cen"))
                elif g == "medium":
                    add(p, "mar", val(b, "mar")); add(p, "men", val(b, "men"))
                else:
                    add(p, "coar", val(b, "coar")); add(p, "coen", val(b, "coen"))
        log(f"details {min(i+DETAIL_BATCH, len(qids))}/{len(qids)}")
    return det


# ---------- Step 3: Arabic Wikipedia extracts ----------
def fetch_extracts(titles):
    res = {}
    for i in range(0, len(titles), 20):
        chunk = titles[i:i + 20]
        params = {"action": "query", "prop": "extracts", "exintro": "1", "explaintext": "1",
                  "exlimit": "20", "titles": "|".join(chunk), "redirects": "1",
                  "format": "json", "formatversion": "2"}
        url = ARAPI + "?" + urllib.parse.urlencode(params)
        data = cached("ar:" + "|".join(chunk), lambda: json.loads(http_get(url)))
        q = data.get("query", {})
        # map requested title -> final title
        fwd = {}
        for lst in (q.get("normalized", []), q.get("redirects", [])):
            for m in lst:
                fwd[m["from"]] = m["to"]
        ext = {p["title"]: p.get("extract", "") for p in q.get("pages", []) if "extract" in p}
        for t in chunk:
            cur, seen = t, 0
            while cur in fwd and seen < 5:
                cur = fwd[cur]; seen += 1
            if cur in ext:
                res[t] = ext[cur]
        if (i // 20) % 25 == 0:
            log(f"extracts {min(i+20, len(titles))}/{len(titles)}")
    return res


def year_of(s):
    if not s:
        return None
    m = re.match(r"^(-?)(\d{1,4})-", s)
    if not m:
        return None
    y = int(m.group(2))
    return str(-y) if m.group(1) else str(y)


def first(det, k):
    v = det.get(k)
    return v[0] if v else None


def commons_name(uri):
    name = urllib.parse.unquote(uri.rsplit("/", 1)[-1])
    return name


def main():
    paintings = list_paintings()
    qids = sorted(paintings, key=lambda x: int(x[1:]))
    log(f"{len(qids)} paintings with arwiki sitelink")
    extracts = fetch_extracts([paintings[q] for q in qids])
    kept = [q for q in qids if len(extracts.get(paintings[q], "").strip()) >= MIN_EXTRACT]
    log(f"{len(kept)} with extract >= {MIN_EXTRACT} chars")
    det = fetch_details(kept)

    recs = []
    for q in kept:
        d = det[q]
        t_ar = paintings[q]
        img = first(d, "img")
        cf = commons_name(img) if img else None
        h, w = first(d, "h"), first(d, "w")
        r = {
            "id": "wd-" + q, "qid": q,
            "title_ar": first(d, "lar") or t_ar,
            "title_en": first(d, "len") or first(d, "entitle"),
            "artist_ar": first(d, "car"), "artist_en": first(d, "cen"),
            "date": year_of(first(d, "inc")),
            "medium": first(d, "mar") or first(d, "men"),
            "collection": first(d, "coar") or first(d, "coen"),
            "commons_file": cf,
            "commons_url": ("https://commons.wikimedia.org/wiki/Special:FilePath/" + urllib.parse.quote(cf.replace(" ", "_"))) if cf else None,
            "wikipedia_url": "https://ar.wikipedia.org/wiki/" + urllib.parse.quote(t_ar.replace(" ", "_")),
            "description_ar": extracts[t_ar].strip(),
            "licence": LICENCE,
        }
        if h or w:
            r["height_cm"], r["width_cm"] = h, w
        recs.append(r)
    if len(recs) > 20000:
        recs = recs[:20000]
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(recs, f, ensure_ascii=False, indent=1)
    log(f"wrote {OUT}: {len(recs)} records; artist={sum(1 for r in recs if r['artist_ar'] or r['artist_en'])} "
        f"date={sum(1 for r in recs if r['date'])} image={sum(1 for r in recs if r['commons_file'])}")


if __name__ == "__main__":
    main()
