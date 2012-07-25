###########################################################
#
# precompiled binary PVCONNECT
#
#############################################################
PVCONNECT_SOURCE:=pvconnect.tar.bz2
PVCONNECTD_PATH:=usr/pvconnect
PVCONNECT_SITE=
UNPACK_DIR=$(TARGET_DIR)/usr

$(DL_DIR)/$(PVCONNECT_SOURCE):
	 $(WGET) -P $(DL_DIR) $(PVCONNECT_SITE)/$(PVCONNECT_SOURCE)

# use pvconnectd as "proof" of installation
$(TARGET_DIR)/$(PVCONNECTD_PATH)/pvconnectd: $(DL_DIR)/$(PVCONNECT_SOURCE)
	(\
	cd $(UNPACK_DIR);\
	tar -xjf $(DL_DIR)/$(PVCONNECT_SOURCE);\
        cp pvconnect/S35pvconnect.sh $(TARGET_DIR)/etc/init.d/;\
	cd $(TARGET_DIR)/etc/init.d;\
	rm K35pvconnect.sh;\
	ln -s S35pvconnect.sh K35pvconnect.sh;\
	)

pvconnect: $(TARGET_DIR)/$(PVCONNECTD_PATH)/pvconnectd

pvconnect-clean:

pvconnect-dirclean:
	(\
        rm $(TARGET_DIR)/etc/init.d/S35pvconnect.sh;\
	rm $(TARGET_DIR)/etc/init.d/K35pvconnect.sh;\
	rm -rf $(UNPACK_DIR)/pvconnect;\
	)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_PVCONNECT)),y)
TARGETS+=pvconnect
endif

