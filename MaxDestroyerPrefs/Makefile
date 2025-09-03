ARCHS = arm64 arm64e
TARGET = iphone:clang:14.5:13.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MaxDestroyerPrefs

MaxDestroyerPrefs_FILES = MaxDestroyerPrefsRootListController.m
MaxDestroyerPrefs_FRAMEWORKS = UIKit
MaxDestroyerPrefs_PRIVATE_FRAMEWORKS = Preferences
MaxDestroyerPrefs_INSTALL_PATH = /Library/PreferenceBundles
MaxDestroyerPrefs_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/bundle.mk
