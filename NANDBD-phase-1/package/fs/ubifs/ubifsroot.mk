
UBIVOL_CFG := $(OUTPUT_DIR)/ubivol.cfg
UBIVOLUME := $(OUTPUT_DIR)/rootfs.$(strip $(subst ",, $(SDK_TARGET_ARCH))).ubi
UBIFSIMG := $(OUTPUT_DIR)/rootfs.$(strip $(subst ",, $(SDK_TARGET_ARCH))).ubifs

ubifsroot: $(UBIVOLUME)

MTD_BOOTPART_MSIZ := $(shell expr $(shell expr 310 \* 128 + 1023) / 1024)
MTD_DATAPART_MSIZ := $(shell expr $(SDK_TARGET_NAND_SIZE) - $(MTD_BOOTPART_MSIZ))

PAGE_ROUND_FACTOR := $(shell expr $(SDK_TARGET_NAND_MINIOSIZE) - 1)
UBIFS_HEADER_PAGE := $(shell expr $(SDK_TARGET_NAND_SUBPAGE) \* 2)
UBIFS_HEADER_PAGE_ROUND := $(shell expr $(shell expr $(UBIFS_HEADER_PAGE) + $(PAGE_ROUND_FACTOR)) / $(SDK_TARGET_NAND_MINIOSIZE))
UBIFS_HEADER_OVERHEAD := $(shell expr $(UBIFS_HEADER_PAGE_ROUND) \* $(SDK_TARGET_NAND_MINIOSIZE))
UBIFS_LEBSIZE := $(shell expr $(SDK_TARGET_NAND_PEBSIZE) - $(UBIFS_HEADER_OVERHEAD))

UBI_PEB_CNT := $(shell expr $(MTD_DATAPART_MSIZ) \* 1024 \* 1024 / $(SDK_TARGET_NAND_PEBSIZE))
PEB_BAD_RESERVE := $(shell expr $(UBI_PEB_CNT) / 100)
UBI_OVERHEAD1 := $(shell expr $(shell expr $(PEB_BAD_RESERVE) + 4) \* $(SDK_TARGET_NAND_PEBSIZE))
UBI_OVERHEAD2 := $(shell expr $(SDK_TARGET_NAND_PEBSIZE) - $(UBIFS_LEBSIZE))
UBI_OVERHEAD3 := $(shell expr $(UBI_OVERHEAD2) \* $(shell expr $(UBI_PEB_CNT) - $(PEB_BAD_RESERVE) - 4))
UBI_OVERHEAD := $(shell expr $(UBI_OVERHEAD1) + $(UBI_OVERHEAD3))
UBI_OVERHEAD_PEB := $(shell expr $(UBI_OVERHEAD) / $(SDK_TARGET_NAND_PEBSIZE))

UBI_DATA_FREE_PEB := $(shell expr $(UBI_PEB_CNT) - $(UBI_OVERHEAD_PEB))
UBI_DATA_FREE := $(shell expr $(UBI_DATA_FREE_PEB) \* $(SDK_TARGET_NAND_PEBSIZE))
UBI_DATA_FREE_MB := $(shell expr $(UBI_DATA_FREE) / 1024 / 1024)
UBI_LEB_MAXCNT := $(shell expr $(UBI_DATA_FREE) / $(UBIFS_LEBSIZE))

create_ubifs =	\
	TARGET="$(strip $1)";	\
	OUTPUT="$(dir $(strip $2))";	\
	IMAGE="$(notdir $(strip $2))";	\
\
	touch $(BASE_DIR)/.fakeroot.0000;	\
	cat $(BASE_DIR)/.fakeroot* > $(BASE_DIR)/_fakeroot.$${IMAGE};	\
	echo "chown -R 0:0 $${TARGET}" >> $(BASE_DIR)/_fakeroot.$${IMAGE};	\
	echo "$(MKFS_UBIFS_HOST)/mkfs.ubifs -d $${TARGET} "	\
		"-D $(TARGET_DEVICE_TABLE) -e $(UBIFS_LEBSIZE) "	\
		"-c $(UBI_LEB_MAXCNT) -m $(SDK_TARGET_NAND_MINIOSIZE)"	\
		" -o $${OUTPUT}/$${IMAGE}" >>	$(BASE_DIR)/_fakeroot.$${IMAGE};	\
	chmod a+x $(BASE_DIR)/_fakeroot.$${IMAGE};	\
	$(FAKEROOT_DIR1)/usr/bin/fakeroot -- $(BASE_DIR)/_fakeroot.$${IMAGE};	\
	rm -rf $(BASE_DIR)/_fakeroot.$${IMAGE};	\
	rm -rf $(BASE_DIR)/.fakeroot.0000

$(UBIFSIMG): fakeroot-host mkfs.ubifs-host
	@$(call sdk_strip_binaries, $(ROOTFS_DIR))
	$(call create_ubifs, $(ROOTFS_DIR), $@)

$(UBIVOLUME): ubinize-host $(UBIFSIMG)
	@echo "[rootfs]" > $(UBIVOL_CFG) &&	\
	echo "mode=ubi" >> $(UBIVOL_CFG) &&	\
	echo "image=$(UBIFSIMG)" >> $(UBIVOL_CFG) &&	\
	echo "vol_id=0" >> $(UBIVOL_CFG) &&	\
	echo "vol_size=$(UBI_DATA_FREE_MB)MiB" >> $(UBIVOL_CFG) &&	\
	echo "vol_name=rootfs" >> $(UBIVOL_CFG) &&	\
	echo "vol_type=dynamic" >> $(UBIVOL_CFG) &&	\
	echo "vol_flags=autoresize" >> $(UBIVOL_CFG)
	$(UBI_UTILS_HOST)/ubinize	\
		-m $(SDK_TARGET_NAND_MINIOSIZE)	\
		-p $(SDK_TARGET_NAND_PEBSIZE)	\
		-s $(SDK_TARGET_NAND_SUBPAGE) -o $@ $(UBIVOL_CFG)

ubifsroot-clean:
	@rm -rf $(UBIVOL_CFG)
	@rm -rf $(UBIVOLUME)
	@rm -rf $(UBIFSIMG)

MINI_UBIVOLUME := $(OUTPUT_DIR)/mini-rootfs.$(strip $(subst ",, $(SDK_TARGET_ARCH))).ubi
MINI_UBIFSIMG := $(OUTPUT_DIR)/mini-rootfs.$(strip $(subst ",, $(SDK_TARGET_ARCH))).ubifs

mini-ubifsroot: $(MINI_UBIVOLUME)

$(MINI_UBIVOLUME): ubinize-host $(MINI_UBIFSIMG)
	@echo "[rootfs]" > $(UBIVOL_CFG) &&	\
	echo "mode=ubi" >> $(UBIVOL_CFG) &&	\
	echo "image=$(MINI_UBIFSIMG)" >> $(UBIVOL_CFG) &&	\
	echo "vol_id=0" >> $(UBIVOL_CFG) &&	\
	echo "vol_size=$(UBI_DATA_FREE_MB)MiB" >> $(UBIVOL_CFG) &&	\
	echo "vol_name=rootfs" >> $(UBIVOL_CFG) &&	\
	echo "vol_type=dynamic" >> $(UBIVOL_CFG) &&	\
	echo "vol_flags=autoresize" >> $(UBIVOL_CFG)
	$(UBI_UTILS_HOST)/ubinize	\
		-m $(SDK_TARGET_NAND_MINIOSIZE)	\
		-p $(SDK_TARGET_NAND_PEBSIZE)	\
		-s $(SDK_TARGET_NAND_SUBPAGE) -o $@ $(UBIVOL_CFG)

$(MINI_UBIFSIMG): fakeroot-host mkfs.ubifs-host
	$(call create_ubifs, $(MINIFS_DIR), $@)

mini-ubifsroot-clean:
	@rm -rf $(UBIVOL_CFG)
	@rm -rf $(MINI_UBIVOLUME)
	@rm -rf $(MINI_UBIFSIMG)

