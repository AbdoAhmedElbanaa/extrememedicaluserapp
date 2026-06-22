#!/bin/bash
# ============================================
# Flutter Build Monitor - ElbanaDev
# Usage: bash build_watch.sh [debug|release]
# ============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m'
BOLD='\033[1m'

BUILD_TYPE=${1:-debug}
LOG_FILE="$HOME/flutter_build_$(date +%Y%m%d_%H%M%S).log"
PROJECT_DIR="$HOME/extrememedicaluserapp"
START_TIME=$(date +%s)

# ---- Header ----
clear
echo -e "${BOLD}${BLUE}"
echo "  ███████╗██╗     ██╗   ██╗████████╗████████╗███████╗██████╗ "
echo "  ██╔════╝██║     ██║   ██║╚══██╔══╝╚══██╔══╝██╔════╝██╔══██╗"
echo "  █████╗  ██║     ██║   ██║   ██║      ██║   █████╗  ██████╔╝"
echo "  ██╔══╝  ██║     ██║   ██║   ██║      ██║   ██╔══╝  ██╔══██╗"
echo "  ██║     ███████╗╚██████╔╝   ██║      ██║   ███████╗██║  ██║"
echo "  ╚═╝     ╚══════╝ ╚═════╝    ╚═╝      ╚═╝   ╚══════╝╚═╝  ╚═╝"
echo -e "${NC}"
echo -e "${BOLD}${WHITE}  🚀 Flutter APK Build Monitor${NC} ${DIM}by ElbanaDev${NC}"
echo -e "${DIM}  ─────────────────────────────────────────────────────${NC}"
echo -e "  📁 Project : ${CYAN}$PROJECT_DIR${NC}"
echo -e "  🏗️  Mode    : ${YELLOW}$BUILD_TYPE${NC}"
echo -e "  📝 Log     : ${DIM}$LOG_FILE${NC}"
echo -e "  🕐 Started : $(date '+%H:%M:%S')${NC}"
echo -e "${DIM}  ─────────────────────────────────────────────────────${NC}"
echo ""

# ---- Step counter ----
STEP=0
step() {
    STEP=$((STEP + 1))
    echo -e "\n${BOLD}${MAGENTA}  [$STEP] $1${NC}"
}

# ---- Check project ----
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}  ❌ Project directory not found: $PROJECT_DIR${NC}"
    exit 1
fi

cd "$PROJECT_DIR" || exit 1

# ---- Flutter clean ----
step "تنظيف الـ build القديم..."
flutter clean 2>&1 | while IFS= read -r line; do
    echo -e "  ${DIM}🗑️  $line${NC}"
done

# ---- Flutter pub get ----
step "تحميل الـ dependencies..."
flutter pub get 2>&1 | while IFS= read -r line; do
    if [[ $line == *"Downloading"* ]] || [[ $line == *"download"* ]]; then
        echo -e "  ${CYAN}⬇️  $line${NC}"
    elif [[ $line == *"Got dependencies"* ]] || [[ $line == *"Resolving"* ]]; then
        echo -e "  ${GREEN}✅ $line${NC}"
    elif [[ $line == *"Warning"* ]] || [[ $line == *"warning"* ]]; then
        echo -e "  ${YELLOW}⚠️  $line${NC}"
    else
        echo -e "  ${DIM}📦 $line${NC}"
    fi
done

# ---- Flutter build ----
step "بناء الـ APK ($BUILD_TYPE)..."
echo -e "  ${DIM}هتشوف التفاصيل كلها هنا...${NC}\n"

flutter build apk --$BUILD_TYPE --verbose 2>&1 | tee "$LOG_FILE" | while IFS= read -r line; do

    # Errors
    if [[ $line == *"FAILURE"* ]] || [[ $line == *"BUILD FAILED"* ]]; then
        echo -e "\n  ${RED}${BOLD}╔══════════════════════════════════╗${NC}"
        echo -e "  ${RED}${BOLD}║  ❌  BUILD FAILED                ║${NC}"
        echo -e "  ${RED}${BOLD}╚══════════════════════════════════╝${NC}"
        echo -e "  ${RED}$line${NC}"

    elif [[ $line == *"error:"* ]] || [[ $line == *"Error:"* ]] || [[ $line == *"Exception"* ]]; then
        echo -e "  ${RED}❌  $line${NC}"

    # Warnings
    elif [[ $line == *"warning:"* ]] || [[ $line == *"Warning:"* ]] || [[ $line == *"WARN"* ]]; then
        echo -e "  ${YELLOW}⚠️   $line${NC}"

    # Downloads
    elif [[ $line == *"Downloading"* ]] || [[ $line == *"Download "* ]]; then
        echo -e "  ${CYAN}⬇️   $line${NC}"

    # Gradle tasks
    elif [[ $line == *"> Task"* ]]; then
        echo -e "  ${BLUE}🔨  $line${NC}"

    # Compiling Dart
    elif [[ $line == *"Compiling"* ]] || [[ $line == *"compiling"* ]]; then
        echo -e "  ${YELLOW}⚙️   $line${NC}"

    # Linking
    elif [[ $line == *"Linking"* ]] || [[ $line == *"linking"* ]]; then
        echo -e "  ${MAGENTA}🔗  $line${NC}"

    # Assets
    elif [[ $line == *"asset"* ]] || [[ $line == *"Asset"* ]] || [[ $line == *"Flutter assets"* ]]; then
        echo -e "  ${CYAN}🖼️   $line${NC}"

    # Build success
    elif [[ $line == *"BUILD SUCCESSFUL"* ]] || [[ $line == *"✓"* ]]; then
        echo -e "  ${GREEN}${BOLD}✅  $line${NC}"

    # Built APK output
    elif [[ $line == *"Built build/"* ]]; then
        echo -e "\n  ${GREEN}${BOLD}╔══════════════════════════════════╗${NC}"
        echo -e "  ${GREEN}${BOLD}║  ✅  APK READY!                  ║${NC}"
        echo -e "  ${GREEN}${BOLD}╚══════════════════════════════════╝${NC}"
        echo -e "  ${GREEN}${BOLD}📦  $line${NC}\n"

    # Info / verbose lines
    elif [[ $line == *"Running"* ]] || [[ $line == *"Gradle"* ]]; then
        echo -e "  ${DIM}▶   $line${NC}"

    # Dart kernel / snapshot
    elif [[ $line == *"kernel"* ]] || [[ $line == *"snapshot"* ]]; then
        echo -e "  ${MAGENTA}📸  $line${NC}"

    # Skip empty lines but keep structure
    elif [[ -z "$line" ]]; then
        echo ""

    # Everything else
    else
        echo -e "  ${DIM}    $line${NC}"
    fi

done

# ---- Summary ----
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

echo ""
echo -e "${DIM}  ─────────────────────────────────────────────────────${NC}"
echo -e "  ⏱️  Total time: ${BOLD}${MINUTES}m ${SECONDS}s${NC}"

# Check if APK exists
APK_PATH="$PROJECT_DIR/build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk"
if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -sh "$APK_PATH" | cut -f1)
    echo -e "  📦 APK Size  : ${BOLD}${GREEN}$APK_SIZE${NC}"
    echo -e "  📍 APK Path  : ${CYAN}$APK_PATH${NC}"
    echo ""
    echo -e "  ${GREEN}${BOLD}🎉 Build completed successfully!${NC}"
else
    echo -e "  ${RED}❌ APK not found — check log: $LOG_FILE${NC}"
fi

echo -e "${DIM}  ─────────────────────────────────────────────────────${NC}"
echo ""