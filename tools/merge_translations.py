#!/usr/bin/env python3
"""Merge translated batches with the English source records and validate them.
Usage: merge_translations.py [first last outname]; default batches 1-8 -> sample_ar.json."""
import json, re, sys
first, last, name = (int(sys.argv[1]), int(sys.argv[2]), sys.argv[3]) if len(sys.argv) > 3 else (1, 8, "sample_ar.json")
from pathlib import Path
P = Path(__file__).resolve().parent / "out" / "paintings"
src = {r["id"]: r for r in json.load(open(P / "museums_en.json", encoding="utf-8"))}
merged, problems = [], []
for i in range(first, last + 1):
    f_in, f_out = P / f"batches/in_{i}.json", P / f"batches/out_{i}.json"
    if not f_out.exists():
        problems.append(f"batch {i}: missing"); continue
    ins, outs = json.load(open(f_in, encoding="utf-8")), json.load(open(f_out, encoding="utf-8"))
    if [r["id"] for r in ins] != [r["id"] for r in outs]:
        problems.append(f"batch {i}: ids differ"); continue
    for a in outs:
        s = src[a["id"]]
        d = a.get("description_ar") or ""
        ar_letters = len(re.findall(r"[؀-ۿ]", d))
        lat = len(re.findall(r"[A-Za-z]", d))
        ratio = len(d.split()) / max(1, len(s["description"].split()))
        if ar_letters < 30 or lat > ar_letters * 0.2: problems.append(f"{a['id']}: mostly non-Arabic")
        if ratio < 0.55 or ratio > 1.6: problems.append(f"{a['id']}: length ratio {ratio:.2f}")
        for k in ("title_ar", "artist_ar", "medium_ar"):
            if not a.get(k): problems.append(f"{a['id']}: {k} empty")
        merged.append({**s, **{k: v for k, v in a.items() if k != "id"}, "translation": "machine-assisted (Claude), unreviewed"})
(P / name).write_text(json.dumps(merged, ensure_ascii=False, indent=1), encoding="utf-8")
print(len(merged), "merged;", len(problems), "problems")
print("\n".join(problems[:30]))
