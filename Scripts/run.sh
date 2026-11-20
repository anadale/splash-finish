#!/usr/bin/env bash
# Build a local development copy in build/ and start it, like the other bobuk-io apps.
# Development builds are ad-hoc signed and not notarized. Set SPLASH_FINISH_HOME=/tmp/... to keep
# your real inbox in ~/Library/Application Support/Splash Finish untouched.
#   Scripts/run.sh [debug|release]
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
APP="$ROOT/build/Splash Finish.app"
EXECUTABLE="$APP/Contents/MacOS/SplashFinish"

# Ask a running development copy to quit; never force-kill it.
if pgrep -f -x "$EXECUTABLE" >/dev/null; then
  osascript -e "tell application \"$APP\" to quit" >/dev/null 2>&1 || true
  for _ in {1..30}; do
    pgrep -f -x "$EXECUTABLE" >/dev/null || break
    sleep 0.2
  done
  if pgrep -f -x "$EXECUTABLE" >/dev/null; then
    echo "The development copy of Splash Finish did not quit; quit it from the menu bar and try again." >&2
    exit 1
  fi
fi

SIGNING_MODE=adhoc ARCHES=$(uname -m) "$ROOT/Scripts/package_app.sh" "${1:-debug}"
if [[ -n "${SPLASH_FINISH_HOME:-}" ]]; then
  # `open` does not pass the environment; start the executable directly instead.
  SPLASH_FINISH_HOME="$SPLASH_FINISH_HOME" "$EXECUTABLE" >/dev/null 2>&1 &
  disown
else
  open "$APP"
fi
echo "Splash Finish started in the menu bar."
