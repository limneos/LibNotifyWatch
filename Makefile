TWEAK_NAME = libnotify
libnotify_FILES = libnotify.xm
libnotify_LDFLAGS = -lsqlite3
libnotify_FRAMEWORKS = UIKit CoreFoundation
include framework/makefiles/common.mk
include framework/makefiles/tweak.mk
