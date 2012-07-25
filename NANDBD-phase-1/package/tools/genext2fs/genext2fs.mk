
GENEXT2FS_VERSION := 1.4
GENEXT2FS_SOURCE := genext2fs-$(GENEXT2FS_VERSION).tar.gz
GENEXT2FS_DIR := $(BUILD_DIR)/genext2fs-$(GENEXT2FS_VERSION)

genext2fs: $(GENEXT2FS_DIR)/genext2fs

$(GENEXT2FS_DIR)/genext2fs: $(GENEXT2FS_DIR)/.configured
	$(MAKE) -C $(GENEXT2FS_DIR)

$(GENEXT2FS_DIR)/.configured: $(GENEXT2FS_DIR)/.unpacked
	@cd $(GENEXT2FS_DIR); ./configure
	@touch $@

$(GENEXT2FS_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		(tar -xvf $(PKG_DIR)/$(GENEXT2FS_SOURCE))
	@touch $@

genext2fs-clean:
	-$(MAKE) -C $(GENEXT2FS_DIR) clean

genext2fs-clean-all:
	@rm -rf $(GENEXT2FS_DIR)
