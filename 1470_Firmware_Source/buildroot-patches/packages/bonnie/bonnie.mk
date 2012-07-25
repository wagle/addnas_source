	
#############################################################
#
# bonnie
#
#############################################################
BONNIE_SOURCE:=bonnie-1.4.tar.gz
BONNIE_SITE:=http://www.garloff.de/kurt/linux/bonnie/
BONNIE_DIR:=$(BUILD_DIR)/bonnie
BONNIE_CAT:=zcat
BONNIE_BINARY:=bonnie
BONNIE_TARGET_BINARY:=bonnie

$(DL_DIR)/$(BONNIE_SOURCE):
	 $(WGET) -P $(DL_DIR) $(BONNIE_SITE)/$(BONNIE_SOURCE)

bonnie-source: $(DL_DIR)/$(BONNIE_SOURCE)

$(BONNIE_DIR)/.unpacked: $(DL_DIR)/$(BONNIE_SOURCE)
	$(BONNIE_CAT) $(DL_DIR)/$(BONNIE_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	(cd $(BONNIE_DIR) ;\
		patch -p 1 < $(BASE_DIR)/package/bonnie/bonnie-1.4-builtroot.patch ;\
		patch -p 1 < $(BASE_DIR)/package/bonnie/bonnie-1.patch \
	);
	touch $(BONNIE_DIR)/.unpacked

bonnie-unpacked: $(BONNIE_DIR)/.unpacked

$(BONNIE_DIR)/$(BONNIE_BINARY): $(BONNIE_DIR)/.unpacked
	$(MAKE) -C $(BONNIE_DIR)

# This stuff is needed to work around GNU make deficiencies
bonnie-target_binary: $(BONNIE_DIR)/$(BONNIE_BINARY)
	@if [ -L $(TARGET_DIR)/$(BONNIE_TARGET_BINARY) ] ; then \
		rm -f $(TARGET_DIR)/$(BONNIE_TARGET_BINARY); fi;
	@if [ ! -f $(BONNIE_DIR)/$(BONNIE_BINARY) -o $(TARGET_DIR)/$(BONNIE_TARGET_BINARY) -ot \
	$(BONNIE_DIR)/$(BONNIE_BINARY) ] ; then \
	    set -x; \
	    rm -f $(TARGET_DIR)/bin/bonnie ; \
	    cp -a $(BONNIE_DIR)/bonnie $(TARGET_DIR)/bin/; fi

bonnie: uclibc bonnie-target_binary

bonnie-clean:
	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(BONNIE_DIR) uninstall
	-$(MAKE) -C $(BONNIE_DIR) clean

bonnie-dirclean:
	rm -rf $(BONNIE_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_BONNIE)),y)
TARGETS+=bonnie
endif
