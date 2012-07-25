
include sdk.config

##############################################################################
# Should check the following tools existing on the system automatically
##############################################################################
CROSS_COMPILE := $(SDK_TOOLCHAIN_PATH)/usr/bin/$(SDK_TOOLCHAIN_PREFIX)-
TARGET_CC := $(CROSS_COMPILE)gcc
TARGET_CXX := $(CROSS_COMPILE)g++
TARGET_AR := $(CROSS_COMPILE)ar
TARGET_AS := $(CROSS_COMPILE)as
TARGET_LD := $(CROSS_COMPILE)ld
TARGET_NM := $(CROSS_COMPILE)nm
TARGET_RANLIB := $(CROSS_COMPILE)ranlib
TARGET_OBJCOPY := $(CROSS_COMPILE)objcopy
TARGET_STRIP := $(CROSS_COMPILE)strip
STRIPCMD := $(CROSS_COMPILE)strip
STRIPCMD_STRIP_ALL := $(TARGET_STRIP) --strip-all
STRIPCMD_STRIP_DEBUG := $(TARGET_STRIP) --strip-debug
INSTALL := install
MAKE := make
SED := sed -i -e
HOSTCC := gcc
LN := ln
DISKUSAGE := du -sh
JAR := java -jar
MSGFMT := msgfmt
##############################################################################
GNU_TARGET_NAME := `readlink $(CROSS_COMPILE)gcc | xargs basename | sed 's/-gcc//'`
GNU_HOST_NAME := i386-cross-linux-gnu

BASE_DIR := $(shell cd $(shell pwd); pwd)
PKG_DIR := $(BASE_DIR)/archives/3rd_party
SDK_DIR := $(BASE_DIR)/archives/oxsemi
BUILD_DIR := $(BASE_DIR)/build_$(strip $(subst ",, $(SDK_TARGET_ARCH)))
#"))
STAGING_DIR := $(BUILD_DIR)/staging_dir
OUTPUT_DIR := $(BASE_DIR)/output
SDKCONFIG := $(BASE_DIR)/sdk.config
SCRIPT_DIR := $(BASE_DIR)/script

SDK_LIBC_FILENAME:=$(shell $(TARGET_CC) --print-file-name=$(SDK_LIBC))
SDK_LIBC_TYPE:=$(shell readlink $(SDK_LIBC_FILENAME) | cut -d'-' -f1 | sed 's/lib//')
ifeq ($(strip $(SDK_LIBC_TYPE)), uClibc)
ROOTFS_DIR := $(BASE_DIR)/rootfs_uClibc
else
ROOTFS_DIR := $(BASE_DIR)/rootfs_glibc
endif
MINIFS_DIR := $(BASE_DIR)/rootfs_mini
SED_ROOTFS_DIR := `echo $(ROOTFS_DIR) | sed s/'\/'/'\\\\\/'/g`
SED_MINIFS_DIR := `echo $(MINIFS_DIR) | sed s/'\/'/'\\\\\/'/g`

TARGET_CFLAGS := -Os -msoft-float -march=$(strip $(subst ",, $(SDK_TARGET_MARCH))) -mtune=$(strip $(subst ",, $(SDK_TARGET_MTUNE))) -I$(STAGING_DIR)/usr/include -I$(SDK_TOOLCHAIN_PATH)/usr/include 
#"))
#"))
ifeq ($(strip $(SDK_BUILD_DEBUG)), y)
TARGET_CFLAGS += -g
endif
TARGET_LDFLAGS := -L$(STAGING_DIR)/usr/lib -L$(ROOTFS_DIR)/lib -L$(ROOTFS_DIR)/usr/lib -L$(SDK_TOOLCHAIN_PATH)/lib -L$(SDK_TOOLCHAIN_PATH)/usr/lib
TARGET_CONFIGURE_OPTS := \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"	\
		CC="$(TARGET_CC) $(TARGET_CFLAGS)"	\
		CXX="$(TARGET_CXX) $(TARGET_CFLAGS)"	\
		LD="$(TARGET_LD) $(TARGET_LDFLAGS)"	\
		AR=$(TARGET_AR)	\
		NM=$(TARGET_NM)	\
		RANLIB=$(TARGET_RANLIB)	\
		STRIP=$(TARGET_STRIP)

ifeq ($(strip $(SDK_LIBC_TYPE)), uClibc)
CONFIG_UPDATE := cp -f $(SCRIPT_DIR)/config.sub $(SCRIPT_DIR)/config.guess
else
CONFIG_UPDATE := true
endif

##############################################################################
ifeq ($(strip $(subst ",, $(SDK_BUILD_NAND_BOOT))), y)
#"))
all: dirs rootfs mini

dirs: $(OUTPUT_DIR) $(BUILD_DIR) $(ROOTFS_DIR) $(MINIFS_DIR) $(STAGING_DIR) $(SCRIPT_DIR)
else
all: dirs stage1 uboot kernel rootfs ext2fsroot
ifeq ($(strip $(subst ",, $(SDK_TARGET_PLATFORM))), 7820)
	$(INSTALL) -m 0755 $(SCRIPT_DIR)/install-7820.sh $(OUTPUT_DIR)
#"))
endif
ifeq ($(strip $(subst ",, $(SDK_TARGET_PLATFORM))), 7821)
	$(INSTALL) -m 0755 $(SCRIPT_DIR)/install-7821-raid1.sh $(OUTPUT_DIR)
#"))
endif
ifeq ($(strip $(subst ",, $(SDK_TARGET_PLATFORM))), 7825_SINGLE)
	$(INSTALL) -m 0755 $(SCRIPT_DIR)/install-7825-singleSATA.sh $(OUTPUT_DIR)
#"))
endif
ifeq ($(strip $(subst ",, $(SDK_TARGET_PLATFORM))), 7825_RAID)
	$(INSTALL) -m 0755 $(SCRIPT_DIR)/install-7825-raid1SATA.sh $(OUTPUT_DIR)
#"))
endif

dirs: $(OUTPUT_DIR) $(BUILD_DIR) $(ROOTFS_DIR) $(STAGING_DIR) $(SCRIPT_DIR)
endif

$(OUTPUT_DIR) $(BUILD_DIR) $(ROOTFS_DIR) $(MINIFS_DIR) $(STAGING_DIR):
	@mkdir -p $@

$(SCRIPT_DIR):
	@chmod +x $@/*.{sh,py}
	@chmod +x $@/config.*

-include package/*.mk
-include package/*/*.mk
-include package/*/*/*.mk

.PHONY: all dirs clean dirclean	\
	$(OUTPUT_DIR) $(BUILD_DIR) $(ROOTFS_DIR) $(MINIFS_DIR) $(STAGING_DIR)	\
	$(SCRIPT_DIR)

SDK_PACKAGES_CLEAN:=$(patsubst %,%-clean,$(SDK_ROOTFS_PACKAGES))
SDK_PACKAGES_CLEAN += stage1-clean uboot-clean kernel-clean
ifeq ($(strip $(subst ",, $(SDK_BUILD_NAND_BOOT))), y)
SDK_PACKAGES_CLEAN += mini-stage1-clean mini-uboot-clean
#"))
endif

clean: $(SDK_PACKAGES_CLEAN)
	@rm -rf $(OUTPUT_DIR) $(ROOTFS_DIR) $(MINIFS_DIR)

dirclean: nandbd-dirclean
	@rm -rf $(OUTPUT_DIR) $(ROOTFS_DIR) $(MINIFS_DIR) $(BUILD_DIR)

##############################################################################
# Packages for rootfs
##############################################################################

create_libc =	\
	PREFIX="$(strip $1)";	\
\
	for libs in $(strip $(subst ",, $(SDK_LIBC))); do \
		$(call copy_toolchain_libs, $${PREFIX}, $$libs, /lib, y);	\
	done;	\
	for libs in $(strip $(subst ",, $(SDK_EXTERNAL_LIBS))); do \
		$(call copy_toolchain_libs, $${PREFIX}, $$libs, /lib, y);	\
	done;	\
	for libs in $(strip $(subst ",, $(SDK_EXTERNAL_LIBS))); do \
		$(call ln_toolchain_libs, $${PREFIX}, /lib, usr/lib, ../../lib, $$libs); \
	done;	\
	NSSWITCH=$${PREFIX}/etc/nsswitch.conf;	\
	if [ "$(strip $(SDK_LIBC_TYPE))" != "uClibc" ]; then	\
		echo "\#Begin /etc/nsswitch.conf" > $${NSSWITCH};	\
		echo "" >> $${NSSWITCH};	\
		echo "passwd: files" >> $${NSSWITCH};	\
		echo "group: files" >> $${NSSWITCH};	\
		echo "shadow: files" >> $${NSSWITCH};	\
		echo "hosts: files dns" >> $${NSSWITCH};	\
		echo "networks: files" >> $${NSSWITCH};	\
		echo "protocols: files" >> $${NSSWITCH};	\
		echo "services: files" >> $${NSSWITCH};	\
		echo "ethers: files" >> $${NSSWITCH};	\
		echo "rpcs: files" >> $${NSSWITCH};	\
		echo "" >> $${NSSWITCH};	\
		echo "\#End /etc/nsswitch.conf" >> $${NSSWITCH};	\
	fi

libc: target_skeleton $(ROOTFS_DIR)/lib/$(strip $(subst ",, $(SDK_LIBC)))

$(ROOTFS_DIR)/lib/$(strip $(subst ",, $(SDK_LIBC))):
	@$(call create_libc, $(ROOTFS_DIR))

rootfs: libc $(SDK_ROOTFS_PACKAGES) kernel-modules

##############################################################################
# Mini
##############################################################################
ifeq ($(strip $(subst ",, $(SDK_BUILD_NAND_BOOT))), y)

mini_libc: $(MINIFS_DIR)/lib/$(strip $(subst ",, $(SDK_LIBC)))

$(MINIFS_DIR)/lib/$(strip $(subst ",, $(SDK_LIBC))):
	@$(call create_libc, $(MINIFS_DIR))

MINI_ROOTFS_PACKAGES += mini_skeleton mini_libc mini-busybox mini-bash mini-mtd-utils mini-nandbd mini-kernel-modules

minifs: stage1 kernel uboot $(MINI_ROOTFS_PACKAGES) ubifsroot
	@$(INSTALL) -d $(MINIFS_DIR)/var/images
	@$(INSTALL) $(OUTPUT_DIR)/stage1.wrapped $(MINIFS_DIR)/var/images
	@$(INSTALL) $(OUTPUT_DIR)/u-boot.wrapped $(MINIFS_DIR)/var/images
	@$(INSTALL) $(OUTPUT_DIR)/uImage $(MINIFS_DIR)/var/images
	@$(INSTALL) $(UBIVOLUME) $(MINIFS_DIR)/var/images
	@$(INSTALL) -m 0755 $(NANDBD_DIR)/nandbd.sh $(MINIFS_DIR)/usr/sbin

MINI_BOOT_PACKAGES += mini-stage1 mini-uboot
mini: minifs $(MINI_BOOT_PACKAGES) mini-ext2fsroot
	$(INSTALL) -m 0755 $(SCRIPT_DIR)/install-mini.sh $(OUTPUT_DIR)
endif

