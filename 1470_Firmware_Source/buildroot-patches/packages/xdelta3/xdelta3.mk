#############################################################
#
# xdelta3
#
#############################################################
XDELTA3_VER:=0q
XDELTA3_SOURCE:=xdelta3$(XDELTA3_VER).tar.gz
XDELTA3_SRC=xdelta3.c
XDELTA3_SITE:=http://xdelta.googlecode.com/files/
XDELTA3_DIR:=$(BUILD_DIR)/xdelta3$(XDELTA3_VER)
XDELTA3_CAT:=zcat
XDELTA3_BINARY:=xdelta3
XDELTA3_TARGET_BINARY:=usr/sbin/xdelta3
XDELTA3_CC_OPTS:=-DXD3_DEBUG=0 \
              -DXD3_USE_LARGEFILE64=1 \
              -DREGRESSION_TEST=0 \
              -DSECONDARY_DJW=1 \
              -DSECONDARY_FGK=1 \
              -DXD3_MAIN=1 \
              -DXD3_POSIX=1


$(DL_DIR)/$(XDELTA3_SOURCE):
	 $(WGET) -P $(DL_DIR) $(XDELTA3_SITE)/$(XDELTA3_SOURCE)

xdelta3-source: $(DL_DIR)/$(XDELTA3_SOURCE)

#############################################################
#
# build xdelta3 for use on the target system
#
#############################################################
$(XDELTA3_DIR)/.unpacked: $(DL_DIR)/$(XDELTA3_SOURCE)
	$(XDELTA3_CAT) $(DL_DIR)/$(XDELTA3_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(XDELTA3_DIR) package/xdelta3/ xdelta3\*.patch
	touch  $(XDELTA3_DIR)/.unpacked

$(XDELTA3_DIR)/.configured: $(XDELTA3_DIR)/.unpacked
	touch  $(XDELTA3_DIR)/.configured

$(XDELTA3_DIR)/$(XDELTA3_BINARY): $(XDELTA3_DIR)/.configured
	${TARGET_CC} $(TARGET_CFLAGS) $(XDELTA3_CC_OPTS)\
			${XDELTA3_DIR}/${XDELTA3_SRC} -o ${XDELTA3_DIR}/${XDELTA3_BINARY}
   
$(TARGET_DIR)/$(XDELTA3_TARGET_BINARY): $(XDELTA3_DIR)/$(XDELTA3_BINARY)
	cp $(XDELTA3_DIR)/$(XDELTA3_BINARY) $(TARGET_DIR)/$(XDELTA3_TARGET_BINARY)


xdelta3: uclibc $(TARGET_DIR)/$(XDELTA3_TARGET_BINARY)

xdelta3-clean:
	$(MAKE) -C $(XDELTA3_DIR) clean

xdelta3-dirclean:
	rm -rf $(XDELTA3_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_XDELTA3)),y)
TARGETS+=xdelta3
endif
