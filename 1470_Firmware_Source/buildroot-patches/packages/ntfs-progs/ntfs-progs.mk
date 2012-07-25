#############################################################
#
# precompiled binary NTFS-PROGS
#
#############################################################
NTFS-PROGS_VER:=1.13.0
NTFS-PROGS_SOURCE:=ntfsprogs-$(NTFS-PROGS_VER)-bin-eabi.tar.bz2

# oxsemi ftp site?
NTFS-PROGS_SITE=

$(DL_DIR)/$(NTFS-PROGS_SOURCE):
	 $(WGET) -P $(DL_DIR) $(NTFS-PROGS_SITE)/$(NTFS-PROGS_SOURCE)

# use ntfslabel as "proof" of installation
$(TARGET_DIR)/usr/sbin/ntfslabel: $(DL_DIR)/$(NTFS-PROGS_SOURCE)
	(\
	cd $(TARGET_DIR);\
	tar -xjf $(DL_DIR)/$(NTFS-PROGS_SOURCE) ;\
	)
	
NTFS-PROGS: $(TARGET_DIR)/usr/sbin/ntfslabel

NTFS-PROGS-clean:

NTFS-PROGS-dirclean:

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_NTFS-PROGS)),y)
TARGETS+=NTFS-PROGS
endif

