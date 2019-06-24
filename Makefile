include $(THEOS)/makefiles/common.mk
ARCHS = armv7 arm64 #支持cpu类型
TARGET = iphone:latest:8.0 #最低支持版本
THEOS_DEVICE_IP = 192.168.100.138#手机的ip
THEOS_DEVICE_PORT = 2222 #ssh端口
TWEAK_NAME = wxRedTweak
wxRedTweak_FILES = Tweak.xm
WXRedTweak_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
