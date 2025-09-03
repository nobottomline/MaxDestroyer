ARCHS = arm64 arm64e
TARGET = iphone:clang:14.5:13.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MaxDestroyer

MaxDestroyer_FILES = Tweak.xm
MaxDestroyer_CFLAGS = -fobjc-arc
MaxDestroyer_FRAMEWORKS = UIKit Foundation
MaxDestroyer_PRIVATE_FRAMEWORKS = SpringBoardServices

include $(THEOS)/makefiles/tweak.mk

# Preferences Bundle
SUBPROJECTS += MaxDestroyerPrefs

include $(THEOS)/makefiles/aggregate.mk
