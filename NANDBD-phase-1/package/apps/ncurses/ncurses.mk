
NCURSES_VERSION:=5.6
NCURSES_SOURCE:=ncurses-$(NCURSES_VERSION).tar.gz
NCURSES_DIR:=$(BUILD_DIR)/ncurses-$(NCURSES_VERSION)

ncurses: $(ROOTFS_DIR)/lib/libncurses.so

$(ROOTFS_DIR)/lib/libncurses.so: $(NCURSES_DIR)/lib/libncurses.so
	@$(INSTALL) -d $(addprefix $(ROOTFS_DIR), /lib /usr/lib)
	@cp -af $(NCURSES_DIR)/lib/libncurses.so* $(@D)
	@cd $(ROOTFS_DIR)/lib;	\
		$(LN) -sf `readlink libncurses.so` libcurses.so
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(NCURSES_DIR) install.includes
	@rm -f $(ROOTFS_DIR)/usr/lib/terminfo
	ln -sf /usr/share/terminfo $(ROOTFS_DIR)/usr/lib/terminfo
	touch -c $@

$(NCURSES_DIR)/lib/libncurses.so: $(NCURSES_DIR)/.configured
	$(MAKE) -C $(NCURSES_DIR) libs panel menu form headers

$(NCURSES_DIR)/.configured: $(NCURSES_DIR)/.patched
	(cd $(NCURSES_DIR); rm -rf config.cache; \
		BUILD_CC="$(HOSTCC)" \
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
		--includedir=/usr/include \
		--mandir=/usr/man \
		--infodir=/usr/info \
		--with-terminfo-dirs=/usr/share/terminfo \
		--with-default-terminfo-dir=/usr/share/terminfo \
		--with-shared --without-cxx --without-cxx-binding \
		--without-ada --without-progs --disable-big-core \
		--without-profile --without-debug --disable-rpath \
		--enable-echo --enable-const --enable-overwrite \
		--enable-broken_linker \
		--disable-static	\
	)
	touch $@

$(NCURSES_DIR)/.patched: $(NCURSES_DIR)/.unpacked
	@script/patch-kernel.sh $(@D) package/apps/ncurses ncurses\*.patch
	$(SED) 's~\$$srcdir/shlib tic\$$suffix~/usr/bin/tic~' \
        $(NCURSES_DIR)/misc/run_tic.in
	@touch $@

$(NCURSES_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		(tar -xvf $(PKG_DIR)/$(NCURSES_SOURCE))
	@touch $@

ncurses-clean:
	-$(MAKE) DESTDIR=$(ROOTFS_DIR) -C $(NCURSES_DIR) uninstall.includes
	rm -f $(ROOTFS_DIR)/usr/lib/terminfo
	rm -rf $(ROOTFS_DIR)/lib/libncurses.so*
	-$(MAKE) -C $(NCURSES_DIR) clean

ncurses-dirclean:
	@rm -rf $(NCURSES_DIR)

mini-ncurses: $(MINIFS_DIR)/lib/libncurses.so

$(MINIFS_DIR)/lib/libncurses.so: $(NCURSES_DIR)/lib/libncurses.so
	@$(INSTALL) -d $(addprefix $(MINIFS_DIR), /lib /usr/lib)
	@cp -af $(NCURSES_DIR)/lib/libncurses.so* $(@D)
	@cd $(@D);	\
		$(LN) -sf `readlink libncurses.so` libcurses.so
	@rm -f $(MINIFS_DIR)/usr/lib/terminfo
	ln -sf /usr/share/terminfo $(MINIFS_DIR)/usr/lib/terminfo
	touch -c $@

ifeq ($(strip $(SDK_ROOTFS_APPS_NCURSES)),y)
SDK_ROOTFS_PACKAGES += ncurses
endif

