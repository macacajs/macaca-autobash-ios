#!/bin/bash
# owner: SamuelZhaoY

source "$(dirname $0)/environment.sh"

#-## Usage
#-##		`make upload ARGS="[options]"`, e.g. make build ARGS="--filename=${file-name}.zip --version=1.0.0.0"
#-## Description
#-##		Upload file from local dir
#-## Options
#-##		--filename <s>	:the name of the compressed file in the current invocation directory, to be uploaded
#-##		--version <s>	:file version, in format of '1.0.0.0', which will be put into the part of the downloading resource url

for arg in "$@"; do
	case "$arg" in
		--filename=*) FILE_NAME="${arg#*=}" ;;
		--version=*) VERSION="${arg#*=}" ;;
		*) break ;;
	esac
done

outputDoing "Checking arguments"
[ -z "$2" ] && outputError "Arguments required.\nUsage: make upload ARGS=\"--filename={YourFileName} --version={Version}\"" 1
[ -f "${PROJECT_DIR}/$FILE_NAME" ] || outputError "File not found: ${PROJECT_DIR}/$FILE_NAME." 2
outputDone

outputTitle "Uploading $FILE_NAME v$VERSION..."
UPLOAD_RESULT=$(basefileUpload "$FILE_NAME" "$VERSION" | grep -o "\"http.*\"")
[ -z "$UPLOAD_RESULT" ] && exit 10
outputFinish "$FILE_NAME uploaded at $UPLOAD_RESULT"
