# Motion-Omni — Project Page

Project page for **Motion-Omni: End-to-End Joint Speech and Full-Body Motion for Spoken Dialogue**.

A static site — no build step, no framework. Open `index.html` directly, or serve the folder:

```bash
python3 -m http.server 8000
```

## Deploying with GitHub Pages

Settings → Pages → Source: *Deploy from a branch* → Branch: `main`, folder: `/ (root)`.

`.nojekyll` is present so Jekyll does not filter any files.

## Layout

Sections run in this order: abstract, framework figure, video samples, result
tables, BibTeX. The videos sit above the tables so a reader meets them without
scrolling to the end. To reorder, move the `<section>` blocks in `index.html` —
the rendering code addresses elements by id, so it does not depend on their order.

```
index.html                 markup + rendering logic
manifest.json              ALL page content — edit this, not index.html
assets/architecture.png    Figure 1 — framework diagram
assets/quality_latency.png Figure 2 — motion quality vs. response latency
thumbs/*.jpg               video posters
videos/*.mp4               6 demo clips, 720x1280, 15 fps, with audio
```

## Editing content

**Edit `manifest.json`, not `index.html`.** The page reads every string, number
and table row from the manifest when it loads, so changing text never requires
touching the markup. Reload the browser to see the result — there is nothing to
rebuild.

`manifest.json` is JSON, so: strings need double quotes, no trailing comma after
the last item in a list or object, and a literal `"` inside text must be written
`\"`. If the page renders blank, the JSON is malformed — paste it into any JSON
validator to find the spot.

Everything below lives under the `"paper"` key unless stated otherwise.

### Links (arXiv / paper / code)

```json
"arxiv": "https://arxiv.org/abs/2608.01234",
"pdf":   "https://arxiv.org/pdf/2608.01234",
"code":  "https://github.com/..."
```

An empty string renders as a greyed-out, non-clickable button, so the page stays
presentable before a link exists.

### Venue

```json
"venue": ""
```

Empty hides the line entirely. Set it to e.g. `"ICLR 2027"` and it appears under
the title.

### Authors

```json
"authors": [
  { "name": "Chengqian Ma", "aff": "Peking University", "equal": true },
  { "name": "Yiwen Guo", "aff": "Independent Researcher", "corresponding": true }
]
```

Order in the list is the order shown. Two optional flags add role markers,
matching the paper: `"equal": true` marks equal contribution (`*`) and
`"corresponding": true` marks the corresponding author (`†`). Each note line
appears only when at least one author carries that flag. The BibTeX entry is
generated from this same list, so the two can never disagree.

When the authors flagged `"equal"` are the leading run of the list, the note
names them — "The first three authors contributed equally". Flag a
non-contiguous set instead and it lists them by name.

Names appear on one line and affiliations on the next, linked by superscript
numbers that are assigned automatically. Authors sharing an affiliation share a
number — write the affiliation string identically for that to happen.

### Title, abstract, figure captions

```json
"title":         "...",
"abstract":      "...",
"arch_caption":  "...",
"ql_caption":    "..."
```

The abstract accepts inline HTML — `<strong>bold</strong>`, `<em>italic</em>`,
`&times;` for ×.

### Highlight cards

The four cards under the abstract:

```json
"highlights": [
  { "v": "2.62%", "k": "WER on Seed-TTS-Eval", "n": "lowest among omni-modal LLMs" }
]
```

`v` is the big number, `k` the label, `n` the small grey note. Add or remove
entries freely; the row re-flows.

### Result tables

Four tables, each under its own key, each holding a `caption` and a `cols` list
of headers.

**`"motion"` and `"latency"`** hold a flat `rows` list. Cells are written
`["7.59", 0]`, where the second element controls emphasis:

| value | rendering |
|---|---|
| `0` | plain |
| `1` | best — green highlight |
| `2` | second best — underlined |

`"ours_row"` is the zero-based index of the row highlighted in blue. In the
motion table, `"teacher_rows"` lists the rows greyed out as running the motion
teacher at inference time. **If you add or delete a row, update these indices** —
they are positions, not names.

**`"speech"`** is grouped instead, because the table separates dedicated TTS
systems from omni-modal LLMs:

```json
"groups": [
  ["Dedicated TTS", [["CosyVoice 2", "2.57", 0]]],
  ["Omni-modal LLMs", [["Motion-Omni-Q7 (ours)", "2.62", 1]]]
]
```

Each group is `[heading, rows]`, and a row is `[name, value, emphasis]` — flat,
not nested like the other tables. A row whose name contains `ours` is
highlighted automatically, so this table needs no `ours_row`.

**`"data"`** is plain text throughout — rows are just lists of strings with no
emphasis markers. Its last row is bolded automatically as the total.

### Video captions

The six clips live under the **top-level** `"items"` key (not under `"paper"`).
Editing `question` or `answer` changes the caption text only. To swap a clip you
also need to replace the file in `videos/` and its poster in `thumbs/`, keeping
the `video` and `name` fields in sync with the filenames.

## Changing colours and layout

These are in `index.html`. The palette is a handful of CSS variables at the top:

```css
--bg      page background
--panel   card background
--ink     primary text
--ink2    secondary text
--accent  link and heading blue
--best    green used for best values in tables
```

## Video samples

Six responses generated end-to-end from spoken input; speech and full-body motion
come from a single autoregressive pass, with no retiming or hand editing. Clips
were screened for audio-text consistency (Whisper-large-v3 word error rate; five
of six are exactly 0.0%) and then selected manually.
