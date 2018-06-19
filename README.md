## 1. Tracing Issue:

## 2. Initialize Project
1. Create direcotry for the new project
2. Ensure you have installed cocoapod and configured standard podfile and .podspec (.podspec.json) in your project
3. Open terminal and enter the directory
4. Run command:
   `curl -fsSL https://github.com/macacajs/marmot-ios/files/2114402/Makefile.txt -o Makefile`

## 3. Usage
After installation, simply invoke `make help` to get the full list available commands and params.

## 4. Configuration
Even though the default environment variables used to conduct build, pack and release in the current set of scripts have already been taken cared by the internal implementation. `In some rare or special cases` the default setting might not be well suited into the target project's needs. As a further enhancement, two layers of `.profile` can be placed in order to fulfil user's varies needs.

### 4.1 Global Scope
Create a profile into the installation dir of the automation scripts, like `~/marmot_home/`. In this `.profile` file, you can specify env vars which are globally used across projects

```
# content of global `.profile`

# your company information
export COMPANY="${COMPANY_NAME}"
export COMPANY_ID="com.xxx.xxx"

# customize your own cocoapod private specs

export POD_REPO_NAME="${NAME_OF_SPECS_REPO}"
export POD_REPO_URL="git@github.xxxxx/Specs.git"

```

### 4.2 Project Scope
Create a profile into the working project dir, like `xxxx/${PROJECT_ROOT}/.marmot-profile`. In this `.marmot-profile` file, you can specify env vars which are locally reference by the current project.

```
# content of local `.profile`

# customise your own
export PROJECT_NAME="${PROJECT_NAME}"
export SOURCE_DIR="$(pwd)/${YOUR_SOURCE_FOLDER}"

```

## 5. References
Since `OCLint`, `Infer`, `Slather` and `appleDoc` are well known utilities across iOS communities, we are not providing any customised installation assistant for them. Please refer to the reference below to get more information on how to install those commonly used prerequisite tools:

```
OCLint:
http://oclint-docs.readthedocs.io/en/stable/guide/xcode.html

Infer:
http://fbinfer.com/docs/getting-started.html

Slather:
https://github.com/SlatherOrg/slather

AppleDoc:
https://github.com/tomaz/appledoc

```
