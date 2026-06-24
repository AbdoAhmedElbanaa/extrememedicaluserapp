#!/usr/bin/env bash

# ==============================================================================
# Extreme Medical - Premium Flutter Build & Upload Script
# ==============================================================================
# Features:
#   - Select Build Mode (Release or Debug).
#   - Build APK, AppBundle (AAB), or Both.
#   - Computes SHA-1 and SHA-256 signatures for built artifacts.
#   - Premium CLI interface with spinners and progress bars.
#   - Uploads to Pixeldrain via REST API and generates public links.
# ==============================================================================

set -e

API_KEY="46b65651-90a3-4eb2-ad4b-c5f4175b3034"

# Color Codes
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
MAGENTA='\e[1;35m'
CYAN='\e[1;36m'
WHITE='\e[1;37m'
NC='\e[0m' # No Color

# Text Styles
BOLD='\e[1m'
UNDERLINE='\e[4m'

# Clear screen and draw banner
clear
draw_banner() {
    echo -e "${CYAN}======================================================================${NC}"
    echo -e "  ${BOLD}${MAGENTA}⚕️  EXTREME MEDICAL — PRESET BUILD & SECURE DEPLOYMENT ENGINE  ⚕️${NC}"
    echo -e "${CYAN}======================================================================${NC}"
    echo -e "   Build Artifacts • Signature Verification • Pixeldrain Deployment"
    echo -e "${CYAN}----------------------------------------------------------------------${NC}"
}

# Loading Spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while kill -0 "$pid" 2>/dev/null; do
        for i in {0..9}; do
            local char="${spinstr:$i:1}"
            printf "\r${CYAN}   [%s] Building in progress, please wait...${NC}" "$char"
            sleep "$delay"
        done
    done
    printf "\r\e[K"
}

# Perform Build
run_build() {
    local build_type=$1 # "apk" or "appbundle"
    local mode=$2       # "release" or "debug"
    local label=""
    local cmd=""

    if [ "$build_type" = "apk" ]; then
        label="APK ($mode)"
        cmd="flutter build apk --$mode"
    else
        label="AppBundle ($mode)"
        cmd="flutter build appbundle --$mode"
    fi

    echo -e "\n${YELLOW}🔨 Starting compilation: ${WHITE}$label...${NC}"
    
    # Run build in background to hook spinner
    $cmd > /tmp/flutter_build.log 2>&1 &
    local build_pid=$!
    
    # Run spinner
    spinner "$build_pid"
    
    # Wait and check exit code
    wait "$build_pid"
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        echo -e "\n${RED}❌ Build Failed! Review details below:${NC}"
        echo -e "${RED}------------------------------------------------${NC}"
        tail -n 25 /tmp/flutter_build.log
        echo -e "${RED}------------------------------------------------${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ Build Completed Successfully!${NC}"
    fi
}

# Print Artifact details
process_artifact() {
    local file_path=$1
    local type_label=$2

    if [ ! -f "$file_path" ]; then
        echo -e "${RED}Error: Built file not found at $file_path${NC}"
        return 1
    fi

    local file_name=$(basename "$file_path")
    local file_size=$(du -sh "$file_path" | cut -f1)

    echo -e "\n${CYAN}======================================================================${NC}"
    echo -e "  ${BOLD}${GREEN}📦 ARTIFACT DETECTED: $type_label${NC}"
    echo -e "${CYAN}----------------------------------------------------------------------${NC}"
    echo -e "   ${BOLD}File Name:${NC} $file_name"
    echo -e "   ${BOLD}File Path:${NC} $file_path"
    echo -e "   ${BOLD}File Size:${NC} $file_size"
    
    echo -e "\n   ${BOLD}Calculating Signatures...${NC}"
    local sha1_sig=$(sha1sum "$file_path" | awk '{print $1}')
    local sha256_sig=$(sha256sum "$file_path" | awk '{print $1}')
    
    echo -e "   ${CYAN}SHA-1 Hash:   ${WHITE}$sha1_sig${NC}"
    echo -e "   ${CYAN}SHA-256 Hash: ${WHITE}$sha256_sig${NC}"
    echo -e "${CYAN}----------------------------------------------------------------------${NC}"

    # Ask for upload
    read -p "   Do you want to upload this $type_label to Pixeldrain? (y/N): " choice
    case "$choice" in 
        [yY][eE][sS]|[yY])
            upload_to_pixeldrain "$file_path" "$file_name"
            ;;
        *)
            echo -e "   ${YELLOW}Skipped upload for $file_name.${NC}"
            ;;
    esac
}

# Upload to Pixeldrain
upload_to_pixeldrain() {
    local file_path=$1
    local file_name=$2

    echo -e "\n   ${BLUE}🚀 Uploading $file_name to Pixeldrain...${NC}"
    
    local response_file=$(mktemp)
    
    # Run curl with standard progress bar
    curl -# -u :"$API_KEY" -F "file=@$file_path" "https://pixeldrain.com/api/file/" > "$response_file" 2>&1
    
    local upload_id=$(python3 -c "import sys, json; print(json.load(open('$response_file'))['id'])" 2>/dev/null || true)
    
    if [ -z "$upload_id" ]; then
        echo -e "\n   ${RED}❌ Upload failed! Server Response:${NC}"
        echo -e "   ${RED}------------------------------------------------${NC}"
        cat "$response_file"
        echo -e "\n   ${RED}------------------------------------------------${NC}"
    else
        echo -e "\n   ${GREEN}✨ Upload Successful!${NC}"
        echo -e "   ${BOLD}Download URL:${NC} ${CYAN}https://pixeldrain.com/u/$upload_id${NC}"
    fi
    
    rm -f "$response_file"
}

# Program Entry Menu
while true; do
    draw_banner
    
    # 1. Select Build Mode
    echo -e "   Please select the build mode:"
    echo -e "     ${BOLD}${CYAN}[1]${NC} Release Mode (Optimized, ready for deployment)"
    echo -e "     ${BOLD}${CYAN}[2]${NC} Debug Mode (Development configuration)"
    echo -e "${CYAN}----------------------------------------------------------------------${NC}"
    read -p "   Enter option (1-2): " mode_opt
    
    BUILD_MODE="release"
    if [ "$mode_opt" = "2" ]; then
        BUILD_MODE="debug"
    fi
    
    # Path configuration based on mode
    APK_PATH="build/app/outputs/flutter-apk/app-${BUILD_MODE}.apk"
    AAB_PATH="build/app/outputs/bundle/${BUILD_MODE}/app-${BUILD_MODE}.aab"
    
    echo -e "\n   Selected Mode: ${BOLD}${GREEN}${BUILD_MODE^^}${NC}"
    echo -e "${CYAN}----------------------------------------------------------------------${NC}"

    # 2. Select Build Type
    echo -e "   Please select a build configuration:"
    echo -e "     ${BOLD}${CYAN}[1]${NC} Build APK (${BUILD_MODE})"
    echo -e "     ${BOLD}${CYAN}[2]${NC} Build AppBundle (AAB) (${BUILD_MODE})"
    echo -e "     ${BOLD}${CYAN}[3]${NC} Build Both (APK & AppBundle) (${BUILD_MODE})"
    echo -e "     ${BOLD}${CYAN}[4]${NC} Exit / Start Over"
    echo -e "${CYAN}----------------------------------------------------------------------${NC}"
    read -p "   Enter option (1-4): " opt

    case "$opt" in
        1)
            run_build "apk" "$BUILD_MODE"
            process_artifact "$APK_PATH" "APK ($BUILD_MODE)"
            break
            ;;
        2)
            run_build "appbundle" "$BUILD_MODE"
            process_artifact "$AAB_PATH" "AppBundle ($BUILD_MODE)"
            break
            ;;
        3)
            run_build "apk" "$BUILD_MODE"
            run_build "appbundle" "$BUILD_MODE"
            process_artifact "$APK_PATH" "APK ($BUILD_MODE)"
            process_artifact "$AAB_PATH" "AppBundle ($BUILD_MODE)"
            break
            ;;
        4)
            echo -e "\n${YELLOW}Restarting or exiting utility...${NC}"
            sleep 1
            clear
            ;;
        *)
            echo -e "\n${RED}Invalid option! Please enter a number from 1 to 4.${NC}"
            sleep 1.5
            clear
            ;;
    esac
done
