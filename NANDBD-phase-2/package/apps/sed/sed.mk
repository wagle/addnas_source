
SED_VERSION:=4.1.5
SED_SOURCE:=sed-$(SED_VERSION).tar.gz
SED_DIR:=$(BUILD_DIR)/sed-$(SED_VERSION)

sed: $(ROOTFS_DIR)/bin/sed

$(ROOTFS_DIR)/bin/sed: $(SED_DIR)/sed/sed
	@install -d $(ROOTFS_DIR)/bin
	$(MAKE) DESTDIR=$(ROOTFS_DIR) CC=$(TARGET_CC) -C $(SED_DIR) install-exec &&	\
		mv $(ROOTFS_DIR)/usr/bin/sed $(ROOTFS_DIR)/bin/

$(SED_DIR)/sed/sed: $(SED_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(SED_DIR)
 
$(SED_DIR)/.configured: $(SED_DIR)/.patched
	(cd $(SED_DIR); rm -rf config.cache; \
		CPPFLAGS="-D_FILE_OFFSET_BITS=64" \
		./configure \
		--target=$(GNU_TARGET_NAME)	\
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
	);
	@touch $@

$(SED_DIR)/.patched: $(SED_DIR)/.unpacked
	@script/patch-kernel.sh $(SED_DIR) package/apps/sed sed-*
	@touch $@

$(SED_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		(tar -xvf $(PKG_DIR)/$(SED_SOURCE))
	@touch $@

sed-clean:
	-$(MAKE) DESTDIR=$(ROOTFS_DIR) CC=$(TARGET_CC) -C $(SED_DIR) uninstall
	-$(MAKE) -C $(SED_DIR) clean
	@rm -rf $(ROOTFS_DIR)/bin/sed

sed-dirclean:
	@rm -rf $(SED_DIR)

ifeq ($(strip $(SDK_ROOTFS_APPS_SED)),y)
SDK_ROOTFS_PACKAGES += sed
endif

