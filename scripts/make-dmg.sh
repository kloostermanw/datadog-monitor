#!/bin/bash
# Build a Release datadog-monitor.app and package it into a drag-to-Applications .dmg.
# Usage: scripts/make-dmg.sh
set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="datadog-monitor"
SCHEME="datadog-monitor"
DERIVED="build-release"
DMG_OUT="$APP_NAME.dmg"

# Sign ad hoc. The Xcode project uses automatic signing with an Apple
# Development certificate, which only runs on the developer's own Macs and
# breaks the build when it expires. An ad hoc signature is enough for a
# sandboxed app downloaded from GitHub (Gatekeeper treats both the same).
ADHOC_SIGNING=(
  CODE_SIGN_STYLE=Manual
  CODE_SIGN_IDENTITY="-"
  DEVELOPMENT_TEAM=""
  PROVISIONING_PROFILE_SPECIFIER=""
  CODE_SIGNING_REQUIRED=YES
  CODE_SIGNING_ALLOWED=YES
)

echo "==> Building Release"
xcodebuild -scheme "$SCHEME" -configuration Release -destination 'platform=macOS' \
  -derivedDataPath "$DERIVED" "${ADHOC_SIGNING[@]}" build >/dev/null \
  || { echo "build failed: rerun without >/dev/null to see the xcodebuild error" >&2; exit 1; }

APP_PATH="$DERIVED/Build/Products/Release/$APP_NAME.app"
[ -d "$APP_PATH" ] || { echo "build failed: $APP_PATH missing" >&2; exit 1; }

# The app is sandboxed, so it must carry a valid signature or macOS will not
# launch it. Refuse to ship if signing did not happen.
echo "==> Checking the signature"
codesign --verify --deep --strict "$APP_PATH" \
  || { echo "refusing to package an unsigned app: check the ADHOC_SIGNING overrides above" >&2; exit 1; }

echo "==> Staging disk-image contents"
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT
cp -R "$APP_PATH" "$STAGING/"
ln -s /Applications "$STAGING/Applications"   # drag-target for the user

echo "==> Creating $DMG_OUT"
rm -f "$DMG_OUT"
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$STAGING" \
  -fs HFS+ \
  -format UDZO \
  -ov \
  "$DMG_OUT" >/dev/null

echo "==> Done: $(pwd)/$DMG_OUT"
