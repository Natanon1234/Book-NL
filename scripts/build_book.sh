#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build}"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist}"
PACKAGE_DIR="$BUILD_DIR/package"
LOG_DIR="$BUILD_DIR/logs"

rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR" "$PACKAGE_DIR/chapters" "$LOG_DIR"

assert_pdf() {
  local pdf="$1"
  if [[ ! -s "$pdf" ]]; then
    echo "Expected a non-empty PDF at: $pdf" >&2
    exit 1
  fi
  if [[ "$(head -c 5 "$pdf")" != "%PDF-" ]]; then
    echo "File is not a valid PDF: $pdf" >&2
    exit 1
  fi
}

compile_tex() {
  local source="$1"
  local destination="$2"
  local source_dir
  local filename
  local stem
  local pdf_path
  local log_path
  local log_destination

  source_dir="$(dirname "$source")"
  filename="$(basename "$source")"
  stem="${filename%.tex}"
  pdf_path="$source_dir/$stem.pdf"
  log_path="$source_dir/$stem.log"
  log_destination="$LOG_DIR/$source_dir/$stem.log"

  mkdir -p "$(dirname "$destination")" "$(dirname "$log_destination")"

  echo "::group::XeLaTeX: $source"
  (
    cd "$ROOT_DIR/$source_dir"
    # Compile in the source directory. The book's standalone wrappers calculate
    # relative paths from here; an external output directory can shadow those
    # checks and point image lookups at the wrong location.
    latexmk \
      -cd \
      -xelatex \
      -interaction=nonstopmode \
      -halt-on-error \
      -file-line-error \
      "$filename"
  )
  echo "::endgroup::"

  assert_pdf "$ROOT_DIR/$pdf_path"
  if [[ ! -s "$ROOT_DIR/$log_path" ]]; then
    echo "Expected a XeLaTeX log at: $ROOT_DIR/$log_path" >&2
    exit 1
  fi

  cp "$ROOT_DIR/$pdf_path" "$destination"
  cp "$ROOT_DIR/$log_path" "$log_destination"

  # Remove auxiliary files without deleting the PDF that has just been copied.
  (
    cd "$ROOT_DIR/$source_dir"
    latexmk -c "$filename" >/dev/null
  )

  # Some legacy source PDFs are tracked placeholders. Restore tracked files;
  # remove only PDFs created by this build from untracked source directories.
  if git ls-files --error-unmatch -- "$pdf_path" >/dev/null 2>&1; then
    git restore --worktree -- "$pdf_path"
  else
    rm -f "$ROOT_DIR/$pdf_path"
  fi
}

echo "Building the complete book..."
compile_tex "main.tex" "$DIST_DIR/Book-NL.pdf"

echo "Building every numbered main-book chapter..."
mapfile -t MAIN_CHAPTERS < <(
  find chapters -maxdepth 1 -type f -name 'chapter[0-9]*.tex' -print | sort -V
)
if [[ "${#MAIN_CHAPTERS[@]}" -eq 0 ]]; then
  echo "No numbered main-book chapter sources were found." >&2
  exit 1
fi

for source in "${MAIN_CHAPTERS[@]}"; do
  chapter_name="$(basename "${source%.tex}")"
  compile_tex "$source" "$PACKAGE_DIR/chapters/$chapter_name.pdf"
done

echo "Building each standalone appendix chapter/topic..."
mapfile -d '' APPENDIX_SOURCES < <(
  find appendices -type f -name '*.tex' -print0 | sort -z
)
APPENDIX_COUNT=0
for source in "${APPENDIX_SOURCES[@]}"; do
  filename="$(basename "$source")"
  case "$filename" in
    *volume.tex|chapter-template.tex|review-notes-standalone.tex)
      continue
      ;;
  esac

  relative_path="${source#appendices/}"
  relative_stem="${relative_path%.tex}"
  compile_tex "$source" "$PACKAGE_DIR/appendices/chapters/$relative_stem.pdf"
  APPENDIX_COUNT=$((APPENDIX_COUNT + 1))
done

if [[ "$APPENDIX_COUNT" -eq 0 ]]; then
  echo "No standalone appendix chapter sources were found." >&2
  exit 1
fi

echo "Building the combined appendix collection and each appendix volume..."
APPENDIX_VOLUMES=(
  "appendices/appendix-volume.tex"
  "appendices/appendix 1-Physiology/physiology-volume.tex"
  "appendices/appendix 2-Pharmacology/pharmacology-volume.tex"
  "appendices/appendix 3-Medical Microbiology and Immunology/medical-microbiology-volume.tex"
  "appendices/appendix 4-Review Notes/review-notes-volume.tex"
)
for source in "${APPENDIX_VOLUMES[@]}"; do
  volume_name="$(basename "${source%.tex}")"
  compile_tex "$source" "$PACKAGE_DIR/appendices/volumes/$volume_name.pdf"
done

# Fail on unresolved citations/references or duplicate labels, even if TeX exits
# successfully. Layout warnings remain in the stored logs for review.
if grep -R -n -E \
  'There were undefined references|(Citation|Reference) .*undefined|Label .* multiply defined' \
  "$LOG_DIR" --include='*.log'; then
  echo "The build contains unresolved references/citations or duplicate labels." >&2
  exit 1
fi

cat > "$PACKAGE_DIR/README.txt" <<'PACKAGE_README'
Book NL — standalone PDF package

chapters/
  One PDF for each numbered main-book chapter.

appendices/chapters/
  Standalone appendix chapter/topic PDFs, preserving the source appendix
  directory structure.

appendices/volumes/
  The combined appendix collection and the four individual appendix volumes.

The complete book, including front matter, main chapters, appendices,
bibliography, and index, is distributed separately as Book-NL.pdf.
PACKAGE_README

EXPECTED_PDFS=$((${#MAIN_CHAPTERS[@]} + APPENDIX_COUNT + ${#APPENDIX_VOLUMES[@]}))
ACTUAL_PDFS="$(find "$PACKAGE_DIR" -type f -name '*.pdf' | wc -l | tr -d ' ')"
if [[ "$ACTUAL_PDFS" -ne "$EXPECTED_PDFS" ]]; then
  echo "Package PDF count mismatch: expected $EXPECTED_PDFS, found $ACTUAL_PDFS." >&2
  exit 1
fi

(
  cd "$BUILD_DIR"
  zip -q -r -9 "$DIST_DIR/Book-NL-chapters-and-appendices.zip" package
)
unzip -t "$DIST_DIR/Book-NL-chapters-and-appendices.zip"
assert_pdf "$DIST_DIR/Book-NL.pdf"
test -s "$DIST_DIR/Book-NL-chapters-and-appendices.zip"

echo
echo "Build package created successfully:"
echo "  $DIST_DIR/Book-NL.pdf"
echo "  $DIST_DIR/Book-NL-chapters-and-appendices.zip"
echo "  Main chapters: ${#MAIN_CHAPTERS[@]}"
echo "  Appendix chapter/topic PDFs: $APPENDIX_COUNT"
echo "  Appendix volumes: ${#APPENDIX_VOLUMES[@]}"
echo "  PDFs inside ZIP: $ACTUAL_PDFS"
