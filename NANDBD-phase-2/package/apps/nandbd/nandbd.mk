
NANDBD_DIR := $(BASE_DIR)/package/apps/nandbd

mini-nandbd: $(MINIFS_DIR)/usr/sbin/nandbd

nandbd: $(ROOTFS_DIR)/usr/sbin/nandbd

$(ROOTFS_DIR)/usr/sbin/nandbd $(MINIFS_DIR)/usr/sbin/nandbd: $(NANDBD_DIR)/nandbd
	@install -d $(@D)
	@install -m 755 $< $@

PARTMAP = SDK_BUILD_NAND_STAGE1_BLOCK=$(SDK_BUILD_NAND_STAGE1_BLOCK)	\
	SDK_BUILD_NAND_STAGE1_BLOCK2=$(SDK_BUILD_NAND_STAGE1_BLOCK2)	\
	SDK_BUILD_NAND_STAGE2_BLOCK=$(SDK_BUILD_NAND_STAGE2_BLOCK)	\
	SDK_BUILD_NAND_STAGE2_BLOCK2=$(SDK_BUILD_NAND_STAGE2_BLOCK2)	\
	SDK_BUILD_NAND_KERNEL_BLOCK=$(SDK_BUILD_NAND_KERNEL_BLOCK)	\
	SDK_BUILD_NAND_KERNEL_BLOCK2=$(SDK_BUILD_NAND_KERNEL_BLOCK2)

$(NANDBD_DIR)/nandbd:
	$(MAKE) -C $(NANDBD_DIR) CROSS_COMPILE=$(CROSS_COMPILE) CFLAGS="$(TARGET_CFLAGS)" $(PARTMAP)

nandbd-clean nandbd-dirclean:
	-$(MAKE) -C $(NANDBD_DIR) CROSS_COMPILE=$(CROSS_COMPILE) clean
	@rm -rf $(ROOTFS_DIR)/usr/sbin/nandbd

# Kernel must support MTD drivers first, or it's useless
ifeq ($(strip $(SDK_ROOTFS_APPS_NANDBD)),y)
ifeq ($(strip $(SDK_BUILD_NAND_BOOT)),y)
SDK_ROOTFS_PACKAGES += nandbd
endif
endif

