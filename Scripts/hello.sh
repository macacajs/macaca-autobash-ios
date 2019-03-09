#!/bin/bash
# owner: SamuelZhaoY

### Usage
###		`make hi`
### Description
###		make method templates, use this to customize your command
### Options
###		--greeting <s>		:content of this greeting

source "$(dirname $0)/environment.sh"

greeting=""

for arg in "$@"; do
	case "$arg" in
		--greeting=*) greeting="${arg#*=}" ;;
		*) break ;;
	esac
	shift
done

echo "Hi there, ${greeting}"
