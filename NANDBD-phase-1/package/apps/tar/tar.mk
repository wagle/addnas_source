
GNUTAR_VERSION:=1.21
GNUTAR_SOURCE:=tar-$(GNUTAR_VERSION).tar.bz2
GNUTAR_DIR:=$(BUILD_DIR)/tar-$(GNUTAR_VERSION)

tar: $(ROOTFS_DIR)/bin/tar

$(ROOTFS_DIR)/bin/tar: $(GNUTAR_DIR)/src/tar
	@if [ -L $(ROOTFS_DIR)/bin/tar ]; then \
		rm -f $(ROOTFS_DIR)/bin/tar; \
	fi
	@if [ ! -f $(GNUTAR_DIR)/src/tar -o $(ROOTFS_DIR)/bin/tar \
		-ot $(GNUTAR_DIR)/src/tar ]; then \
		set -x; \
		rm -f $(ROOTFS_DIR)/bin/tar; \
		install -d $(ROOTFS_DIR)/bin;	\
		cp -a $(GNUTAR_DIR)/src/tar \
			$(ROOTFS_DIR)/bin/tar; \
	fi

$(GNUTAR_DIR)/src/tar: $(GNUTAR_DIR)/.configured
	$(MAKE) -C $(GNUTAR_DIR)

$(GNUTAR_DIR)/.configured: $(GNUTAR_DIR)/.patched
	(cd $(GNUTAR_DIR); rm -rf config.cache; \
		ac_cv_func_chown_works=yes \
		gl_cv_func_chown_follows_symlink=yes \
		$(TARGET_CONFIGURE_OPTS)	\
		./configure \
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
		--mandir=/usr/man \
		--infodir=/usr/info \
	)
	touch $@

$(GNUTAR_DIR)/.patched: $(GNUTAR_DIR)/.unpacked
	@script/patch-kernel.sh $(GNUTAR_DIR) package/apps/tar tar\*.patch
	@touch $@

$(GNUTAR_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		(tar -xvf $(PKG_DIR)/$(GNUTAR_SOURCE))
	@touch $@

tar-clean:
	-$(MAKE) DESTDIR=$(ROOTFS_DIR) -C $(GNUTAR_DIR) uninstall
	-$(MAKE) -C $(GNUTAR_DIR) clean

tar-dirclean:
	rm -rf $(GNUTAR_DIR)

ifeq ($(strip $(SDK_ROOTFS_APPS_TAR)),y)
SDK_ROOTFS_PACKAGES += tar
endif
