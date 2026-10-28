WASHIJ (وَشيج) is an Arabic digital art museum. Every painting is presented with the artist, the period and the ideas that connect it to other works. It is a museum, not a shop: no prices, no bidding, no "buy" language anywhere.

The concept is connection. Art is not an isolated image; it is a thread between people, time, memory and meaning. Do not claim an etymology for the name beyond that it evokes connection and interweaving.

## Content fundamentals

- Primary language is Arabic; English mirrors it. Write Arabic first, then adapt. Never machine-translate headings.
- Tone: thoughtful, curious, clear. Poetic only when introducing an artwork (`poetic-ar`, two lines at most). Facts are plain and sourced.
- Present interpretations as interpretations: "يرى بعض الباحثين…", "يُرجَّح…". Never "the greatest", "the most famous", "a masterpiece".
- Tagline: **كل لوحة خيط في حكاية الفن** (Every painting is a thread in the story of art).
- Use Western digits (1642, 44.5 × 39) for dates and measures in both languages. Do not mix digit systems in one screen.
- No emoji. No exclamation marks. Sentence case in English; uppercase only for `eyebrow-en`.

## Visual foundations

- One theme: `gallery`, the night sky. Grounds are `bg`, `surface`, `surface-raised`; text is `ink` and `ink-muted`. There is no light theme.
- The palette is the nocturnal sky: `midnight` ground, `indigo` for selected surfaces (`surface-selected` with `on-selected`), `interactive` cobalt for restrained secondary controls (with `on-interactive`), `muted-sky` (`accent`) for links and labels on dark, and `star-yellow` as the thread. Yellow is an accent, never a large fill and never body text: use `thread` for graphic lines, and `accent-fill` with `on-accent` for the single primary button on a screen.
- Never put a blue or yellow filter, wash or gradient over a painting. The blue belongs to the surroundings; paintings keep their source colours.
- Corners are square (`radius-none`). Paintings have corners. `radius-round` is for avatars and the app icon mask only.
- The only shadow is `shadow-hang`, for an artwork hanging on a wall. UI cards have no shadow; they are set apart by `hairline`.
- Controls use `border-control` (3:1). `hairline` is decorative only.
- Focus: 2px solid `focus`, 2px offset, on every interactive element.
- Spacing steps are `space-1` to `space-9`. Page gutter `space-4` on mobile, `space-6` on desktop.
- Paintings keep their original colour. Darkness comes from the surroundings, never from a filter on the work.

## Typography

- Arabic headings, poems and titles: Aref Ruqaa (`arabic`), a calligraphic ruqaa with a poetic hand. Arabic reading text: Scheherazade New (`text`), a warm naskh. UI, labels and metadata: Readex Pro (`ui`). English display: Cormorant Garamond (`display`), whose Arabic fallback is Aref Ruqaa. The Arabic wordmark stays in Amiri Bold (`wordmark`) and is used for the logo only.
- Arabic is never letter-spaced and never uppercased. English `eyebrow-en` is tracked at 0.18em.
- Arabic line height: 1.6 for display and headings (ruqaa needs room for its stacked marks), 1.9 or more for reading (`body-ar` is 20/38).
- In a bilingual line, set the English run inline with `dir="ltr"` and keep the same font-size; do not shrink it.
- Do not use Cormorant or Aref Ruqaa for paragraphs or functional UI text.

## Logo

- Use the supplied lockups. Symbol: a 3:5 portrait frame crossed by one thread (over the left edge, under the right). Wordmarks are live type: Amiri Bold (`wordmark`) with a yellow fatha; Cormorant caps tracked 0.32em.
- Clear space is half the symbol width. Minimums: symbol 16px, Arabic wordmark 72px, English wordmark 80px, horizontal lockup 160px.
- Monochrome versions are one ink (ivory or midnight) for foil, embossing and print on paper. They are not a screen theme.
- Logo files: see the Logos asset group. The symbol is also drawn in the Symbol component.

## Graphic language

- The Long Thread: one line, 1.2-1.6px, crossing a row of frames, over then under. Separators are a hairline broken by one thread stroke. Frame devices are four ink corner marks.
- The symbol pattern is `hairline` on `surface`, never behind text, never yellow.
- No Islamic geometric ornament, textures, flourishes, glows or gradients on UI. Do not imitate brushwork or swirls of a particular painting: The Starry Night informs the palette only.

## Sections

Further brand-book sections follow: creative exploration, guidelines, art direction and verbal identity.
