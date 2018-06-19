#!/bin/bash
# owner: SamuelZhaoY

### Usage
###		`make help`
### Description
###		list all available commands

source "$(dirname $0)/environment.sh"

fullineSeperator
outputTitle "Command Line User Guide:"

for path in "$(dirname $0)"/*
do
  target=$(basename $path | cut -d . -f1)
  # exclude irrelevant use cases
  if [ $target = "Makefile" ] || [ $target = "utils" ] ||
   [ $target = "environment" ]; then
    continue
  fi

  # scan each of the file and print out document
  fullineSeperator
  echo "$(tput bold)${target}$(tput sgr0) :"
  echo ""
  fgrep  -G "^###" $path | sed 's/###//g'
  echo ""

done

fullineSeperator
