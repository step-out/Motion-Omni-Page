#!/usr/bin/env bash
# Build the side-by-side comparison clips the page plays.
#
# Why pre-composite instead of two <video> elements: two elements decode and
# buffer independently, so keeping them in step needs JS that watches one and
# seeks the other.  That works until a network hiccup or a rejected play()
# leaves one side stalled -- readers then see one avatar moving and one frozen.
# One file has one decoder and one clock, so the halves cannot drift apart.
#
# Ours is always the left half.  Audio comes from ours only: the baselines were
# driven by that same response audio, so a second track would just echo.
# A 2px divider is drawn at the seam rather than added in CSS so that it also
# survives fullscreen, where the page's own overlay is not composited.
#
# Usage: tools/make_pairs.sh [name ...]      (default: every clip in videos/)
set -euo pipefail
cd "$(dirname "$0")/.."

FFMPEG="${FFMPEG:-ffmpeg}"
command -v "$FFMPEG" >/dev/null || {
  # imageio-ffmpeg ships a static build; use it when no system ffmpeg exists.
  FFMPEG=$(python3 -c 'import imageio_ffmpeg;print(imageio_ffmpeg.get_ffmpeg_exe())' 2>/dev/null) || {
    echo "need ffmpeg: pip install imageio-ffmpeg" >&2; exit 1; }
}

BASELINES="lom:videos_lom glsm:videos_glsm emage:videos_emage mamba:videos_mamba"
CRF="${CRF:-21}"
mkdir -p videos_pair thumbs_pair

names=("$@")
if [ ${#names[@]} -eq 0 ]; then
  mapfile -t names < <(cd videos && ls *.mp4 | sed 's/\.mp4$//')
fi

for name in "${names[@]}"; do
  left="videos/$name.mp4"
  [ -f "$left" ] || { echo "skip $name: no $left" >&2; continue; }
  for pair in $BASELINES; do
    key="${pair%%:*}"; dir="${pair##*:}"
    right="$dir/$name.mp4"
    out="videos_pair/${name}__${key}.mp4"
    [ -f "$right" ] || { echo "skip $key/$name: no $right" >&2; continue; }

    # A length mismatch would desync the halves permanently, so refuse instead.
    # `ffmpeg -i` with no output file exits 1 by design, hence the `|| true`:
    # under `set -e` the bare substitution would abort the whole script.
    probe() { "$FFMPEG" -i "$1" -hide_banner 2>&1 | sed -n 's/.*Duration: \([0-9:.]*\).*/\1/p' || true; }
    dl=$(probe "$left"); dr=$(probe "$right")
    [ -n "$dl" ] && [ "$dl" = "$dr" ] || { echo "SKIP $key/$name: duration '$dl' vs '$dr'" >&2; continue; }

    "$FFMPEG" -y -hide_banner -loglevel error -i "$left" -i "$right" \
      -filter_complex "[0:v][1:v]hstack=inputs=2[s];\
[s]drawbox=x=719:y=0:w=2:h=1280:color=0x2a3038@1:t=fill[v]" \
      -map "[v]" -map 0:a \
      -c:v libx264 -crf "$CRF" -preset slow -pix_fmt yuv420p \
      -c:a aac -b:a 80k \
      -movflags +faststart "$out"          # faststart: play before fully fetched

    # Poster, so the pair is visible before anyone presses play.
    "$FFMPEG" -y -hide_banner -loglevel error -ss 0 -i "$out" -frames:v 1 \
      -vf scale=720:-2 -q:v 4 "thumbs_pair/${name}__${key}.jpg"
    echo "  built $out"
  done
done
