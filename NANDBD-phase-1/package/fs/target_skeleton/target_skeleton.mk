
NAS_SYSTEM_TYPE:=2nc
ifeq ($(strip $(subst ",, $(SDK_TARGET_PLATFORM))), 7820)
#"))
NAS_SYSTEM_TYPE:=1nc
endif
ifeq ($(strip $(subst ",, $(SDK_TARGET_PLATFORM))), 7825_SINGLE)
#"))
NAS_SYSTEM_TYPE:=1nc
endif

TARGET_DEVICE_TABLE := package/fs/target_skeleton/device_table.txt

TARGET_SKELETON_DIRS := bin dev/pts etc/crontabs etc/default etc/hotplug/pci etc/hotplug/usb etc/hotplug.d/default etc/init.d etc/lighttpd etc/network etc/ssmtp home/guest lib man mnt opt proc root sbin sys tftpboot usr/bin usr/include usr/lib usr/local/samba/lib usr/sbin usr/share/terminfo/a usr/share/terminfo/d usr/share/terminfo/l usr/share/terminfo/r usr/share/terminfo/s usr/share/terminfo/v usr/share/terminfo/x usr/share/udhcpc usr/share/zoneinfo usr/www var/empty var/etc/ssmtp var/lib/pcmcia var/lock var/locks var/log/lighttpd var/log/httpd var/mionet var/oxsemi var/pcmcia var/pending var/private var/run var/spool/cron/crontabs/root var/spool/cups var/spool/samba var/tmp var/upgrade

target_skeleton: $(ROOTFS_DIR)/var/lib/current-version

$(ROOTFS_DIR)/var/lib/current-version:
	$(call create_skeleton, $(ROOTFS_DIR),	\
		"var/lib/current-version", $(NAS_SYSTEM_TYPE))

target_skeleton-clean:
	@rm -rf $(ROOTFS_DIR)/var/lib/current-version

ifeq ($(strip $(subst ",, $(SDK_BUILD_NAND_BOOT))), y)
#"))

mini_skeleton: $(MINIFS_DIR)/var/lib/current-version

$(MINIFS_DIR)/var/lib/current-version:
	@$(call create_skeleton, $(MINIFS_DIR),	\
		"var/lib/current-version", $(NAS_SYSTEM_TYPE))

mini_skeleton-clean:
	@rm -rf $(MINIFS_DIR)/var/lib/current-version

endif

create_skeleton =	\
	PREFIX="$(strip $1)";	\
	VERSION_FILE="$(strip $2)";	\
	SYSTEMTYPE="$(strip $3)";	\
 \
	for d in $(TARGET_SKELETON_DIRS); do	\
		mkdir -p $${PREFIX}/$$d;	\
	done;	\
	ln -sf ../var/etc/exports $${PREFIX}/etc/exports;	\
	ln -sf ../var/etc/TZ $${PREFIX}/etc/TZ;	\
	ln -sf ../../var/etc/ssmtp/ssmtp.conf $${PREFIX}/etc/ssmtp/ssmtp.conf;	\
	ln -sf S30network $${PREFIX}/etc/init.d/K60network;	\
	ln -sf S20urandom $${PREFIX}/etc/init.d/K70urandom;	\
	ln -sf S25time $${PREFIX}/etc/init.d/K65time;	\
	rsync -avzC package/fs/target_skeleton/root/* $${PREFIX} &&	\
		chmod +x $${PREFIX}/sbin/* &&	\
		chmod +x $${PREFIX}/etc/*.sh &&	\
		chmod +x $${PREFIX}/etc/zcip.conf &&	\
		chmod +x $${PREFIX}/etc/init.d/* &&	\
		chmod +x $${PREFIX}/etc/hotplug.d/default/* &&	\
		chmod +x $${PREFIX}/etc/hotplug/*.{agent,functions,rc} &&	\
		chmod +x $${PREFIX}/etc/hotplug/mount-external-drive;	\
	$(SED) 's/system_type[ ^t]*=.*$$/system_type='$${SYSTEMTYPE}'/' $${PREFIX}/var/oxsemi/network-settings;	\
	echo -n "$(strip $(subst ",, $(SDK_BUILD_VERSION)))" > $${PREFIX}/$${VERSION_FILE}

