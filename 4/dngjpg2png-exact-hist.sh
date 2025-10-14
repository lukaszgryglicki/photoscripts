#!/bin/bash
# dng2png_match.sh — match a DNG to its JPG look but keep lossless 16-bit grayscale PNG
# Usage: ./dng2png_match.sh xyz [abc ...]    # looks for xyz.DNG and xyz.JPG; writes xyz.png
set -euo pipefail

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 2; }; }

# Always needed
need magick
# need oxipng
# need optipng
need vips

# At least one renderer:
have_rt=0; command -v rawtherapee-cli >/dev/null 2>&1 && have_rt=1
if [ $have_rt -eq 0 ]
then
  echo "Install rawtherapee-cli." >&2; exit 2
fi

for p in \
  "/usr/share/rawtherapee/profiles/Auto-Matched Curve - ISO Low.pp3" \
  "/usr/share/rawtherapee/profiles/Auto-Matched Curve - ISO High.pp3"
do
  if [ ! -f "$p" ]
  then
    echo "[error] Missing RawTherapee profile: $p" >&2
    exit 2
  fi
done

if [ "$#" -lt 1 ]; then
  echo "Usage: $(basename "$0") basename [basename2 ...]" >&2
  exit 1
fi

export OMP_NUM_THREADS="$(nproc)"
export VIPS_WARNING=0

for base in "$@"; do
  # Resolve DNG (case-insensitive)
  DNG=""; for ext in DNG dng; do [ -e "${base}.${ext}" ] && DNG="${base}.${ext}" && break; done
  [ -z "$DNG" ] && { echo "[skip] No DNG for ${base}"; continue; }
  ISO=$(exiftool -ISO "$DNG" | awk '{print $3}')
  echo "[info] Processing ${DNG} (ISO: ${ISO}) ..."
  if (( ISO > 50000 )); then
    PP3="/usr/share/rawtherapee/profiles/Auto-Matched Curve - ISO High.pp3"
  else
    PP3="/usr/share/rawtherapee/profiles/Auto-Matched Curve - ISO Low.pp3"
  fi

  # Resolve JPG (case-insensitive); we use it to match tones
  JPG=""; for ext in JPG jpg jpeg Jpg Jpeg; do [ -e "${base}.${ext}" ] && JPG="${base}.${ext}" && break; done
  if [ -z "$JPG" ]; then
    echo "[skip] No JPG for ${base}"
    continue
  fi
  echo "[info] Using JPG ${JPG:-<none>}"

  out_png="${base}.png"
  # tmpdir="$(mktemp -d)"
  tmpdir="${base}.tmp"
  if [ -d "${tmpdir}" ]
  then
    echo "[fail] Temporary directory ${tmpdir} already exists; please remove it and try again."
    continue
  fi
  mkdir -p "$tmpdir"

  # 1) Develop DNG -> 16-bit TIFF
  # RawTherapee: Auto-Matched Curve (matches embedded JPEG)
  outdir="$tmpdir/rt"; mkdir -p "$outdir"
  echo "[info] Using RawTherapee profile: $PP3"
  rawtherapee-cli -b16 -tz -o "$outdir" -p "$PP3" -Y -c "$DNG"
  tiff="$(find "$outdir" -type f \( -name '*.tif' -o -name '*.tiff' \) | head -n1)"
  [ -z "${tiff:-}" ] && { echo "[fail] Could not produce TIFF for ${base}"; rm -rf "$tmpdir"; continue; }
  echo "[ok] Produced intermediate TIFF ${tiff}"
  identify -quiet "$tiff"

  # 2) Do histogram matching on luminance to mimic its tone
  matched_tiff="$tiff"
  echo "[info] Matching tones to ${JPG} ..."
  ref_gray="$tmpdir/ref-gray.png"
  # Force 16-bit so both histograms have 65536 bins
  magick -quiet "$JPG" -colorspace Gray -alpha off -define png:color-type=0 -define png:bit-depth=16 "${ref_gray}"
  echo "[info] Reference grayscale image: ${ref_gray}"
  identify -quiet "$ref_gray"

  # Build normalised CDFs (what vips hist_match expects), create LUT, scale to 16‑bit, apply
  # Source: take one band from the 16‑bit sRGB TIFF (M11M output has equal RGB)
  vips extract_band "$tiff" "$tmpdir/src16.v" 0
  vips cast "$ref_gray" "$tmpdir/ref16.v" ushort
  # CDFs
  vips hist_find "$tmpdir/src16.v" "$tmpdir/src-h.v"
  vips hist_cum  "$tmpdir/src-h.v" "$tmpdir/src-hc.v"
  vips hist_norm "$tmpdir/src-hc.v" "$tmpdir/src-hn.v"
  vips hist_find "$tmpdir/ref16.v" "$tmpdir/ref-h.v"
  vips hist_cum  "$tmpdir/ref-h.v" "$tmpdir/ref-hc.v"
  vips hist_norm "$tmpdir/ref-hc.v" "$tmpdir/ref-hn.v"
  # Build LUT (already in index units 0..65535 for 16‑bit); cast and apply
  vips hist_match "$tmpdir/src-hn.v" "$tmpdir/ref-hn.v" "$tmpdir/lutf.v"
  vips cast "$tmpdir/lutf.v" "$tmpdir/lut16.v" ushort
  vips maplut "$tmpdir/src16.v" "$tmpdir/hm16.tif" "$tmpdir/lut16.v"
  matched_tiff="$tmpdir/hm16.tif"
  identify -quiet "$matched_tiff"

  echo "[ok] Histogram matched to ${JPG} -> ${matched_tiff}"

  # 3) Write 16-bit single-channel PNG and max-compress
  echo "[info] Writing final PNG ${out_png} ..."
  magick -quiet "$matched_tiff" -unsharp 0x0.7+0.75+0 -colorspace Gray -alpha off \
    -define png:color-type=0 -define png:bit-depth=16 -define png:compression-level=9 \
    -strip "${out_png}"
  identify -quiet "$out_png"

  # echo "[info] Optimizing PNG ${out_png} ..."
  # oxipng -o max --zopfli --strip all "$out_png"
  # optipng -o7 -strip all "$out_png"
  echo "[ok] Wrote ${out_png}"

  # 4) Copy EXIF/ICC metadata from DNG (do this AFTER optimizing)
  echo "[info] Copying EXIF/ICC from ${DNG} to ${out_png} ..."
  exiftool -TagsFromFile "$DNG" -overwrite_original \
    -All:All -icc_profile -Orientation "$out_png" >/dev/null || \
    echo "[warn] EXIF copy failed (non-fatal)"
  identify -quiet "$out_png"

  echo "[info] Cleaning up temporary files ..."
  rm -rf "$tmpdir"
  echo "[done] Finished ${base}"
done
echo "[all done]"
