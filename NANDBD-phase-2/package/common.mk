
#
# set_config
#
# $1: config variabe (Ex. CONFIG_ARM)
# $2: original value (y|n|m|u)
# $3: desired value (y|n|m|u)
# $4: command (set|append)
# $5: config file
#
set_config = \
	VAR="$(strip $1)";	\
	VAL1="$(strip $2)";	\
	VAL2="$(strip $3)";	\
	CMD="$(strip $4)";	\
	CONFIG="$(strip $5)";	\
	\
	if [ "$${VAL1}" != "u" ]; then	\
		STR_TARGET="$${VAR}=$${VAL1}$$";	\
	else	\
		STR_TARGET="\# $${VAR} .*";	\
	fi;	\
	if [ "$${CMD}" == "set" ]; then	\
		if [ "$${VAL2}" != "u" ]; then	\
			STR_RESULT="$${VAR}=$${VAL2}";	\
		else	\
			STR_RESULT="\# $${VAR} is not set";	\
		fi;	\
		sed -i "s/^$${STR_TARGET}/$${STR_RESULT}/" $${CONFIG};	\
	else	\
		STR_RESULT="";	\
		for LINE in $${VAL2}; do	\
			N=`echo $${LINE} | cut -d '=' -f1`;	\
			V=`echo $${LINE} | cut -d '=' -f 2`;	\
			if [ "$${V}" == "u" ]; then	\
				LINE="\# $${N} is not set";	\
			fi;	\
			if [ "$${STR_RESULT}" == "" ]; then	\
				STR_RESULT="$${LINE}";	\
			else	\
				STR_RESULT="$${STR_RESULT}\n$${LINE}";	\
			fi;	\
		done;	\
		sed -i "/^$${STR_TARGET}/a$${STR_RESULT}" $${CONFIG};	\
	fi

#
# board_config_kernel
#
# $1: NOR_SIZ (4|8)
# $2: UART	(3|2)
# $3: BOARD (EVB_NORMAL|EVB_NAND)
# $4: config file
#
board_config_kernel = \
	BOOTMOD="$(strip $1)";	\
	KCONFIG="$(strip $2)";	\
	\
	if [ "$${BOOTMOD}" == "DISK_BOOT" ]; then	\
		$(call set_config, CONFIG_MTD, y, m, set, $${KCONFIG});	\
		$(call set_config, CONFIG_MTD_BLOCK, m, $(strip   \
			CONFIG_MTD_BLOCK_RO=u	\
		), append, $${KCONFIG});    \
		$(call set_config, CONFIG_MTD_UBI, y, m, set, $${KCONFIG});	\
		$(call set_config, CONFIG_UBIFS_FS, y, m, set, $${KCONFIG});	\
		$(call set_config, CONFIG_CRYPTO_DEFLATE, y, m, set, $${KCONFIG});	\
		$(call set_config, CONFIG_CRYPTO_LZO, y, m, set, $${KCONFIG});	\
		$(call set_config, CONFIG_ZLIB_DEFLATE, y, m, set, $${KCONFIG});	\
		$(call set_config, CONFIG_LZO_COMPRESS, y, m, set, $${KCONFIG});	\
		$(call set_config, CONFIG_LZO_DECOMPRESS, y, m, set, $${KCONFIG});	\
	elif [ "$${BOOTMOD}" == "NAND_BOOT" ]; then	\
		$(call set_config, CONFIG_MTD, m, y, set, $${KCONFIG});	\
		$(call set_config, CONFIG_MTD_REDBOOT_PARTS, u, $(strip   \
			CONFIG_MTD_CMDLINE_PARTS=u	\
		), append, $${KCONFIG});    \
		$(call set_config, CONFIG_MTD_CHAR, m, y, set, $${KCONFIG});	\
		$(call set_config, CONFIG_MTD_BLKDEVS, m, y, set, $${KCONFIG});	\
		$(call set_config, CONFIG_MTD_BLOCK, m, y, set, $${KCONFIG});	\
		$(call set_config, CONFIG_MTD_NAND, m, y, set, $${KCONFIG});	\
		$(call set_config, CONFIG_MTD_NAND_IDS, m, y, set, $${KCONFIG});	\
		$(call set_config, CONFIG_MTD_NAND_OX820, m, y, set, $${KCONFIG});	\
		$(call set_config, CONFIG_MTD_UBI, m, y, set, $${KCONFIG});	\
		$(call set_config, CONFIG_UBIFS_FS, m, y, set, $${KCONFIG});	\
		$(call set_config, CONFIG_CRYPTO_DEFLATE, m, y, set, $${KCONFIG});	\
		$(call set_config, CONFIG_CRYPTO_LZO, m, y, set, $${KCONFIG});	\
		$(call set_config, CONFIG_ZLIB_DEFLATE, m, y, set, $${KCONFIG});	\
		$(call set_config, CONFIG_LZO_COMPRESS, m, y, set, $${KCONFIG});	\
		$(call set_config, CONFIG_LZO_DECOMPRESS, m, y, set, $${KCONFIG});	\
	else	\
		echo "Unrecognized Boot Mode: $${BOOTMOD}" && exit 1;	\
	fi
	
#
# copy_toolchain_libs
#
# $1: source
# $2: destination
# $2: strip (y|n)       default is to strip
#
copy_toolchain_libs = \
	PREFIX="$(strip $1)";	\
	LIB="$(strip $2)"; \
	DST="$(strip $3)"; \
	STRIP="$(strip $4)"; \
 \
	LIB_DIR=`$(CROSS_COMPILE)gcc -print-file-name=$${LIB} | sed -e "s,/$${LIB}\$$,,"`; \
 \
	if test -z "$${LIB_DIR}"; then \
		echo "copy_toolchain_libs: lib=$${LIB} not found"; \
		exit -1; \
	fi; \
 \
	for FILE in `find $${LIB_DIR} -maxdepth 1 -type l -name "$${LIB}*"`; do \
		LIB=`basename $${FILE}`; \
		while test \! -z "$${LIB}"; do \
			echo "copy_toolchain_libs lib=$${LIB} dst=$${DST}"; \
			rm -fr $${PREFIX}$${DST}/$${LIB}; \
			mkdir -p $${PREFIX}$${DST}; \
			if test -h $${LIB_DIR}/$${LIB}; then \
				cp -d $${LIB_DIR}/$${LIB} $${PREFIX}$${DST}/; \
			elif test -f $${LIB_DIR}/$${LIB}; then \
				cp $${LIB_DIR}/$${LIB} $${PREFIX}$${DST}/$${LIB}; \
				case "$${STRIP}" in \
				(0 | n | no) \
;; \
				(*) \
					$(CROSS_COMPILE)strip "$${PREFIX}$${DST}/$${LIB}"; \
;; \
				esac; \
			else \
				exit -1; \
			fi; \
			LIB="`readlink $${LIB_DIR}/$${LIB}`"; \
		done; \
	done; \
 \
	echo -n

ln_toolchain_libs = \
	PREFIX="$(strip $1)";	\
	DST="$(strip $2)"; \
	SRC="$(strip $3)"; \
	LNK_DIR="$(strip $4)";	\
	LIB="$(strip $5)"; \
 \
	if test -h $${PREFIX}/$${DST}/$${LIB}; then \
		TARGET=`readlink $${PREFIX}/$${DST}/$${LIB}`;	\
	elif test -f $${PREFIX}/$${DST}/$${LIB}; then	\
		TARGET=`basename $${PREFIX}/$${DST}/$${LIB}`;	\
	else	\
		exit -1;	\
	fi;	\
	FILTER=`echo $${TARGET} | awk -F'[-.]' '$$0 ~ /^lib/ {print $$1}'`;	\
	if test -n "$${FILTER}"; then	\
		ln -sf $${LNK_DIR}/$${TARGET} $${PREFIX}/$${SRC}/$${FILTER}.so;	\
	fi;	\
	echo -n

#
# sdk_strip_binaries
#
# $1: prefix
#
sdk_strip_binaries =	\
	PREFIX="$(strip $1)";	\
 \
	echo -n "Before striping: ";	\
	$(DISKUSAGE) $${PREFIX};	\
	chmod +x $(SCRIPT_DIR)/stripper.sh;	\
	$(SCRIPT_DIR)/stripper.sh $(TARGET_STRIP) $${PREFIX};	\
	echo -n "After stripping: ";	\
	$(DISKUSAGE) $${PREFIX}

