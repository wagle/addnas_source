
MTD_UTILS_VERSION := 1.3.1
MTD_UTILS_SOURCE := mtd-utils-$(MTD_UTILS_VERSION).tar.bz2

MTD_UTILS_DIR := $(BUILD_DIR)/mtd-utils-$(MTD_UTILS_VERSION)
MKFS_UBIFS_DIR := $(MTD_UTILS_DIR)/mkfs.ubifs
UBI_UTILS_DIR := $(MTD_UTILS_DIR)/ubi-utils

MTD_UTILS_HOST := $(BUILD_DIR)/mtd-utils-host
MKFS_UBIFS_HOST := $(MTD_UTILS_HOST)/mkfs.ubifs
UBI_UTILS_HOST := $(MTD_UTILS_HOST)/ubi-utils

mini-mtd-utils: mini-e2fsprogs mini-zlib mini-lzo $(MINIFS_DIR)/usr/sbin/flash_eraseall

mtd-utils: e2fsprogs zlib lzo $(ROOTFS_DIR)/usr/sbin/flash_eraseall

$(ROOTFS_DIR)/usr/sbin/flash_eraseall: $(MTD_UTILS_DIR)/$(strip $(subst ",, $(SDK_TOOLCHAIN_PREFIX)))/flash_eraseall
	export PATH=$(SDK_TOOLCHAIN_PATH)/usr/bin:$(shell echo $$PATH); \
		cd $(MTD_UTILS_DIR); $(MAKE) LZOCPPFLAGS=-I$(LZO_DIR)/include	\
		LZOLDFLAGS=-L$(ROOTFS_DIR)/usr/lib \
		ZLIBCPPFLAGS=-I$(ZLIB_DIR) ZLIBLDFLAGS=-L$(ROOTFS_DIR)/usr/lib	\
		CROSS=$(SDK_TOOLCHAIN_PREFIX)-	\
		CC="$(TARGET_CC) $(TARGET_CFLAGS)" DESTDIR=$(ROOTFS_DIR) install
	-@rm -rf $(ROOTFS_DIR)/usr/share/man

$(MINIFS_DIR)/usr/sbin/flash_eraseall: $(MTD_UTILS_DIR)/$(strip $(subst ",, $(SDK_TOOLCHAIN_PREFIX)))/flash_eraseall
	export PATH=$(SDK_TOOLCHAIN_PATH)/usr/bin:$(shell echo $$PATH); \
		cd $(MTD_UTILS_DIR); $(MAKE) LZOCPPFLAGS=-I$(LZO_DIR)/include	\
		LZOLDFLAGS=-L$(ROOTFS_DIR)/usr/lib \
		ZLIBCPPFLAGS=-I$(ZLIB_DIR) ZLIBLDFLAGS=-L$(ROOTFS_DIR)/usr/lib	\
		CROSS=$(SDK_TOOLCHAIN_PREFIX)-	\
		CC="$(TARGET_CC) $(TARGET_CFLAGS)" DESTDIR=$(MINIFS_DIR) install
	-@rm -rf $(MINIFS_DIR)/usr/share/man

$(MTD_UTILS_DIR)/$(strip $(subst ",, $(SDK_TOOLCHAIN_PREFIX)))/flash_eraseall: $(MTD_UTILS_DIR)/.patched
	export PATH=$(SDK_TOOLCHAIN_PATH)/usr/bin:$(shell echo $$PATH); \
		cd $(MTD_UTILS_DIR); $(MAKE) LZOCPPFLAGS=-I$(LZO_DIR)/include	\
		LZOLDFLAGS=-L$(ROOTFS_DIR)/usr/lib \
		ZLIBCPPFLAGS=-I$(ZLIB_DIR) ZLIBLDFLAGS=-L$(ROOTFS_DIR)/usr/lib	\
		CROSS=$(SDK_TOOLCHAIN_PREFIX)-	\
		CFLAGS=-I$(E2FSPROGS_DIR)/lib	\
		LDFLAGS=-L$(E2FSPROGS_DIR)/lib	\
		CC="$(TARGET_CC) $(TARGET_CFLAGS)"

mkfs.ubifs-host: lzo-host $(MKFS_UBIFS_HOST)/mkfs.ubifs

ubinize-host: lzo-host $(UBI_UTILS_HOST)/ubinize

$(MKFS_UBIFS_HOST)/mkfs.ubifs $(UBI_UTILS_HOST)/ubinize: $(MTD_UTILS_HOST)/.patched
	cd $(MTD_UTILS_HOST); $(MAKE) LZOCPPFLAGS=-I$(LZO_HOST)/usr/include LZOLDFLAGS=-L$(LZO_HOST)/usr/lib

$(MTD_UTILS_HOST)/.unpacked:
	@mkdir -p $(MTD_UTILS_HOST)
	@cd $(MTD_UTILS_HOST);	\
		(tar -jxvf $(PKG_DIR)/$(MTD_UTILS_SOURCE) --strip-components 1)
	@touch $@

$(MTD_UTILS_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		(tar -jxvf $(PKG_DIR)/$(MTD_UTILS_SOURCE))
	@touch $@

$(MTD_UTILS_HOST)/.patched: $(MTD_UTILS_HOST)/.unpacked
	@script/patch-kernel.sh $(MTD_UTILS_HOST) package/apps/mtd-utils mtd-utils-$(MTD_UTILS_VERSION)-all\*.patch
	@touch $@

$(MTD_UTILS_DIR)/.patched: $(MTD_UTILS_DIR)/.unpacked
	@script/patch-kernel.sh $(MTD_UTILS_DIR) package/apps/mtd-utils mtd-utils-\*.patch
	@touch $@

mtd-utils-clean:
	-@export PATH=$(SDK_TOOLCHAIN_PATH)/usr/bin:$(shell echo $$PATH); \
		cd $(MTD_UTILS_DIR) && $(MAKE) LZOCPPFLAGS=-I$(LZO_DIR)/include	\
		LZOLDFLAGS=-L$(LZO_TARGET)/src/.libs CROSS=$(SDK_TOOLCHAIN_PREFIX)- DESTDIR=$(ROOTFS_DIR) clean

mtd-utils-dirclean:
	@rm -rf $(MTD_UTILS_DIR)

ifeq ($(strip $(SDK_ROOTFS_MTD_UTILS)),y)
SDK_ROOTFS_PACKAGES += mtd-utils
endif

