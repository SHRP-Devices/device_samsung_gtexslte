#########################################################
#
# SHRP SPECIFIC FLAGS
#
#########################################################

# Release name
PRODUCT_RELEASE_NAME := gtexslte

$(call inherit-product, build/target/product/embedded.mk)

PRODUCT_PACKAGES += \
	degas-mkbootimg

## Device identifier. This must come after all inclusions
PRODUCT_NAME := shrp_gtexslte
PRODUCT_DEVICE := gtexslte
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-T285
PRODUCT_MANUFACTURER := samsung
PRODUCT_CHARACTERISTICS := tablet

TARGET_SCREEN_WIDTH := 800
TARGET_SCREEN_HEIGHT := 1280

PRODUCT_COPY_FILES += \
    bionic/libc/zoneinfo/tzdata:recovery/root/system/usr/share/zoneinfo/tzdata

################################################
# SHRP specific build flags

TARGET_RECOVERY_FSTAB := device/samsung/gtexslte/twrp.fstab

#SHRP_EXPRESS := true
# Path of your SHRP Tree
SHRP_PATH := device/samsung/gtexslte
# Maintainer name
SHRP_MAINTAINER := steadfasterX
# Device codename
SHRP_DEVICE_CODE := $(PRODUCT_DEVICE)
# SHRP state
SHRP_OFFICIAL := true
# put this 0 if device has no EDL mode
SHRP_EDL_MODE := 0
SHRP_EXTERNAL := /external_sd
SHRP_INTERNAL := /sdcard
SHRP_OTG := /usb_otg
# Put 0 to disable flashlight
SHRP_FLASH := 0
# These are led paths, find yours then put here (Optional)
#SHRP_CUSTOM_FLASHLIGHT := true
#SHRP_FONP_1 := /sys/class/leds/led:torch_0/brightness
#SHRP_FONP_2 := /sys/class/leds/led:torch_1/brightness
#SHRP_FONP_3 := /sys/class/leds/led:switch/brightness
# Max Brightness of LED (Optional)
#SHRP_FLASH_MAX_BRIGHTNESS := 200
# Check your device's recovery path, dont use blindly
SHRP_REC := /dev/block/platform/sdio_emmc/by-name/RECOVERY
# Recovery Type (It can be treble,normal,SAR) [Only for About Section]
SHRP_REC_TYPE := normal
# Recovery Type (It can be A/B or A_only) [Only for About Section]
SHRP_DEVICE_TYPE := A_Only

# shrink size
SHRP_LITE := true
SHRP_EXCLUDE_DEFAULT_ADDONS := true
SHRP_SKIP_DEFAULT_ADDON_1 := true
SHRP_SKIP_DEFAULT_ADDON_2 := true
SHRP_SKIP_DEFAULT_ADDON_3 := true
SHRP_SKIP_DEFAULT_ADDON_4 := true
# recovery does not load when using LZMA!
#LZMA_RAMDISK_TARGETS := recovery
#LZMA_COMPRESSION := -9
TW_EXCLUDE_NANO := true
TW_EXCLUDE_BASH := true
TW_EXCLUDE_ENCRYPTED_BACKUPS := true
#TW_EXCLUDE_MTP := true
