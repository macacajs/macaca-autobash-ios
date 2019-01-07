#!/bin/bash
# owner: SamuelZhaoY

### Usage
###		`make build ARGS="[options]"`, e.g. make build ARGS="--configuration=debug"
### Description
###		Build binary files for both simulator and device, combine and produce fat files.
###		Users can specify build target, workspace and event build configuration.
### Options
###		--configuration <s>	:the building configuration, e.g. debug, release (by default 'release' will be used)
###		--workspace-name <s>	:the workspace name, e.g. 'AFNetworking'
###		--framework-name <s>	:the framework name, also used as the build target name.

source "$(dirname $0)/environment.sh"

set -euo pipefail
IFS=$'\n\t'

outputDoing "Preparing building"

# Sets the target folders and the final framework product.
FRAMEWORK_NAME=$PROJECT_NAME
WORKSPACE_NAME=$PROJECT_NAME  # by default, assuming the workspace name is the same as the framework name
FRAMEWORK_CONFIG="Release"
SRCROOT=${PROJECT_DIR}
PUBLISH_BUILD=0

for arg in "$@"; do
	case "$arg" in
		--configuration=*) FRAMEWORK_CONFIG="${arg#*=}" ;;
		--framework-name=*) FRAMEWORK_NAME="${arg#*=}" ;;
		--workspace-name=*) WORKSPACE_NAME="${arg#*=}" ;;
		--publish) PUBLISH_BUILD=1 ;;
		*) break ;;
	esac
	shift
done

# Install dir will be the final output to the framework.
# The following line create it in the root folder of the current project.
INSTALL_DIR="$SRCROOT/Frameworks/$FRAMEWORK_NAME.framework"
[ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Prepare directories
WORK_DIR="$SRCROOT/build"
DEVICE_DIR="$WORK_DIR/${FRAMEWORK_CONFIG}-iphoneos/$FRAMEWORK_NAME.framework"
mkdir -p "$DEVICE_DIR"
SIMULATOR_DIR="$WORK_DIR/${FRAMEWORK_CONFIG}-iphonesimulator/$FRAMEWORK_NAME.framework"
mkdir -p "$SIMULATOR_DIR"

# Update pods if necessary
[[ -f Podfile && ! -d "$FRAMEWORK_NAME.xcworkspace" ]] && [ "$FRAMEWORK_NAME" == "$PROJECT_NAME" ] && pod update

# xcpretty
XCODEBUILD_PIPE="cat"
[ "$(gem list -i xcpretty)" == "true" ] && XCODEBUILD_PIPE="xcpretty"

# release mode: avoid any release build when there is still pending change
CURRENT_COMMIT="`git rev-parse --short HEAD`"
if [ $PUBLISH_BUILD -eq 1 ]; then
	# check pending commits. if there is any, aborting build
	git status | grep -o "working tree clean" > /dev/null || outputError "pending local changes exist, please make a stash or commit first" 3

	# write commit hash
	PROPERTY_KEY="LastCommitHash"
	LINES="$(/usr/libexec/PlistBuddy -c 'Print' "$PLIST_INFO_FILE" | grep "$PROPERTY_KEY" | wc -l || true)"
	if [[ $LINES -gt 0 ]]; then
		/usr/libexec/PlistBuddy -c "Set :$PROPERTY_KEY \"$CURRENT_COMMIT\"" "$PLIST_INFO_FILE"
	else
		/usr/libexec/PlistBuddy -c "Add :$PROPERTY_KEY string \"$CURRENT_COMMIT\"" "$PLIST_INFO_FILE"
	fi

	VERSION="$(currentVersion).$(updateBuildNumber)"
else
	VERSION="$(currentVersion).0"
fi

# append options for publish
PREPROCESSOR_DEFINITIONS+=( 'SDK_VERSION="'$VERSION'"' 'SDK_COMMIT="'$CURRENT_COMMIT'"' )
outputDone

# Create binary
outputTitle "Building device..."
if [ -d "$WORKSPACE_NAME.xcworkspace" ]; then
	xcodebuild -workspace "$WORKSPACE_NAME.xcworkspace" -scheme $FRAMEWORK_NAME -configuration $FRAMEWORK_CONFIG -sdk iphoneos CONFIGURATION_BUILD_DIR="$DEVICE_DIR/.." clean build | $XCODEBUILD_PIPE
else
	xcodebuild -project "$FRAMEWORK_NAME.xcodeproj" -target $FRAMEWORK_NAME -configuration $FRAMEWORK_CONFIG -sdk iphoneos CONFIGURATION_BUILD_DIR="$DEVICE_DIR/.." clean build | $XCODEBUILD_PIPE
fi

outputTitle "Build simulator..."
if [ -d "$WORKSPACE_NAME.xcworkspace" ]; then
	xcodebuild -workspace "$WORKSPACE_NAME.xcworkspace" -scheme $FRAMEWORK_NAME -configuration $FRAMEWORK_CONFIG -sdk iphonesimulator CONFIGURATION_BUILD_DIR="$SIMULATOR_DIR/.." clean build | $XCODEBUILD_PIPE
else
	xcodebuild -project "$FRAMEWORK_NAME.xcodeproj" -target $FRAMEWORK_NAME -configuration $FRAMEWORK_CONFIG -sdk iphonesimulator CONFIGURATION_BUILD_DIR="$SIMULATOR_DIR/.." clean build | $XCODEBUILD_PIPE
fi

outputDoing "Copying files"
cp -r "$DEVICE_DIR" "$INSTALL_DIR/.."
outputDone

outputDoing "Merging iphoneos and simulator binaries"
lipo -create "$DEVICE_DIR/$FRAMEWORK_NAME" "$SIMULATOR_DIR/$FRAMEWORK_NAME" -output "$INSTALL_DIR/$FRAMEWORK_NAME"
outputDone

outputDoing "Cleaning up"
rm -rf "$WORK_DIR"
outputDone

outputFinish "Check install directory ${INSTALL_DIR/#$HOME/~}."
