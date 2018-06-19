#!/bin/bash
# owner: SamuelZhaoY

source "$(dirname $0)/environment.sh"

### Usage
###		`make lint`
### Description
###		generate lint based on oclint or infer, depending on current workstation's environment

# Running Infer

if [ $(isInstalled "OCLint") -gt 0 ]
then
  echo "### OCLit installed, conducting OCLint check"
  xcodebuild clean
  xcodebuild -scheme ${PROJECT_NAME} -workspace ${PROJECT_NAME}.xcworkspace -configuration Debug -sdk iphonesimulator | xcpretty -r json-compilation-database
  oclint-json-compilation-database -- -report-type xcode
else
  echo "### OCLint uninstalled, skipping OCLint check"
fi

if [ $(isInstalled "Infer") -gt 0 ]
then
  echo "### Infer installed, conducting Infer check"
  xcodebuild -scheme ${PROJECT_NAME} -workspace ${PROJECT_NAME}.xcworkspace -sdk iphonesimulator clean
  infer run --keep-going --no-xcpretty  -- xcodebuild -scheme ${PROJECT_NAME} -workspace ${PROJECT_NAME}.xcworkspace -sdk iphonesimulator
else
  echo "### Infer uninstalled, skipping Infer check"
fi
