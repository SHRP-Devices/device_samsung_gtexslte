LOCAL_PATH := $(call my-dir)

# custom mkbootimg
BOARD_PROVIDES_MKBOOTIMG := true
MKBOOTIMG := $(HOST_OUT_EXECUTABLES)/degas-mkbootimg
# override unsupported args
INTERNAL_MKBOOTIMG_VERSION_ARGS :=

DTBTOOL := ./scripts/mkdtimg.sh
INSTALLED_DTIMAGE_TARGET := $(TOP)/device/samsung/gtexslte/dt.img
INSTALLED_SEANDROID_IMAGE := $(TOP)/device/samsung/gtexslte/seandroid.img

# $(INSTALLED_DTIMAGE_TARGET): $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr $(INSTALLED_KERNEL_TARGET)
# 	@echo -e ${CL_CYN}"Start DT image: $@"${CL_RST}
# 	$(call pretty,"Target dt image: ${INSTALLED_DTIMAGE_TARGET}")
# 	$(hide) cd $(TOP)/kernel/samsung/gtexslte && $(DTBTOOL) -o $(INSTALLED_DTIMAGE_TARGET) -p $(KERNEL_OUT) -i $(TOP)/kernel/samsung/gtexslte/arch/arm/boot/dts/
# 	@echo -e ${CL_CYN}"Made DT image: $@"${CL_RST}

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(INSTALLED_DTIMAGE_TARGET) $(INSTALLED_SEANDROID_IMAGE)
	$(call pretty,"Target boot image: $@  ${MKBOOTIMG} ${INTERNAL_BOOTIMAGE_ARGS} ${BOARD_MKBOOTIMG_ARGS}")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --dt $(INSTALLED_DTIMAGE_TARGET) --signature $(INSTALLED_SEANDROID_IMAGE) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made boot image: $@"${CL_RST}
	@echo -e ${CL_GRN}"----- Lying about SEAndroid state to Samsung bootloader ------"${CL_RST}
	$(hide) echo -n "SEANDROIDENFORCE" >> $(INSTALLED_BOOTIMAGE_TARGET)

## Overload recoveryimg generation: Same as the original, + --dt arg
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(INSTALLED_DTIMAGE_TARGET) \
		$(recovery_ramdisk) \
		$(recovery_kernel)
	@echo -e ${CL_CYN}"----- Making recovery image ------"${CL_RST}
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made recovery image: $@"${CL_RST}
