#############################################################
#
# fakeroot
#
#############################################################
FAKEROOT_VERSION:=1.9.3
FAKEROOT_SOURCE:=fakeroot_$(FAKEROOT_VERSION).tar.gz
FAKEROOT_SOURCE_DIR:=$(BUILD_DIR)/fakeroot-$(FAKEROOT_VERSION)
FAKEROOT_DIR1:=$(BUILD_DIR)/fakeroot-$(FAKEROOT_VERSION)-host
FAKEROOT_DIR2:=$(BUILD_DIR)/fakeroot-$(FAKEROOT_VERSION)-target

#############################################################
#
# build fakeroot for use on the host system
#
#############################################################

$(FAKEROOT_SOURCE_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		(tar -xvf $(PKG_DIR)/$(FAKEROOT_SOURCE))
	@touch $@

$(FAKEROOT_SOURCE_DIR)/.patched: $(FAKEROOT_SOURCE_DIR)/.unpacked
	# If using busybox getopt, make it be quiet.
	$(SED) "s,getopt --version,getopt --version 2>/dev/null," \
		$(FAKEROOT_SOURCE_DIR)/scripts/fakeroot.in
	@script/patch-kernel.sh $(FAKEROOT_SOURCE_DIR)	\
		package/tools/fakeroot fakeroot\*.patch
	@touch $@

$(FAKEROOT_DIR1)/.configured: $(FAKEROOT_SOURCE_DIR)/.patched
	mkdir -p $(FAKEROOT_DIR1)
	(cd $(FAKEROOT_DIR1); rm -rf config.cache; \
		CC="$(HOSTCC)" \
		$(FAKEROOT_SOURCE_DIR)/configure \
		--prefix=/usr \
	)
	@touch $@

$(FAKEROOT_DIR1)/faked: $(FAKEROOT_DIR1)/.configured
	$(MAKE) -C $(FAKEROOT_DIR1)
	@touch -c $@

$(FAKEROOT_DIR1)/usr/bin/fakeroot: $(FAKEROOT_DIR1)/faked
	$(MAKE) DESTDIR=$(FAKEROOT_DIR1) -C $(FAKEROOT_DIR1) install
	@$(SED) 's,^PREFIX=.*,PREFIX=$(FAKEROOT_DIR1)/usr,g' $(FAKEROOT_DIR1)/usr/bin/fakeroot
	@$(SED) 's,^BINDIR=.*,BINDIR=$(FAKEROOT_DIR1)/usr/bin,g' $(FAKEROOT_DIR1)/usr/bin/fakeroot
	@$(SED) 's,^PATHS=.*,PATHS=$(FAKEROOT_DIR1)/.libs:/lib:/usr/lib,g' $(FAKEROOT_DIR1)/usr/bin/fakeroot
	@$(SED) "s,^libdir=.*,libdir=\'$(FAKEROOT_DIR1)/usr/lib\',g" \
		$(FAKEROOT_DIR1)/usr/lib/libfakeroot.la
	@touch -c $@

fakeroot-host: $(FAKEROOT_DIR1)/usr/bin/fakeroot

fakeroot-host-clean:
	-$(MAKE) -C $(FAKEROOT_DIR1) clean

fakeroot-host-cleanall:
	@rm -rf $(FAKEROOT_DIR1)
