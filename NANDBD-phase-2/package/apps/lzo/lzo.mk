
LZO_VERSION := 2.03
LZO_SOURCE := lzo-$(LZO_VERSION).tar.gz

LZO_DIR := $(BUILD_DIR)/lzo-$(LZO_VERSION)
LZO_TARGET := $(BUILD_DIR)/lzo-target
LZO_HOST := $(BUILD_DIR)/lzo-host

lzo-host: $(LZO_HOST)/usr/lib/liblzo2.a

mini-lzo: $(MINIFS_DIR)/usr/lib/liblzo2.so

lzo: $(ROOTFS_DIR)/usr/lib/liblzo2.so

$(ROOTFS_DIR)/usr/lib/liblzo2.so: $(LZO_TARGET)/src/.libs/liblzo2.so
	$(MAKE) -C $(LZO_TARGET) DESTDIR=$(ROOTFS_DIR) install-exec
	@rm -f $(addprefix $(ROOTFS_DIR)/usr/lib/, liblzo2.la liblzo2.a)

$(LZO_TARGET)/src/.libs/liblzo2.so: $(LZO_TARGET)/.configured
	$(MAKE) -C $(LZO_TARGET)

$(MINIFS_DIR)/usr/lib/liblzo2.so: $(LZO_TARGET)/src/.libs/liblzo2.so
	$(MAKE) -C $(LZO_TARGET) DESTDIR=$(MINIFS_DIR) install-exec
	@rm -f $(addprefix $(MINIFS_DIR)/usr/lib/, liblzo2.la liblzo2.a)

$(LZO_HOST)/usr/lib/liblzo2.a: $(LZO_HOST)/.configured
	$(MAKE) -C $(LZO_HOST)
	$(MAKE) -C $(LZO_HOST) DESTDIR=$(LZO_HOST) install

$(LZO_HOST)/.configured: $(LZO_DIR)/.patched
	@mkdir -p $(LZO_HOST)
	(cd $(LZO_HOST); rm -rf config.cache;	\
		$(LZO_DIR)/configure	\
		--prefix="/usr"	\
		--sysconfdir="/etc"	\
		--enable-shared	\
	)
	@touch $@

$(LZO_TARGET)/.configured: $(LZO_DIR)/.patched
	@mkdir -p $(LZO_TARGET)
	(cd $(LZO_TARGET); rm -rf config.cache;	\
		$(TARGET_CONFIGURE_OPTS)	\
		$(LZO_DIR)/configure	\
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix="/usr"	\
		--sysconfdir="/etc"	\
		--enable-shared	\
	)
	@touch $@

$(LZO_DIR)/.patched: $(LZO_DIR)/.unpacked
	@script/patch-kernel.sh $(LZO_DIR) package/apps/lzo lzo-\*.patch
	@touch $@

$(LZO_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		(tar -xvf $(PKG_DIR)/$(LZO_SOURCE))
	@touch $@

lzo-clean:
	-$(MAKE) -C $(LZO_TARGET) DESTDIR=$(ROOTFS_DIR) uninstall
	-$(MAKE) -C $(LZO_TARGET) clean

lzo-dirclean:
	@rm -rf $(LZO_TARGET)

lzo-host-clean:
	-$(MAKE) -C $(LZO_HOST) DESTDIR=$(LZO_HOST) uninstall
	-$(MAKE) -C $(LZO_HOST) clean

lzo-host-dirclean:
	@rm -rf $(LZO_HOST)

ifeq ($(strip $(SDK_ROOTFS_APPS_LZO)),y)
SDK_ROOTFS_PACKAGES += lzo
endif

