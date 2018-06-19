#!/bin/bash
# owner: SamuelZhaoY

function outputTitle () {
  COLOR='\033[1;32m'
  NC='\033[0m' # No Color
  echo -e "\n🛫  ${COLOR}${1-Running...}${NC}"
}

function outputDoing () {
  COLOR='\033[0;34m'
  NC='\033[0m' # No Color
  echo -en "🕑  ${COLOR}${1-Please wait}...${NC}"
}

function fullineSeperator () {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

function outputDone () {
  COLOR='\033[0;34m'
  NC='\033[0m' # No Color
  echo -e "${COLOR}done.${NC}"
}

function outputFinish () {
  COLOR='\033[0;32m'
  NC='\033[0m' # No Color
  echo -e "\n🏖  ${COLOR}Action $ACTION_NAME executed successfully.${NC} ${1-}"
}

function outputError () {
  COLOR='\033[0;31m'
  NC='\033[0m' # No Color
  >&2 echo -e "\n❌ ${COLOR}Error: ${1-Unknown error}.${NC}"
  exit ${2-100}
}

function isInstalled () {
  $1 --version | grep -c "version"
}

function urlEncode () {
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c"
        esac
    done
}

function urlDecode () {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

function packFiles () {
  OUTPUT_DIR="${PROJECT_DIR}/OUTPUT"
  FRAMEWORK_DIR="${PROJECT_DIR}/${1}"
  RESOURCE_DIR="${PROJECT_DIR}/${2}"
  TARGET_FILE="${PROJECT_DIR}/${PROJECT_NAME}.zip"

  [ -f "$TARGET_FILE" ] && rm -f "$TARGET_FILE"
  [ -d "$OUTPUT_DIR" ] && rm -rf "$OUTPUT_DIR"
  mkdir -p "$OUTPUT_DIR"

  [ -d "$FRAMEWORK_DIR" ] && cp -rf "$FRAMEWORK_DIR" "$OUTPUT_DIR"
  [ -d "$RESOURCE_DIR" ] && cp -rf "$RESOURCE_DIR" "$OUTPUT_DIR"

  cd $OUTPUT_DIR
  zip -r "$TARGET_FILE" * > /dev/null
  cd ..
  rm -rf "$OUTPUT_DIR"
}

function currentBuildNumber () {
  echo `/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$PLIST_INFO_FILE"`
}

function updateBuildNumber () {
  BUILD_NUMBER=$(currentBuildNumber)
  if [ "$BUILD_NUMBER" -eq "$BUILD_NUMBER" ] 2>/dev/null; then
    BUILD_NUMBER=$(($BUILD_NUMBER + 1))
  else
    BUILD_NUMBER=1
  fi

  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$PLIST_INFO_FILE"
  echo $BUILD_NUMBER
}

function updateHeaderVersion () {
    sed -i -e "s/${PROJECT_NAME}Version[[:space:]]*@\".*\"$/${PROJECT_NAME}Version @\"$1\"/" "$MAIN_HEADER_FILE"
    [ $? = 0 ] && rm -f "$MAIN_HEADER_FILE-e"
}

function currentVersion () {
  echo `/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$PLIST_INFO_FILE"`
}

function updateSpecs () {
  UPLOAD_RESULT="${1}"
  SPECS_VERSION="${2}"

  # supporting both .podspec and .podspec.json format
  if [ -f "${PROJECT_NAME}.podspec.json" ]; then

    sed -i -e \
    "s/\"version\"[[:space:]]*:[[:space:]]*\".*\",$/\"version\"\: \"${SPECS_VERSION}\",/g" \
    ${PROJECT_NAME}.podspec.json

    sed -i -e \
    "s/\"http\"[[:space:]]*:[[:space:]]*\".*\"$/\"http\"\: ${UPLOAD_RESULT}/g" \
    ${PROJECT_NAME}.podspec.json

    rm ${PROJECT_NAME}.podspec.json-e

  elif [ -f "${PROJECT_NAME}.podspec" ]; then

    sed -i -e \
    "s/\.version[[:space:]]*=[[:space:]]*'.*'/\.version = '${SPECS_VERSION}'/g" \
    ${PROJECT_NAME}.podspec

    sed -i -e \
    "s/:http[[:space:]]*=>[[:space:]]*\".*\"/:http => ${UPLOAD_RESULT}/g" \
    ${PROJECT_NAME}.podspec

    rm ${PROJECT_NAME}.podspec-e

  fi
}

function currentSpecsFile () {

  # check about specs file format
  if [ -f "${PROJECT_NAME}.podspec.json" ]; then
    echo "${PROJECT_NAME}.podspec.json"
  elif [ -f "${PROJECT_NAME}.podspec" ]; then
    echo "${PROJECT_NAME}.podspec"
  fi
}

function basefileUpload () {
  FILE_NAME=$1
  FILE_VERSION=$2
  FILE_PATH="${PROJECT_DIR}/${FILE_NAME}"
  COMMIT_HASH=`echo $(git rev-parse --short HEAD)`
  #TODO: file upload implementation
}

function basefileDelete () {
  FILE_ENCODED_URL= urlEncode $1
  #TODO: file delete implementation
}
