
create_ext2fs =	\
	TARGET="$(strip $1)";	\
	OUTPUT="$(dir $(strip $2))";	\
	IMAGE="$(notdir $(strip $2))";	\
\
	touch $(BASE_DIR)/.fakeroot.0000;	\
	cat $(BASE_DIR)/.fakeroot* > $(BASE_DIR)/_fakeroot.$${IMAGE};	\
	echo "chown -R 0:0 $${TARGET}" >> $(BASE_DIR)/_fakeroot.$${IMAGE};	\
	GENEXT2_REALSIZE=`LC_ALL=C du -s -c -k $${TARGET} | grep total | sed -e "s/total//"`; \
	GENEXT2_ADDTOROOTSIZE=`if [ $$GENEXT2_REALSIZE -ge 20000 ]; then echo 16384; else echo 2400; fi`; \
	GENEXT2_SIZE=`expr $$GENEXT2_REALSIZE + $$GENEXT2_ADDTOROOTSIZE`; \
	GENEXT2_ADDTOINODESIZE=`find $${TARGET} | wc -l`; \
	GENEXT2_INODES=`expr $$GENEXT2_ADDTOINODESIZE + 400`; \
	set -x; \
	echo "$(GENEXT2FS_DIR)/genext2fs -b $$GENEXT2_SIZE " \
		"-N $$GENEXT2_INODES -d $${TARGET} -U " \
		"-D $(TARGET_DEVICE_TABLE) $${OUTPUT}/$${IMAGE}" >> $(BASE_DIR)/_fakeroot.$${IMAGE};	\
	chmod a+x $(BASE_DIR)/_fakeroot.$${IMAGE};	\
	$(FAKEROOT_DIR1)/usr/bin/fakeroot -- $(BASE_DIR)/_fakeroot.$${IMAGE};	\
	rm -rf $(BASE_DIR)/_fakeroot.$${IMAGE};	\
	rm -rf $(BASE_DIR)/.fakeroot.0000

EXT2IMG := $(OUTPUT_DIR)/rootfs.$(strip $(subst ",, $(SDK_TARGET_ARCH))).ext2

ext2fsroot: $(EXT2IMG)

$(EXT2IMG): fakeroot-host genext2fs
	@$(call sdk_strip_binaries, $(ROOTFS_DIR))
	$(call create_ext2fs, $(ROOTFS_DIR), $@)

ext2fsroot-clean:
	rm -rf $(OUTPUT_DIR)/$(EXT2IMG)

MINI_EXT2IMG := $(OUTPUT_DIR)/mini-rootfs.$(strip $(subst ",, $(SDK_TARGET_ARCH))).ext2

mini-ext2fsroot: $(MINI_EXT2IMG)

$(MINI_EXT2IMG): fakeroot-host genext2fs
	$(call create_ext2fs, $(MINIFS_DIR), $@)

mini-ext2fsroot-clean:
	rm -rf $(OUTPUT_DIR)/$(MINI_EXT2IMG)

