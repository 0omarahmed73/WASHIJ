#!/usr/bin/env python3
"""Apply correction patches to the translated sets and write translated_400_ar.json.

Patches: recheck/out_*.json and fixes_reviewed.json (entries {id, field, new, ...}).
Guards: id and field must exist, new value non-empty and Arabic, and length within
0.7-1.4x of the old value; anything else is skipped and listed.
"""
import glob, json, re, collections
from pathlib import Path
P = Path(__file__).resolve().parent / "out" / "paintings"
recs = {r["id"]: r for f in ("sample_ar.json", "sample2_ar.json") for r in json.load(open(P / f, encoding="utf-8"))}
FIELDS = {"title_ar", "artist_ar", "date_ar", "medium_ar", "origin_ar", "description_ar"}
patches = []
for f in sorted(glob.glob(str(P / "recheck/out_*.json"))):
    patches += [dict(p, src=Path(f).name) for p in json.load(open(f, encoding="utf-8"))]
fx = P / "fixes_reviewed.json"
if fx.exists():
    patches += [dict(p, src=fx.name) for p in json.load(open(fx, encoding="utf-8")) if p.get("applied", True)]
applied, skipped = collections.Counter(), []
for p in patches:
    r = recs.get(p["id"]); new = p.get("new")
    if not r or p["field"] not in FIELDS or not new or not re.search(r"[؀-ۿ]", new):
        skipped.append((p["id"], p["field"], "invalid patch")); continue
    old = r[p["field"]] or ""
    if old and not 0.7 <= len(new) / len(old) <= 1.4 and len(old) > 40:
        skipped.append((p["id"], p["field"], f"length ratio {len(new)/len(old):.2f}")); continue
    r[p["field"]] = new
    r.setdefault("corrections", []).append({"field": p["field"], "source": p["src"], "reason": p.get("reason") or p.get("note")})
    applied[p["field"]] += 1
out = list(recs.values())
for r in out: r["translation"] = "machine-assisted (Claude, Codex-reviewed), unreviewed by a native editor"
(P / "translated_400_ar.json").write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")
print(len(out), "records;", sum(applied.values()), "patches applied", dict(applied))
print(len(skipped), "skipped:", skipped[:10])
print(sum(1 for r in out if r.get("corrections")), "records corrected")
