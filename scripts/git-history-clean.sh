#!/usr/bin/env bash
set -euo pipefail

echo "=== 1) Currently tracked files that match ignore rules ==="
# Shows tracked files that are now ignored by .gitignore / exclude
git ls-files -ci --exclude-standard || true
echo

echo "=== 2) Historical audit for ignored/sensitive files ==="

# Patterns aligned with your current .gitignore
PATTERNS=(
  # -----------------------------
  # Flutter / Dart
  # -----------------------------
  ".dart_tool/**"
  ".packages"
  ".pub/**"
  ".pub-cache/**"
  ".melos_tool/**"
  ".flutter-plugins"
  ".flutter-plugins-dependencies"
  ".metadata"
  "coverage/**"
  "build/**"
  ".buildlog/**"
  "*.iml"
  "flutter_*.log"
  ".fvm/**"

  # -----------------------------
  # Android
  # -----------------------------
  "**/android/.gradle/**"
  "**/android/.cxx/**"
  "**/android/captures/**"
  "**/android/local.properties"
  "**/android/**/GeneratedPluginRegistrant.java"
  "**/android/build/**"
  "**/android/app/build/**"
  "**/android/app/**/output.json"
  ".gradle/**"  # root gradle cache

  # Signing / Security
  "**/android/app/*.keystore"
  "**/android/app/*.jks"
  "**/android/key.properties"
  "*.keystore"
  "*.jks"

  # Crashlytics / Native Symbols
  "**/android/app/src/main/assets/crashlytics-build.properties"
  "**/android/app/src/main/assets/native-debug-symbols/**"

  # -----------------------------
  # iOS
  # -----------------------------
  "**/ios/Pods/**"
  "**/ios/.symlinks/**"
  "**/ios/Flutter/ephemeral/**"
  "**/ios/Flutter/App.framework"
  "**/ios/Flutter/Flutter.framework"
  "**/ios/Flutter/Generated.xcconfig"
  "**/ios/Flutter/Flutter.podspec"
  "**/ios/**/GeneratedPluginRegistrant.*"
  "**/ios/build/**"
  "**/ios/Flutter/.last_build_id"
  "**/ios/DerivedData/**"

  # Xcode user noise
  "**/ios/Runner.xcworkspace/**"
  "**/ios/Runner.xcodeproj/project.xcworkspace/**"
  "**/ios/Runner.xcodeproj/xcuserdata/**"
  "**/ios/Runner.xcworkspace/xcuserdata/**"
  "*.xcuserstate"

  # Firebase iOS
  "ios/Runner/GoogleService-Info.plist"

  # -----------------------------
  # macOS
  # -----------------------------
  "**/macos/Pods/**"
  "**/macos/Flutter/ephemeral/**"
  "**/macos/Runner.xcworkspace/**"
  "**/macos/**/GeneratedPluginRegistrant.*"

  # -----------------------------
  # Windows
  # -----------------------------
  "**/windows/flutter/ephemeral/**"
  "**/windows/**/generated_plugin_registrant.*"

  # -----------------------------
  # Linux
  # -----------------------------
  "**/linux/flutter/ephemeral/**"
  "**/linux/**/generated_plugin_registrant.*"

  # -----------------------------
  # Web
  # -----------------------------
  "**/web/flutter_service_worker.js"
  "**/web/flutter_service_worker.js.manifest"
  "**/web/flutter.js"
  "**/web/flutter_assets/**"
  "**/web/**/generated_plugin_registrant.dart"
  "build/web/**"

  # -----------------------------
  # Firebase / Secrets
  # -----------------------------
  "**/firebase-debug.log"
  "lib/firebase_options.dart"
  "android/app/google-services.json"
  "*.env"
  ".env.*"
  ".envrc"

  # -----------------------------
  # IDE / Editor
  # -----------------------------
  ".vscode/**"
  ".idea/**"
  ".fleet/**"
  "*.ipr"
  "*.iws"

  # -----------------------------
  # OS Garbage
  # -----------------------------
  ".DS_Store"
  "**/.DS_Store"
  "Thumbs.db"

  # -----------------------------
  # Fastlane
  # -----------------------------
  "**/fastlane/report.xml"
  "**/fastlane/Preview.html"
  "**/fastlane/screenshots/**"
  "**/fastlane/test_output/**"

  # -----------------------------
  # Local Dev Tool Configs
  # -----------------------------
  "devtools_options.yaml"

  # -----------------------------
  # Misc Safety
  # -----------------------------
  "*.orig"
  "*.lock.json"
)

first_commit_for() {
  local spec="$1"
  git log --all --reverse --date=short --pretty=format:'%h|%ad|%an|%s' --diff-filter=A -- "$spec" 2>/dev/null | head -n 1
}

ever_in_history() {
  local spec="$1"
  git log --all --name-only --pretty=format: -- "$spec" 2>/dev/null | head -n 1
}

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
      any="$(git log --all --date=short --pretty=format:'%h (%ad) %an — %s' -- "$p" 2>/dev/null | tail -n 1)"
      printf "%-55s | %-6s | seen in history; e.g., %s\n" "$p" "FOUND" "${any:-unknown}"
    fi
  else
    printf "%-55s | %-6s | %s\n" "$p" "PASS" "no matches in history"
  fi
done

echo
echo "✅ Done. If sensitive files ever appear in history, ROTATE credentials and consider a history rewrite."
