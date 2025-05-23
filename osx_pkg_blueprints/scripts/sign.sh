#!/bin/bash

set -euo pipefail

# Check pkg input
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/component.pkg"
  exit 1
fi

PKG_INPUT="$1"
if [[ ! -f "$PKG_INPUT" ]]; then
  echo "❌ Error: File not found: $PKG_INPUT"
  exit 1
fi

# Build list of Developer ID Installer certs
CERT_LIST=$(security find-identity -p basic -v | grep "Developer ID Installer")
if [[ -z "$CERT_LIST" ]]; then
  echo "❌ No Developer ID Installer certificates found in keychain."
  exit 1
fi

# Save certs to a temporary file
TMP_CERTS=$(mktemp)
INDEX=1
echo "$CERT_LIST" | while read -r line; do
  CERT_NAME=$(echo "$line" | sed -E 's/^ *[0-9]+\) [A-F0-9]+ "(.*)"/\1/')
  echo "$CERT_NAME" >> "$TMP_CERTS"
  echo "  $INDEX) $CERT_NAME"
  INDEX=$((INDEX + 1))
done

echo ""
read -r -p "Select a certificate number: " CHOICE

# Validate and retrieve the cert
SELECTED_CERT=$(sed -n "${CHOICE}p" "$TMP_CERTS")
rm "$TMP_CERTS"

if [[ -z "$SELECTED_CERT" ]]; then
  echo "❌ Invalid selection."
  exit 1
fi

# Variables for wrapping
PKG_DIR=$(dirname "$PKG_INPUT")
PKG_BASENAME=$(basename "$PKG_INPUT" .pkg)
PKG_FINAL="${PKG_DIR}/${PKG_BASENAME}-wrapped.pkg"
IDENTIFIER="com.mozilla.${PKG_BASENAME//_/.}"  # e.g. com.mozilla.p.role.gecko...
VERSION="1.0"

echo "📦 Wrapping component package with productbuild..."
productbuild \
  --identifier "$IDENTIFIER" \
  --version "$VERSION" \
  --package "$PKG_INPUT" \
  --sign "$SELECTED_CERT" \
  "$PKG_FINAL"

echo "🔍 Verifying final signed package..."
spctl -a -vv -t install "$PKG_FINAL"

echo "✅ Signed MDM-compatible package saved to:"
echo "    $PKG_FINAL"