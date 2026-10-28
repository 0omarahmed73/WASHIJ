const $=(s,r=document)=>r.querySelector(s),$$=(s,r=document)=>[...r.querySelectorAll(s)];
const esc=s=>String(s??'').replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const norm=s=>String(s||'').toLowerCase().replace(/[ً-ٰٟـ]/g,'').replace(/[أإآٱ]/g,'ا').replace(/ى/g,'ي').replace(/ة/g,'ه').replace(/[ؤئ]/g,m=>m==='ؤ'?'و':'ي').replace(/\s+/g,' ').trim();
const W=id=>WORKS.find(w=>w.id===id), A=id=>ARTISTS[id], M=id=>MOVEMENTS[id];
const perOf=w=>PERIODS.find(p=>p.test(w.year));
const worksBy=a=>WORKS.filter(w=>w.artist===a), worksIn=m=>WORKS.filter(w=>w.movement===m);
const artistsIn=m=>Object.keys(ARTISTS).filter(a=>ARTISTS[a].movements.includes(m));
const go_=(p)=>`href="#" data-go="${p}"`;
/* ---------- brand ---------- */
function sym(size=34,sf=3.2){const k=sf,gx=sf+k/1,cph=Math.cos(Math.atan(76/108)),gy=(sf/2+k)/cph,ty=x=>98+(22-98)/108*(x-6),yl=ty(33),gxx=sf/2+k+sf/2;
 const frame=`M33,${(yl-gy).toFixed(2)} V15 H87 V105 H33 V${(yl+gy).toFixed(2)}`,xa=87-gxx,xb=87+gxx;
 const th=`M6,98 L33,${yl.toFixed(2)} L${xa.toFixed(2)},${ty(xa).toFixed(2)} M${xb.toFixed(2)},${ty(xb).toFixed(2)} L114,22`;
 return `<svg width="${size}" height="${size}" viewBox="0 0 120 120" aria-hidden="true"><path d="${frame}" fill="none" stroke="currentColor" stroke-width="${sf}"/><path d="${th}" fill="none" stroke="var(--thread)" stroke-width="${sf}" stroke-linecap="round" stroke-linejoin="round"/></svg>`}
/* procedural night sky: our own flow-field brushwork, inspired by swirling night skies, not a copy of any painting */
function makeSky(W=1600,H=900){const c=document.createElement('canvas');c.width=W;c.height=H;const x=c.getContext('2d');let s=11;const R=()=>(s=(s*16807)%2147483647)/2147483647;
 x.fillStyle='#0b2347';x.fillRect(0,0,W,H);
 const C=[[W*.34,H*.38,250],[W*.7,H*.3,190],[W*.52,H*.74,150]];
 const ang=(px,py)=>{let a=Math.sin(px/200)*.8+Math.cos(py/160)*.8+Math.sin((px+py)/340)*.6;C.forEach(([sx,sy,r])=>{const dx=px-sx,dy=py-sy,d=Math.hypot(dx,dy),k=Math.exp(-(d*d)/(2*r*r*.9));a=a*(1-k)+(Math.atan2(dy,dx)+Math.PI/2+d/55)*k});return a};
 const cols=['#0e2542','#14305a','#1e3a8a','#2563eb','#3b5fb5','#7da3d8'];
 for(let i=0;i<11000;i++){let px=R()*W,py=R()*H,w=2+R()*3.4;x.strokeStyle=cols[Math.floor(Math.pow(R(),1.7)*cols.length)];x.globalAlpha=.3+R()*.5;x.lineWidth=w;x.lineCap='round';x.beginPath();x.moveTo(px,py);const n=3+Math.floor(R()*3);for(let k=0;k<n;k++){const a=ang(px,py);px+=Math.cos(a)*7;py+=Math.sin(a)*7;x.lineTo(px,py)}x.stroke()}
 x.globalAlpha=1;
 const halo=(sx,sy,r0,r1,col)=>{for(let r=r0;r<r1;r+=6){const al=.9*(1-(r-r0)/(r1-r0)),steps=Math.floor(r*.9);for(let k=0;k<steps;k++){const t=k/steps*Math.PI*2+R()*.1,len=.5+R()*.3;x.strokeStyle=col;x.globalAlpha=al*(.55+R()*.45);x.lineWidth=2.4+R()*1.6;x.beginPath();x.arc(sx,sy,r+R()*2,t,t+len/r*8);x.stroke()}}x.globalAlpha=1;x.fillStyle=col;x.beginPath();x.arc(sx,sy,r0*.8,0,7);x.fill()};
 [[W*.14,H*.2,9,58],[W*.5,H*.14,11,70],[W*.86,H*.62,8,52],[W*.26,H*.7,7,44],[W*.62,H*.5,8,50],[W*.92,H*.2,7,42]].forEach(([sx,sy,a,b])=>halo(sx,sy,a,b,R()>.4?'#f2c94c':'#f6e9a8'));
 const mx=W*.82,my=H*.2;halo(mx,my,22,84,'#f2c94c');x.fillStyle='#f2c94c';x.beginPath();x.arc(mx,my,34,-Math.PI*.62,Math.PI*.62);x.arc(mx+17,my,28,Math.PI*.62,-Math.PI*.62,true);x.fill();
 return c.toDataURL('image/jpeg',.8)}
function applySky(){setTimeout(()=>{try{document.documentElement.style.setProperty('--sky','url('+makeSky()+')')}catch(_){}},30)}
function weave(){const fr=[];let x=24;[[54,90,28],[72,112,14],[54,90,32],[90,124,8],[54,90,28],[72,112,16],[54,90,32],[90,124,10],[54,90,26],[72,112,14],[54,90,30],[54,90,24]].forEach(([w,h,y])=>{fr.push([x,y,w,h]);x+=w+46});
 const X0=0,X1=1400,Y0=150,Y1=14,m=(Y1-Y0)/(X1-X0),yy=u=>Y0+m*(u-X0),g=7,cross=[];
 fr.forEach(([x,y,w,h])=>[x,x+w].forEach(e=>{const v=yy(e);if(v>y&&v<y+h)cross.push(e)}));cross.sort((a,b)=>a-b);const kind={};cross.forEach((e,i)=>kind[e]=i%2?'under':'over');let out='';
 fr.forEach(([x,y,w,h])=>{const lo=kind[x]==='over',ro=kind[x+w]==='over';
  if(!lo&&!ro)out+=`<rect x="${x}" y="${y}" width="${w}" height="${h}" fill="none" stroke="currentColor" stroke-width="1.2"/>`;
  else{let d=lo?`M${x},${(yy(x)-g).toFixed(1)} V${y} H${x+w}`:`M${x},${y+h} V${y} H${x+w}`;d+=ro?` V${(yy(x+w)-g).toFixed(1)} M${x+w},${(yy(x+w)+g).toFixed(1)} V${y+h} H${x}`:` V${y+h} H${x}`;if(lo)d+=` V${(yy(x)+g).toFixed(1)}`;out+=`<path d="${d}" fill="none" stroke="currentColor" stroke-width="1.2"/>`}});
 let cur_=X0,d='';cross.filter(e=>kind[e]==='under').forEach(e=>{d+=`M${cur_},${yy(cur_).toFixed(1)} L${e-g},${yy(e-g).toFixed(1)} `;cur_=e+g});d+=`M${cur_},${yy(cur_).toFixed(1)} L${X1},${Y1}`;
 return `<svg class="weave" viewBox="0 0 1400 170" role="img" aria-label="خيط واحد يمرّ بين أطر اللوحات، فوق إطار وتحت آخر" preserveAspectRatio="xMidYMid meet">${out}<path d="${d}" fill="none" stroke="var(--thread)" stroke-width="1.8" stroke-linecap="round"/></svg>`}
const plural=n=>n===1?'لوحة':n===2?'لوحتان':n<=10?n+' لوحات':n+' لوحة';
const wordmark='<span class="arw" lang="ar">و<i>َ</i>شيج</span>';
const sepSvg=`<svg class="thread-sep" viewBox="0 0 600 22" preserveAspectRatio="none" aria-hidden="true"><line x1="0" y1="11" x2="286" y2="11" stroke="var(--hair)"/><line x1="314" y1="11" x2="600" y2="11" stroke="var(--hair)"/><path d="M288,19 L312,3" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" fill="none"/></svg>`;
const ico={search:'<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><circle cx="11" cy="11" r="6.5"/><path d="M16 16l5 5"/></svg>',menu:'<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M3 7h18M3 12h18M3 17h18"/></svg>',x:'<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M5 5l14 14M19 5L5 19"/></svg>',theme:'<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><circle cx="12" cy="12" r="8"/><path d="M12 4v16" /><path d="M12 4a8 8 0 010 16z" fill="currentColor"/></svg>',zoom:'<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M4 9V4h5M20 9V4h-5M4 15v5h5M20 15v5h-5"/></svg>',arr:'<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M20 12H5M11 6l-6 6 6 6"/></svg>'};
/* ---------- images ---------- */
function img(w,{eager=false}={}){const m=IMGS[w.img];return `<img src="img/${w.img}.jpg" alt="${esc(w.titleAr+'، '+A(w.artist).ar)}" width="${m.w}" height="${m.h}" ${eager?'fetchpriority="high"':'loading="lazy"'} decoding="async" onload="this.classList.add('ld')" onerror="this.classList.add('ld')">`}
function mat(w,cls='',opt){return w.img?`<div class="mat ${cls}">${img(w,opt)}</div>`:`<div class="mat noimg ${cls}"><div><b>${esc(w.titleAr)}</b>الصورة غير معروضة لأن حقوقها محفوظة</div></div>`}
function wcard(w,extra=''){return `<a class="wcard" ${go_('artwork/'+w.id)}>${mat(w)}<h3>${esc(w.titleAr)}</h3><div class="m">${esc(A(w.artist).ar)} · ${esc(w.date)}</div>${extra}</a>`}
function secH(t,link){return `<div class="sec-h"><h2>${t}</h2>${link||''}</div>`}
/* ---------- router ---------- */
let cur='',stack=[];
const F={q:'',mov:'',art:'',per:'',sort:'date-asc',shown:6,open:false};
function go(p){stack.push(cur);cur=p;render();window.scrollTo(0,0)}
function goBack(fb){const p=stack.pop();cur=p===undefined?fb:p;render();window.scrollTo(0,0)}
function topNav(){const t=cur.split('/')[0];return t===''?'home':({artwork:'artworks',artworks:'artworks',artist:'artists',artists:'artists',movement:'movements',movements:'movements'})[t]||'home'}
/* ---------- home ---------- */
const FEAT=['starry-night','great-wave','night-watch'],HPOS={'starry-night':'50% 40%','great-wave':'50% 50%','night-watch':'50% 30%'};let hi=0;
function heroHTML(){const w=W(FEAT[hi]),a=A(w.artist);return `<div class="hero-bg" style="background-image:url(img/${w.img}.jpg);background-position:${HPOS[w.id]}" role="img" aria-label="${esc(w.titleAr)}، عرض مقتطع من اللوحة"></div><div class="hero-scrim"></div>
<svg class="hero-thread" viewBox="0 0 1440 120" preserveAspectRatio="none" aria-hidden="true"><path d="M-20,96 C220,44 440,112 720,72 S1180,22 1460,66" fill="none" stroke="var(--thread)" stroke-width="1.7" stroke-linecap="round" vector-effect="non-scaling-stroke"/></svg>
<div class="wrap hero-in"><div class="hero-txt"><div class="eyebrow">متحف رقمي للفن</div><h1 style="margin:14px 0 16px">كل لوحة خيط<br>في حكاية الفن</h1>
<p class="read" style="font-size:20px">اكتشف اللوحات، وتعرّف على الفنانين والمدارس والأفكار التي تصل بينها.</p><p class="hero-poem" lang="ar">« ${w.poem} »</p>
<div style="display:flex;gap:12px;flex-wrap:wrap;margin-top:24px"><a class="btn pri" ${go_('artworks')}>استكشف اللوحات</a><a class="btn" ${go_('artwork/'+w.id)}>اقرأ حكاية اللوحة</a></div></div>
<div class="hero-foot"><div class="pager" role="group" aria-label="اللوحات المختارة">${FEAT.map((_,i)=>`<button type="button" data-hero="${i}" aria-pressed="${i===hi}" aria-label="اللوحة ${i+1}">0${i+1}</button>`).join('')}</div>
<a class="hero-cap" ${go_('artwork/'+w.id)}><b class="ar">${esc(w.titleAr)}</b> · ${esc(a.ar)}، ${esc(w.date)}<span>عرض مقتطع من اللوحة. افتحها كاملة ←</span></a></div></div>`}
function home(){
 const cur_=['night-watch','girl-pearl-earring','cafe-terrace','starry-night'].map(W),sp=W('great-wave');
 const rows=[['starry-night','great-wave'],['starry-night','cafe-terrace'],['girl-pearl-earring','milkmaid'],['mona-lisa','birth-of-venus']];
 return `<section class="hero" id="hero"><div id="heroIn">${heroHTML()}</div></section>
<div class="manif sky"><div class="wrap"><p>لا تقف اللوحة وحدها.<br><em>خلفها يدٌ رسمتها، وزمنٌ حملها، وعينٌ نظرت إليها قبلك.</em></p><div class="cap">من بيان وَشيج</div></div></div><div class="wrap">${weave()}</div>
<section><div class="wrap">${secH('<span>مجموعة: ضوء في العتمة</span>',`<a class="tl" ${go_('artworks')}>كل اللوحات</a>`)}
<p class="read muted" style="margin:-12px 0 28px">لوحات يخرج فيها الضوء من ظلمة عميقة ويصير هو موضوعها.</p>
<div class="curated"><a class="wcard big" ${go_('artwork/'+cur_[0].id)}>${mat(cur_[0])}<h3>${cur_[0].titleAr}</h3><div class="m">${A(cur_[0].artist).ar} · ${cur_[0].date}</div><div class="cpoem">${cur_[0].poem}</div></a>
${cur_.slice(1).map(w=>`<a class="wcard sm" ${go_('artwork/'+w.id)}>${mat(w)}<h3>${w.titleAr}</h3><div class="m">${A(w.artist).ar} · ${w.date}</div><div class="cpoem">${w.poem}</div></a>`).join('')}</div></div></section>
<section class="spot"><div class="wrap spot-g"><a class="brk" ${go_('artwork/'+sp.id)}>${mat(sp)}</a><div><div class="eyebrow">لوحة تحت المجهر</div><h2 style="margin:8px 0 6px">${sp.titleAr}</h2><div class="en muted" style="font-size:20px">The Great Wave off Kanagawa</div>
<p class="read" style="margin-top:16px;font-size:19px">${sp.intro}</p>
<ul class="ctx"><li><b>اليابان</b><span>في عهد توكوغاوا كانت التجارة الخارجية محدودة جدًا، وبقيت قنوات صغيرة مع الهولنديين والصينيين.</span></li><li><b>إيدو</b><span>ازدهرت في المدينة سوق للمطبوعات الملونة يشتريها سكانها.</span></li><li><b>الصبغة</b><span>وصل الأزرق البروسي إلى اليابان عبر التجارة، فصار استخدامه في الطباعة ممكنًا.</span></li><li><b>الأثر</b><span>وصلت المطبوعات اليابانية إلى أوروبا في القرن 19 وأثرت في فنانين مثل فان غوخ ومونيه.</span></li></ul>
<a class="btn sec" style="margin-top:22px" ${go_('artwork/'+sp.id)}>اقرأ حكاية اللوحة</a></div></div></section>
<section><div class="wrap">${secH('أعمال تستحق الاكتشاف','<span class="railbtns"><button type="button" data-rail="1" aria-label="التالي">←</button><button type="button" data-rail="-1" aria-label="السابق">→</button></span>')}<div class="rail-sc" id="rsc">${WORKS.filter(w=>w.img).map(w=>wcard(w)).join('')}</div></div></section>
<section><div class="wrap">${secH('فنانون للاكتشاف',`<a class="tl" ${go_('artists')}>كل الفنانين</a>`)}
<div class="artists">${['van-gogh','vermeer','monet','leonardo'].map(id=>{const a=A(id);return `<a class="acard" ${go_('artist/'+id)}>${mat(W(a.lead))}<h3>${a.ar}</h3><div class="cap">${a.born} – ${a.died} · ${M(a.movements[0]).ar}</div></a>`}).join('')}</div></div></section>
<section style="padding-top:0"><div class="wrap">${secH('استكشف المدارس الفنية',`<a class="tl" ${go_('movements')}>كل المدارس</a>`)}
<div class="mv-list">${['renaissance','dutch','romanticism','impressionism','postimpressionism','ukiyoe'].map(mvRow).join('')}</div></div></section>
<section class="spot"><div class="wrap">${secH('خيوط بين اللوحات')}<p class="read muted" style="margin:-12px 0 20px">كل خيط يصل لوحة بأخرى، ويذكر السبب.</p>
<div class="threads">${rows.map(([a,b])=>{const wa=W(a),why=wa.related.find(r=>r[0]===b)[1];return `<div class="trow"><a ${go_('artwork/'+a)} aria-label="${esc(wa.titleAr)}">${mat(wa)}</a><div class="why"><span>${esc(why)}</span></div><a ${go_('artwork/'+b)} aria-label="${esc(W(b).titleAr)}">${mat(W(b))}</a></div>`}).join('')}</div></div></section>
<section style="padding-top:0"><div class="wrap"><div class="tiles3">${[['movements','استكشف حسب المدرسة الفنية','تسع مدارس، من النهضة إلى السريالية','impression-sunrise'],['artists','تعرّف على الفنانين','سِيَر قصيرة وأعمال من عصور مختلفة','girl-pearl-earring'],['artworks','تتبّع الروابط بين اللوحات','لكل لوحة سبب يصلها بغيرها','starry-night']].map(([g,t,d,i])=>`<a class="tile3" ${go_(g)}>${mat(W(i))}<div><h3>${t}</h3><p class="muted">${d}</p></div></a>`).join('')}</div></div></section>
`}
function mvRow(id){const m=M(id);return `<a class="mv-row" ${go_('movement/'+id)}><h3>${m.ar}</h3><span class="muted">${m.period}</span><span class="cap">${plural(worksIn(id).length)}</span></a>`}
/* ---------- collection ---------- */
function filtered(){const q=norm(F.q);let r=WORKS.filter(w=>{if(F.mov&&w.movement!==F.mov)return false;if(F.art&&w.artist!==F.art)return false;if(F.per&&perOf(w).id!==F.per)return false;
 if(q){const hay=norm([w.titleAr,w.orig,A(w.artist).ar,A(w.artist).orig,M(w.movement).ar,M(w.movement).orig].join(' '));return q.split(' ').every(t=>hay.includes(t))}return true});
 r.sort((a,b)=>F.sort==='title'?a.titleAr.localeCompare(b.titleAr,'ar'):F.sort==='date-desc'?b.year-a.year:a.year-b.year);return r}
const opt=(items,sel,all)=>`<option value="">${all}</option>`+items.map(([v,t])=>`<option value="${v}" ${v===sel?'selected':''}>${esc(t)}</option>`).join('');
function chipsHTML(){const c=[];if(F.q)c.push(['q','بحث: '+F.q]);if(F.mov)c.push(['mov',M(F.mov).ar]);if(F.art)c.push(['art',A(F.art).ar]);if(F.per)c.push(['per',PERIODS.find(p=>p.id===F.per).ar]);
 return c.map(([k,t])=>`<span class="chip">${esc(t)}<button type="button" data-clr="${k}" aria-label="إزالة ${esc(t)}">${ico.x.replace('20','14')}</button></span>`).join('')}
function resultsHTML(){const r=filtered(),sh=r.slice(0,F.shown);
 if(!r.length)return `<div class="empty"><div>${sym(56,4)}</div><h3>لا توجد لوحات مطابقة</h3><p class="muted read" style="font-size:18px">جرّب اسمًا آخر، أو وسّع الفترة، أو أزل بعض المرشحات.</p><button class="btn pri" type="button" data-reset>إعادة الضبط</button></div>`;
 return `<div class="grid">${sh.map(w=>wcard(w)).join('')}</div><div style="text-align:center;margin-top:40px" class="muted">عرض ${sh.length} من ${r.length}${r.length>sh.length?`<div style="margin-top:14px"><button class="btn" type="button" data-more>تحميل المزيد</button></div>`:''}</div>`}
function collection(){
 const arts=Object.keys(ARTISTS).map(a=>[a,ARTISTS[a].ar]),mv=Object.keys(MOVEMENTS).map(m=>[m,MOVEMENTS[m].ar]);
 return `<div class="page-h"><div class="wrap"><div class="eyebrow">المجموعة</div><h1>اللوحات</h1><p class="read muted" style="margin-top:6px">ابحث بعنوان اللوحة أو اسم الفنان، وصفِّ بالمدرسة والفترة.</p></div></div>
<div class="wrap coll"><aside><button class="btn fbtn" type="button" data-ftoggle style="margin-bottom:12px" aria-expanded="${F.open}">المرشحات</button><form class="flt ${F.open?'':'collapsed'}" id="flt" role="search" onsubmit="return false">
<div class="fld full"><label for="fq">بحث</label><input id="fq" type="search" value="${esc(F.q)}" placeholder="عنوان اللوحة أو الفنان" autocomplete="off"></div>
<div class="fld"><label for="fm">المدرسة الفنية</label><select id="fm">${opt(mv,F.mov,'كل المدارس')}</select></div>
<div class="fld"><label for="fa">الفنان</label><select id="fa">${opt(arts,F.art,'كل الفنانين')}</select></div>
<div class="fld"><label for="fp">الفترة</label><select id="fp">${opt(PERIODS.map(p=>[p.id,p.ar]),F.per,'كل الفترات')}</select></div>
<div class="fld"><label for="fs">الترتيب</label><select id="fs"><option value="date-asc" ${F.sort==='date-asc'?'selected':''}>التاريخ: الأقدم أولًا</option><option value="date-desc" ${F.sort==='date-desc'?'selected':''}>التاريخ: الأحدث أولًا</option><option value="title" ${F.sort==='title'?'selected':''}>العنوان</option></select></div>
<div class="fld full"><button class="btn" type="button" data-reset style="width:100%;justify-content:center">إعادة الضبط</button></div></form></aside>
<div><div class="chips" id="chips">${chipsHTML()}</div><div class="res-top"><span id="cnt" role="status">${filtered().length} من ${WORKS.length} لوحة</span></div><div id="res">${resultsHTML()}</div></div></div>`}
function refreshRes(){$('#chips').innerHTML=chipsHTML();$('#cnt').textContent=filtered().length+' من '+WORKS.length+' لوحة';$('#res').innerHTML=resultsHTML();fixImgs()}
/* ---------- artwork detail ---------- */
function cropHTML(w,d){const m=IMGS[w.img],r=d.r;return `<div class="crop" role="img" aria-label="${esc(d.t)}: تفصيل من الصورة الأصلية" style="aspect-ratio:${(r.w*m.w).toFixed(0)} / ${(r.h*m.h).toFixed(0)};max-width:${Math.round(380*r.w*m.w/(r.h*m.h))}px;background-image:url(img/${w.img}.jpg);background-size:${(10000/r.w).toFixed(1)}% ${(10000/r.h).toFixed(1)}%;background-position:${r.w>=100?0:(r.x/(100-r.w)*100).toFixed(1)}% ${r.h>=100?0:(r.y/(100-r.h)*100).toFixed(1)}%"></div>`}
function artwork(id){
 const w=W(id);if(!w)return notFound();const a=A(w.artist),m=M(w.movement),meta=IMGS[w.img]||{};
 const dsec=(sid,h,body,th)=>`<div class="dsec" id="${sid}"><h2 ${th?'data-th':''}>${h}</h2><div>${body}</div></div>`;
 const hasCrop=w.details.some(d=>d.r);
 const dets=hasCrop?`<div class="dts">${w.details.filter(d=>d.r).map(d=>`<div>${cropHTML(w,d)}<h3>${d.t}</h3><p>${d.d}</p></div>`).join('')}</div><p class="note" style="margin-top:18px">التفاصيل مقتطعة من الصورة الأصلية دون تعديل في الألوان.</p>`:`<ul class="traits" style="max-width:720px">${w.details.map(d=>`<li><span><b>${d.t}:</b> ${d.d}</span></li>`).join('')}</ul>`;
 const rel=w.related.map(([rid,why])=>`<div><a class="wcard" ${go_('artwork/'+rid)}>${mat(W(rid))}<h3>${W(rid).titleAr}</h3><div class="m">${A(W(rid).artist).ar} · ${W(rid).date}</div></a><div class="why">${esc(why)}</div></div>`).join('');
 const links=[];if(w.img){links.push(`<a href="https://commons.wikimedia.org/wiki/File:${meta.file}" target="_blank" rel="noopener">الصورة: ويكيميديا كومنز</a> · عمل في الملك العام، ولا تُعرف قيود على الصورة الفوتوغرافية له`);links.push(`<a href="${meta.wiki}" target="_blank" rel="noopener">مقال ويكيبيديا عن اللوحة</a> · مرجع عام لبيانات العمل`)}
 if(w.src.moma)links.push(`<a href="${w.src.moma}" target="_blank" rel="noopener">صفحة العمل في متحف الفن الحديث</a> · الجهة المقتنية`);
 (w.src.extra||[]).forEach(([t,u])=>links.push(`<a href="${u}" target="_blank" rel="noopener">${t}</a> · مصدر للرسائل والنصوص`));
 if(!w.img)links.push('لا تُعرض صورة لهذا العمل في النموذج الأولي لأن حقوقه محفوظة.');
 return `<div class="wrap"><nav class="crumbs" aria-label="مسار التصفح"><a ${go_('')}>الرئيسية</a>/<a ${go_('artworks')}>اللوحات</a>/<span aria-current="page" style="color:var(--ink)">${w.titleAr}</span></nav></div>
<div class="detail stars" id="detail"><svg class="rail" id="rail" aria-hidden="true"></svg><div class="wrap">
<div class="d-hero"><div><div class="eyebrow">${m.ar} · ${m.period}</div><h1 style="margin-top:10px" id="h1" tabindex="-1">${w.titleAr}</h1><div class="en muted" style="font-size:22px;margin-top:4px">${esc(w.orig)}</div>
<div class="poem" lang="ar"><span>${w.poem}<small>سطر تحريري من وَشيج، وليس من كلام الفنان</small></span></div>
<a class="achip" ${go_('artist/'+w.artist)}><span class="av">${sym(30,6)}</span><span><b class="ar" style="font-size:20px">${a.ar}</b><span class="cap" style="display:block">${a.born} – ${a.died}</span></span></a>
<dl class="facts"><div><dt>التاريخ</dt><dd>${w.date}</dd></div><div><dt>الخامة</dt><dd>${w.medium}</dd></div><div><dt>القياس</dt><dd>${w.dims}</dd></div><div><dt>مكان الإنجاز</dt><dd>${w.place}</dd></div><div class="w"><dt>الجهة المقتنية</dt><dd>${w.where}</dd></div></dl>
<p class="read">${w.intro}</p>
<div style="display:flex;gap:10px;flex-wrap:wrap;margin-top:24px"><a class="btn pri" ${go_('artist/'+w.artist)}>الفنان: ${a.ar}</a><button class="btn" type="button" data-back="artworks">${ico.arr} العودة إلى اللوحات</button></div></div>
<figure class="plate" id="plate" data-th>${w.img?`<button class="zoom" type="button" data-zoom="${w.img}" aria-label="عرض اللوحة بحجم أكبر">${ico.zoom}</button>`:''}${w.img?`<div class="brk"><div class="mat">${img(w,{eager:true})}</div></div>`:mat(w)}<figcaption class="cap" style="margin-top:10px">اللوحة كاملة بنسبتها وألوانها الأصلية، دون اقتصاص أو فلتر.</figcaption></figure></div></div>
<nav class="subnav" aria-label="أقسام الصفحة"><div class="wrap">${[['s-story','حكاية اللوحة'],['s-read','قراءة فنية'],['s-det','تفاصيل تستحق الانتباه'],['s-int','التفسيرات'],['s-src','المصادر'],['s-rel','لوحات متصلة']].map(([i,t])=>`<a href="#" data-scroll="${i}">${t}</a>`).join('')}</div></nav>
<div class="wrap">${dsec('s-story','حكاية اللوحة',`<div class="read">${w.story.map(p=>`<p>${p}</p>`).join('')}</div>`,1)}
${dsec('s-read','قراءة فنية',`<div class="read">${w.reading.map(p=>`<p>${p}</p>`).join('')}</div>`,1)}
${dsec('s-det','تفاصيل تستحق الانتباه',dets,1)}
${dsec('s-int','تفسيرات منسوبة',`<p class="note" style="margin:0 0 16px;max-width:760px">الوقائع في الأقسام السابقة مأخوذة من مراجع المتاحف والدراسات. أما ما يلي فاجتهادات لباحثين وقراء، وتختلف بينهم.</p><div class="interp">${w.interp.map(i=>`<div class="intp"><p>${i.t}</p><div class="a">${i.a}</div></div>`).join('')}</div>`,1)}
${dsec('s-src','المصادر والاعتمادات',`<ul class="srcs">${links.map(l=>`<li>${l}</li>`).join('')}</ul>`,1)}
<div class="dsec" id="s-rel" style="border:0"><h2 data-th>لوحات متصلة</h2><div><div class="rel" data-th-end>${rel}</div></div></div></div></div>`}
function notFound(){return `<div class="wrap" style="padding-block:80px"><div class="empty"><h3>لم نجد هذه الصفحة</h3><a class="btn pri" ${go_('')}>العودة إلى الرئيسية</a></div></div>`}
/* ---------- artists & movements ---------- */
function artists(){return `<div class="page-h"><div class="wrap"><div class="eyebrow">الفنانون</div><h1>الفنانون</h1><p class="read muted" style="margin-top:6px">اثنا عشر فنانًا من عصور وبلدان مختلفة.</p></div></div><section><div class="wrap"><div class="artists" style="grid-template-columns:repeat(auto-fill,minmax(220px,1fr))">${Object.keys(ARTISTS).map(id=>{const a=A(id),l=a.lead?W(a.lead):worksBy(id)[0];return `<a class="acard" ${go_('artist/'+id)}>${mat(l)}<h3>${a.ar}</h3><div class="cap">${a.born} – ${a.died} · ${a.movements.map(m=>M(m).ar).join('، ')}</div></a>`}).join('')}</div></div></section>`}
function artist(id){const a=A(id);if(!a)return notFound();const ws=worksBy(id),l=ws.find(w=>w.id===a.lead)||ws[0];
 const same=[...new Set(a.movements.flatMap(artistsIn))].filter(x=>x!==id);
 return `<div class="wrap"><nav class="crumbs"><a ${go_('')}>الرئيسية</a>/<a ${go_('artists')}>الفنانون</a>/<span style="color:var(--ink)">${a.ar}</span></nav>
<div class="p-hero"><div><div class="eyebrow">${a.born} – ${a.died} · ${a.place}</div><h1 id="h1" tabindex="-1" style="margin-top:10px">${a.ar}</h1><div class="en muted" style="font-size:24px">${esc(a.orig)}</div>
<div class="meta-row">${a.movements.map(m=>`<a class="tag" ${go_('movement/'+m)}>${M(m).ar}</a>`).join('')}</div></div><a ${go_('artwork/'+l.id)}>${mat(l)}</a></div>
<div class="dsec"><h2>السيرة</h2><div class="read"><p>${a.bio}</p></div></div>
<div class="dsec"><h2>الأسلوب والسياق</h2><div class="read"><p>${a.style}</p><p class="muted" style="font-size:17px">${a.movements.map(m=>`${M(m).ar}: ${M(m).period}، ${M(m).where}.`).join(' ')}</p></div></div>
<div class="dsec" style="border:0"><h2>أعمال في المجموعة</h2><div class="grid" style="grid-template-columns:repeat(auto-fill,minmax(220px,1fr))">${ws.map(w=>wcard(w)).join('')}</div></div>
${same.length?`<div class="dsec" style="border:0"><h2>فنانون من المدرسة نفسها</h2><div class="alist">${same.map(x=>`<a ${go_('artist/'+x)}><b class="ar" style="font-size:20px">${A(x).ar}</b><span class="cap">${A(x).born} – ${A(x).died}</span></a>`).join('')}</div></div>`:''}</div>`}
function movements(){return `<div class="page-h"><div class="wrap"><div class="eyebrow">المدارس الفنية</div><h1>المدارس الفنية</h1><p class="read muted" style="margin-top:6px">تسع مدارس تجمع اللوحات في سياقاتها.</p></div></div><section><div class="wrap"><div class="mv-list">${Object.keys(MOVEMENTS).map(mvRow).join('')}</div></div></section>`}
function movement(id){const m=M(id);if(!m)return notFound();const ws=worksIn(id),as=artistsIn(id);
 return `<div class="wrap"><nav class="crumbs"><a ${go_('')}>الرئيسية</a>/<a ${go_('movements')}>المدارس الفنية</a>/<span style="color:var(--ink)">${m.ar}</span></nav>
<div style="padding-block:clamp(24px,4vw,48px) 8px"><div class="eyebrow">${m.period} · ${m.where}</div><h1 id="h1" tabindex="-1" style="margin-top:10px">${m.ar}</h1><div class="en muted" style="font-size:24px">${m.orig}</div><div class="mline" lang="ar">${m.line}</div></div>
<div class="dsec"><h2>مقدمة تاريخية</h2><div class="read"><p>${m.intro}</p></div></div>
<div class="dsec"><h2>ما يميّزها</h2><ul class="traits">${m.traits.map(t=>`<li>${t}</li>`).join('')}</ul></div>
<div class="dsec"><h2>فنانون مرتبطون</h2><div class="alist">${as.map(x=>`<a ${go_('artist/'+x)}><b class="ar" style="font-size:20px">${A(x).ar}</b><span class="cap">${A(x).born} – ${A(x).died}</span></a>`).join('')}</div></div>
<div class="dsec" style="border:0"><h2>لوحات من هذه المدرسة</h2><div class="grid" style="grid-template-columns:repeat(auto-fill,minmax(220px,1fr))">${ws.map(w=>wcard(w)).join('')}</div></div></div>`}
/* ---------- shell ---------- */
function footer(){return `<footer class="ftr"><div class="wrap ftr-g"><div><div class="logo" style="margin-bottom:12px">${sym(34,5)}${wordmark}</div><p class="muted" style="max-width:36ch">كل لوحة خيط في حكاية الفن.</p></div>
<div><b>تنقّل</b><ul style="margin-top:8px"><li><a ${go_('')}>الرئيسية</a></li><li><a ${go_('artworks')}>اللوحات</a></li><li><a ${go_('artists')}>الفنانون</a></li><li><a ${go_('movements')}>المدارس الفنية</a></li></ul></div>
<div><b>المصادر والاعتمادات</b><p class="cap" style="margin-top:8px">صور اللوحات من ويكيميديا كومنز، وهي أعمال في الملك العام وتُعرض بألوانها الأصلية. البيانات من مراجع المتاحف والمقالات المنشورة، وتُذكر في صفحة كل لوحة. هذا نموذج أولي، والمحتوى مختصر وقيد المراجعة التحريرية.</p></div></div></footer>`}
function render(){
 const [t,p]=cur.split('/'),v=$('#view');
 v.innerHTML=({'':home,artworks:collection,artwork:()=>artwork(p),artists,artist:()=>artist(p),movements,movement:()=>movement(p)}[t]||notFound)();
 $('#view').insertAdjacentHTML('beforeend',footer());
 const tp=topNav();$$('[data-nav]').forEach(a=>{a.toggleAttribute('aria-current',a.dataset.nav===tp);if(a.dataset.nav===tp)a.setAttribute('aria-current','page');else a.removeAttribute('aria-current')});
 closeAll();fixImgs();v.style.animation='none';void v.offsetWidth;v.style.animation='';
 if(t==='artwork')setupDetail();else $('#rail')?.remove();
 const h=$('#h1');if(h)h.focus({preventScroll:true});
}
function fixImgs(){$$('img:not(.ld)').forEach(i=>{if(i.complete)i.classList.add('ld')});setTimeout(()=>$$('img:not(.ld)').forEach(i=>i.classList.add('ld')),3000)}
/* detail: Long Thread in the margin + subnav */
function drawRail(){const d=$('#detail'),r=$('#rail');if(!d||!r||getComputedStyle(r).display==='none')return;
 const dr=d.getBoundingClientRect(),pts=$$('[data-th]',d).map(e=>{const b=e.getBoundingClientRect();return e.id==='plate'?b.bottom-dr.top-16:b.top-dr.top+22});
 const last=$('[data-th-end]',d);if(last){pts.push(last.getBoundingClientRect().top-dr.top+60)}
 if(pts.length<2)return;const x=24,H=d.offsetHeight;r.setAttribute('viewBox',`0 0 48 ${H}`);r.setAttribute('height',H);
 let p=`M${x},${pts[0]}`;for(let i=1;i<pts.length;i++){const y0=pts[i-1],y1=pts[i],ym=(y0+y1)/2,s=i%2?10:-10;p+=` C${x+s},${y0+(ym-y0)*.5} ${x+s},${ym+(y1-ym)*.5} ${x},${y1}`}
 r.innerHTML=`<path d="${p}"/>${pts.map(y=>`<circle cx="${x}" cy="${y}" r="4"/>`).join('')}`}
let rafL=0;function onScroll(){if(rafL)return;rafL=requestAnimationFrame(()=>{rafL=0;const subs=$$('.subnav a');if(!subs.length)return;let on=null;subs.forEach(a=>{const s=$('#'+a.dataset.scroll);if(s&&s.getBoundingClientRect().top<180)on=a});subs.forEach(a=>a.classList.toggle('on',a===on))})}
function setupDetail(){drawRail();[200,800,1800].forEach(t=>setTimeout(drawRail,t));onScroll()}
/* overlays */
function closeAll(){$('#drawer').classList.remove('open');$('#sov').classList.remove('open');$('#lb').classList.remove('open');document.body.style.overflow=''}
function openSearch(){$('#sov').classList.add('open');document.body.style.overflow='hidden';const i=$('#sq');i.value='';sres('');setTimeout(()=>i.focus(),30)}
function sres(q){const n=norm(q);const r=n?WORKS.filter(w=>n.split(' ').every(t=>norm([w.titleAr,w.orig,A(w.artist).ar,A(w.artist).orig,M(w.movement).ar].join(' ')).includes(t))).slice(0,8):[];
 $('#sr').innerHTML=!n?`<p class="muted">اكتب عنوان لوحة أو اسم فنان.</p>`:r.length?r.map(w=>`<a ${go_('artwork/'+w.id)}>${w.img?`<img src="img/${w.img}.jpg" alt="" width="44" height="44">`:'<span style="width:44px;height:44px;background:var(--surface)"></span>'}<span><b class="ar" style="font-size:19px">${w.titleAr}</b><br><span class="cap">${A(w.artist).ar} · ${w.date}</span></span></a>`).join('')+`<a ${go_('artworks')} data-q="${esc(q)}" class="tl" style="border:0">عرض كل النتائج في المجموعة</a>`:`<p class="muted">لا نتائج لهذا البحث.</p>`}
/* events */
document.addEventListener('click',e=>{const t=e.target.closest('[data-go],[data-back],[data-hero],[data-rail],[data-clr],[data-reset],[data-more],[data-ftoggle],[data-zoom],[data-scroll],#openS,#openM,#closeM,#closeS,#lb');if(!t)return;
 if(t.dataset.go!==undefined){e.preventDefault();if(t.dataset.q!==undefined){F.q=t.dataset.q}go(t.dataset.go)}
 else if(t.dataset.back){goBack(t.dataset.back)}
 else if(t.dataset.rail){const el=$('#rsc');el.scrollBy({left:-(+t.dataset.rail)*el.clientWidth*.8,behavior:matchMedia('(prefers-reduced-motion: reduce)').matches?'auto':'smooth'})}
 else if(t.dataset.hero){hi=+t.dataset.hero;$('#heroIn').innerHTML=heroHTML()}
 else if(t.dataset.clr){const k=t.dataset.clr;F[k==='q'?'q':k]='';if(k==='q')$('#fq').value='';['fm','fa','fp'].forEach((i,n)=>{});F.shown=6;syncFilters();refreshRes()}
 else if(t.dataset.reset!==undefined){Object.assign(F,{q:'',mov:'',art:'',per:'',sort:'date-asc',shown:6});syncFilters();refreshRes()}
 else if(t.dataset.more!==undefined){F.shown+=6;refreshRes()}
 else if(t.dataset.ftoggle!==undefined){F.open=!F.open;$('#flt').classList.toggle('collapsed',!F.open);t.setAttribute('aria-expanded',F.open)}
 else if(t.dataset.zoom){$('#lbi').src='img/'+t.dataset.zoom+'.jpg';$('#lb').classList.add('open');document.body.style.overflow='hidden'}
 else if(t.dataset.scroll){e.preventDefault();$('#'+t.dataset.scroll).scrollIntoView({behavior:matchMedia('(prefers-reduced-motion: reduce)').matches?'auto':'smooth',block:'start'})}
 else if(t.id==='openS')openSearch();else if(t.id==='closeS'){closeAll()}
 else if(t.id==='openM'){$('#drawer').classList.add('open');document.body.style.overflow='hidden'}else if(t.id==='closeM')closeAll();
 else if(t.id==='lb')closeAll();
});
function syncFilters(){const f=$('#fq');if(!f)return;f.value=F.q;$('#fm').value=F.mov;$('#fa').value=F.art;$('#fp').value=F.per;$('#fs').value=F.sort}
document.addEventListener('input',e=>{if(e.target.id==='fq'){F.q=e.target.value;F.shown=6;refreshRes()}if(e.target.id==='sq')sres(e.target.value)});
document.addEventListener('change',e=>{const m={fm:'mov',fa:'art',fp:'per',fs:'sort'}[e.target.id];if(m){F[m]=e.target.value;F.shown=6;refreshRes()}});
document.addEventListener('keydown',e=>{if(e.key==='Escape')closeAll();if(e.key==='Enter'&&e.target.id==='sq'){F.q=e.target.value;go('artworks')}});
addEventListener('resize',()=>{drawRail()});addEventListener('scroll',onScroll,{passive:true});
$('#logoA').innerHTML=sym(36,5)+wordmark;$('#openS').insertAdjacentHTML('afterbegin',ico.search);$('#openM').innerHTML=ico.menu;$('#closeM').innerHTML=ico.x;$('#closeS').innerHTML=ico.x;$('#lbx').innerHTML=ico.x;
render();applySky();
