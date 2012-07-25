
GREP_VERSION:=2.5.3
GREP_SOURCE:=grep-$(GREP_VERSION).tar.bz2
GREP_DIR:=$(BUILD_DIR)/grep-$(GREP_VERSION)
GREP_BINARY:=src/grep
GREP_TARGET_BINARY:=bin/grep

ifeq ($(strip $(SDK_LIBC_TYPE)), uClibc)
grep: libintl $(ROOTFS_DIR)/bin/grep
else
grep: $(ROOTFS_DIR)/bin/grep
endif

$(ROOTFS_DIR)/bin/grep: $(GREP_DIR)/src/grep
	@if [ -L $(ROOTFS_DIR)/bin/grep ]; then \
		rm -f $(ROOTFS_DIR)/bin/grep; fi
	@if [ ! -f $(GREP_DIR)/src/grep -o $(ROOTFS_DIR)/bin/grep -ot \
	$(GREP_DIR)/src/grep ]; then \
	    set -x; \
	    rm -f $(ROOTFS_DIR)/bin/grep $(ROOTFS_DIR)/bin/egrep $(ROOTFS_DIR)/bin/fgrep; \
		install -d $(ROOTFS_DIR)/bin;	\
	    cp -a $(GREP_DIR)/src/grep $(GREP_DIR)/src/egrep \
		$(GREP_DIR)/src/fgrep $(ROOTFS_DIR)/bin/; fi

$(GREP_DIR)/src/grep: $(GREP_DIR)/.configured
	$(MAKE) -C $(GREP_DIR)

$(GREP_DIR)/.configured: $(GREP_DIR)/.patched
	(cd $(GREP_DIR); rm -rf config.cache; \
		ac_cv_func_mmap_fixed_mapped=yes \
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
		--disable-perl-regexp \
		--without-included-regex \
	)
	touch $@

$(GREP_DIR)/.patched: $(GREP_DIR)/.unpacked
	@script/patch-kernel.sh $(GREP_DIR) package/apps/grep grep-*
	@touch $@

$(GREP_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		(tar -xvf $(PKG_DIR)/$(GREP_SOURCE))
	@touch $@

grep-clean:
	@rm -f $(addprefix $(ROOTFS_DIR)/bin/, grep egrep fgrep)
	-$(MAKE) -C $(GREP_DIR) clean

grep-dirclean:
	rm -rf $(GREP_DIR)

ifeq ($(strip $(SDK_ROOTFS_APPS_GREP)),y)
SDK_ROOTFS_PACKAGES += grep
endif

