THEOS_DEVICE_IP = 192.168.0.101
TARGET := iphone:latest:14.0
ARCHS = arm64
DEBUG = 0 
FINALPACKAGE = 1
FOR_RELEASE = 1
ROOTLESS = 1

THEOS_PACKAGE_SCHEME = $(if $(filter 1,$(ROOTLESS)),rootless,)

SDK_PATH = $(if $(filter 1,$(MOBILE_THEOS)),$(THEOS)/sdks/iPhoneOS16.5.sdk/,)
SYSROOT = $(SDK_PATH)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NinjaFramework
KITTYMEMORY_SRC = $(wildcard KittyMemory/*.cpp)
SCLAlertView_SRC = $(wildcard SCLAlertView/*.m)
TrustMe_SRC = $(wildcard TrustMe/*.mm)
Magicolors_SRC = $(wildcard Magicolors/*.m)
SDKCheats_SRC = $(wildcard SDKCheats/*.mm)
NFViews_SRC = $(wildcard NFViews/*.mm)

# Common flags
COMMON_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG
COMMON_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -O3

# NinjaFramework settings
NinjaFramework_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreTelephony AVFoundation AudioToolbox CoreGraphics CoreText Accelerate GLKit SystemConfiguration GameController
NinjaFramework_RESOURCES = HighSpeed.ttf
NinjaFramework_CCFLAGS = $(COMMON_CCFLAGS)
NinjaFramework_CFLAGS = $(COMMON_CFLAGS)
NinjaFramework_FILES = NFramework.mm  Layout.xm NFrameworkObserver.m $(TrustMe_SRC) ESPView.mm $(NFViews_SRC) $(SDKCheats_SRC) $(SCLAlertView_SRC) $(wildcard Icons/*.m)    NFToggles.mm $(wildcard Magicolors/*.m) $(wildcard ESP/*.m) $(wildcard Cheat/*.xm) $(wildcard Utils/*.m) $(KITTYMEMORY_SRC)

include $(THEOS_MAKE_PATH)/tweak.mk
