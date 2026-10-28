import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
existing_html = (ROOT / 'index.html').read_text(encoding='utf-8')
match = re.search(r'const IMGS=(\{.*?\});const MOVEMENTS=', existing_html)
if match is None:
    raise SystemExit('Could not find the existing IMGS metadata in prototype/index.html')
IM = json.loads(match.group(1))
data = (ROOT / 'src/data.js').read_text(encoding='utf-8')
css = (ROOT / 'src/style.css').read_text(encoding='utf-8')
js = (ROOT / 'src/app.js').read_text(encoding='utf-8')
html=f'''<title>وَشيج | WASHIJ</title>
<meta name="claude:viewport-fit-sides" content="cover">
<meta name="color-scheme" content="dark">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Amiri:wght@700&family=Cormorant+Garamond:wght@400;500;600&family=Aref+Ruqaa:wght@400;700&family=Scheherazade+New:wght@400;700&family=Readex+Pro:wght@300..700&display=swap">
<style>{css}</style>
<div id="app" dir="rtl" lang="ar">
<a class="sr" href="#view">انتقل إلى المحتوى</a>
<header class="hdr"><div class="wrap"><a class="logo" id="logoA" href="#" data-go="" aria-label="وَشيج، الرئيسية"></a>
<nav class="nav" aria-label="التنقل الرئيسي"><a href="#" data-go="" data-nav="home">الرئيسية</a><a href="#" data-go="artworks" data-nav="artworks">اللوحات</a><a href="#" data-go="artists" data-nav="artists">الفنانون</a><a href="#" data-go="movements" data-nav="movements">المدارس الفنية</a></nav>
<div class="tools"><button class="srch-btn" id="openS" type="button" aria-label="بحث"><span>ابحث عن لوحة أو فنان</span></button><button class="ibtn menu-btn" id="openM" type="button" aria-label="القائمة"></button></div></div></header>
<div class="drawer" id="drawer" role="dialog" aria-label="القائمة"><div style="display:flex;justify-content:space-between;align-items:center"><span class="logo" style="gap:10px"></span><button class="ibtn" id="closeM" type="button" aria-label="إغلاق"></button></div>
<a href="#" data-go="" data-nav="home">الرئيسية</a><a href="#" data-go="artworks" data-nav="artworks">اللوحات</a><a href="#" data-go="artists" data-nav="artists">الفنانون</a><a href="#" data-go="movements" data-nav="movements">المدارس الفنية</a></div>
<div class="overlay" id="sov" role="dialog" aria-label="بحث"><div class="s-input"><input id="sq" type="search" placeholder="ابحث عن لوحة أو فنان" autocomplete="off" aria-label="بحث"><button class="ibtn" id="closeS" type="button" aria-label="إغلاق البحث"></button></div><div class="s-res" id="sr"></div></div>
<div class="lb" id="lb" role="dialog" aria-label="عرض اللوحة"><img id="lbi" alt=""><button type="button" id="lbx" aria-label="إغلاق"></button></div>
<main id="view" tabindex="-1"></main></div>
<script>const IMGS={json.dumps(IM)};{data}</script>
<script>{js}</script>
'''
(ROOT / 'index.html').write_text(html, encoding='utf-8')
print(len(html) // 1024, 'KB')
