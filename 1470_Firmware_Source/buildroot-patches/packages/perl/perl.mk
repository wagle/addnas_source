#############################################################
#
# precompiled binary PERL
#
#############################################################
PERL_VER:=5.10.0
PERL_SOURCE:=perl-bin-eabi-$(PERL_VER).tar.bz2

# oxsemi ftp site?
PERL_SITE=

$(DL_DIR)/$(PERL_SOURCE):
	 $(WGET) -P $(DL_DIR) $(PERL_SITE)/$(PERL_SOURCE)

# use perlcc as "proof" of installation
$(TARGET_DIR)/usr/local/bin/perlcc: $(DL_DIR)/$(PERL_SOURCE)
	(\
	cd $(TARGET_DIR);\
	tar -xjf $(DL_DIR)/$(PERL_SOURCE) ;\
	)
	
PERL: $(TARGET_DIR)/usr/local/bin/perlcc

PERL-clean:
	rm $(TARGET_DIR)/usr/local/bin/perl*

PERL-dirclean:

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_PERL)),y)
TARGETS+=PERL
endif

