#!/bin/bash
# owner: SamuelZhaoY

source "$(dirname $0)/environment.sh"

### Usage
###		`make doc`
### Description
###		generate doc set for current workspace

# known issue methioned in here, so far xcode dose not support reload to share doc
# https://github.com/tomaz/appledoc/issues/598

/usr/local/bin/appledoc \
--project-name "${PROJECT_NAME}" \
--project-company "${COMPANY}" \
--company-id "${COMPANY_ID}" \
--output "${DOC_OUTPUT_PATH}" \
--create-html \
--no-create-docset \
--keep-undocumented-objects \
--keep-undocumented-members \
--keep-intermediate-files \
--no-repeat-first-par \
--no-warn-invalid-crossref \
--merge-categories \
--exit-threshold 2 \
--docset-platform-family ${DOC_TARGET} \
--ignore "*.m" \
--ignore "*.pch" \
--verbose 5 \
"${SOURCE_DIR}"
