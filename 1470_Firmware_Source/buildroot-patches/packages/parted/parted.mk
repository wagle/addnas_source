#############################################################
#
# parted
#
#############################################################
PARTED_VERSION:=1.8.8
PARTED_SOURCE:=parted-$(PARTED_VERSION).tar.gz
PARTED_SITE:=http://ftp.gnu.org/gnu/parted/
PARTED_DIR:=$(BUILD_DIR)/parted-$(PARTED_VERSION)
PARTED_BINARY:=parted/parted
PARTED_TARGET_BINARY:=sbin/parted
PARTED_COMPILE_OPT:=--without-readline --disable-dynamic-loading --disable-nls --without-included-regex --disable-shared

$(DL_DIR)/$(PARTED_SOURCE):
	$(WGET) -P $(DL_DIR) $(PARTED_SITE)/$(PARTED_SOURCE)

$(PARTED_DIR)/.source: $(DL_DIR)/$(PARTED_SOURCE)
	$(ZCAT) $(DL_DIR)/$(PARTED_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@
	
parted-source: $(DL_DIR)/$(PARTED_SOURCE)

$(PARTED_DIR)/.unpacked: $(DL_DIR)/$(PARTED_SOURCE)
	$(ZCAT) $(DL_DIR)/$(PARTED_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(PARTED_DIR) package/parted/ parted\*.patch
	touch $@

$(PARTED_DIR)/.configured: $(PARTED_DIR)/.unpacked
	(cd $(PARTED_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/ \
		--sbindir=/sbin \
		$(PARTED_COMPILE_OPT) \
		)
		touch $@

$(PARTED_DIR)/$(PARTED_BINARY): $(PARTED_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(PARTED_DIR)

$(TARGET_DIR)/$(PARTED_TARGET_BINARY): $(PARTED_DIR)/$(PARTED_BINARY)
	$(MAKE1) PATH=$(TARGET_PATH) DESTDIR=$(TARGET_DIR) -C $(PARTED_DIR) install-exec
	rm -rf $(TARGET_DIR)/usr/man
	rm -rf $(TARGET_DIR)/usr/include

parted: uclibc e2fsprogs-libs $(TARGET_DIR)/$(PARTED_TARGET_BINARY)

parted-source: $(DL_DIR)/$(PARTED_SOURCE)

parted-clean:
	$(MAKE1) PATH=$(TARGET_PATH) DESTDIR=$(TARGET_DIR) -C $(PARTED_DIR) uninstall
	-$(MAKE) -C $(PARTED_DIR) clean

parted-dirclean:
	rm -rf $(PARTED_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################

ifeq ($(strip $(BR2_PACKAGE_PARTED)),y)
TARGETS+=parted
endif
