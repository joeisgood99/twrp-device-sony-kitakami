LOCAL_PATH := $(call my-dir)

DTBTOOL := $(HOST_OUT_EXECUTABLES)/dtbtool
MKIVYBOOTIMG := $(HOST_OUT_EXECUTABLES)/mkivybootimg

# dtbtool is badly written. Pathnames to the dtc and dtb folders MUST have a trailing slash

INSTALLED_DTIMAGE_TARGET := $(PRODUCT_OUT)/dt.img
$(INSTALLED_DTIMAGE_TARGET): $(PRODUCT_OUT)/kernel $(DTBTOOL)
	@echo -e ${CL_CYN}"----- Making dt image ------"${CL_RST}
	$(call pretty,"Target dt image: $(INSTALLED_DTIMAGE_TARGET)")
	$(hide) $(DTBTOOL) -o $(INSTALLED_DTIMAGE_TARGET) -s $(BOARD_KERNEL_DTBPAGEESIZE) -p $(KERNEL_OUT)/scripts/dtc/ $(KERNEL_OUT)/arch/$(TARGET_KERNEL_ARCH)/boot/dts/
	@echo -e ${CL_CYN}"----- Made dt image --------"${CL_RST}

INSTALLED_BOOTIMAGE_TARGET := $(PRODUCT_OUT)/boot.img
$(INSTALLED_BOOTIMAGE_TARGET): $(MKIVYBOOTIMG) $(PRODUCT_OUT)/kernel $(INSTALLED_RAMDISK_TARGET) $(INSTALLED_DTIMAGE_TARGET) $(INTERNAL_BOOTIMAGE_FILES) 
	$(call pretty,"Boot image: $@")
	$(call append-dtb)
	$(hide) $(MKIVYBOOTIMG) --kernel $(PRODUCT_OUT)/kernel --ramdisk $(INSTALLED_RAMDISK_TARGET) --cmdline "$(BOARD_KERNEL_CMDLINE)" --base $(BOARD_KERNEL_BASE) --pagesize $(BOARD_KERNEL_PAGESIZE) --dt $(INSTALLED_DTIMAGE_TARGET) $(BOARD_MKBOOTIMG_ARGS) -o $(INSTALLED_BOOTIMAGE_TARGET)
	@echo -e ${CL_CYN}"----- Made boot image -----"${CL_RST}

INSTALLED_RECOVERYIMAGE_TARGET := $(PRODUCT_OUT)/recovery.img
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKIVYBOOTIMG) $(INSTALLED_DTIMAGE_TARGET) \
	$(recovery_ramdisk) \
	$(recovery_kernel) 
	@echo -e ${CL_CYN}"----- Making recovery image ------"${CL_RST}
	$(hide) $(MKIVYBOOTIMG) --kernel $(PRODUCT_OUT)/kernel --ramdisk $(PRODUCT_OUT)/ramdisk-recovery.img --cmdline "$(BOARD_KERNEL_CMDLINE)" --base $(BOARD_KERNEL_BASE) --pagesize $(BOARD_KERNEL_PAGESIZE) --dt $(INSTALLED_DTIMAGE_TARGET) $(BOARD_MKBOOTIMG_ARGS) -o $(INSTALLED_RECOVERYIMAGE_TARGET)
	@echo -e ${CL_CYN}"----- Made recovery image ----- "${CL_RST}

