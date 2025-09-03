ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MaxDestroyer

MaxDestroyer_FILES = Tweak.xm
MaxDestroyer_CFLAGS = -fobjc-arc
MaxDestroyer_FRAMEWORKS = UIKit

# Важно: добавляем бандл настроек как дополнительный модуль
SUBPROJECTS += Preferences

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
