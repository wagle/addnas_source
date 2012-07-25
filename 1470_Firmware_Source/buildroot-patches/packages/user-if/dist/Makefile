#
# Make file to take the web interface files and a nubber of configuration files
# and put them in the right places with the right permissions.
#

HTML_DIR=$(TARGET_DIR)/usr/www
SRC_DIR=$(CURDIR)/src

# where the config files loosly associoted with the web-ui are stored. Other
# files may reference this location, so be careful if you change it.
CONFIG_DIR=$(TARGET_DIR)/var/oxsemi

# list all in lib, nbin and ptpl from the src directory with their 
# target being /usr/www/...
web-content = $(shell \
	cd $(SRC_DIR)/nbin ;\
	find . -xtype f -printf $(HTML_DIR)/nbin/%p\\n ;\
	cd $(SRC_DIR)/ptpl ;\
	find . -xtype f -printf $(HTML_DIR)/ptpl/%p\\n ;\
	cd $(SRC_DIR)/lib ;\
	find . -xtype f -printf $(HTML_DIR)/lib/%p\\n ;\
	)

# These are writable config files, copied with 644 permissions
writable-config-files = \
	$(CONFIG_DIR)/nas.ini \
	$(CONFIG_DIR)/nas.ini.factory \
	$(CONFIG_DIR)/shares.inc \
	$(CONFIG_DIR)/senvid.inc \
	$(TARGET_DIR)/var/private/lighttpd.htdigest.user \
	$(TARGET_DIR)/var/private/lighttpd.htdigest.user.factory

# These are read only config files, copied with 444 permissions
readonly-config-files = \
	$(TARGET_DIR)/etc/lighttpd/lighttpd.conf

# the sudoers file must be copied with 440 permissions
sudoers-config-file = $(TARGET_DIR)/etc/sudoers

# various empty and non-empty directories required for things to run
directories = \
	$(CONFIG_DIR) 
		
.PHONEY: user-if
# this is quite a long line, so pay attention
user-if : $(directories) $(web-content) $(writable-config-files) $(readonly-config-files) $(sudoers-config-file)

# go through all the web content take from src_dir and install in html_dir
$(web-content) : $(HTML_DIR)%: $(SRC_DIR)%
	install -D $< $@

# Always install the sudoers file
$(sudoers-config-file) :
	rm -f $@
	install -D -m 440 $(SRC_DIR)/sudoers $@

$(CONFIG_DIR)/nas.ini : $(SRC_DIR)/nas.ini
	install -D -m 666 $< $@

$(CONFIG_DIR)/nas.ini.factory : $(SRC_DIR)/nas.ini.factory
	install -D -m 666 $< $@

$(CONFIG_DIR)/shares.inc :
	touch $@
	chmod a+w $@

$(CONFIG_DIR)/senvid.inc :
	touch $@
	chmod a+w $@

$(TARGET_DIR)/etc/lighttpd/lighttpd.conf : $(SRC_DIR)/lighttpd.conf
	install -D -m 444 $< $@

$(TARGET_DIR)/var/private/lighttpd.htdigest.user : $(SRC_DIR)/lighttpd.htdigest.user
	install -D -m 666 $< $@

$(TARGET_DIR)/var/private/lighttpd.htdigest.user.factory : $(SRC_DIR)/lighttpd.htdigest.user.factory
	install -D -m 666 $< $@

$(directories)::
	if [ ! -d $@ ] ;then mkdir $@;fi
	chmod a+w $@

## Target for perl unit tests
# NB Some tests require unix utils for the nas that may not be present on the
# test system. 
# Some require sudo password to be entered.
# The 02_CoreCompile requires some perl modules to run.
test: test02 test05 test10 test11 test12 test13 test14

test02:  
	perl -I./lib/ t/02_CoreCompile.t 

test05:
	perl -I./lib/ t/05_SysCmd.t

test10:
	perl -I./lib/ t/10_Ethernet.t

test11:
	perl -I./lib/ t/11_Storage.t

test12:
	perl -I./lib/ t/12_Permission.t

test13:
	perl -I./lib/ t/13_Config.t

test14:
	perl -I./lib/ t/14_Session.t

testAll:
	perl -I ./lib -MTest::Harness -e'runtests( sort glob( "t/*.t") )'

live:
	./dbin/makelive
