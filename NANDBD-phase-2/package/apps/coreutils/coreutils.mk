
COREUTILS_VERSION:=7.4
COREUTILS_SOURCE:=coreutils-$(COREUTILS_VERSION).tar.gz
COREUTILS_DIR:=$(BUILD_DIR)/coreutils-$(COREUTILS_VERSION)
COREUTILS_BINS:=cat chgrp chmod chown cp date dd df dir echo false hostname \
	ln ls mkdir mknod mv pwd rm rmdir vdir sleep stty sync touch true uname

ifeq ($(SDK_ROOTFS_APPS_BUSYBOX),y)
coreutils: busybox $(ROOTFS_DIR)/bin/vdir
else
coreutils: $(ROOTFS_DIR)/bin/vdir
endif

$(ROOTFS_DIR)/bin/vdir: $(COREUTILS_DIR)/src/vdir
	$(MAKE) DESTDIR=$(ROOTFS_DIR) -C $(COREUTILS_DIR) install-exec
	# some things go in root rather than usr
	for f in $(COREUTILS_BINS); do \
		mv $(ROOTFS_DIR)/usr/bin/$$f $(ROOTFS_DIR)/bin/$$f; \
	done
	# link for archaic shells
	ln -sf test $(ROOTFS_DIR)/usr/bin/[
	# gnu thinks chroot is in bin, debian thinks it's in sbin
	mv $(ROOTFS_DIR)/usr/bin/chroot $(ROOTFS_DIR)/usr/sbin/chroot

$(COREUTILS_DIR)/src/vdir: $(COREUTILS_DIR)/.configured
	$(MAKE) -C $(COREUTILS_DIR)

$(COREUTILS_DIR)/.configured: $(COREUTILS_DIR)/.patched
	(cd $(COREUTILS_DIR); rm -rf config.cache; \
		ac_cv_func_strtod=yes \
		ac_fsusage_space=yes \
		fu_cv_sys_stat_statfs2_bsize=yes \
		ac_cv_func_closedir_void=no \
		ac_cv_func_getloadavg=no \
		ac_cv_lib_util_getloadavg=no \
		ac_cv_lib_getloadavg_getloadavg=no \
		ac_cv_func_getgroups=yes \
		ac_cv_func_getgroups_works=yes \
		ac_cv_func_chown_works=yes \
		ac_cv_have_decl_euidaccess=no \
		ac_cv_func_euidaccess=no \
		ac_cv_have_decl_strnlen=yes \
		ac_cv_func_strnlen_working=yes \
		ac_cv_func_lstat_dereferences_slashed_symlink=yes \
		ac_cv_func_lstat_empty_string_bug=no \
		ac_cv_func_stat_empty_string_bug=no \
		gl_cv_func_rename_trailing_slash_bug=no \
		ac_cv_have_decl_nanosleep=yes \
		jm_cv_func_nanosleep_works=yes \
		gl_cv_func_working_utimes=yes \
		ac_cv_func_utime_null=yes \
		ac_cv_have_decl_strerror_r=yes \
		ac_cv_func_strerror_r_char_p=no \
		jm_cv_func_svid_putenv=yes \
		ac_cv_func_getcwd_null=yes \
		ac_cv_func_getdelim=yes \
		ac_cv_func_mkstemp=yes \
		utils_cv_func_mkstemp_limitations=no \
		utils_cv_func_mkdir_trailing_slash_bug=no \
		gl_cv_func_rename_dest_exists_bug=no \
		jm_cv_func_gettimeofday_clobber=no \
		am_cv_func_working_getline=yes \
		gl_cv_func_working_readdir=yes \
		jm_ac_cv_func_link_follows_symlink=no \
		utils_cv_localtime_cache=no \
		ac_cv_struct_st_mtim_nsec=no \
		gl_cv_func_tzset_clobber=no \
		gl_cv_func_getcwd_null=yes \
		gl_cv_func_getcwd_path_max=yes \
		ac_cv_func_fnmatch_gnu=yes \
		am_getline_needs_run_time_check=no \
		am_cv_func_working_getline=yes \
		gl_cv_func_mkdir_trailing_slash_bug=no \
		gl_cv_func_mkstemp_limitations=no \
		ac_cv_func_working_mktime=yes \
		jm_cv_func_working_re_compile_pattern=yes \
		ac_use_included_regex=no \
		gl_cv_c_restrict=no \
		$(TARGET_CONFIGURE_OPTS)	\
		./configure	\
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libdir=/lib \
		--libexecdir=/usr/lib \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--disable-rpath \
		--disable-dependency-tracking \
	)
	touch $@

$(COREUTILS_DIR)/.patched: $(COREUTILS_DIR)/.unpacked
	@script/patch-kernel.sh $(COREUTILS_DIR) package/apps/coreutils coreutils-$(COREUTILS_VERSION)\*.patch
	# ensure rename.m4 file is older than configure / aclocal.m4 so
	# auto* isn't rerun
	touch -d '1979-01-01' $(@D)/m4/rename.m4
	@touch $@

$(COREUTILS_DIR)/.unpacked:
	@cd $(BUILD_DIR);	\
		(tar -xvf $(PKG_DIR)/$(COREUTILS_SOURCE))
	@touch $@

# If both coreutils and busybox are selected, the corresponding applets
# may need to be reinstated by the clean targets.
coreutils-clean:
	-$(MAKE) DESTDIR=$(ROOTFS_DIR) -C $(COREUTILS_DIR) uninstall
	-$(MAKE) -C $(COREUTILS_DIR) clean

coreutils-dirclean:
	rm -rf $(COREUTILS_DIR)

ifeq ($(strip $(SDK_ROOTFS_APPS_COREUTILS)),y)
SDK_ROOTFS_PACKAGES += coreutils
endif

