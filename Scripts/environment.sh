#!/bin/bash
# owner: SamuelZhaoY

source "$AUTOMATION_HOME/Scripts/utils.sh"

## REPO INFO
export MARMOT_HOME="$AUTOMATION_HOME/.."

## PROJECT INFO
export PROJECT_DIR="$(pwd)"
export PODS_ROOT="$PROJECT_DIR/Pods"
export PROJECT_NAME="$(ls | grep --color=never xcodeproj | cut -d . -f 1 | sed -n 1p)"
export PREPROCESSOR_DEFINITIONS=( 'BUILD_TOOL="marmot-ios"' )
export PLIST_INFO_FILE="$(find . -type f -name "${PROJECT_NAME}-Info.plist" -not -path "*/*.framework/*" -not -path "*/Pods/*" | head -n 1)"
export MAIN_HEADER_FILE="$(find . -type f -name "${PROJECT_NAME}.h" -not -path "*/*.framework/*" -not -path "*/Pods/*" | head -n 1)"

## DOC INFO
export DOC_TARGET="iphoneos"
export DOC_OUTPUT_PATH="${PROJECT_DIR}/Documents"
export DOC_SCANNING_IGNORE_DIR=""

# source user's personal settings
[ -f "$MARMOT_HOME/profile" ] && source "$MARMOT_HOME/profile"

# source project's local settings
# eg: export BUILD_CONFIGURATIONS in this file to add additional configuration for xcodebuild
[ -f "${PROJECT_DIR}/.marmot-profile" ] && source "${PROJECT_DIR}/.marmot-profile"

if [ -z ${SOURCE_DIR+x} ]; then
	export SOURCE_DIR="${PROJECT_DIR}/${PROJECT_NAME}"
	[ -d "$SOURCE_DIR" ] || export SOURCE_DIR="${PROJECT_DIR}/Sources"
fi
