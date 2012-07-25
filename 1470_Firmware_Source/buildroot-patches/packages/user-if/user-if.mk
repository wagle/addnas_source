#############################################################
#
# user interface
#
#############################################################
USERIF_DIR:=$(BUILD_DIR)/user-if
TARGET_BINARY:=usr/www/lib/nasMaster.pl

$(USERIF_DIR)/.source:
	mkdir -p $(USERIF_DIR)/src
	cp -r package/user-if/dist/* $(USERIF_DIR)/src/
	mv $(USERIF_DIR)/src/Makefile $(USERIF_DIR)/Makefile
	touch $(USERIF_DIR)/.source

$(TARGET_DIR)/$(TARGET_BINARY):  $(USERIF_DIR)/.source native-samba PERL PERL_MODULES
	$(MAKE) -C $(USERIF_DIR) TARGET_DIR=$(TARGET_DIR)

user-if: $(TARGET_DIR)/$(TARGET_BINARY)

user-if-clean:
	rm -fr $(TARGET_DIR)/usr/www

user-if-dirclean:
	rm -rf $(USERIF_DIR)

#############################################################
#
# Toplevel Makefile options (always need the user interface)
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_USERIF)),y)
TARGETS+=user-if
endif
