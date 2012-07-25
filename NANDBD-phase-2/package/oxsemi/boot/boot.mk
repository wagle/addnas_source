
HDRT_SOURCE := boot-tools.tar.bz2
HDRT_DIR := $(BUILD_DIR)/boot-tools
BIN_HDR := $(HDRT_DIR)/update_header

hdr_tool: $(BIN_HDR)

$(BIN_HDR): $(HDRT_DIR)/.unpacked
	$(MAKE) -C $(HDRT_DIR)

$(HDRT_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		tar -xvf $(SDK_DIR)/$(HDRT_SOURCE)
	@touch $@

hdr_tool_clean:
	-$(MAKE) -C $(HDRT_DIR) clean

STAGE1_DIR := $(BUILD_DIR)/stage1
STAGE1_MINI := $(BUILD_DIR)/stage1-mini
STAGE1_SOURCE := stage1.tar.bz2
PKGER_DIR := $(STAGE1_DIR)/tools

stage1: hdr_tool $(OUTPUT_DIR)/stage1.wrapped

$(OUTPUT_DIR)/stage1.wrapped: $(STAGE1_DIR)/stage1.wrapped
	@install $< $@
 
ifeq ($(strip $(subst ",, $(SDK_BUILD_DEBUG))), y)
STAGE1_OPT += SDK_BUILD_DEBUG=$(SDK_BUILD_DEBUG)
endif
ifeq ($(strip $(subst ",, $(SDK_BUILD_NAND_BOOT))), y)
STAGE1_OPT += SDK_BUILD_NAND_BOOT=$(SDK_BUILD_NAND_BOOT)
endif
ifneq ($(strip $(subst ",, $(SDK_BUILD_NAND_STAGE2_BLOCK))), )
STAGE1_OPT += SDK_BUILD_NAND_STAGE2_BLOCK=$(SDK_BUILD_NAND_STAGE2_BLOCK)
endif
ifneq ($(strip $(subst ",, $(SDK_BUILD_NAND_STAGE2_BLOCK2))), )
STAGE1_OPT += SDK_BUILD_NAND_STAGE2_BLOCK2=$(SDK_BUILD_NAND_STAGE2_BLOCK2)
endif
$(STAGE1_DIR)/stage1.wrapped: $(STAGE1_DIR)/.patched
	PLL_FIXED_INDEX=10 $(MAKE)	\
		CROSS_COMPILE=$(CROSS_COMPILE) $(STAGE1_OPT) -C $(STAGE1_DIR) 

$(STAGE1_DIR)/.patched: $(STAGE1_DIR)/.unpacked
	@script/patch-kernel.sh $(@D) package/oxsemi/boot stage1-\*.patch
	@touch $@

packager: $(PKGER_DIR)/packager

$(PKGER_DIR)/packager: $(STAGE1_DIR)/.unpacked
	$(MAKE) -C $(PKGER_DIR)

$(STAGE1_DIR)/.unpacked:
	@cd $(BUILD_DIR);   \
		tar -xvf $(SDK_DIR)/$(STAGE1_SOURCE)
	@touch $@

stage1-clean:
	@rm -rf $(OUTPUT_DIR)/stage1.wrapped
	-$(MAKE) -C $(STAGE1_DIR) clean

stage1-dirclean:
	@rm -rf $(STAGE1_DIR)

mini-stage1: hdr_tool $(OUTPUT_DIR)/mini-stage1.wrapped

$(OUTPUT_DIR)/mini-stage1.wrapped: $(STAGE1_MINI)/stage1.wrapped
	@install $< $@

$(STAGE1_MINI)/stage1.wrapped: $(STAGE1_MINI)/.patched
	$(MAKE) -C $(STAGE1_MINI) CROSS_COMPILE=$(CROSS_COMPILE)

$(STAGE1_MINI)/.patched: $(STAGE1_MINI)/.unpacked
	@script/patch-kernel.sh $(@D) package/oxsemi/boot stage1-\*.patch
	@touch $@

$(STAGE1_MINI)/.unpacked:
	@mkdir -p $(STAGE1_MINI)
	@cd $(STAGE1_MINI);	\
		(tar -xvf $(SDK_DIR)/$(STAGE1_SOURCE) --strip-components 1)
	@touch $@

mini-stage1-clean:
	@rm -rf $(OUTPUT_DIR)/mini-stage1.wrapped
	-$(MAKE) -C $(STAGE1_MINI) clean

mini-stage1-dirclean:
	@rm -rf $(STAGE1_MINI)

UBOOT_DIR := $(BUILD_DIR)/u-boot
UBOOT_MINI := $(BUILD_DIR)/u-boot-mini
UBOOT_SOURCE := u-boot.tar.bz2
BOOT_TOOL_DIR := $(BUILD_DIR)/u-boot/tools

LOC_KERN1 := $(shell expr $(SDK_BUILD_NAND_KERNEL_BLOCK) \* $(SDK_TARGET_NAND_PEBSIZE))
HEX_LOC_KERN1 := $(shell echo "obase=16;$(LOC_KERN1)" | bc)
LOC_KERN2 := $(shell expr $(SDK_BUILD_NAND_KERNEL_BLOCK2) \* $(SDK_TARGET_NAND_PEBSIZE))
HEX_LOC_KERN2 := $(shell echo "obase=16;$(LOC_KERN2)" | bc)
LOC_DEF_FILE := $(UBOOT_DIR)/include/configs/ox820.h

uboot: packager $(OUTPUT_DIR)/u-boot.wrapped

$(OUTPUT_DIR)/u-boot.wrapped: $(UBOOT_DIR)/u-boot.wrapped
	@install $< $@

$(UBOOT_DIR)/u-boot.wrapped: $(UBOOT_DIR)/u-boot.bin
	@cd $(UBOOT_DIR);	\
		$(PKGER_DIR)/packager $< $@

ifeq ($(strip $(subst ",, $(SDK_BUILD_NAND_BOOT))), y)
UBOOT_OPT += SDK_BUILD_NAND_BOOT=$(SDK_BUILD_NAND_BOOT)
UBOOT_OPT += USE_NAND=1 USE_SATA=0 USE_SATA_ENV=0
UBOOT_OPT += USE_OTP=1 USE_OTP_MAC=1
endif

$(UBOOT_DIR)/u-boot.bin: $(UBOOT_DIR)/.configured
	$(MAKE) -C $(UBOOT_DIR) CROSS_COMPILE=$(CROSS_COMPILE) $(UBOOT_OPT)

$(UBOOT_DIR)/.configured: $(UBOOT_DIR)/.patched
	$(MAKE) -C $(UBOOT_DIR) ox820_config CROSS_COMPILE=$(CROSS_COMPILE)
	@touch $@

$(UBOOT_DIR)/.patched: $(UBOOT_DIR)/.unpacked
	@script/patch-kernel.sh $(@D) package/oxsemi/boot uboot-\*.patch
	@$(SED) 's/\("load_nand=nboot\s60500000\s0\s\).*/\1$(HEX_LOC_KERN1)\\0" \\/' $(LOC_DEF_FILE)
	@$(SED) 's/\("load_nand2=nboot\s60500000\s0\s\).*/\1$(HEX_LOC_KERN2)\\0" \\/' $(LOC_DEF_FILE)
	@touch $@

$(UBOOT_DIR)/.unpacked:
	@cd $(BUILD_DIR);   \
		tar -xvf $(SDK_DIR)/$(UBOOT_SOURCE)
	@touch $@

uboot-clean:
	@rm -rf $(OUTPUT_DIR)/u-boot.wrapped
	@rm -rf $(UBOOT_DIR)/u-boot.wrapped
	@rm -rf $(UBOOT_DIR)/u-boot.bin
	-@$(MAKE) -C $(UBOOT_DIR) CROSS_COMPILE=$(CROSS_COMPILE) clean

uboot-dirclean:
	@rm -rf $(UBOOT_DIR)

mini-uboot: packager $(OUTPUT_DIR)/mini-u-boot.wrapped

$(OUTPUT_DIR)/mini-u-boot.wrapped: $(UBOOT_MINI)/u-boot.wrapped
	@install $< $@

$(UBOOT_MINI)/u-boot.wrapped: $(UBOOT_MINI)/u-boot.bin
	@cd $(UBOOT_MINI);	\
		$(PKGER_DIR)/packager $< $@

$(UBOOT_MINI)/u-boot.bin: $(UBOOT_MINI)/.configured
	$(MAKE) -C $(UBOOT_MINI) CROSS_COMPILE=$(CROSS_COMPILE) USE_NAND=1

$(UBOOT_MINI)/.configured: $(UBOOT_MINI)/.patched
	$(MAKE) -C $(UBOOT_MINI) ox820_config CROSS_COMPILE=$(CROSS_COMPILE)
	@touch $@

$(UBOOT_MINI)/.patched: $(UBOOT_MINI)/.unpacked
	@script/patch-kernel.sh $(@D) package/oxsemi/boot uboot-\*.patch
	@touch $@

$(UBOOT_MINI)/.unpacked:
	@mkdir -p $(UBOOT_MINI)
	@cd $(UBOOT_MINI);	\
		(tar -xvf $(SDK_DIR)/$(UBOOT_SOURCE) --strip-components 1)
	@touch $@

mini-uboot-clean:
	@rm -rf $(OUTPUT_DIR)/mini-u-boot.wrapped
	@rm -rf $(UBOOT_MINI)/u-boot.wrapped
	@rm -rf $(UBOOT_MINI)/u-boot.bin
	-@$(MAKE) -C $(UBOOT_MINI) CROSS_COMPILE=$(CROSS_COMPILE) clean

mini-uboot-dirclean:
	@rm -rf $(UBOOT_MINI)

MKIMAGE := $(BOOT_TOOL_DIR)/mkimage
boot-tools: $(MKIMAGE)

$(MKIMAGE): $(UBOOT_DIR)/.configured
	@$(MAKE) -C $(UBOOT_DIR) CROSS_COMPILE=$(CROSS_COMPILE) tools

