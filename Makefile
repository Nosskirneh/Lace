include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Lace
Lace_FILES = Lace.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
