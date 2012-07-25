
E2FSPROGS_VERSION:=1.41.11
E2FSPROGS_SOURCE=e2fsprogs-$(E2FSPROGS_VERSION).tar.gz
E2FSPROGS_DIR := $(BUILD_DIR)/e2fsprogs-$(E2FSPROGS_VERSION)

e2fsprogs: $(ROOTFS_DIR)/sbin/mke2fs

$(ROOTFS_DIR)/sbin/mke2fs: $(E2FSPROGS_DIR)/misc/mke2fs
	$(MAKE) -C $(E2FSPROGS_DIR) DESTDIR=$(ROOTFS_DIR) install install-shlibs
	@rm -rf $(ROOTFS_DIR)/usr/share/info $(ROOTFS_DIR)/usr/share/locale $(ROOTFS_DIR)/usr/share/man

mini-e2fsprogs: $(MINIFS_DIR)/sbin/mke2fs

$(MINIFS_DIR)/sbin/mke2fs: $(E2FSPROGS_DIR)/misc/mke2fs
	$(MAKE) -C $(E2FSPROGS_DIR) DESTDIR=$(MINIFS_DIR) install install-shlibs
	@rm -rf $(MINIFS_DIR)/usr/share/info $(MINIFS_DIR)/usr/share/locale $(MINIFS_DIR)/usr/share/man

$(E2FSPROGS_DIR)/misc/mke2fs: $(E2FSPROGS_DIR)/.configured
	$(MAKE) -C $(E2FSPROGS_DIR)

$(E2FSPROGS_DIR)/.configured: $(E2FSPROGS_DIR)/.patched
	(cd $(E2FSPROGS_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS)	\
		./configure	\
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/bin \
		--sbindir=/sbin \
		--libdir=/lib \
		--libexecdir=/usr/lib \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--disable-tls \
		--enable-elf-shlibs \
		--disable-debugfs \
		--disable-imager \
		--disable-resizer \
		--enable-fsck \
		--disable-e2initrd-helper \
		--disable-testio-debug	\
	)
	touch $@

$(E2FSPROGS_DIR)/.patched: $(E2FSPROGS_DIR)/.unpacked
	@script/patch-kernel.sh $(@D) package/apps/e2fsprogs e2fsprogs\*.patch
	@touch $@

$(E2FSPROGS_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		(tar -xvf $(PKG_DIR)/$(E2FSPROGS_SOURCE))
	@touch $@

e2fsprogs-clean:
	-$(MAKE) DESTDIR=$(ROOTFS_DIR) -C $(E2FSPROGS_DIR) uninstall
	-$(MAKE) -C $(E2FSPROGS_DIR) clean

e2fsprogs-dirclean:
	@rm -rf $(E2FSPROGS_DIR)

ifeq ($(strip $(SDK_ROOTFS_APPS_E2FSPROGS)),y)
SDK_ROOTFS_PACKAGES += e2fsprogs
endif

