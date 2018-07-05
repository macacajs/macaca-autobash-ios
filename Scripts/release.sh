#!/bin/bash
# owner: SamuelZhaoY

source "$(dirname $0)/environment.sh"

### Usage
###		`make release`
### Description
###		pack documents and generate necessary templates for README, CHANGELOG if any of them missing

outputTitle "Releasing $PROJECT_NAME..."

outputDoing "Preparing release"

# Create private pod repo if necessary
[ -d "$HOME/.cocoapods/repos/$POD_REPO_NAME" ] || pod repo add "$POD_REPO_NAME" "$POD_REPO_URL"

# Check info plist
[ -f "$PLIST_INFO_FILE" ] || outputError "Cannot determine the .plist file. Default filename is $PROJECT_NAME-Info.plist" 1

outputDone

# Create the zip file
outputDoing "Packing files"
packFiles "Frameworks" "Resources"
outputDone

# Resolve full version to release
UPDATED_VERSION="$(currentVersion).$(currentBuildNumber)"

# move the zip file to intranet oss
outputTitle "Uploading binary version $UPDATED_VERSION..."
mkdir --parents $MARMOT_HOME/static/$PROJECT_NAME/
mv ${PROJECT_DIR}/${PROJECT_NAME}.zip $MARMOT_HOME/static/$PROJECT_NAME/${PROJECT_NAME}-$UPDATED_VERSION.zip
echo "Move file to static hosts at"

outputDoing "Removing local uploaded zip file"
rm -f "${PROJECT_NAME}.zip"
outputDone

# Get the downloading URL for the zip file
ESCAPED_UPLOAD_RESULT=""

# Update full version and downloading URL in the podspec
outputDoing "Updating Pod Specs"
updateSpecs "$ESCAPED_UPLOAD_RESULT" "$UPDATED_VERSION"
outputDone
#
# Publish this new version into private repo
outputTitle "Publishing new version to $POD_REPO_NAME..."
pod repo push \
${POD_REPO_NAME} \
$(currentSpecsFile) \
--verbose --allow-warnings --sources="$POD_REPO_URL,https://github.com/CocoaPods/Specs.git"

[ $? == 0 ] || exit $?

# Commit & Push
outputTitle "Update local change to git repo: $PROJECT_NAME..."
git tag $UPDATED_VERSION || outputError "fails to tag, please check git log" 3
git add --a && git commit -m "[Update] $UPDATED_VERSION" || outputError "fails to commit, please check git log" 3
git push || outputError "fails to push please check git log" 3
git push --tags || outputError "fails to push tags, please check git log" 3

# Release done
outputFinish "$PROJECT_NAME version $UPDATED_VERSION released successfully."
