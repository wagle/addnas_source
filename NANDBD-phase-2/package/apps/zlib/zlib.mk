
ZLIB_VERSION:=1.2.3
ZLIB_SOURCE:=zlib-$(ZLIB_VERSION).tar.bz2
ZLIB_DIR:=$(BUILD_DIR)/zlib-$(ZLIB_VERSION)

ZLIB_CFLAGS:=-fPIC
ZLIB_CFLAGS+=-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64

zlib: $(ROOTFS_DIR)/usr/lib/libz.so

$(ROOTFS_DIR)/usr/lib/libz.so: $(ZLIB_DIR)/libz.so
	$(INSTALL) -D $(ZLIB_DIR)/zlib.h $(STAGING_DIR)/usr/include/zlib.h
	$(INSTALL) $(ZLIB_DIR)/zconf.h $(STAGING_DIR)/usr/include/
	$(INSTALL) -d $(STAGING_DIR)/usr/lib
	cp -dpf $(ZLIB_DIR)/libz.so* $(STAGING_DIR)/usr/lib/
	@install -d $(ROOTFS_DIR)/usr/lib
	cp -af $(ZLIB_DIR)/libz.* $(ROOTFS_DIR)/usr/lib

mini-zlib: $(MINIFS_DIR)/usr/lib/libz.so

$(MINIFS_DIR)/usr/lib/libz.so: $(ZLIB_DIR)/libz.so
	@install -d $(MINIFS_DIR)/usr/lib
	cp -af $(ZLIB_DIR)/libz.* $(MINIFS_DIR)/usr/lib

$(ZLIB_DIR)/libz.so: $(ZLIB_DIR)/.configured
	$(MAKE) -C $(ZLIB_DIR)

$(ZLIB_DIR)/.configured: $(ZLIB_DIR)/.patched
	(cd $(ZLIB_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS)	\
		CFLAGS="$(TARGET_CFLAGS) $(ZLIB_CFLAGS)" \
		./configure \
		--shared \
		--prefix=/usr \
		--exec-prefix=/usr/bin \
		--libdir=/usr/lib \
		--includedir=/usr/include \
	)
	touch $@

$(ZLIB_DIR)/.patched: $(ZLIB_DIR)/.unpacked
	@script/patch-kernel.sh $(ZLIB_DIR) package/apps/zlib zlib-\*.patch
	@touch $@

$(ZLIB_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		(tar -xvf $(PKG_DIR)/$(ZLIB_SOURCE))
	@touch $@

zlib-clean:
	rm -f $(ROOTFS_DIR)/usr/lib/libz.so*
	-$(MAKE) -C $(ZLIB_DIR) clean

zlib-dirclean:
	rm -rf $(ZLIB_DIR)

ifeq ($(strip $(SDK_ROOTFS_APPS_ZLIB)),y)
SDK_ROOTFS_PACKAGES += zlib
endif

