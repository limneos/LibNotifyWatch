GO_EASY_ON_ME=1
include theos/makefiles/common.mk

BUNDLE_NAME = LibNotifyWatch
LibNotifyWatch_FILES = LibNotifyWatch.mm
LibNotifyWatch_INSTALL_PATH = /Library/PreferenceBundles
LibNotifyWatch_FRAMEWORKS = UIKit
LibNotifyWatch_PRIVATE_FRAMEWORKS = Preferences
LibNotifyWatch_LDFLAGS=-lsubstrate
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LibNotifyWatch.plist$(ECHO_END)
