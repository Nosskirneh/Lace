export SDKVERSION=10.1
export ARCHS = armv7 arm64

TARGET=iphone:clang:10.1:10.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Lace
Lace_FILES = Lace.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
