LOCAL_PATH := $(call my-dir)

# custom mkbootimg
BOARD_PROVIDES_MKBOOTIMG := true
CUSTOM_MKBOOTIMG := $(HOST_OUT_EXECUTABLES)/degas-mkbootimg
# override unsupported args
#INTERNAL_MKBOOTIMG_VERSION_ARGS :=
TARGET_CUSTOM_DTBTOOL := $(TARGET_KERNEL_SOURCE)/scripts/mkdtimg.sh
INSTALLED_DTIMAGE_TARGET := $(PRODUCT_OUT)/dt.img

# ODIN pkg for TWRP
TWRP_METAPATH := $(LOCAL_PATH)/recovery_zip/META-INF
BDATE := $(shell date +%F)
FLASH_IMAGE_TARGET ?= $(PRODUCT_OUT)/$(TARGET_PRODUCT)_$(BDATE)

DTS_FILES := .sprd-scx35l_sharkls_gtexslte_rev00.dtb.dts .sprd-scx35l_sharkls_gtexslte_rev01.dtb.dts .sprd-scx35l_sharkls_gtexslte_rev02.dtb.dts .sprd-scx35l_sharkls_gtexslte_rev03.dtb.dts

# DTB
$(INSTALLED_DTIMAGE_TARGET): $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr $(INSTALLED_KERNEL_TARGET)
	@echo -e ${CL_CYN}"###############################################################"${CL_RST}
	@echo -e ${CL_CYN}"Start DT image: $@"${CL_RST}
	@echo -e ${CL_CYN}"###############################################################"${CL_RST}
	$(call pretty,"Target dt image: ${INSTALLED_DTIMAGE_TARGET}")
	$(hide) $(TARGET_CUSTOM_DTBTOOL) -o $(INSTALLED_DTIMAGE_TARGET) -ks $(TARGET_KERNEL_SOURCE) -ko $(PRODUCT_OUT)/obj/KERNEL_OBJ -i $(DTS_FILES)
	@echo -e ${CL_CYN}"Made DT image: $@"${CL_RST}

# BOOT.IMG
$(INSTALLED_BOOTIMAGE_TARGET): $(CUSTOM_MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(INSTALLED_DTIMAGE_TARGET)
	@echo -e ${CL_CYN}"###############################################################"${CL_RST}
	$(call pretty,"Target boot image: $@  ${CUSTOM_MKBOOTIMG} ${INTERNAL_BOOTIMAGE_ARGS} ${BOARD_MKBOOTIMG_ARGS}")
	@echo -e ${CL_CYN}"###############################################################"${CL_RST}
	$(hide) $(CUSTOM_MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --dt $(INSTALLED_DTIMAGE_TARGET) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"###############################################################"${CL_RST}
	@echo -e ${CL_GRN}"----- faking selinux state for Samsung bootloader ------"${CL_RST}
	@echo -e ${CL_CYN}"###############################################################"${CL_RST}
	$(hide) echo -n "SEANDROIDENFORCE" >> $(INSTALLED_BOOTIMAGE_TARGET)
	@echo -e ${CL_CYN}"Made boot image: $@"${CL_RST}

# RECOVERY.IMG
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(INSTALLED_DTIMAGE_TARGET) \
		$(recovery_ramdisk) \
		$(recovery_kernel) 
	@echo -e ${CL_CYN}"###############################################################"${CL_RST}
	@echo -e ${CL_CYN}"----- Shrinking recovery image ------"${CL_RST}
	@echo -e ${CL_CYN}"###############################################################"${CL_RST}
	#$(LOCAL_PATH)/shrink.sh "$(PRODUCT_OUT)/recovery/root/twres/images"
	#$(LOCAL_PATH)/shrink.sh "$(PRODUCT_OUT)/recovery/root/twres/themeResources" # <--- causes glitched nav bar
	#$(LOCAL_PATH)/shrink.sh "$(PRODUCT_OUT)/recovery/root/twres/themeResources/accentResources/" # <-- causes glitched nav bar
	@rm -vr $(PRODUCT_OUT)/recovery/root/twres/themeResources/accentResources/pink/*
	@rm -vr $(PRODUCT_OUT)/recovery/root/twres/themeResources/accentResources/rpink/*
	@rm -vr $(PRODUCT_OUT)/recovery/root/twres/themeResources/accentResources/red
	@rm -vr $(PRODUCT_OUT)/recovery/root/twres/themeResources/accentResources/lred
	@rm -vr $(PRODUCT_OUT)/recovery/root/twres/themeResources/accentResources/indigo/*
	@rm -vr $(PRODUCT_OUT)/recovery/root/twres/themeResources/accentResources/brown
	@rm -vr $(PRODUCT_OUT)/recovery/root/twres/themeResources/accentResources/teal
	@rm -v $(PRODUCT_OUT)/ramdisk-recovery.img
	@echo -e ${CL_CYN}"###############################################################"${CL_RST}
	@echo -e ${CL_CYN}"----- Making recovery image (again) ------"${CL_RST}
	@echo -e ${CL_CYN}"###############################################################"${CL_RST}
	$(hide) $(MKBOOTFS) $(TARGET_RECOVERY_ROOT_OUT) > $(recovery_uncompressed_ramdisk)
	$(hide) $(RECOVERY_RAMDISK_COMPRESSOR) < $(recovery_uncompressed_ramdisk) > $(recovery_ramdisk)
	$(call build-recoveryimage-target,$@)
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"###############################################################"${CL_RST}
	@echo -e ${CL_GRN}"----- faking selinux state for Samsung bootloader ------"${CL_RST}
	@echo -e ${CL_CYN}"###############################################################"${CL_RST}
	$(hide) echo -n "SEANDROIDENFORCE" >> $(INSTALLED_RECOVERYIMAGE_TARGET)
	$(hide) cp $(PRODUCT_OUT)/recovery.img $(FLASH_IMAGE_TARGET).img
	$(hide) tar -C $(PRODUCT_OUT) -H ustar -c recovery.img > $(FLASH_IMAGE_TARGET)_odin.tar
	$(hide) cp -a $(TWRP_METAPATH) $(PRODUCT_OUT) && cd $(PRODUCT_OUT) && zip -r9 ${FLASH_IMAGE_TARGET}.zip recovery.img META-INF
	@echo -e ${CL_CYN}"###############################################################"${CL_RST}
	@echo -e ${CL_GRN}"----- Recovery images finished ------"${CL_RST}
	@echo -e ${CL_CYN}"  * $(TARGET_PRODUCT) image:\t\t$(FLASH_IMAGE_TARGET).img"${CL_RST}
	@echo -e ${CL_CYN}"  * Recovery for Odin:\t\t\t${FLASH_IMAGE_TARGET}_ODIN.tar"${CL_RST}
	@echo -e ${CL_CYN}"  * Recovery image:\t\t\t$@"${CL_RST}
	@echo -e ${CL_CYN}"  * Recovery as flashable recovery zip:\t${FLASH_IMAGE_TARGET}.zip"${CL_RST}
	@echo -e ${CL_GRN}"----- Recovery images finished ------"${CL_RST}
	@echo -e ${CL_CYN}"###############################################################"${CL_RST}
