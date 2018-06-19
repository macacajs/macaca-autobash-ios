#!/bin/bash
# owner: SamuelZhaoY

source "$(dirname $0)/environment.sh"

### Usage
###		`make pack`
### Description
###		pack documents and generate necessary templates for README, CHANGELOG if any of them missing

# Create README.md , CHANGELOG.md from templates, if necessary
[ -f "${PROJECT_DIR}/README.md" ] || cp "$(dirname $0)"/../Templates/Template.bundle/README.md ${PROJECT_DIR}
[ -f "${PROJECT_DIR}/CHANGELOG.md" ] || cp "$(dirname $0)"/../Templates/Template.bundle/CHANGELOG.md ${PROJECT_DIR}

# Remove obsolete package
[ ! -f "${PROJECT_NAME}.zip" ] || rm -rf "${PROJECT_NAME}.zip"

# Repack new package
zip -ry "${PROJECT_NAME}.zip" "./Frameworks" "./Resources" "./README.md" "./CHANGELOG.md"
