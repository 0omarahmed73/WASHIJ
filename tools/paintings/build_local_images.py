#!/usr/bin/env python3
"""Download the translated museum sample's public images as compact app assets."""

from __future__ import annotations

import concurrent.futures
import io
import json
import os
import sys
import urllib.parse
import urllib.request
from pathlib import Path

from PIL import Image, ImageOps


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "tools/out/paintings/translated_400_ar.json"
OUTPUT = ROOT / "app/assets/data/museum_paintings_ar.json"
IMAGE_DIR = ROOT / "app/assets/images/museum_paintings"
MAX_EDGE = 960
MAX_DOWNLOAD_BYTES = 32 * 1024 * 1024
ALLOWED_HOSTS = {
    "www.artic.edu",
    "openaccess-cdn.clevelandart.org",
}


def download_image(row: dict) -> tuple[str, str | None, int]:
    image_url = row.get("image")
    if not image_url:
        return row["id"], None, 0

    parsed = urllib.parse.urlparse(image_url)
    if parsed.scheme != "https" or parsed.hostname not in ALLOWED_HOSTS:
        raise ValueError(f"untrusted image URL for {row['id']}")

    destination = IMAGE_DIR / f"{row['id']}.webp"
    if destination.is_file() and destination.stat().st_size:
        return row["id"], f"assets/images/museum_paintings/{destination.name}", 0

    request = urllib.request.Request(
        image_url,
        headers={
            "User-Agent": (
                "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                "(KHTML, like Gecko) Chrome/126.0 Safari/537.36"
            ),
            "Accept": "image/avif,image/webp,image/apng,image/*,*/*;q=0.8",
            "Referer": (
                "https://www.artic.edu/"
                if row["source"] == "Art Institute of Chicago"
                else "https://www.clevelandart.org/"
            ),
        },
    )
    with urllib.request.urlopen(request, timeout=45) as response:
        final = urllib.parse.urlparse(response.geturl())
        if final.scheme != "https" or final.hostname not in ALLOWED_HOSTS:
            raise ValueError(f"untrusted redirect for {row['id']}")
        data = response.read(MAX_DOWNLOAD_BYTES + 1)

    if not data or len(data) > MAX_DOWNLOAD_BYTES:
        raise ValueError(f"invalid image size for {row['id']}")

    with Image.open(io.BytesIO(data)) as source:
        image = ImageOps.exif_transpose(source)
        resampling = getattr(Image, "Resampling", Image)
        image.thumbnail((MAX_EDGE, MAX_EDGE), resampling.LANCZOS)
        if image.mode not in ("RGB", "RGBA"):
            image = image.convert("RGB")
        icc_profile = source.info.get("icc_profile")

        temporary = destination.with_suffix(".webp.part")
        image.save(
            temporary,
            format="WEBP",
            quality=86,
            method=5,
            icc_profile=icc_profile,
        )
        os.replace(temporary, destination)

    return row["id"], f"assets/images/museum_paintings/{destination.name}", destination.stat().st_size


def main() -> int:
    rows = json.loads(SOURCE.read_text(encoding="utf-8"))
    if not isinstance(rows, list) or len(rows) != 400:
        raise ValueError("expected the corrected 400-record source dataset")
    ids = [row.get("id") for row in rows]
    if len(set(ids)) != len(rows) or any(not item for item in ids):
        raise ValueError("source dataset has missing or duplicate ids")

    IMAGE_DIR.mkdir(parents=True, exist_ok=True)
    results: dict[str, str | None] = {}
    failures: list[tuple[str, str]] = []
    total_bytes = 0

    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        futures = {pool.submit(download_image, row): row for row in rows}
        for index, future in enumerate(concurrent.futures.as_completed(futures), start=1):
            row = futures[future]
            try:
                item_id, asset, size = future.result()
                results[item_id] = asset
                total_bytes += size
            except Exception as error:  # keep failed remote URLs as a runtime fallback
                results[row["id"]] = None
                failures.append((row["id"], str(error)))
            if index % 25 == 0 or index == len(rows):
                print(f"Processed {index}/{len(rows)} paintings")

    for row in rows:
        row["image_asset"] = results[row["id"]]

    temporary_output = OUTPUT.with_suffix(".json.tmp")
    temporary_output.write_text(
        json.dumps(rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    os.replace(temporary_output, OUTPUT)

    image_count = sum(asset is not None for asset in results.values())
    print(f"Bundled {image_count}/399 available images ({total_bytes:,} new WebP bytes).")
    print(f"Updated {OUTPUT.relative_to(ROOT)}")
    for item_id, error in failures:
        print(f"Image fallback retained for {item_id}: {error}", file=sys.stderr)
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
