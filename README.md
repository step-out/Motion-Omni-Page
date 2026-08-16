# Motion-Omni — Project Page

Project page for **Motion-Omni: End-to-End Joint Speech and Full-Body Motion for Spoken Dialogue**.

A static site — no build step. Open `index.html` directly, or serve the folder:

```bash
python3 -m http.server 8000
```

## Deploying with GitHub Pages

Settings → Pages → Source: *Deploy from a branch* → Branch: `main`, folder: `/ (root)`.

`.nojekyll` is present so Jekyll does not filter any files.

## Layout

```
index.html                 markup + rendering logic (no framework)
manifest.json              ALL page content: title, authors, abstract, tables, video metadata
assets/architecture.png    Figure 1 — framework diagram
assets/quality_latency.png Figure 2 — motion quality vs. response latency
thumbs/*.jpg               video posters
videos/*.mp4               6 demo clips, 720x1280, 15 fps, with audio
```

## Editing content

Edit `manifest.json`, not `index.html` — the page reads every string, number and table
row from the manifest at load time.

To fill in the arXiv / paper / code links, set the corresponding fields under `paper`:

```json
"arxiv": "https://arxiv.org/abs/XXXX.XXXXX",
"pdf":   "https://arxiv.org/pdf/XXXX.XXXXX",
"code":  "https://github.com/..."
```

Empty strings render as greyed-out, non-clickable buttons, so the page stays
presentable before the links exist.

## Video samples

Six responses generated end-to-end from spoken input; speech and full-body motion come
from a single autoregressive pass, with no retiming or hand editing. Clips were screened
for audio-text consistency (Whisper-large-v3 word error rate; five of six are exactly
0.0%) and then selected manually.
