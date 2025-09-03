ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MaxDestroyerPreferences

MaxDestroyerPreferences_FILES = 
MaxDestroyerPreferences_FRAMEWORKS = UIKit
MaxDestroyerPreferences_INSTALL_PATH = /Library/PreferenceBundles
MaxDestroyerPreferences_CFLAGS = -fobjc-arc

# Копируем entry.plist в корень bundle'а
MaxDestroyerPreferences_EXTRA_FRAMEWORKS = 
MaxDestroyerPreferences_COPY_FILES = entry.plist

include $(THEOS_MAKE_PATH)/bundle.mk
