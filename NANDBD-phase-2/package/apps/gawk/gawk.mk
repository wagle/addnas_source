
GAWK_VERSION:=3.1.5
GAWK_SOURCE:=gawk-$(GAWK_VERSION).tar.bz2
GAWK_DIR:=$(BUILD_DIR)/gawk-$(GAWK_VERSION)

gawk: $(ROOTFS_DIR)/usr/bin/gawk

$(ROOTFS_DIR)/usr/bin/gawk: $(GAWK_DIR)/gawk
	rm -f $(ROOTFS_DIR)/usr/bin/awk
	$(MAKE) DESTDIR=$(ROOTFS_DIR) -C $(GAWK_DIR) install-exec
	rm -f $(ROOTFS_DIR)/usr/bin/gawk-*
	(cd $(ROOTFS_DIR)/usr/bin; ln -snf gawk awk)

$(GAWK_DIR)/gawk: $(GAWK_DIR)/.configured
	$(MAKE) -C $(GAWK_DIR)

$(GAWK_DIR)/.configured: $(GAWK_DIR)/.unpacked
	(cd $(GAWK_DIR); rm -rf config.cache;	\
		ac_cv_func_getpgrp_void=yes \
		$(TARGET_CONFIGURE_OPTS)	\
		./configure	\
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libdir=/lib \
		--libexecdir=/usr/lib \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
	)
	touch $@

$(GAWK_DIR)/.patched: $(GAWK_DIR)/.unpacked
	@script/patch-kernel.sh $(GAWK_DIR) package/apps/gawk gawk\*.patch
	@touch $@

$(GAWK_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		(tar -xvf $(PKG_DIR)/$(GAWK_SOURCE))
	@touch $@

gawk-clean:
	-$(MAKE) DESTDIR=$(ROOTFS_DIR) -C $(GAWK_DIR) uninstall
	-$(MAKE) -C $(GAWK_DIR) clean

gawk-dirclean:
	rm -rf $(GAWK_DIR)

ifeq ($(strip $(SDK_ROOTFS_APPS_GAWK)),y)
SDK_ROOTFS_PACKAGES += gawk
endif

