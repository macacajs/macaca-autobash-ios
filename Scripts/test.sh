#!/bin/bash
# owner: SamuelZhaoY

source "$(dirname $0)/environment.sh"

### Usage
###		`make test ARGS="[options]"`, e.g. make test ARGS="--test=${TestName}"
### Description
###		Execute test based on default project setting or the schema and workspace specified by user.
### Options
###		--test <s>		:the test schema which needs to be triggered.
###		--workspace-name <s>	:the workspace name.

set -euo pipefail
IFS=$'\n\t'

outputDoing "Preparing test"

FRAMEWORK_NAME=$PROJECT_NAME
WORKSPACE_NAME=$PROJECT_NAME

for arg in "$@"; do
	case "$arg" in
		--workspace-name=*) WORKSPACE_NAME="${arg#*=}" ;;
		--framework-name=*) FRAMEWORK_NAME="${arg#*=}" ;;
		--test=*) TESTS_NAME="${arg#*=}" ;;
		*) break ;;
	esac
	shift
done

if [ -z ${TESTS_NAME+x} ]; then
	TESTS_NAME="${FRAMEWORK_NAME}Tests"
	[ -d "$TESTS_NAME" ] || TESTS_NAME="${FRAMEWORK_NAME}Test"
	if [ ! -d "$TESTS_NAME" ]; then
		echo "Nothing to test."
		exit 0
	fi
fi

# Update pods if necessary
[[ -f Podfile && ! -d "$FRAMEWORK_NAME.xcworkspace" ]] && [ "$FRAMEWORK_NAME" == "$PROJECT_NAME" ] && pod update

# xcpretty
XCODEBUILD_PIPE="cat"
which xcpretty > /dev/null && XCODEBUILD_PIPE="xcpretty"

outputDone

# Create binary
outputTitle "Testing..."
if [ -d "$WORKSPACE_NAME.xcworkspace" ]; then
	xcodebuild -workspace "$WORKSPACE_NAME.xcworkspace" -scheme $TESTS_NAME -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone X' ${BUILD_CONFIGURATIONS:-} test | $XCODEBUILD_PIPE || true
else
	xcodebuild clean build -project "$FRAMEWORK_NAME.xcodeproj" -scheme $TESTS_NAME -configuration $FRAMEWORK_CONFIG -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone X' ${BUILD_CONFIGURATIONS:-} test | $XCODEBUILD_PIPE || true
fi

outputFinish
