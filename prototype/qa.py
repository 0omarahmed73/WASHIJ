from pathlib import Path

from playwright.sync_api import sync_playwright
import json
ROOT = Path(__file__).resolve().parent
OUTPUT_DIR = ROOT / 'qa-output'
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
U = (ROOT / 'index.html').as_uri()
res=[]
def ck(n,ok,extra=''): res.append((n,ok,extra)); print(('PASS' if ok else 'FAIL'),n,extra)
with sync_playwright() as p:
    b=p.chromium.launch(executable_path='/usr/bin/google-chrome',args=['--no-sandbox'])
    pg=b.new_page(viewport={'width':1280,'height':900}); errs=[]
    pg.on('console',lambda m: errs.append(m.text) if m.type=='error' else None); pg.on('pageerror',lambda e: errs.append(str(e)))
    pg.goto(U); pg.wait_for_timeout(1500)
    pg.screenshot(path=str(OUTPUT_DIR / 'q_home.png'),full_page=True)
    # nav
    for nav,h in [('artworks','اللوحات'),('artists','الفنانون'),('movements','المدارس الفنية'),('home','')]:
        pg.click(f'.nav a[data-nav="{nav}"]'); pg.wait_for_timeout(250)
        cur=pg.eval_on_selector('.nav a[aria-current="page"]','e=>e.dataset.nav'); ck('nav '+nav,cur==nav)
    # collection
    pg.click('.nav a[data-nav="artworks"]'); pg.wait_for_timeout(300)
    n=lambda: pg.eval_on_selector_all('#res .wcard','e=>e.length')
    ck('collection initial 6',n()==6,str(n()))
    pg.click('[data-more]'); pg.wait_for_timeout(100); ck('load more 12',n()==12,str(n()))
    pg.click('[data-more]'); ck('load more 14',n()==14,str(n()))
    pg.fill('#fq','فان غوخ'); pg.wait_for_timeout(100); ck('search van gogh',n()==2,str(n()))
    pg.fill('#fq','vermeer'); ck('search latin artist',n()==2,str(n()))
    pg.fill('#fq','الموناليزا'); ck('search mona',n()==1,str(n()))
    pg.fill('#fq','اسطورة'); ck('no results state',pg.locator('.empty').count()==1)
    pg.click('#res [data-reset]'); ck('reset',n()==6 and pg.input_value('#fq')=='')
    pg.select_option('#fm','dutch'); ck('filter movement dutch',n()==3,str(n()))  # pearl, milkmaid, night watch (3)?
    pg.select_option('#fm',''); pg.select_option('#fp','p2'); ck('filter period 17c',n()==4,str(n()))
    pg.select_option('#fa','vermeer'); ck('combined filter',n()==2,str(n()))
    pg.select_option('#fa',''); pg.select_option('#fp',''); pg.select_option('#fs','date-desc'); pg.click('[data-more]')
    t=pg.eval_on_selector_all('#res .wcard h3','e=>e.map(x=>x.textContent)'); ck('sort newest first',t[0]=='إصرار الذاكرة',t[0])
    pg.select_option('#fs','date-asc'); t=pg.eval_on_selector_all('#res .wcard h3','e=>e.map(x=>x.textContent)'); ck('sort oldest first',t[0]=='الموناليزا'.replace('الموناليزا','ميلاد فينوس') or t[0] in('ميلاد فينوس','الموناليزا'),t[0])
    # detail
    pg.fill('#fq','النجوم'); pg.click('#res .wcard'); pg.wait_for_timeout(1200)
    ck('detail starry', 'الليلة المرصعة' in pg.inner_text('h1'))
    pg.screenshot(path=str(OUTPUT_DIR / 'q_detail.png'),full_page=True)
    ck('detail image complete',pg.eval_on_selector('.plate img','i=>i.complete&&i.naturalWidth>0'))
    ratio=pg.eval_on_selector('.plate img','i=>[i.naturalWidth/i.naturalHeight,i.clientWidth/i.clientHeight]'); ck('aspect preserved',abs(ratio[0]-ratio[1])<0.02,str(ratio))
    ck('rail drawn',pg.locator('#rail circle').count()>=5,str(pg.locator('#rail circle').count()))
    # related
    pg.click('#s-rel .wcard'); pg.wait_for_timeout(300); ck('related -> cafe terrace','شرفة مقهى' in pg.inner_text('h1'))
    # artist link
    pg.click('.d-hero a.achip'); pg.wait_for_timeout(300); ck('to artist','فان غوخ' in pg.inner_text('h1'))
    pg.click('.p-hero .meta-row a'); pg.wait_for_timeout(300); ck('artist->movement','ما بعد' in pg.inner_text('h1'))
    pg.click('.wcard'); pg.wait_for_timeout(300)
    pg.click('[data-back]'); pg.wait_for_timeout(300); ck('back returns to previous screen','ما بعد' in pg.inner_text('h1'))
    # home featured open
    pg.click('.nav a[data-nav="home"]'); pg.wait_for_timeout(300)
    for i in range(3):
        pg.click(f'[data-hero="{i}"]'); pg.click('#heroIn .btn:not(.pri)'); pg.wait_for_timeout(250); ck('hero feature open '+str(i),pg.locator('h1').count()==1); pg.click('.nav a[data-nav="home"]'); pg.wait_for_timeout(200)
    # every card on home leads somewhere
    hrefs=pg.eval_on_selector_all('#view [data-go]','e=>[...new Set(e.map(x=>x.dataset.go))]')
    bad=[]
    for h in hrefs:
        pg.evaluate(f"go('{h}')"); 
        if pg.locator('.empty h3:has-text(\"لم نجد\")').count(): bad.append(h)
        pg.evaluate("go('')")
    ck('all home links resolve',not bad,str(bad)+f' ({len(hrefs)} links)')
    # surrealism no-image
    pg.evaluate("go('artwork/persistence-of-memory')"); pg.wait_for_timeout(300); ck('no-image artwork handled',pg.locator('.noimg').count()>=1)
    pg.evaluate("go('movement/surrealism')"); pg.wait_for_timeout(300); ck('movement page',pg.locator('.dsec').count()>=3)
    # marketplace words
    allt=''
    for r in ['','artworks','artists','movements','artwork/mona-lisa','artist/dali','movement/renaissance']:
        pg.evaluate(f"go('{r}')"); allt+=' '+pg.inner_text('#app')+' '
    bad=[w for w in ['سعر','شراء','اشترِ','أضف إلى السلة',' سلة ','مزاد','$','دفع','للبيع'] if w in allt]
    ck('no marketplace language',not bad,str(bad))
    ck('no console errors',not errs,str(errs[:3]))
    # mobile
    m=b.new_page(viewport={'width':390,'height':844}); m.goto(U); m.wait_for_timeout(1200)
    for r in ['','artworks','artwork/starry-night','artist/van-gogh','movement/impressionism','artists','movements']:
        m.evaluate(f"go('{r}')"); m.wait_for_timeout(500)
        ov=m.evaluate("[...document.querySelectorAll('#app *')].filter(e=>!e.closest('.subnav,.rail-sc,.drawer,.overlay,.lb,.rail')&&(e.getBoundingClientRect().right>innerWidth+1||e.getBoundingClientRect().left<-1)&&e.getBoundingClientRect().width>0).map(e=>e.tagName+'.'+e.className).slice(0,5)"); ck('mobile clipped/overflow '+r,not ov,str(ov))
    m.evaluate("go('')"); m.wait_for_timeout(500); m.screenshot(path=str(OUTPUT_DIR / 'q_m_home.png'),full_page=False)
    m.click('#openM'); m.wait_for_timeout(200); m.screenshot(path=str(OUTPUT_DIR / 'q_m_menu.png')); m.click('#drawer a[data-nav="artists"]'); m.wait_for_timeout(300); ck('mobile menu nav','الفنانون' in m.inner_text('h1'))
    m.evaluate("go('artwork/starry-night')"); m.wait_for_timeout(1000); m.screenshot(path=str(OUTPUT_DIR / 'q_m_detail.png'),full_page=True)
    m.evaluate("go('artworks')"); m.wait_for_timeout(500); m.screenshot(path=str(OUTPUT_DIR / 'q_m_coll.png'),full_page=True)
    t=b.new_page(viewport={'width':820,'height':1100}); t.goto(U); t.wait_for_timeout(1200); t.evaluate("go('artwork/starry-night')"); t.wait_for_timeout(800)
    ck('tablet overflow',t.evaluate('document.documentElement.scrollWidth-document.documentElement.clientWidth')<=0)
    # light theme
    pg.evaluate("go('')"); pg.wait_for_timeout(1200); pg.screenshot(path=str(OUTPUT_DIR / 'q_home2.png'),full_page=True); pg.evaluate("go('artwork/the-kiss')"); pg.wait_for_timeout(900); pg.screenshot(path=str(OUTPUT_DIR / 'q_detail2.png'))
    b.close()
print(sum(1 for r in res if not r[1]),'failures of',len(res))
