LOCAL_PATH := $(call my-dir)

# custom mkbootimg
BOARD_PROVIDES_MKBOOTIMG := true
CUSTOM_MKBOOTIMG := $(HOST_OUT_EXECUTABLES)/degas-mkbootimg
# override unsupported args
#INTERNAL_MKBOOTIMG_VERSION_ARGS :=
TARGET_CUSTOM_DTBTOOL := $(TARGET_KERNEL_SOURCE)/scripts/mkdtimg.sh
INSTALLED_DTIMAGE_TARGET := $(PRODUCT_OUT)/dt.img

# ODIN pkg for TWRP
FLASH_IMAGE_TARGET ?= $(PRODUCT_OUT)/twrp_odin.tar

DTS_FILES := .sprd-scx35l_sharkls_gtexslte_rev00.dtb.dts .sprd-scx35l_sharkls_gtexslte_rev01.dtb.dts .sprd-scx35l_sharkls_gtexslte_rev02.dtb.dts .sprd-scx35l_sharkls_gtexslte_rev03.dtb.dts

# DTB
$(INSTALLED_DTIMAGE_TARGET): $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr $(INSTALLED_KERNEL_TARGET)
	@echo -e ${CL_CYN}"Start DT image: $@"${CL_RST}
	$(call pretty,"Target dt image: ${INSTALLED_DTIMAGE_TARGET}")
	$(hide) $(TARGET_CUSTOM_DTBTOOL) -o $(INSTALLED_DTIMAGE_TARGET) -ks $(TARGET_KERNEL_SOURCE) -ko $(PRODUCT_OUT)/obj/KERNEL_OBJ -i $(DTS_FILES)
	@echo -e ${CL_CYN}"Made DT image: $@"${CL_RST}

# RAMDISK.IMG
$(INSTALLED_RAMDISK_TARGET): $(MKBOOTFS) $(INTERNAL_RAMDISK_FILES) | $(MINIGZIP)
	$(call pretty,"Target ram disk: $@")
	@echo -e ${CL_GRN}"----- building external WiFi module ------"${CL_RST}
	$(hide) cp $(KERNEL_OUT)/Module.symvers $(TARGET_KERNEL_SOURCE)/external_module/wifi/
	$(hide) KERNEL_PATH=$(TARGET_KERNEL_SOURCE) $(TARGET_KERNEL_SOURCE)/build_kernel.sh modules
	$(hide) $(MKBOOTFS) -d $(TARGET_OUT) $(TARGET_ROOT_OUT) | $(BOOT_RAMDISK_COMPRESSOR) > $@
	$(hide) KERNEL_PATH=$(TARGET_KERNEL_SOURCE) $(TARGET_KERNEL_SOURCE)/build_kernel.sh clean

# BOOT.IMG
$(INSTALLED_BOOTIMAGE_TARGET): $(CUSTOM_MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(INSTALLED_DTIMAGE_TARGET)
	$(call pretty,"Target boot image: $@  ${CUSTOM_MKBOOTIMG} ${INTERNAL_BOOTIMAGE_ARGS} ${BOARD_MKBOOTIMG_ARGS}")
	$(hide) $(CUSTOM_MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --dt $(INSTALLED_DTIMAGE_TARGET) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_GRN}"----- faking selinux state for Samsung bootloader ------"${CL_RST}
	$(hide) echo -n "SEANDROIDENFORCE" >> $(INSTALLED_BOOTIMAGE_TARGET)
	@echo -e ${CL_CYN}"Made boot image: $@"${CL_RST}

# RECOVERY.IMG
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(INSTALLED_DTIMAGE_TARGET) \
		$(recovery_ramdisk) \
		$(recovery_kernel)
	@echo "Building RECOVERY Kernel"
	$(MAKE) $(MAKE_FLAGS) -C $(KERNEL_SRC) O=$(KERNEL_OUT) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) $(TARGET_PREBUILT_INT_KERNEL_TYPE) $(TARGET_RECOVERY_CONFIG)
	@echo "Building RECOVERY DTBs"
	$(MAKE) $(MAKE_FLAGS) -C $(KERNEL_SRC) O=$(KERNEL_OUT) ARCH=$(KERNEL_ARCH) KCONF=$(TARGET_RECOVERY_CONFIG) $(KERNEL_CROSS_COMPILE) dtbs
	echo "Building RECOVERY Kernel Modules"
	$(MAKE) $(MAKE_FLAGS) -C $(KERNEL_SRC) O=$(KERNEL_OUT) ARCH=$(KERNEL_ARCH) KCONF=$(TARGET_RECOVERY_CONFIG) $(KERNEL_CROSS_COMPILE) modules
	@echo -e ${CL_CYN}"----- Making recovery image ------"${CL_RST}
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	#$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made recovery image: $@"${CL_RST}
	@echo -e ${CL_GRN}"----- faking selinux state for Samsung bootloader ------"${CL_RST}
	$(hide) echo -n "SEANDROIDENFORCE" >> $(INSTALLED_RECOVERYIMAGE_TARGET)
	$(hide) tar -C $(PRODUCT_OUT) -H ustar -c recovery.img > $(FLASH_IMAGE_TARGET)
	@echo -e ${CL_CYN}"Made Odin flashable recovery tar: ${FLASH_IMAGE_TARGET}"${CL_RST}
 
