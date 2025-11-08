#!/usr/bin/env bash
set -euo pipefail

echo "=== 1) Currently tracked files that match ignore rules ==="
# Tracked AND matched by .gitignore/.git/info/exclude/global ignores:
git ls-files -ci --exclude-standard || true
echo

echo "=== 2) Historical audit for ignored/sensitive files ==="

# List of patterns to audit (from your .gitignore)
PATTERNS=(
  # Flutter/Dart
  ".dart_tool/**"
  ".packages"
  ".pub-cache/**"
  ".pub/**"
  "build/**"
  ".flutter-plugins"
  ".flutter-plugins-dependencies"
  ".melos_tool/**"
  "coverage/**"
  "*.iml"

  # Android
  "**/android/.gradle/**"
  "**/android/captures/**"
  "**/android/local.properties"
  "**/android/**/GeneratedPluginRegistrant.java"
  "**/android/app/**/output.json"
  "**/android/app/build/**"
  "**/android/build/**"
  "**/android/app/*.keystore"
  "**/android/app/*.jks"
  "**/android/key.properties"
  "**/android/app/src/main/assets/crashlytics-build.properties"

  # iOS
  "**/ios/Pods/**"
  "**/ios/.symlinks/**"
  "**/ios/Flutter/Flutter.podspec"
  "**/ios/Flutter/Generated.xcconfig"
  "**/ios/Flutter/ephemeral/**"
  "**/ios/Flutter/App.framework"
  "**/ios/Flutter/Flutter.framework"
  "**/ios/**/GeneratedPluginRegistrant.*"
  "**/ios/Runner.xcodeproj/project.xcworkspace/**"
  "**/ios/Runner.xcworkspace/**"
  "**/ios/Runner/GeneratedPluginRegistrant.*"
  "**/ios/build/**"
  "ios/Runner/GoogleService-Info.plist"

  # macOS
  "**/macos/Pods/**"
  "**/macos/Flutter/ephemeral/**"
  "**/macos/Runner.xcworkspace/**"

  # Windows
  "**/windows/flutter/ephemeral/**"

  # Linux
  "**/linux/flutter/ephemeral/**"

  # Web
  "**/web/flutter_service_worker.js"
  "**/web/flutter_service_worker.js.manifest"
  "**/web/flutter.js"
  "**/web/flutter_assets/**"

  # IDEs and Editors
  ".vscode/**"
  ".idea/**"
  "*.ipr"
  "*.iws"

  # Firebase / secrets
  "**/firebase-debug.log"
  "lib/firebase_options.dart"
  "android/app/google-services.json"

  # Environment files
  "*.env"
  ".env.*"
  ".envrc"

  # OS generated
  ".DS_Store"
  "Thumbs.db"

  # Fastlane
  "**/fastlane/report.xml"
  "**/fastlane/Preview.html"
  "**/fastlane/screenshots/**"
  "**/fastlane/test_output/**"

  # Crashlytics/perf (duplicate included intentionally)
  "**/android/app/src/main/assets/crashlytics-build.properties"

  # Local dev tools
  "devtools_options.yaml"
)

# Function: find the FIRST commit that added a pathspec (if any)
first_commit_for() {
  local spec="$1"
  # --diff-filter=A shows only additions; -n 1 gives the earliest by reversing order.
  # We reverse the log so earliest is first, then pick one.
  git log --all --reverse --date=short --pretty=format:'%h|%ad|%an|%s' --diff-filter=A -- "$spec" 2>/dev/null | head -n 1
}

# Function: check if the pathspec ever appeared in history at all
ever_in_history() {
  local spec="$1"
  # --name-only to show file paths touched; grep to confirm any match.
  git log --all --name-only --pretty=format: -- "$spec" 2>/dev/null | head -n 1
}

# Report header
printf "%-55s | %-6s | %s\n" "PATTERN" "STATUS" "DETAILS"
printf -- "--------------------------------------------------------------------------\n"

for p in "${PATTERNS[@]}"; do
  if out="$(ever_in_history "$p")" && [[ -n "${out:-}" ]]; then
    fc="$(first_commit_for "$p")"
    if [[ -n "$fc" ]]; then
      hash="${fc%%|*}"; rest="${fc#*|}"
      date="${rest%%|*}"; rest2="${rest#*|}"
      author="${rest2%%|*}"; msg="${rest2#*|}"
      printf "%-55s | %-6s | first added in %s (%s) by %s — %s\n" "$p" "FOUND" "$hash" "$date" "$author" "$msg"
    else
      # Found in history, but couldn't isolate first-add commit (e.g., renames). Show any touching commit:
      any="$(git log --all --date=short --pretty=format:'%h (%ad) %an — %s' -- "$p" 2>/dev/null | tail -n 1)"
      printf "%-55s | %-6s | seen in history; e.g., %s\n" "$p" "FOUND" "${any:-unknown}"
    fi
  else
    printf "%-55s | %-6s | %s\n" "$p" "PASS" "no matches in history"
  fi
done

echo
echo "Tip: If anything sensitive was ever committed (e.g., *.jks, key.properties, google-services.json, GoogleService-Info.plist, .env), rotate those credentials and purge history if needed."
