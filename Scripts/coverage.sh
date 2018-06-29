#!/bin/bash
# owner: SamuelZhaoY

source "$(dirname $0)/environment.sh"

### Usage
###		`make coverage`
### Description
###		generate coverage report
### Options
###		--workspace-name <s>	:the workspace name, e.g. 'IAPRPCService'
###		--framework-name <s>	:the framework name, also used as the build target name.
###		--test <s>	:the testing target, based on which the coverage data is collected.
###   --reprt-format <s>: specify the report format, run slather coverage -h to check possible formats, default is llvm-cov

set -euo pipefail
IFS=$'\n\t'

FRAMEWORK_NAME=$PROJECT_NAME
WORKSPACE_NAME=$PROJECT_NAME
FORMAT="llvm-cov"

for arg in "$@"; do
	case "$arg" in
		--workspace-name=*) WORKSPACE_NAME="${arg#*=}" ;;
		--test=*) TESTS_NAME="${arg#*=}" ;;
		--reprt-format=*) FORMAT="${arg#*=}" ;;
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

outputDoing "Preparing coverage"
which slather > /dev/null || outputError "Please follow https://github.com/SlatherOrg/slather to install locally" $?
outputDone

outputTitle "Collecting coverage files..."

if [ -d "$WORKSPACE_NAME.xcworkspace" ]; then
  slather coverage --$FORMAT --scheme $TESTS_NAME --workspace $WORKSPACE_NAME.xcworkspace $FRAMEWORK_NAME.xcodeproj
else
  slather coverage  --$FORMAT --scheme $TESTS_NAME $FRAMEWORK_NAME.xcodeproj
fi

outputFinish ""
