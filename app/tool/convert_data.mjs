import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoDir = path.resolve(toolDir, '../..');
const prototypeDir = path.join(repoDir, 'prototype');
const outputDir = path.join(repoDir, 'app/assets/data');

const qids = {
  'starry-night': 'Q45585',
  'girl-pearl-earring': 'Q185372',
  'great-wave': 'Q252485',
  'mona-lisa': 'Q12418',
  'birth-of-venus': 'Q151047',
  'impression-sunrise': 'Q328523',
  'the-scream': 'Q18891156',
  'night-watch': 'Q219831',
  milkmaid: 'Q167605',
  wanderer: 'Q311243',
  'las-meninas': 'Q208758',
  'the-kiss': 'Q698487',
  'cafe-terrace': 'Q1025704',
  'persistence-of-memory': 'Q25729',
};

const commonsAuthors = {
  'starry-night': 'Vincent van Gogh',
  'girl-pearl-earring': 'Johannes Vermeer',
  'great-wave': 'Katsushika Hokusai',
  'mona-lisa': 'Leonardo da Vinci',
  'birth-of-venus': 'Sandro Botticelli',
  'impression-sunrise': 'Claude Monet',
  'the-scream': 'Edvard Munch',
  'night-watch': 'Rembrandt',
  milkmaid: 'Johannes Vermeer',
  wanderer: 'Caspar David Friedrich',
  'las-meninas': 'Diego Velázquez',
  'the-kiss': 'Gustav Klimt',
  'cafe-terrace': 'Vincent van Gogh',
};

const articleTitles = {
  'starry-night': ['ar', 'ليلة النجوم (لوحة)'],
  'girl-pearl-earring': ['ar', 'الفتاة ذات القرط اللؤلؤي (لوحة)'],
  'great-wave': ['ar', 'الموجة الكبيرة في كاناغاوا'],
  'mona-lisa': ['ar', 'موناليزا'],
  'birth-of-venus': ['ar', 'ولادة فينوس'],
  'impression-sunrise': ['ar', 'انطباع، شروق الشمس'],
  'the-scream': ['en', 'The Scream'],
  'night-watch': ['ar', 'دورية الليل'],
  milkmaid: ['ar', 'ساقية الحليب'],
  wanderer: ['ar', 'متجول فوق بحر من الضباب'],
  'las-meninas': ['ar', 'لاس مينيناس'],
  'the-kiss': ['ar', 'لوحة القبلة'],
  'cafe-terrace': ['ar', 'شرفة مقهى في الليل'],
  'persistence-of-memory': ['ar', 'إصرار الذاكرة'],
};

const filePage = (file) =>
  `https://commons.wikimedia.org/wiki/File:${encodeURIComponent(file.replaceAll(' ', '_'))}`;
const articleUrl = (id) => {
  const [language, title] = articleTitles[id];
  return `https://${language}.wikipedia.org/wiki/${encodeURIComponent(title.replaceAll(' ', '_'))}`;
};

const sandbox = {};
const source = fs.readFileSync(path.join(prototypeDir, 'src/data.js'), 'utf8');
vm.runInNewContext(
  `${source}\nglobalThis.__washij = {WORKS, ARTISTS, MOVEMENTS, PERIODS};`,
  sandbox,
  { filename: 'prototype/src/data.js' },
);

const html = fs.readFileSync(path.join(prototypeDir, 'index.html'), 'utf8');
const imageMatch = html.match(/const IMGS=(\{.*?\});const MOVEMENTS/s);
if (!imageMatch) throw new Error('Could not find the prototype IMGS metadata.');
const imageMetadata = JSON.parse(imageMatch[1]);
const { WORKS, ARTISTS, MOVEMENTS, PERIODS } = sandbox.__washij;

const works = WORKS.map((work) => {
  const image = work.img ? imageMetadata[work.img] : null;
  const author = commonsAuthors[work.id];
  const article = articleTitles[work.id];
  if (!qids[work.id] || !article || (image && !author)) {
    throw new Error(`Missing verified metadata for ${work.id}.`);
  }

  return {
    id: work.id,
    qid: qids[work.id],
    titleAr: work.titleAr,
    titleOrig: work.orig,
    artistId: work.artist,
    movementId: work.movement,
    year: work.year,
    dateText: work.date,
    medium: work.medium,
    dimensions: work.dims,
    collection: work.where,
    place: work.place,
    poem: work.poem,
    intro: work.intro,
    story: work.story,
    reading: work.reading,
    details: work.details.map((detail) => ({
      title: detail.t,
      text: detail.d,
      ...(detail.r ? { crop: detail.r } : {}),
    })),
    interpretations: work.interp.map((item) => ({
      text: item.t,
      attribution: item.a,
    })),
    related: work.related.map(([artworkId, reason]) => ({ artworkId, reason })),
    sources: (work.src?.extra ?? []).map(([title, url]) => ({ title, url })),
    image: image
      ? {
          asset: `assets/img/${work.img}.jpg`,
          width: image.w,
          height: image.h,
        }
      : null,
    commonsFile: image?.file ?? '',
    wikipediaTitle: article[1],
    credit: {
      author: author ?? 'No image; rights held',
      licence: image ? 'Public domain' : 'Image withheld',
      fileUrl: image ? filePage(image.file) : '',
      articleUrl: articleUrl(work.id),
      attribution: image
        ? `Image by ${author}, public domain via Wikimedia Commons. Wikipedia article under CC BY-SA.`
        : 'Wikipedia article under CC BY-SA.',
      isFallback: true,
    },
  };
});

const artists = Object.fromEntries(
  Object.entries(ARTISTS).map(([id, artist]) => [id, artist]),
);
const movements = Object.fromEntries(
  Object.entries(MOVEMENTS).map(([id, movement]) => [id, movement]),
);
const periods = PERIODS.map(({ id, ar }) => {
  const limits = {
    p1: [-10000, 1600],
    p2: [1600, 1700],
    p3: [1700, 1900],
    p4: [1900, null],
  }[id];
  return { id, ar, minYear: limits[0], maxYearExclusive: limits[1] };
});

fs.mkdirSync(outputDir, { recursive: true });
for (const [name, value] of Object.entries({ works, artists, movements, periods })) {
  fs.writeFileSync(
    path.join(outputDir, `${name}.json`),
    `${JSON.stringify(value, null, 2)}\n`,
  );
}
console.log(`Wrote ${works.length} works, ${Object.keys(artists).length} artists, ` +
  `${Object.keys(movements).length} movements and ${periods.length} periods.`);
