
KERNEL_VERSION := 2.6.31
KERNEL_SOURCE := linux-kernel.tar.bz2
KERNEL_DIR := $(BUILD_DIR)/linux-kernel
KERNEL_CONFIG := $(KERNEL_DIR)/.config
KERNEL_IMAGE_DIR := $(KERNEL_DIR)/arch/arm/boot

BOOT_TOOL_DIR := $(UBOOT_DIR)/tools
KERNEL_ENV_PATH := $(BOOT_TOOL_DIR):$(shell echo $$PATH)

kernel: boot-tools $(OUTPUT_DIR)/uImage

$(OUTPUT_DIR)/uImage: $(KERNEL_IMAGE_DIR)/uImage
	@$(INSTALL) $< $@

$(KERNEL_IMAGE_DIR)/uImage: $(KERNEL_DIR)/.oxconfig
	export PATH=$(KERNEL_ENV_PATH); $(MAKE) -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) uImage

mini-kernel-modules: kernel depmod
	export PATH=$(KERNEL_ENV_PATH); $(MAKE) -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) modules
	export INSTALL_MOD_PATH=$(MINIFS_DIR);	\
		$(MAKE) -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) modules_install

kernel-modules: kernel depmod
	export PATH=$(KERNEL_ENV_PATH); $(MAKE) -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) modules
	export INSTALL_MOD_PATH=$(ROOTFS_DIR);	\
		$(MAKE) -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) modules_install

$(KERNEL_DIR)/.oxconfig: $(KERNEL_DIR)/.configured
ifeq ($(strip $(subst ",, $(SDK_BUILD_NAND_BOOT))), y)
#"))
	@$(call board_config_kernel, NAND_BOOT, $(KERNEL_CONFIG))
else
	@$(call board_config_kernel, DISK_BOOT, $(KERNEL_CONFIG))
endif
	# TSI board customization ...
	$(call set_config, CONFIG_PCI, y, n, set, $(KERNEL_CONFIG))
	$(MAKE) -C $(KERNEL_DIR) oldconfig
	@touch $@

ifeq ($(strip $(subst ",, $(SDK_TARGET_PLATFORM))), 7820)
KERN_DEFCONFIG := ox820_testbrd_smp_TxSRAM_defconfig
#"))
endif
ifeq ($(strip $(subst ",, $(SDK_TARGET_PLATFORM))), 7821)
KERN_DEFCONFIG := ox7821_testbrd_smp_TxSRAM_defconfig
#"))
endif
ifeq ($(strip $(subst ",, $(SDK_TARGET_PLATFORM))), 7825_SINGLE)
KERN_DEFCONFIG := ox7825_singleSATA_singleGigE_TxSRAM_defconfig
#"))
endif
ifeq ($(strip $(subst ",, $(SDK_TARGET_PLATFORM))), 7825_RAID)
KERN_DEFCONFIG := ox7825_dualSATA_singleGigE_TxSRAM_defconfig
#"))
endif
$(KERNEL_DIR)/.configured: $(KERNEL_DIR)/.patched
	$(MAKE) -C $(KERNEL_DIR)	\
		CROSS_COMPILE=$(CROSS_COMPILE) $(KERN_DEFCONFIG)
	@touch $@

$(KERNEL_DIR)/.patched: $(KERNEL_DIR)/.unpacked
	@script/patch-kernel.sh $(KERNEL_DIR)	\
		package/oxsemi/kernel kernel-\*.patch
	@$(SED) 's/^\(DEPMOD\s*=\s*\)\/sbin\/\(depmod\)/\1'$(SED_MODINIT_TOOL_DIR)'\/\2/' $(KERNEL_DIR)/Makefile
	@touch $@

$(KERNEL_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		tar -xvf $(SDK_DIR)/$(KERNEL_SOURCE)
	@touch $@

kernel-clean:
	@rm -rf $(OUTPUT_DIR)/uImage
	@rm -rf $(ROOTFS_DIR)/lib/modules/$(KERNEL_VERSION)*
	-$(MAKE) -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) clean

kernel-dirclean:
	@rm -rf $(KERNEL_DIR)

