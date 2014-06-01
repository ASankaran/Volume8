export ARCHS = armv7 armv7s arm64
export TARGET = iphone:clang:7.1:7.1
THEOS_DEVICE_IP = 192.168.0.170

include theos/makefiles/common.mk

BUNDLE_NAME = com.mootjeuh.volume8

com.mootjeuh.volume8_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS)/makefiles/bundle.mk

TWEAK_NAME = Volume8
Volume8_FILES = main.xm Volume8.xm
Volume8_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
