
#BUSYBOX_VERSION := 1.16.1
BUSYBOX_VERSION := 1.10.3
BUSYBOX_SOURCE := busybox-$(BUSYBOX_VERSION).tar.bz2
BUSYBOX_DIR := $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)
BUSYBOX_CONFIG := busybox-$(BUSYBOX_VERSION).config

busybox: $(ROOTFS_DIR)/bin/busybox

$(ROOTFS_DIR)/bin/busybox: $(BUSYBOX_DIR)/busybox
	$(MAKE) -C $(BUSYBOX_DIR) CC=$(CROSS_COMPILE)gcc	\
		CROSS_COMPILE="$(CROSS_COMPILE)" CROSS="$(CROSS_COMPILE)"	\
		CONFIG_PREFIX="$(ROOTFS_DIR)"	\
		ARCH=$(SDK_TARGET_ARCH)	\
		EXTRA_CFLAGS="$(BUSYBOX_CFLAGS)" install

$(BUSYBOX_DIR)/busybox: $(BUSYBOX_DIR)/.patched
	$(MAKE) -C $(BUSYBOX_DIR) CC=$(CROSS_COMPILE)gcc	\
		CROSS_COMPILE="$(CROSS_COMPILE)" CROSS="$(CROSS_COMPILE)"	\
		PREFIX="$(ROOTFS_DIR)"	\
		ARCH=$(SDK_TARGET_ARCH)	\
		EXTRA_CFLAGS="$(BUSYBOX_CFLAGS)"

$(BUSYBOX_DIR)/.patched: $(BUSYBOX_DIR)/.unpacked
	@script/patch-kernel.sh $(BUSYBOX_DIR) package/apps/busybox busybox-$(BUSYBOX_VERSION)\*.patch
	@cp package/apps/busybox/$(BUSYBOX_CONFIG) $(BUSYBOX_DIR)/.config &&	\
		$(SED) s/'^CONFIG_PREFIX=.*'/'CONFIG_PREFIX='\"$(SED_ROOTFS_DIR)\"/ $(BUSYBOX_DIR)/.config;	\
		$(MAKE) -C $(BUSYBOX_DIR) oldconfig
	@touch $@

$(BUSYBOX_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		(tar -xvf $(PKG_DIR)/$(BUSYBOX_SOURCE))
	@touch $@

busybox-clean:
	@if [ -d $(BUSYBOX_DIR) ]; then	\
		$(MAKE) -C $(BUSYBOX_DIR) CC=$(CROSS_COMPILE)gcc	\
			CROSS_COMPILE="$(CROSS_COMPILE)" CROSS="$(CROSS_COMPILE)"	\
			PREFIX="$(ROOTFS_DIR)"	\
			ARCH=$(SDK_TARGET_ARCH)	\
			EXTRA_CFLAGS="$(BUSYBOX_CFLAGS)" uninstall;	\
		$(MAKE) -C $(BUSYBOX_DIR) CC=$(CROSS_COMPILE)gcc	\
			CROSS_COMPILE="$(CROSS_COMPILE)" CROSS="$(CROSS_COMPILE)"	\
			PREFIX="$(ROOTFS_DIR)"	\
			ARCH=$(SDK_TARGET_ARCH)	\
			EXTRA_CFLAGS="$(BUSYBOX_CFLAGS)" clean;	\
	fi

busybox-dirclean:
	@rm -rf $(BUSYBOX_DIR)


BUSYBOX_MINI := $(BUILD_DIR)/busybox-mini
BUSYBOX_CONFIG_MINI := busybox-$(BUSYBOX_VERSION)-mini.config

mini-busybox: $(MINIFS_DIR)/bin/busybox

$(MINIFS_DIR)/bin/busybox: $(BUSYBOX_MINI)/busybox
	$(MAKE) -C $(BUSYBOX_MINI) CC=$(CROSS_COMPILE)gcc	\
		CROSS_COMPILE="$(CROSS_COMPILE)" CROSS="$(CROSS_COMPILE)"	\
		CONFIG_PREFIX="$(MINIFS_DIR)"	\
		ARCH=$(SDK_TARGET_ARCH)	\
		EXTRA_CFLAGS="$(BUSYBOX_CFLAGS)" install

$(BUSYBOX_MINI)/busybox: $(BUSYBOX_MINI)/.patched
	$(MAKE) -C $(BUSYBOX_MINI) CC=$(CROSS_COMPILE)gcc	\
		CROSS_COMPILE="$(CROSS_COMPILE)" CROSS="$(CROSS_COMPILE)"	\
		PREFIX="$(MINIFS_DIR)"	\
		ARCH=$(SDK_TARGET_ARCH)	\
		EXTRA_CFLAGS="$(BUSYBOX_CFLAGS)"

$(BUSYBOX_MINI)/.patched: $(BUSYBOX_MINI)/.unpacked
	@script/patch-kernel.sh $(BUSYBOX_MINI) package/apps/busybox busybox-$(BUSYBOX_VERSION)\*.patch
	@cp package/apps/busybox/$(BUSYBOX_CONFIG_MINI) $(BUSYBOX_MINI)/.config &&	\
		sed -i s/'^CONFIG_PREFIX=.*'/'CONFIG_PREFIX='\"$(SED_MINIFS_DIR)\"/ $(BUSYBOX_MINI)/.config;	\
		$(MAKE) -C $(BUSYBOX_MINI) oldconfig
	@touch $@

$(BUSYBOX_MINI)/.unpacked:
	@mkdir -p $(BUSYBOX_MINI)
	@cd $(BUSYBOX_MINI);	\
		(tar -xvf $(PKG_DIR)/$(BUSYBOX_SOURCE) --strip-components 1)
	@touch $@

mini-busybox-clean:
	@if [ -d $(BUSYBOX_MINI) ]; then	\
		$(MAKE) -C $(BUSYBOX_MINI) CC=$(CROSS_COMPILE)gcc	\
			CROSS_COMPILE="$(CROSS_COMPILE)" CROSS="$(CROSS_COMPILE)"	\
			PREFIX="$(MINIFS_DIR)"	\
			ARCH=$(SDK_TARGET_ARCH)	\
			EXTRA_CFLAGS="$(BUSYBOX_CFLAGS)" uninstall;	\
		$(MAKE) -C $(BUSYBOX_MINI) CC=$(CROSS_COMPILE)gcc	\
			CROSS_COMPILE="$(CROSS_COMPILE)" CROSS="$(CROSS_COMPILE)"	\
			PREFIX="$(MINIFS_DIR)"	\
			ARCH=$(SDK_TARGET_ARCH)	\
			EXTRA_CFLAGS="$(BUSYBOX_CFLAGS)" clean;	\
	fi

mini-busybox-dirclean:
	@rm -rf $(BUSYBOX_MINI)

ifeq ($(strip $(SDK_ROOTFS_APPS_BUSYBOX)),y)
SDK_ROOTFS_PACKAGES += busybox
endif

