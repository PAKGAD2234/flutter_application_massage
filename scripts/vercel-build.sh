#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${GEMINI_API_KEY:-}" ]]; then
  echo "Missing GEMINI_API_KEY. Add it to the Vercel project's Environment Variables."
  exit 1
fi

if command -v flutter >/dev/null 2>&1; then
  FLUTTER_BIN="$(command -v flutter)"
else
  FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/flutter}"
  FLUTTER_BIN="$FLUTTER_ROOT/bin/flutter"

  if [[ ! -x "$FLUTTER_BIN" ]]; then
    git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$FLUTTER_ROOT"
  fi

  export PATH="$FLUTTER_ROOT/bin:$PATH"
fi

"$FLUTTER_BIN" config --no-analytics
"$FLUTTER_BIN" pub get
"$FLUTTER_BIN" build web \
  --release \
  --dart-define="GEMINI_API_KEY=$GEMINI_API_KEY"
