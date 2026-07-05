export TARGET = iphone:clang:latest:12.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeatherGround

WeatherGround_FILES = $(wildcard *.xm) vendor/RemoteLog/RemoteLog.m
WeatherGround_CFLAGS = -fobjc-arc -Wno-unguarded-availability-new
WeatherGround_CFLAGS += -I./vendor/RemoteLog
WeatherGround_PRIVATE_FRAMEWORKS = SpringBoardFoundation Weather WeatherUI


include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += wgprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "sbreload"
