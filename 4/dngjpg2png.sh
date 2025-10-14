#!/bin/bash
# dng2png_match.sh — match a DNG to its JPG look but keep lossless 16-bit grayscale PNG
# Usage: ./dng2png_match.sh xyz [abc ...]    # looks for xyz.DNG and xyz.JPG; writes xyz.png
# COMPRESS=''|'oxipng'|'optipng'             # set to choose PNG optimizer; default: none
# NR=1                                       # set to enable noise reduction; default: off
# NOSHARP=1                                  # set to disable unsharp mask; default: on
set -eo pipefail

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 2; }; }

# Always needed
need magick
need vips
need exiftool
need identify
need rawtherapee-cli
if [ "${COMPRESS}" = "oxipng" ]
then
  need oxipng
fi
if [ "${COMPRESS}" = "optipng" ]
then
  need optipng
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
  ISO="$(exiftool -s -s -s -n -ISO "$DNG" 2>/dev/null || echo 0)"
  if [[ -z "$ISO" ]]; then ISO=0; fi
  echo "[info] Processing ${DNG} (ISO: ${ISO}) ..."
  if (( ISO > 100000 )); then
    PP3="/usr/share/rawtherapee/profiles/Auto-Matched Curve - ISO High.pp3"
  else
    PP3="/usr/share/rawtherapee/profiles/Auto-Matched Curve - ISO Low.pp3"
  fi

  # Resolve JPG (case-insensitive); we use it to match tones
  JPG=""; for ext in JPG jpg JPEG jpeg Jpg Jpeg; do [ -e "${base}.${ext}" ] && JPG="${base}.${ext}" && break; done
  if [ -z "$JPG" ]; then
    echo "[skip] No JPG for ${base}"
    continue
  fi
  echo "[info] Using JPG ${JPG:-<none>}"

  out_png="${base}.png"
  tmpdir="${base}.tmp"
  if [ -d "${tmpdir}" ]
  then
    echo "[fail] Temporary directory ${tmpdir} already exists; please remove it and try again."
    continue
  fi
  mkdir -p "$tmpdir"
  if [ -z "${NR}" ]
  then
    # Partial PP3 to *disable* all sharpening / NR (overlay on top of AMTC profile)
    no_nr_pp3="$tmpdir/noNR.pp3"
    cat > "$no_nr_pp3" <<'PP3'
[Directional Pyramid Denoising]
Enabled=false
[Impulse Denoising]
Enabled=false
PP3
  fi

  # Force NO demosaic (Mono) for monochrome RAW; keeps photosite detail, no RGB interpolation
  no_demosaic_pp3="$tmpdir/noDemosaic.pp3"
  cat > "$no_demosaic_pp3" <<'PP3'
[RAW Bayer]
Method=mono
[RAW]
CA=false
HotPixelFilter=false
DeadPixelFilter=false
PP3

  outdir="$tmpdir/rt"; mkdir -p "$outdir"
  echo "[info] Using RawTherapee profile: $PP3"
  if [ -z "${NR}" ]
  then
    rawtherapee-cli -b16 -tz -o "$outdir" -p "$PP3" -p "$no_demosaic_pp3" -p "$no_nr_pp3" -Y -c "$DNG"
  else
    rawtherapee-cli -b16 -tz -o "$outdir" -p "$PP3" -p "$no_demosaic_pp3" -Y -c "$DNG"
  fi
  tiff="$(find "$outdir" -type f \( -name '*.tif' -o -name '*.tiff' \) | head -n1)"
  [ -z "${tiff:-}" ] && { echo "[fail] Could not produce TIFF for ${base}"; rm -rf "$tmpdir"; continue; }
  echo "[ok] Produced intermediate TIFF ${tiff}"
  identify -quiet "$tiff"
  # Collapse RT's 3 identical channels to a true single-channel 16‑bit TIFF
  vips extract_band "$tiff" "$tmpdir/rt_gray.v" 0
  vips cast "$tmpdir/rt_gray.v" "$tmpdir/rt_gray16.tif" ushort
  tiff="$tmpdir/rt_gray16.tif"
  echo "[ok] Collapsed to single-channel ${tiff}"
  identify -quiet "$tiff"

  # LG: hard part
  # 2) Tone-guide from JPG (hint only): estimate gamma + gain/offset from stats, keep full 16-bit range
  echo "[info] Guiding tones from ${JPG} (gamma + gain/offset)…"
  ref_gray="$tmpdir/ref-gray.png"
  magick -quiet "$JPG" -colorspace Gray -alpha off -define png:color-type=0 -define png:bit-depth=16 "${ref_gray}"
  identify -quiet "$ref_gray"
  # Stats (normalized 0..1)
  SRC_MEAN=$(magick -quiet "$tiff" -colorspace Gray -alpha off -define png:color-type=0 -define png:bit-depth=16 -format "%[fx:mean]" info:)
  SRC_STD=$(magick -quiet "$tiff" -colorspace Gray -alpha off -define png:color-type=0 -define png:bit-depth=16 -format "%[fx:standard_deviation]" info:)
  REF_MEAN=$(magick -quiet "$ref_gray" -format "%[fx:mean]" info:)
  REF_STD=$(magick -quiet "$ref_gray" -format "%[fx:standard_deviation]" info:)
  # Compute exponent a for y = x^a to align midtones approximately
  GAMMA=$(awk -v r="$REF_MEAN" -v s="$SRC_MEAN" 'BEGIN{e=1e-6; if(s<e)s=e; if(r<e)r=e; g=log(r)/log(s); if(g<0.4)g=0.4; if(g>2.5)g=2.5; print g}')
  echo "[info] src_mean=$SRC_MEAN ref_mean=$REF_MEAN -> gamma(exponent)=$GAMMA"
  # Apply gamma in 16-bit, then compute gain/offset to match global contrast & mean
  magick -quiet "$tiff" -colorspace Gray -alpha off -evaluate Pow "$GAMMA" "$tmpdir/gamma.tif"
  G_MEAN=$(magick -quiet "$tmpdir/gamma.tif" -colorspace Gray -alpha off -define png:color-type=0 -define png:bit-depth=16 -format "%[fx:mean]" info:)
  G_STD=$(magick -quiet "$tmpdir/gamma.tif" -colorspace Gray -alpha off -define png:color-type=0 -define png:bit-depth=16 -format "%[fx:standard_deviation]" info:)
  SCALE=$(awk -v rr="$REF_STD" -v ss="$G_STD" 'BEGIN{e=1e-12; if(ss<e)ss=e; s=rr/ss; if(s<0.5)s=0.5; if(s>2.0)s=2.0; print s}')
  OFFSET=$(awk -v rm="$REF_MEAN" -v sm="$G_MEAN" -v sc="$SCALE" 'BEGIN{ off=rm - sc*sm; print off }')
  echo "[info] gamma_mean=$G_MEAN ref_std=$REF_STD gamma_std=$G_STD -> scale=$SCALE offset=$OFFSET"
  magick -quiet "$tmpdir/gamma.tif" -evaluate Multiply "$SCALE" -evaluate Add "$OFFSET" -clamp -colorspace Gray -alpha off "$tmpdir/tone.tif"
  matched_tiff="$tmpdir/tone.tif"
  identify -quiet "$matched_tiff"
  echo "[ok] Tone guided by JPG -> ${matched_tiff}"

  # 3) Write 16-bit single-channel PNG and max-compress
  if [ -z "$NOSHARP" ]
  then
    magick -quiet "$matched_tiff" -unsharp 0x0.8+0.8+2% -colorspace Gray -alpha off \
      -define png:color-type=0 -define png:bit-depth=16 -define png:compression-level=9 \
      -strip "${out_png}"
  else
    magick -quiet "$matched_tiff" -colorspace Gray -alpha off \
      -define png:color-type=0 -define png:bit-depth=16 -define png:compression-level=9 \
      -strip "${out_png}"
  fi
  echo "[ok] Wrote ${out_png}"
  identify -quiet "$out_png"

  if [ -z "${COMPRESS}" ]
  then
    echo "[info] Skipping PNG optimization"
  fi
  if [ "${COMPRESS}" = "oxipng" ]
  then
    echo "[info] Optimizing PNG with oxipng ..."
    oxipng -o max --zopfli --strip all "$out_png"
    echo "[ok] Optimized ${out_png} with oxipng"
    identify -quiet "$out_png"
  fi
  if [ "${COMPRESS}" = "optipng" ]
  then
    echo "[info] Optimizing PNG with optipng ..."
    optipng -o7 -strip all "$out_png"
    echo "[ok] Optimized ${out_png} with optipng"
    identify -quiet "$out_png"
  fi

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
