# owner: SamuelZhaoY

# Version configurations only accept {major} or {major}.{minor}, do not append {revision}
# Minimal macOS version
MIN_OS_VERSION = 10.12
# Minimal Xcode version
MIN_XCODE_VERSION = 9.2
# Minimal Xcode Command Line Tools version
MIN_XCODE_CTL_VERSION = 2347

stop:
	@[ -z "$(MESSAGE)" ] || echo "ERROR: $(MESSAGE)." >&2
	@[ -z "$(CODE)" ] || exit $(CODE)
	@exit -1

repo: init
	@open "$(AUTOMATION_HOME)"

doctor: init
# Check if Xcode is installed
	@[ -f "/usr/bin/xcodebuild" ] || $(MAKE) MESSAGE="Missing Xcode" CODE=2 stop

# Check if macOS version is matched
	@OS_VERSION=$$(sw_vers -productVersion); \
	RESULT=$$(bc <<< "$${OS_VERSION%.*} >= $(MIN_OS_VERSION)"); \
	[[ $$RESULT = "1" ]] || $(MAKE) MESSAGE="macOS version $(MIN_OS_VERSION) is required. You're running v$$OS_VERSION" CODE=3 stop

# Check if Xcode version is matched
	@XCODE_VERSION=$$(xcodebuild -version | head -n 1 | cut -d ' ' -f 2); \
	RESULT=$$(bc <<< "$$XCODE_VERSION >= $(MIN_XCODE_VERSION)"); \
	[[ $$RESULT = "1" ]] || $(MAKE) MESSAGE="Xcode version $(MIN_XCODE_VERSION) is required, current version is $$XCODE_VERSION" CODE=4 stop

# Check if Xcode Command Line Tools is installed
	@XCODE_CTL_VERSION=$$(xcode-select --version | cut -d ' ' -f 3 | cut -d . -f 1); \
	RESULT=$$(bc <<< "$$XCODE_CTL_VERSION >= $(MIN_XCODE_CTL_VERSION)"); \
	[[ $$RESULT = "1" ]] || $(MAKE) MESSAGE="Xcode Command Line Tools version $(MIN_XCODE_CTL_VERSION) is required, current version is $$XCODE_CTL_VERSION" CODE=5 stop

# Check if Plist utility is installed
	@[ -f "/usr/libexec/PlistBuddy" ] || $(MAKE) MESSAGE="Missing PlistBuddy" CODE=6 stop

# Check if Plist exist
	@[ $$(find . -type f -name "*-Info.plist" -not -path "*/*.framework/*" -not -path "*/Pods/*" | head -n 1) ] || $(MAKE) MESSAGE="Missing Info-Plist, please add a default one for your project" CODE=7 stop

# Check xcpretty installation
	@[ "$$(gem list -i xcpretty)" == "true" ] || echo "Missing xcpretty. It's recommended to install it by running 'sudo gem install xcpretty'\n"

# Well done
	@echo "Everything looks good."

clean: init
	@echo -n Cleaning Xcode\'s DerivedData...
	@rm -rf "$HOME/Library/Developer/Xcode/DerivedData"
	@echo "done."

	@echo -n Cleaning cocoapods generated files...
	@rm -rf Pods
	@echo "done."

	@echo -n Cleaning building outputs...
	@rm -rf out .out .build
	@echo "done."

open: init
	@open "$(PROJECT_NAME).xcworkspace"

update: init
	@echo -n Updating AutomationScripts...
	@git -C "$(AUTOMATION_HOME)" pull

script:
	@[ ! -z "$(SCRIPT)" ] || $(MAKE) MESSAGE="Missing script filename" CODE=80 stop
# Allow overriding shared scripts
	@SCRIPT_FILE="./Scripts/$(SCRIPT).sh"; \
	[ -f "$$SCRIPT_FILE" ] || SCRIPT_FILE="$(AUTOMATION_HOME)/Scripts/$(SCRIPT).sh"; \
	if [ -f "$$SCRIPT_FILE" ]; then \
		AUTOMATION_HOME="$(AUTOMATION_HOME)" ACTION_NAME="$(SCRIPT)" "$$SCRIPT_FILE" $(ARGS); \
	else \
		$(MAKE) MESSAGE="Missing script file '$(SCRIPT).sh'" CODE=99 stop; \
	fi

release: update
	@$(MAKE) SCRIPT="test" ARGS="$(ARGS)" script
	@$(MAKE) SCRIPT="build" ARGS="$(ARGS) --publish" script
	@$(MAKE) SCRIPT="$@" script  # `release` will take the default target's plist for version recording. one workspace -> one fixed release configuration

coverage: test
	@$(MAKE) SCRIPT="$@" ARGS="$(ARGS)" script

# TODO：  support multiple ways of release
# release implementation

.PHONY: init stop repo doctor clean open update script coverage release
.DEFAULT: update
	@$(MAKE) SCRIPT="$@" ARGS="$(ARGS)" script
