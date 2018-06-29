#!/bin/bash
# owner: SamuelZhaoY

### Usage
###        `make setup ARGS="--framework-name=$framework-to-create --language=$language"`
### Description
###        execute the command to create a framework project in the current directory, it is suggeted each framework project should have its own working directory.
### Options
### Options
###        --framework-name <s>    :the framework name, also used as the build target name.
###        --language <s>    :the language to use.

source "$(dirname $0)/environment.sh"

appname=""
bundle=""

for arg in "$@"; do
case "$arg" in
--framework-name=*) appname="${arg#*=}" ;;
--language=*) bundle="${arg#*=}" ;;
*) break ;;
esac
shift
done

if [ "$bundle" = "swift" ] ; then
bundle="Template-Swift.bundle"
else
bundle="Template.bundle"
fi

function proc_file_content() {
sed "s/Demo/${appname}/g" $1 > $1'.tmp'
rm -f $1
mv $1'.tmp' $1
}

function make_target() {
target=`echo $1 | sed "s/Demo/${appname}/g"`
target_length=${#target}
proj=$(dirname $0)/../Templates/$bundle
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
filter_content_for_type '.swift'
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

list $(dirname $0)/../Templates/$bundle
