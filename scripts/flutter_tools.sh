#!/usr/bin/env bash
# ==============================================================================
# Ultimate Flutter Project Utility Script
#
# A clean, professional, two-column menu for all common Flutter tasks.
# 100% compatible with all terminals (including Android Studio).
#
# To use it:
# 1. Make it executable:  chmod +x flutter_tools.sh
# 2. Run it from anywhere in your project: ./flutter_tools.sh
# ==============================================================================

# --- Strict Mode ---
set -e
set -u
set -o pipefail

# --- Helper Functions (Plain Text) ---
function success_msg() {
    printf "\n%s\n" "[SUCCESS] $1"
}

function error_msg() {
    printf "\n%s\n" "[ERROR] $1"
}

function info_msg() {
    printf "\n%s\n" "[INFO] $1"
}

function warn_msg() {
    printf "\n%s\n" "[WARN] $1"
}

# Checks if a command exists in the user's PATH
function cmd_exists() {
    command -v "$1" &> /dev/null
}

# Finds the project root by searching upwards for pubspec.yaml
function find_project_root() {
    local dir
    dir=$(pwd)
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/pubspec.yaml" ]]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

# --- Project Root Setup ---
PROJECT_ROOT=$(find_project_root)
if [[ $? -ne 0 ]]; then
    error_msg "Could not find 'pubspec.yaml'. Are you in a Flutter project directory?"
    exit 1
fi
cd "$PROJECT_ROOT"

# --- Prerequisite Check ---
if ! cmd_exists flutter; then
    error_msg "Flutter SDK not found in your PATH. Please install Flutter to use this script."
    exit 1
fi

# ==============================================================================
# --- ACTION FUNCTIONS ---
# ==============================================================================

# --- 1. Dump Functions (with timestamp and dump/ folder) ---
function create_dump_dir() {
    if [[ ! -d "dump" ]]; then
        info_msg "Creating 'dump/' directory..."
        mkdir "dump"
    fi
}

function dump_dart_files() {
    create_dump_dir
    local timestamp
    timestamp=$(date +"%Y%m%d-%H%M%S")
    local output_file="dump/all_dart_files-${timestamp}.txt"

    info_msg "Dumping all .dart files (excluding build/ and .dart_tool/)..."
    find . -path ./build -prune -o -path ./.dart_tool -prune -o -name "*.dart" -exec sh -c 'echo "\n==> {} <=="; cat {}' \; > "$output_file"
    success_msg "All .dart files dumped to $output_file"
}

function dump_pubspec() {
    create_dump_dir
    local timestamp
    timestamp=$(date +"%Y%m%d-%H%M%S")
    local output_file="dump/pubspec_dump-${timestamp}.txt"

    info_msg "Dumping pubspec.yaml..."
    cat pubspec.yaml > "$output_file"
    success_msg "pubspec.yaml dumped to $output_file"
}

function dump_gitignore() {
    if [[ ! -f ".gitignore" ]]; then
        error_msg ".gitignore not found."
        return
    fi
    create_dump_dir
    local timestamp
    timestamp=$(date +"%Y%m%d-%H%M%S")
    local output_file="dump/gitignore_dump-${timestamp}.txt"

    info_msg "Dumping .gitignore..."
    cat .gitignore > "$output_file"
    success_msg ".gitignore dumped to $output_file"
}

function dump_git_ignored_status() {
    if ! cmd_exists git; then
        error_msg "'git' command not found."
        return
    fi
    create_dump_dir
    local timestamp
    timestamp=$(date +"%Y%m%d-%H%M%S")
    local output_file="dump/git_ignored_status-${timestamp}.txt"

    info_msg "Dumping git status --ignored..."
    git status --ignored > "$output_file"
    success_msg "Ignored files list dumped to $output_file"
}

function dump_tree() {
    if ! cmd_exists tree; then
        error_msg "'tree' command not found. Please install it ('brew install tree') to use this feature."
        return
    fi
    create_dump_dir
    local timestamp
    timestamp=$(date +"%Y%m%d-%H%M%S")
    local output_file="dump/project_tree-${timestamp}.txt"

    info_msg "Dumping project tree (ignoring .git, .idea, .dart_tool, build)..."
    # Use -o to write directly to file, which preserves line-drawing characters
    # Use -I to ignore common junk directories
    tree -o "$output_file" -I ".git|.idea|.dart_tool|build|ios|android" .

    success_msg "Project tree dumped to $output_file"
}

# --- 2. Project Maintenance ---
function run_pub_get() {
    info_msg "Running 'flutter pub get'..."
    flutter pub get
    success_msg "'flutter pub get' complete."
}

function run_pub_upgrade() {
    info_msg "Running 'flutter pub upgrade'..."
    flutter pub upgrade
    success_msg "'flutter pub upgrade' complete."
}

function run_pub_outdated() {
    info_msg "Checking for outdated packages..."
    flutter pub outdated
}

function run_dart_fix() {
    if ! cmd_exists dart; then
        error_msg "'dart' command not found."
        return
    fi
    info_msg "Running 'dart fix --apply'..."
    dart fix --apply
    success_msg "Dart fixes applied."
}

# --- 3. Cleanup & Reset ---
function run_flutter_clean() {
    info_msg "Running 'flutter clean'..."
    flutter clean
    success_msg "'flutter clean' complete."
}

function run_android_clean() {
    if [[ ! -f "android/gradlew" ]]; then
        warn_msg "Android 'gradlew' script not found. Skipping."
        return
    fi
    info_msg "Cleaning Android project (./gradlew clean)..."
    (cd android && ./gradlew clean)
    success_msg "Android clean complete."
}

function run_ios_clean() {
    if [[ ! -d "ios" ]]; then
        warn_msg "iOS directory not found. Skipping."
        return
    fi
    info_msg "Removing Pods/ and Podfile.lock..."
    rm -rf ios/Pods ios/Podfile.lock

    if ! cmd_exists pod; then
        warn_msg "'pod' (CocoaPods) command not found. Skipping cache clean."
    else
        info_msg "Cleaning iOS Pod cache (pod cache clean)..."
        (cd ios && pod cache clean --all &> /dev/null)
    fi
    success_msg "iOS clean complete."
}

function run_full_clean() {
    info_msg "Starting full clean and pub get sequence..."
    run_flutter_clean
    run_android_clean
    run_ios_clean
    run_pub_get
    success_msg "Full clean and setup complete."
}

# --- 4. System & Diagnostics ---
function run_flutter_doctor() {
    info_msg "Running 'flutter doctor'..."
    flutter doctor
}

function run_flutter_upgrade() {
    info_msg "Running 'flutter upgrade'..."
    flutter upgrade
    success_msg "Flutter upgrade complete."
}

# --- 5. Firebase (FlutterFire) ---
function install_flutterfire_cli() {
    if ! cmd_exists dart; then
        error_msg "Dart SDK not found in PATH."
        return
    fi
    info_msg "Activating/Updating 'flutterfire_cli' globally..."
    dart pub global activate flutterfire_cli
    success_msg "'flutterfire_cli' is ready."
}

function run_flutterfire_configure() {
    if ! cmd_exists flutterfire; then
        warn_msg "'flutterfire' (FlutterFire CLI) not found. Run 'Install/Update flutterfire_cli' first."
        return
    fi
    if ! cmd_exists firebase; then
        warn_msg "'firebase' (Firebase CLI) not found. 'flutterfire configure' might fail."
        warn_msg "If it fails, install it with: npm install -g firebase-tools"
        read -p "Attempt to continue anyway? (y/N): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            info_msg "Operation cancelled."
            return
        fi
    fi

    info_msg "Running 'flutterfire configure'..."
    echo "This will guide you through connecting your Firebase project."
    flutterfire configure
    success_msg "'flutterfire configure' complete. Check for 'firebase_options.dart'."
}

# ==============================================================================
# --- MAIN MENU & LOOP (Categorized Two-Column) ---
# ==============================================================================

function show_menu() {
    # Clear the screen for a clean menu display
    clear
    printf "%s\n" "============================================="
    printf "%s\n" " Ultimate Flutter Project Utility Script"
    printf "%s\n" " Project Root: ${PROJECT_ROOT}"
    printf "%s\n" "============================================="

    # --- Define Menu Items (Plain Text) ---
    local col1_items=(
        "--- Dumps ---"
        "  1. Dump all .dart files"
        "  2. Dump pubspec.yaml"
        "  3. Dump .gitignore"
        "  4. Dump ignored Git Status"
        "  5. Dump project tree"
        "" # Spacer
        "--- Maintenance ---"
        "  6. Run 'flutter pub get' (Install dependencies)"
        "  7. Run 'flutter pub upgrade' (Update dependencies)"
        "  8. Check for outdated packages (List new versions)"
        "  9. Apply Dart fixes (Auto-fix linter warnings)"
    )

    local col2_items=(
        "--- Cleanup ---"
        " 10. Run 'flutter clean' (Delete 'build/' cache)"
        " 11. Clean Android project (Delete Android build cache)"
        " 12. Clean iOS project (Delete iOS cache & Pods)"
        " 13. Run FULL clean & get (Run 10, 11, 12, then 6)"
        "" # This spacer aligns with "5. Dump project tree"
        "" # This spacer aligns with the spacer in col1
        "--- System & Firebase ---"
        " 14. Run 'flutter doctor' (Check SDKs & setup)"
        " 15. Run 'flutter upgrade' (Update Flutter SDK)"
        " 16. Install/Update 'flutterfire_cli' (Global)"
        " 17. Run 'flutterfire configure' (Connect to Firebase)"
    )

    # --- Calculate Number of Rows (max of the two columns) ---
    local num_rows=12 # 12 items in col1

    # --- Calculate Column Widths (Plain Text) ---
    local max_left_width=0
    local max_right_width=0
    local column_padding=5 # Spaces between columns

    for item in "${col1_items[@]}"; do
        (( ${#item} > max_left_width )) && max_left_width=${#item}
    done

    for item in "${col2_items[@]}"; do
        (( ${#item} > max_right_width )) && max_right_width=${#item}
    done

    # --- Print Headers (They are now part of the item arrays) ---
    printf "\n" # Start with a newline

    # --- Print Menu Items in Two Columns ---
    for i in $(seq 0 $((num_rows - 1))); do
        # Use ':-' to provide an empty string if the array index is out of bounds
        local left_item="${col1_items[$i]:-}"
        local right_item="${col2_items[$i]:-}"

        local padding_width
        padding_width=$((max_left_width - ${#left_item} + column_padding))

        printf "%s%*s%s\n" "$left_item" $padding_width "" "$right_item"
    done

    # --- Print Footer ---
    local total_width
    total_width=$((max_left_width + column_padding + max_right_width))
    local divider_line
    # Create a divider line of the correct width
    divider_line=$(printf -- '-%.0s' $(seq 1 $total_width))

    printf "\n"
    printf "%s\n" "  0. Exit"
    printf "%s\n" "${divider_line}"
    printf "%s" " Enter your choice: "
}

# --- Main Loop ---
while true
do
    show_menu
    read -r choice

    # Add a trap to catch Ctrl+C (SIGINT) and exit gracefully
    trap 'printf "\n\n%s\n" "Operation cancelled. Returning to menu."; sleep 1; continue' SIGINT

    { # Start a block to trap errors
        case $choice in
            1) dump_dart_files ;;
            2) dump_pubspec ;;
            3) dump_gitignore ;;
            4) dump_git_ignored_status ;;
            5) dump_tree ;;

            6) run_pub_get ;;
            7) run_pub_upgrade ;;
            8) run_pub_outdated ;;
            9) run_dart_fix ;;

            10) run_flutter_clean ;;
            11) run_android_clean ;;
            12) run_ios_clean ;;
            13) run_full_clean ;;

            14) run_flutter_doctor ;;
            15) run_flutter_upgrade ;;

            16) install_flutterfire_cli ;;
            17) run_flutterfire_configure ;;

            0) printf "\n%s\n" "Goodbye!"; exit 0 ;;
            *) error_msg "Invalid option. Please try again." ;;
        esac
    } || {
        # This block catches errors if 'set -e' is triggered
        error_msg "A command failed. Please check the output above."
    }

    # Reset the trap
    trap - SIGINT

    # Pause and wait for user to press Enter
    printf "\n%s" "Press [Enter] to return to the menu..."
    read -r
done