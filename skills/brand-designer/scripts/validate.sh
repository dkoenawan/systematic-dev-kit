#!/usr/bin/env bash
# validate.sh — Validates brand-designer output files
#
# Usage: bash scripts/validate.sh [brand-dir]
#   brand-dir: path to the brand/ directory (default: ./brand)
#
# Checks:
#   1. Required files exist
#   2. No placeholder syntax remains in output
#   3. CSS custom properties use valid HSL format
#   4. Type scale follows a mathematical ratio
#   5. Google Fonts are real (requires network)
#   6. WCAG contrast ratio for key text/background pairs
#   7. Tailwind config is syntactically valid (if present)

set -euo pipefail

BRAND_DIR="${1:-./brand}"
ERRORS=0
WARNINGS=0

# --- Helpers ---

red()    { printf '\033[0;31m%s\033[0m\n' "$1"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$1"; }
green()  { printf '\033[0;32m%s\033[0m\n' "$1"; }
bold()   { printf '\033[1m%s\033[0m\n' "$1"; }

fail() {
  red "  FAIL: $1"
  ERRORS=$((ERRORS + 1))
}

warn() {
  yellow "  WARN: $1"
  WARNINGS=$((WARNINGS + 1))
}

pass() {
  green "  PASS: $1"
}

# --- Check 1: Required files exist ---

bold "Check 1: Required files"

if [ ! -d "$BRAND_DIR" ]; then
  fail "Brand directory not found: $BRAND_DIR"
  red "Cannot continue without brand directory."
  exit 1
fi

if [ -f "$BRAND_DIR/brand-guideline.md" ]; then
  pass "brand-guideline.md exists"
else
  fail "brand-guideline.md not found"
fi

if [ -f "$BRAND_DIR/brand-theme.css" ]; then
  pass "brand-theme.css exists"
else
  fail "brand-theme.css not found"
fi

if [ -f "$BRAND_DIR/tailwind.brand.js" ]; then
  pass "tailwind.brand.js exists (optional)"
else
  echo "  SKIP: tailwind.brand.js not found (optional, only if Tailwind was selected)"
fi

# --- Check 2: No leftover placeholders ---

bold ""
bold "Check 2: No placeholder syntax"

PLACEHOLDER_PATTERNS='\{[a-z_-]*\}|\{[A-Z_-]*\}|\{val\}|\{size\}|\{hex\}|\{hsl\}|\{h\}|\{s\}|\{l\}|\{Font\}|\{name\}|\{why\}|\{usage\}|\{weight\}|\{lh\}|\{ls\}|\{description\}|\{values\}|\{dark-val\}'

for file in "$BRAND_DIR"/*; do
  [ -f "$file" ] || continue
  filename=$(basename "$file")

  # grep -P for perl regex; fall back to -E
  if grep -Pn "$PLACEHOLDER_PATTERNS" "$file" 2>/dev/null | head -5; then
    fail "Placeholders found in $filename (see above)"
  elif grep -En '\{[a-z_-]+\}' "$file" 2>/dev/null | grep -v 'var(--' | grep -v 'cubic-bezier' | grep -v 'hsla\?' | grep -v '/\*' | grep -v 'url(' | head -5; then
    warn "Possible placeholders in $filename (review lines above)"
  else
    pass "No placeholders in $filename"
  fi
done

# --- Check 3: Valid HSL values in CSS ---

bold ""
bold "Check 3: CSS HSL format validation"

if [ -f "$BRAND_DIR/brand-theme.css" ]; then
  CSS_FILE="$BRAND_DIR/brand-theme.css"

  # Check that HSL values have numeric components (not placeholders)
  INVALID_HSL=$(grep -Pn 'hsl\([^)]*[a-zA-Z]{2,}[^)]*\)' "$CSS_FILE" 2>/dev/null | grep -v 'var(--' | grep -v 'hsla' | head -5 || true)
  if [ -n "$INVALID_HSL" ]; then
    fail "Invalid HSL values found in brand-theme.css:"
    echo "$INVALID_HSL"
  else
    pass "HSL values appear well-formed"
  fi

  # Check that CSS custom properties are defined (not empty)
  EMPTY_PROPS=$(grep -Pn '^\s*--[a-z].*:\s*;' "$CSS_FILE" 2>/dev/null | head -5 || true)
  if [ -n "$EMPTY_PROPS" ]; then
    fail "Empty CSS custom property values found:"
    echo "$EMPTY_PROPS"
  else
    pass "No empty custom property values"
  fi

  # Verify :root block exists
  if grep -q ':root' "$CSS_FILE"; then
    pass ":root block exists"
  else
    fail "No :root block found in brand-theme.css"
  fi

  # Verify dark mode exists
  if grep -q 'prefers-color-scheme: dark' "$CSS_FILE" || grep -q 'data-theme.*dark' "$CSS_FILE"; then
    pass "Dark mode styles found"
  else
    fail "No dark mode styles found — dark mode is required"
  fi
else
  echo "  SKIP: brand-theme.css not found"
fi

# --- Check 4: Type scale mathematical consistency ---

bold ""
bold "Check 4: Type scale consistency"

if [ -f "$BRAND_DIR/brand-theme.css" ]; then
  CSS_FILE="$BRAND_DIR/brand-theme.css"

  # Extract type scale values
  SIZES=()
  while IFS= read -r line; do
    val=$(echo "$line" | grep -oP '[0-9]+\.?[0-9]*(?=rem)' || true)
    if [ -n "$val" ]; then
      SIZES+=("$val")
    fi
  done < <(grep -P '^\s*--text-(display|h[1-4]|body-lg|body|body-sm|caption):' "$CSS_FILE" 2>/dev/null)

  if [ ${#SIZES[@]} -ge 4 ]; then
    # Check that sizes are in descending order
    SORTED=true
    for ((i=1; i<${#SIZES[@]}; i++)); do
      PREV=${SIZES[$((i-1))]}
      CURR=${SIZES[$i]}
      if [ "$(echo "$PREV < $CURR" | bc -l 2>/dev/null || echo 0)" = "1" ]; then
        SORTED=false
        break
      fi
    done

    if $SORTED; then
      pass "Type scale sizes are in descending order"
    else
      fail "Type scale sizes are NOT in descending order: ${SIZES[*]}"
    fi

    # Check ratio consistency (should be within ~10% of a constant ratio)
    if command -v bc &>/dev/null && [ ${#SIZES[@]} -ge 3 ]; then
      RATIO1=$(echo "scale=4; ${SIZES[0]} / ${SIZES[1]}" | bc -l 2>/dev/null || echo "0")
      RATIO2=$(echo "scale=4; ${SIZES[1]} / ${SIZES[2]}" | bc -l 2>/dev/null || echo "0")

      if [ "$RATIO1" != "0" ] && [ "$RATIO2" != "0" ]; then
        DIFF=$(echo "scale=4; ($RATIO1 - $RATIO2) / $RATIO1 * 100" | bc -l 2>/dev/null | sed 's/-//' || echo "999")
        DIFF_INT=$(printf "%.0f" "$DIFF" 2>/dev/null || echo "999")

        if [ "${DIFF_INT:-999}" -le 15 ]; then
          pass "Type scale ratio is roughly consistent (~${RATIO1}x)"
        else
          warn "Type scale ratios vary: ${RATIO1}x vs ${RATIO2}x (${DIFF_INT}% difference)"
        fi
      fi
    fi
  else
    warn "Could not extract enough type scale values to verify consistency (found ${#SIZES[@]})"
  fi
else
  echo "  SKIP: brand-theme.css not found"
fi

# --- Check 5: Google Fonts validation ---

bold ""
bold "Check 5: Google Fonts availability"

if [ -f "$BRAND_DIR/brand-theme.css" ]; then
  CSS_FILE="$BRAND_DIR/brand-theme.css"

  # Extract font names from --font-* properties
  FONTS=()
  while IFS= read -r line; do
    font=$(echo "$line" | grep -oP "'[^']+'" | head -1 | tr -d "'")
    if [ -n "$font" ]; then
      FONTS+=("$font")
    fi
  done < <(grep -P '^\s*--font-(heading|body|mono):' "$CSS_FILE" 2>/dev/null)

  if [ ${#FONTS[@]} -eq 0 ]; then
    warn "No font families found in CSS custom properties"
  else
    for font in "${FONTS[@]}"; do
      # URL-encode the font name
      ENCODED=$(echo "$font" | sed 's/ /+/g')
      if command -v curl &>/dev/null; then
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://fonts.googleapis.com/css2?family=${ENCODED}" 2>/dev/null || echo "000")
        if [ "$HTTP_CODE" = "200" ]; then
          pass "Google Font available: $font"
        elif [ "$HTTP_CODE" = "000" ]; then
          warn "Could not verify font (no network): $font"
        else
          fail "Google Font NOT found: $font (HTTP $HTTP_CODE)"
        fi
      else
        warn "curl not available — cannot verify Google Font: $font"
      fi
    done
  fi
else
  echo "  SKIP: brand-theme.css not found"
fi

# --- Check 6: WCAG contrast approximation ---

bold ""
bold "Check 6: WCAG contrast (approximate)"

# Extract HSL and convert to relative luminance for contrast check
# This is a simplified check — real validation should use a proper tool

if [ -f "$BRAND_DIR/brand-theme.css" ]; then
  CSS_FILE="$BRAND_DIR/brand-theme.css"

  # Extract background lightness and text lightness from light mode
  BG_L=$(grep -P '^\s*--color-bg:' "$CSS_FILE" | head -1 | grep -oP '\d+(?=%)' | tail -1 || echo "")
  TEXT_L=$(grep -P '^\s*--color-text:' "$CSS_FILE" | head -1 | grep -oP '\d+(?=%)' | tail -1 || echo "")

  if [ -n "$BG_L" ] && [ -n "$TEXT_L" ]; then
    # Rough contrast check: background should be high lightness, text should be low
    # For WCAG AA, we need ~4.5:1 ratio which roughly means >60% lightness difference
    DIFF=$((BG_L - TEXT_L))
    if [ "$DIFF" -lt 0 ]; then
      DIFF=$((-DIFF))
    fi

    if [ "$DIFF" -ge 50 ]; then
      pass "Light mode text/background lightness difference: ${DIFF}% (likely meets WCAG AA)"
    elif [ "$DIFF" -ge 35 ]; then
      warn "Light mode lightness difference is ${DIFF}% — may be borderline for WCAG AA. Verify with a contrast checker."
    else
      fail "Light mode lightness difference is only ${DIFF}% — likely fails WCAG AA. Needs more contrast."
    fi
  else
    warn "Could not extract background/text lightness values for contrast check"
  fi

  # Same check for dark mode
  DARK_SECTION=$(sed -n '/prefers-color-scheme: dark/,/}/p' "$CSS_FILE" 2>/dev/null || echo "")
  if [ -n "$DARK_SECTION" ]; then
    DARK_BG_L=$(echo "$DARK_SECTION" | grep -P '\s*--color-bg:' | head -1 | grep -oP '\d+(?=%)' | tail -1 || echo "")
    DARK_TEXT_L=$(echo "$DARK_SECTION" | grep -P '\s*--color-text:' | head -1 | grep -oP '\d+(?=%)' | tail -1 || echo "")

    if [ -n "$DARK_BG_L" ] && [ -n "$DARK_TEXT_L" ]; then
      DARK_DIFF=$((DARK_TEXT_L - DARK_BG_L))
      if [ "$DARK_DIFF" -lt 0 ]; then
        DARK_DIFF=$((-DARK_DIFF))
      fi

      if [ "$DARK_DIFF" -ge 50 ]; then
        pass "Dark mode text/background lightness difference: ${DARK_DIFF}% (likely meets WCAG AA)"
      elif [ "$DARK_DIFF" -ge 35 ]; then
        warn "Dark mode lightness difference is ${DARK_DIFF}% — may be borderline for WCAG AA."
      else
        fail "Dark mode lightness difference is only ${DARK_DIFF}% — likely fails WCAG AA."
      fi
    else
      warn "Could not extract dark mode background/text values"
    fi
  fi
else
  echo "  SKIP: brand-theme.css not found"
fi

# --- Check 7: Tailwind config syntax ---

bold ""
bold "Check 7: Tailwind config (if present)"

if [ -f "$BRAND_DIR/tailwind.brand.js" ]; then
  if command -v node &>/dev/null; then
    # Try to parse the JS file
    if node -e "require('./$BRAND_DIR/tailwind.brand.js')" 2>/dev/null; then
      pass "tailwind.brand.js is valid JavaScript (Node.js require succeeded)"
    else
      fail "tailwind.brand.js has syntax errors (Node.js require failed)"
    fi
  else
    warn "Node.js not available — cannot validate tailwind.brand.js syntax"
  fi
else
  echo "  SKIP: tailwind.brand.js not present"
fi

# --- Summary ---

bold ""
bold "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
  green "All checks passed!"
elif [ "$ERRORS" -eq 0 ]; then
  yellow "$WARNINGS warning(s), 0 errors"
else
  red "$ERRORS error(s), $WARNINGS warning(s)"
fi

bold "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit "$ERRORS"
