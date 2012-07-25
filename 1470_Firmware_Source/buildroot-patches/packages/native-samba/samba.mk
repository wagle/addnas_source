#############################################################
#
# precompiled binary SAMBA
#
#############################################################
NATIVE_SAMBA_VER:=3.0.23c
NATIVE_SAMBA_EXTRA_VERSION:=820-2.6.31-r4597
NATIVE_SAMBA_SOURCE:=samba-bin-$(NATIVE_SAMBA_EXTRA_VERSION)-$(NATIVE_SAMBA_VER).tar.bz2

# oxsemi ftp site?
NATIVE_SAMBA_SITE=

$(DL_DIR)/$(NATIVE_SAMBA_SOURCE):
	 $(WGET) -P $(DL_DIR) $(NATIVE_SAMBA_SITE)/$(NATIVE_SAMBA_SOURCE)

# use smbd as "proof" of installation
$(TARGET_DIR)/usr/local/samba/sbin/smbd: $(DL_DIR)/$(NATIVE_SAMBA_SOURCE)
	(\
	if [ ! -e $(TARGET_DIR)/usr/local/samba/sbin/smbd ]; then\
		cd $(TARGET_DIR);\
		tar -xjf $(DL_DIR)/$(NATIVE_SAMBA_SOURCE) ;\
		cd lib;\
	fi\
	)
	
extra-lib-links:
	(\
	if [ -e $(TARGET_DIR)/usr/local/samba/lib/libtdb.so ]; then\
		cd $(TARGET_DIR)/lib;\
		if [ ! -e libtdb.so.1 ]; then \
			ln -s ../usr/local/samba/lib/libtdb.so libtdb.so.1; fi;\
		if [ ! -e libwbclient.so.0 ]; then \
			ln -s ../usr/local/samba/lib/libwbclient.so libwbclient.so.0; fi;\
		if [ ! -e libtalloc.so.1 ]; then \
			ln -s ../usr/local/samba/lib/libtalloc.so libtalloc.so.1; fi;\
	fi\
	)

native-samba: $(TARGET_DIR)/usr/local/samba/sbin/smbd extra-lib-links

native-samba-clean:
	(\
	cd $(TARGET_DIR)/lib;\
	if [ -e libtdb.so.1 ]; then\
		rm libtdb.so.1; fi;\
	if [ -e libwbclient.so.0 ]; then\
		rm libwbclient.so.0; fi;\
	if [ -e libtalloc.so.1 ]; then\
		rm libtalloc.so.1; fi;\
	)
	rm -rf $(TARGET_DIR)/usr/local/samba

native-samba-dirclean:

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_NATIVE_SAMBA)),y)
TARGETS+=native-samba
endif

