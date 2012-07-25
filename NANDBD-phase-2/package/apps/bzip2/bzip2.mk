
BZIP2_VERSION:=1.0.5
BZIP2_SONAME=1.0.4
BZIP2_SOURCE:=bzip2-$(BZIP2_VERSION).tar.gz
BZIP2_DIR:=$(BUILD_DIR)/bzip2-$(BZIP2_VERSION)

bzip2: $(ROOTFS_DIR)/usr/bin/bzip2

$(ROOTFS_DIR)/usr/bin/bzip2: $(BZIP2_DIR)/bzip2
	$(INSTALL) -D -m 0644 $(BZIP2_DIR)/libbz2.so.$(BZIP2_SONAME)	\
		$(ROOTFS_DIR)/usr/lib/libbz2.so.$(BZIP2_SONAME)
	(cd $(ROOTFS_DIR)/usr/lib;	\
		ln -snf libbz2.so.$(BZIP2_SONAME) libbz2.so.1.0;	\
		ln -snf libbz2.so.$(BZIP2_SONAME) libbz2.so;	\
	)
	$(INSTALL) -d $(ROOTFS_DIR)/usr/bin
	$(INSTALL) -m 0755 $(addprefix $(BZIP2_DIR)/, \
		bzip2 bzmore bzip2recover bzgrep bzdiff)	\
		$(ROOTFS_DIR)/usr/bin
	(cd $(ROOTFS_DIR)/usr/bin;	\
		ln -snf bzip2 bunzip2; \
		ln -snf bzip2 bzcat; \
		ln -snf bzdiff bzcmp; \
		ln -snf bzmore bzless; \
		ln -snf bzgrep bzegrep; \
		ln -snf bzgrep bzfgrep; \
    )

$(BZIP2_DIR)/bzip2: $(BZIP2_DIR)/.patched
	$(MAKE) CC=$(TARGET_CC) RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) \
		-C $(BZIP2_DIR) -f Makefile-libbz2_so
	$(MAKE) CC=$(TARGET_CC) RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) \
		-C $(BZIP2_DIR) libbz2.a bzip2 bzip2recover

$(BZIP2_DIR)/.patched: $(BZIP2_DIR)/.unpacked
	@script/patch-kernel.sh $(BZIP2_DIR) package/apps/bzip2 bzip2\*.patch
	@$(SED) "s,ln \$$(,ln -snf \$$(,g" $(BZIP2_DIR)/Makefile
	@$(SED) "s,ln -s (lib.*),ln -snf \$$1; ln -snf libbz2.so.$(BZIP2_SONAME) \
		libbz2.so,g" $(BZIP2_DIR)/Makefile-libbz2_so
	@$(SED) "s:-O2:$(TARGET_CFLAGS):" $(BZIP2_DIR)/Makefile
	@$(SED) "s:-O2:$(TARGET_CFLAGS):" $(BZIP2_DIR)/Makefile-libbz2_so
	@touch $@

$(BZIP2_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		(tar -xvf $(PKG_DIR)/$(BZIP2_SOURCE))
	@touch $@

bzip2-clean:
	@rm -f $(ROOTFS_DIR)/usr/lib/libbz2.*
	rm -f $(addprefix $(ROOTFS_DIR)/usr/bin/,	\
		bzip2 bzmore bzip2recover bzgrep bzdiff bunzip2 bzcat bzcmp	\
		bzless bzegrep bzfgrep)
	-$(MAKE) -C $(BZIP2_DIR) clean

bzip2-dirclean:
	rm -rf $(BZIP2_DIR)

ifeq ($(strip $(SDK_ROOTFS_APPS_BZIP2)),y)
SDK_ROOTFS_PACKAGES += bzip2
endif

