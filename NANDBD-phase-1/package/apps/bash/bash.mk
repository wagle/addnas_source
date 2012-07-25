
BASH_VERSION := 3.1
BASH_SOURCE := bash-$(BASH_VERSION).tar.gz
BASH_DIR := $(BUILD_DIR)/bash-$(BASH_VERSION)

$(BASH_DIR)/.patched: $(BASH_DIR)/.unpacked
	@script/patch-kernel.sh $(BASH_DIR) package/apps/bash bash??-*
	# This is broken when -lintl is added to LIBS
	@$(SED) 's,LIBS_FOR_BUILD =.*,LIBS_FOR_BUILD =,g' \
		$(BASH_DIR)/builtins/Makefile.in
	@touch $@

$(BASH_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		(tar -xvf $(PKG_DIR)/$(BASH_SOURCE))
	@$(CONFIG_UPDATE) $(BASH_DIR)/support
	@touch $@

bash-clean:
	-$(MAKE) DESTDIR=$(ROOTFS_DIR) CC=$(TARGET_CC) -C $(BASH_DIR) uninstall
	-$(MAKE) -C $(BASH_DIR) clean

bash-dirclean:
	@rm -rf $(BASH_DIR)

$(BASH_DIR)/.configured: $(BASH_DIR)/.patched
	#		bash_cv_have_mbstate_t=yes
	(cd $(BASH_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS)	\
		ac_cv_func_setvbuf_reversed=no \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libexecdir=/usr/lib \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--mandir=/usr/man \
		--infodir=/usr/info \
		--with-curses \
		--enable-alias \
		--without-bash-malloc \
	);
	@touch $@

$(BASH_DIR)/bash: $(BASH_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) CC_FOR_BUILD="$(HOSTCC)" -C $(BASH_DIR)

$(ROOTFS_DIR)/bin/bash: $(BASH_DIR)/bash
	$(MAKE) DESTDIR=$(ROOTFS_DIR) CC=$(TARGET_CC) -C $(BASH_DIR) install
	rm -f $(ROOTFS_DIR)/bin/bash*
	mv $(ROOTFS_DIR)/usr/bin/bash* $(ROOTFS_DIR)/bin/
	(cd $(ROOTFS_DIR)/bin; /bin/ln -sf bash sh)
	rm -rf $(ROOTFS_DIR)/share/locale $(ROOTFS_DIR)/usr/info	\
		$(ROOTFS_DIR)/usr/man $(ROOTFS_DIR)/usr/share/doc

$(MINIFS_DIR)/bin/bash: $(BASH_DIR)/bash
	$(MAKE) DESTDIR=$(MINIFS_DIR) CC=$(TARGET_CC) -C $(BASH_DIR) install
	rm -f $(MINIFS_DIR)/bin/bash*
	mv $(MINIFS_DIR)/usr/bin/bash* $(MINIFS_DIR)/bin/
	(cd $(MINIFS_DIR)/bin; /bin/ln -sf bash sh)
	rm -rf $(MINIFS_DIR)/share/locale $(MINIFS_DIR)/usr/info	\
		$(MINIFS_DIR)/usr/man $(MINIFS_DIR)/usr/share/doc

mini-bash: mini-ncurses $(MINIFS_DIR)/bin/bash

ifeq ($(SDK_ROOTFS_APPS_BUSYBOX),y)
bash: ncurses busybox $(ROOTFS_DIR)/bin/bash
else
bash: ncurses $(ROOTFS_DIR)/bin/bash
endif

ifeq ($(strip $(SDK_ROOTFS_APPS_BASH)),y)
SDK_ROOTFS_PACKAGES += bash
endif
