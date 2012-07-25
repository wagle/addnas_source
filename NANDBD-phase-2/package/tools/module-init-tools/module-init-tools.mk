
MODINIT_TOOL_VERSION := 3.5
MODINIT_TOOL_SOURCE := module-init-tools-$(MODINIT_TOOL_VERSION).tar.bz2
MODINIT_TOOL_DIR := $(BUILD_DIR)/module-init-tools-$(MODINIT_TOOL_VERSION)

SED_MODINIT_TOOL_DIR := $(shell echo $(MODINIT_TOOL_DIR) | sed s/'\/'/'\\\\\/'/g)

depmod: $(MODINIT_TOOL_DIR)/depmod

$(MODINIT_TOOL_DIR)/depmod: $(MODINIT_TOOL_DIR)/.configured
	$(MAKE) -C $(MODINIT_TOOL_DIR) depmod

$(MODINIT_TOOL_DIR)/.configured: $(MODINIT_TOOL_DIR)/.unpacked
	(cd $(MODINIT_TOOL_DIR);	\
		./configure;	\
	)
	@touch $@

$(MODINIT_TOOL_DIR)/.unpacked: 
	@cd $(BUILD_DIR);	\
		(tar -jxvf $(PKG_DIR)/$(MODINIT_TOOL_SOURCE))
	@touch $@

depmod-clean:
	-$(MAKE) -C $(MODINIT_TOOL_DIR) clean

depmod-dirclean:
	@rm -rf $(MODINIT_TOOL_DIR)
