#!/bin/bash
# owner: SamuelZhaoY

### Usage
###		`make setup ARGS="$name-of-framework-to-create"`
### Description
###		execute the command to create a framework project in the current directory, it is suggeted each framework project should have its own working directory.
### Options
###		<s>	:the name of the framework project to setup

source "$(dirname $0)/environment.sh"

if [ $# != 1 ] ; then
	outputError 'Invalid parameters' 1
fi

if [ -d $(pwd)/$1 ]; then
	outputError "The directory $(pwd)/$1 already exists, please setup in an empty directory" 1
fi

appname=$1

function proc_file_content() {
	sed "s/Demo/${appname}/g" $1 > $1'.tmp'
	rm -f $1
	mv $1'.tmp' $1
}

function make_target() {
	target=`echo $1 | sed "s/Demo/${appname}/g"`
	target_length=${#target}
	proj=$(dirname $0)/../Templates/Template.bundle
	proj_length=${#proj}+1
	target_length=$target_length-$proj_length
	target=${target:proj_length:target_length}
	echo $target
}

function replace_filename() {

	source=$1
	target=`make_target "$1"`

	if [ -d "$source" ] ; then
		mkdir -p $target
	else
		cp $source $target
	fi

	filter_content_for_type 'project.pbxproj'
	filter_content_for_type 'xcscheme'
	filter_content_for_type '-Info.plist'
	filter_content_for_type '.podspec.json'
	filter_content_for_type '.h'
	filter_content_for_type '.m'
	filter_content_for_type 'Podfile'
	filter_content_for_type 'README.md'
	filter_content_for_type 'CHANGELOG.md'
}

function filter_content_for_type() {
	type=$1
	position=${#target}-${#type}
	length=${#type}
	if [ ${#target} -ge ${#type} ] && [ ${target:position:length} == $type ] ; then
		proc_file_content $target
	fi
}

function list() {
	for file in `ls $1`
	do
		replace_filename $1/$file
		if [ -d "$1/$file" ] ; then
			list "$1/$file";
		fi
	done
}

list $(dirname $0)/../Templates/Template.bundle
