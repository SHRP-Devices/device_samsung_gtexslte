#########################################################
#
# TWRP SPECIFIC FLAGS
#
#########################################################

# Release name
PRODUCT_RELEASE_NAME := gtexslte

$(call inherit-product, build/target/product/embedded.mk)

PRODUCT_PACKAGES += \
	charger_res_images \
	charger \
	timekeep

PRODUCT_PACKAGES += \
	degas-mkbootimg

TARGET_RECOVERY_FSTAB := device/samsung/gtexslte/twrp.fstab

## Device identifier. This must come after all inclusions
PRODUCT_NAME := twrp_gtexslte
PRODUCT_DEVICE := gtexslte
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-T285
PRODUCT_MANUFACTURER := samsung
PRODUCT_CHARACTERISTICS := tablet

TARGET_SCREEN_WIDTH := 800
TARGET_SCREEN_HEIGHT := 1280

PRODUCT_COPY_FILES += \
    ionic/libc/zoneinfo/tzdata:recovery/root/system/usr/share/zoneinfo/tzdata
