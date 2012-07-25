#############################################################
#
# precompiled binary PERL_MODULES
#
#############################################################
PERL_VER:=5.10.0-29072008
PERL_MODULES_SOURCE:=perl_modules-bin-eabi-$(PERL_VER).tar.bz2

# oxsemi ftp site?
PERL_MODULES_SITE=

$(DL_DIR)/$(PERL_MODULES_SOURCE):
	 $(WGET) -P $(DL_DIR) $(PERL_MODULES_SITE)/$(PERL_MODULES_SOURCE)

# use PodParser as "proof" of installation
$(TARGET_DIR)/usr/local/lib/perl5/site_perl/5.8.8/Module/Build/PodParser.pm: $(DL_DIR)/$(PERL_MODULES_SOURCE)
	(\
	cd $(TARGET_DIR);\
	tar -xjf $(DL_DIR)/$(PERL_MODULES_SOURCE) ;\
	)
	
PERL_MODULES: $(TARGET_DIR)/usr/local/lib/perl5/site_perl/5.8.8/Module/Build/PodParser.pm

PERL_MODULES-clean:
	rm -rf $(TARGET_DIR)/usr/local/lib/perl5

PERL_MODULES-dirclean:

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_PERL_MODULES)),y)
TARGETS+=PERL_MODULES
endif

