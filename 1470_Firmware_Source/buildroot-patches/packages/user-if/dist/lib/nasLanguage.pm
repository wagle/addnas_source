#
#	Holds the translations of messages used within templates.
#
#

package nasLanguage;

use Exporter();

@EXPORT_OK=qw($message);
@ISA=qw(Exporter);

use strict;
use vars qw($message);

$message = {

	en	=>	{
		# Main page, system alerts, system storage
		#
		SystemUsers => 'Current System Users',
		SystemShares => 'Current System Shares',
		m01000 => 'NAS Manager',
		m01001 => 'Addonics NAS Configuration',
		m01002 => 'Device Name',
		m01003 => 'Firmware',
		m01004 => 'Drive Status',
		m01005 => 'Administrator',
		m01006 => 'Home',
		m01007 => 'Language',
		m01008 => 'Help',
		m01009 => 'Addonics Technologies',
		m01010 => 'Configuration',
		m01011 => 'Sharing',
		m01013 => 'System Alerts',
		m01014 => 'System Summary',
		m01015 => 'Storage',
		m01016 => 'Total Space',
		m01017 => 'Available Space',
		m01018 => 'Percentage Free',
		m01019 => 'Network',
		m01021 => 'Speed',
		m01022 => 'IP Address',
		m01023 => 'Default Gateway',
		m01024 => 'Workgroup',
		m01025 => 'Apply',
		m01026 => 'Finish',
		m01027 => 'Cancel',
		m01028 => 'Update',
		m01029 => q[System reconfiguring...],
		m01030 => q[Please wait while the system is reconfigured.],

		m01031 => q[The system is now ready. Click on tab to continue...],
		m01032 => q[Internal drive(s)],
		m01033 => q[External drive(s)],
		m01034 => q[Please reboot your computer to make sure settings are updated],
		m01035 => q[Applying these changes will require you to reboot your PC. Please click Cancel if you do not wish to do this at this time.],
		m01036 => 'Next',
       m01037 => q[One of your IP addresses may be part of a broadcast range, and will not work on most networks. Be sure that these settings are suitable before you continue],
		m01038 => 'P2P/MLDonkey',
		m01039 => 'Reboot',
		m01040 => "Rebooting. Interface will become unresponsive and remain so until reboot completes.",
                m01041 => q[Applying this change will require you to restart the ftp server.  Please click Cancel if you do not wish to do this at this time.],
		m01042 => 'Workgroup',
		# home page
		#
		m02001 => 'Welcome to the Configuration Manager',,
		m02002 => 'This option will allow you to create or update folders and file-share settings (add, rename, delete, permissions).',
		m02003 => 'Advanced',
		m02004 => 'Drive management should be used to view more detailed information about the health of your drive, manage volumes (create, resize,remove), and overall drive statistics.',
		m02005 => 'Configure username and password, date/time, device/workgroup name, network settings, upgrade firmware and view or edit your drive settings.',
		m02006 => 'This option will allow you to control the build in MLDonkey P2P client software and add/remove downloads from the queue.',
		# Initial setup
		#
		m03001 => 'Device Language',
		m03002 => 'Please choose your language',
		m03003 => 'English (Uk)',
		m03004 => 'French',
		m03005 => 'German',
		m03006 => 'Italian',
		m03007 => 'Spanish',
		m03008 => 'Chinese',
		m03015 => 'EULA',
		m03016 => 'Please review the following End User License Agreement and acknowledge your acceptance below to proceed',
		m03018 => 'I Accept',
		m03019 => 'I do NOT Accept',
		m03020 => 'Welcome to the Initial Setup wizard.',
		m03021 => 'This wizard will guide you through the steps necessary to configure your NAS for use in your home or office network.',
		m03022 => 'Please click "Next" when you are ready...',

		# Change username and password
		#
		m04001 => 'Admin Username',
		m04002 => 'New Password',
		m04003 => 'Confirm Password',
		m04004 => 'Continue',
		m04005 => 'Initial User &amp; Password Setup',
	m04006 => 'Next',
	m04007 => 'Back',
		m04008 => 'Username',
        m04009 => 'Change Username &amp; Password Finished',
        m04010 => 'Username and Password updated.',

		e04001 => 'Username is required',
		e04002 => 'Password is required',
		e04003 => 'Passwords do not match',
		e04004 => 'Use only letters, numbers, a-z or 0-9',
		e04005 => 'Username must be between 5 and 20 characters',
		e04006 => 'Use only letters, numbers, a-z or 0-9',
		e04007 => 'Password must be between 5 and 20 characters',
		e04008 => 'Username must start with an alphabetic character',

		# Set date and time
		#
		m05001 => 'Current Date',
		m05002 => 'Current Time',
		m05003 => 'New Date',
		m05004 => 'New Time',
		m05005 => 'TimeZone',
		m05006 => 'January',
		m05007 => 'February',
		m05008 => 'March',
		m05009 => 'April',
		m05010 => 'May',
		m05011 => 'June',
		m05012 => 'July',
		m05013 => 'August',
		m05014 => 'September',
		m05015 => 'October',
		m05016 => 'November',
		m05017 => 'December',
		m05018 => 'Date and Time Settings',
		m05019 => 'Initial Date &amp; Time Setup',
		m05020 => 'Initial Setup Wizard Finished',
		m05021 => 'You have completed the initial setup wizard and you may now continue to update your settings.',

		m05022 => 'Summary of settings:',
		m05023 => 'Update settings',
		m05024 => 'Cancel',


        m05025 => 'Monday',
        m05026 => 'Tuesday',
        m05027 => 'Wednesday',
        m05028 => 'Thursday',
        m05029 => 'Friday',
        m05030 => 'Saturday',
        m05031 => 'Sunday',
        m05032 => 'Date and Time Settings Updated',

		e05001 => 'Please enter a valid date',
		e05002 => 'Please enter a valid time',

		# General Setup page
		#
		m06001 => 'Configure the basic settings of the NAS',
		m06002 => 'Update Admin Username and Password [Advanced]',
		m06003 => 'Change Current Date and Time',
		m06004 => 'Update Device/Workgroup Names',
		m06005 => 'Configure the Network Settings',
		m06006 => 'Upgrade the System Firmware',
		m06007 => 'Configure Email Alerts',
		m06008 => 'Configure User Home Directory Drive',
		m06009 => 'View Drive Information',
		m06010 => 'View User Samba and FTP Login Information',
		m06011 => 'Change FTP Port Number',
		m06012 => 'View Current Network Configuration',

		# Device name and workgroup
		#
		m07001 => 'New Name',
		m07002 => 'New Workgroup',
		m07003 => 'Device name and Workgroup updated',
		m07004 => 'Update Device/Workgroup Names',
		m07005 => 'FTP Port Number updated',
		e07001 => 'Device Name is required',
		e07002 => 'Workgroup is required',
		e07003 => 'Device Name contains invalid characters use characters a-z, 0-9',
		e07004 => 'Work Group contains invalid characters use characters a-z, 0-9',
		e07005 => 'Device Name too long',
		e07006 => 'Work Group name too long',
		e07007 => 'Device Name cannot start with a number',

		# Update Network Settings
		#
		m08001 => 'Network Address Wizard',
		m08002 => 'This section is intended only for advanced users',
		m08003 => 'The Obtain Network Address wizard allows you to change the NAS network settings to a specific configuration. If you are unsure about manually configuring a network, you may cancel this wizard by selecting \'cancel\' button',
		m08004 => 'Begin Wizard',
		m08005 => 'Step',
		m08006 => 'Obtain Network Address:',
		m08007 => 'Automatic',
		m08008 => 'Manual',
		m08009 => 'Next >>',
		m08010 => 'Network Address and Subnet Settings',
		m08011 => 'Network Address',
		m08012 => 'Subnet',
		m08013 => 'Proceed to Gateway Page',
		m08014 => 'Gateway',
		m08015 => 'Finished Gathering Information. Click Finish to update the NAS with the new settings',
		m08016 => 'Network Settings Updated',
		m08017 => 'You have updated the network wizard',
		m08018 => 'DNS Servers',
		m08019 => 'NTP Server',
		m08020 => 'Recommended subnet mask is 255.255.255.0',
		m08021 => 'Back',
		m08022 => 'Subnet Mask',

		e08001 => 'A value between 0 and 255 is required',
		e08002 => 'The address range above 224.0.0.0 is reserved',
		e08003 => 'The address range 127.xxx.xxx.xxx is reserved',
		e08004 => 'Enter the address in decimal numbers',
		e08005 => 'This is not a valid URL',
		e08006 => 'The address range 0.xxx.xxx.xxx is reserved',
		e08007 => '0 and 32 or above are reserved mask values',
		e08008 => 'This is not a valid network mask',
		e08009 => 'A value between 1 and 254 is required',

		# File Share Home Page
		#
		UserDelete => 'Delete',
		UserEdit => 'Edit',
		UserName => 'Username',
		UserCancel => 'Cancel',
		UserCreate => 'Create',
		UserUpdate => 'Update',
		UserDelete => 'Delete',
		UserSelectShareAccess => 'Select Share Access',
		UserCreateNew => 'Create a new user',
		UserUpdateDetails => 'Update user details',
		UserDeleteUser => 'Delete this user',
		m09001 => 'File Sharing',
		m09002 => 'Change Share Access Type',
		m09003 => 'Add a Shared Folder',
		m09004 => 'Rename a Shared Folder',
		m09005 => 'Remove a Shared Folder',
		m09006 => 'Update Security Settings',
		m09007 => 'User',
		m09008 => 'Password',
		m09009 => 'Current Share Access Type',
		m09010 => 'New Share Access Type',
		m09011 => 'Update',
		m09012 => 'User Management',
		m09013 => 'Share Access Type Updated',
		m09014 => 'Existing Users',
		m09015 => 'Delete',
		m09016 => 'Change Password',
		m09017 => 'Create User',
		m09018 => 'Current Shared Folder Settings',
		m09019 => 'FTP Access',
		m09020 => 'Update Access Settings',

		# File Share User Man - Add new user
		#
		m10001 => 'Create User',
		m10002 => 'New User Name',
		m10003 => 'User Management',
		m10004 => 'Share Permissions',
		m10005 => 'Share Name',
		m10006 => 'Full',
		m10007 => 'Read Only',
		m10008 => 'None',
		m10009 => 'User Settings Updated',
		m10010 => 'Drive',
		m10011 => 'Available?',
		e10001 => 'Username already exists',

		# File Share - Add new Share
		#
		m11001 => 'Add a Share Wizard',
		m11002 => 'Welcome to the Add a Shared Folder Wizard, which guides you through the steps of adding a shared folder to the NAS. Be prepared to provide details such as the folder name and public or private access',
		m11003 => 'Begin Wizard',
		m11004 => 'Step 2: Create Shared Folder Name',
		m11005 => 'New Shared Folder Name',
		m11006 => 'Step 1: Select Volume',
		m11007 => 'Volume',
		m11008 => 'Step 3: Access Setting',
		m11009 => 'NFS (Public Share)',
		m11010 => 'HTTP',
		m11011 => 'FTP',
		m11012 => 'CIF',
		m11013 => 'Step 3: Security Setting',
		m11014 => 'To allow public access please leave the two password fields below blank. To restrict access, enter a password into the two fields below. Access to the share will then only be permitted if the matching password is used.',
		m11015 => 'User Name',
		m11016 => 'Submit Setting',
		m11017 => q[Please press the 'Create Share Folder' button to finish creating your new share.],
		m11018 => 'Create Share Folder',
		m11019 => 'Share Type',
		m11020 => 'Everyone (Set Minimum Permissions)',
		m11021 => 'A CIF share type will be created',
		m11022 => 'Existing Folder',

		# file Share - rename share
		#
		m12001 => 'Rename a Shared folder',
		m12002 => 'Rename Shared folder',
		m12003 => 'Enter the new name for the share and press "Rename Shared folder" button"',
		m12004 => 'The new name',
		m12005 => 'Pick a Share to rename',
		m12006 => 'Public',
		m12007 => 'Private',

		e12001 => 'Share Name is required',
		e12002 => 'Share Name already exists',
		e12003 => 'Share Name contains invalid characters use characters a-z, 0-9',
		e12004 => 'Share Name cannot start with a number',

		m13001 => 'Remove a Shared Folder',
		m13002 => 'If you delete a Shared Folder it and all of its contents will be deleted',
		m13003 => 'To perform the delete you must type "yes" into the confirmation box below',
		m13004 => q[
<font color=red>
<b>Do you want to delete this share?</b>
<br /><br />
WARNING:
<br />
1. If the drive is attached and the selected folder appears as available under the File Sharing screen. the directory <b>will be deleted</b> from the hard drive.<br />
2. If you only want to delete the share folder from this NAS adapter and DO NOT want to delete the directory on the hard drive, be sure the share folder is shown as not available under the File sharing screen before proceeding further. <em>To be sure, you should remove the drive from this NAS adapter before you continue.</em>
<br /><br />
<b>Enter 'yes' into this box to perform the removal:</b>
</font>
			],

		m13005 => 'yes',
		m13006 => 'Select Shared Folder to delete',
		m13007 => 'Delete Shared Folder Now',

		e13001 => 'You must enter "yes" to perform the delete',
		e13002 => 'You must chose a share to remove',

		m14001 => 'Update Security Settings',
		m14002 => 'Select a Shared Folder to update',
		m14003 => 'Pick a share to change',
		m14004 => 'New Password',
		m14005 => 'Confirmation of Password',
		m14006 => 'Please choose a share from the above list',
		m14007 => 'User',
		m14008 => 'Full Access',
		m14009 => 'Read Only',
		m14010 => 'None',
		m14011 => 'Apply Setting',
		m14012 => 'Set permissions above',
		m14013 => 'Settings for ',
		m14014 => 'Settings have been applied to ',
		m14015 => 'Click on a tab to continue...',
		m14016 => q[There are no shares available. Please create shares before using this option. ],
        m14017 => 'CIFS Sharing',

		e14001 => 'Please choose a share',
		e14002 => 'Password do not match',
		e14003 => 'Password is too short',
		e14004 => 'Password is too long',

		# file Share - Update Access
		#
        m14100 => 'Update Access Settings',
        m14101 => 'New access settings:',
        m14102 => 'Choose whether the share should be accessible by Windows (CIF) and/or Mac (NFS) Users.',
        m14103 => 'Cancel this update and return to previous page.',
        m14104 => 'Change the selected shared folder\'s access settings.',
        e14101 => 'One method of access must be selected',

		# Delete User
		#
		m15001 => 'Delete User',
		m15002 => 'This page will delete the selected user',
		m15003 => 'User Name',
		m15004 => 'Delete this user',

		# Drive Management
		m16001 => 'Drive Management',
		m16002 => 'This page allows you to choose your drive configuration',
		m16003 => 'Update',
		m16004 => 'Cancel',
		m16005 => 'What type of storage would you like?',
		m16006 => 'Large Single Volume (RAID-0)',
		m16007 => 'Secure Volume (RAID-1)',
		m16008 => 'Change Drive Type',
		m16009 => 'Format Drive',
		m16010 => 'Format New Internal Drive',
		m16011 => 'Restore RAID State',
		m16012 => 'Are you sure you want to do this? All your data will be deleted.',
		m16013 => q[Yes, I'm sure],
		m16014 => q[Formatting in progress],
		m16015 => q[Formatting Complete],
		m16016 => q[Please wait while this process completes. If this page does not refresh, please navigate back to the home page...],
                m16017 => q[This page allows you to format your drive],
                m16018 => q[Drive name:],
                m16019 => q[No external drives found.],
                m16020 => q[This page allows you to format your NEW internal drive],
                m16021 => q[No new internal drives found.],
                m16022 => q[This page allows you to restore the RAID state on your new drive],
                m16023 => q[Current drive type:],
		m16024 => q[Safely Remove Drive],
		m16025 => q[has been stopped.],
		m16026 => q[You may now safely unplug this drive.],
		m16027 => q[The drive is currently busy. Please stop using all shares and try again.],
		m16030 => 'Are you sure you want to do this?',
		m16031 => 'Your data will be rebuilt automatically.',
		m16032 => 'All your data will be deleted.',
        m16033 => 'Replacement drive detected on ',
		m16034 => 'Completed.',
		m16035 => 'You may now proceed by clicking on another tab.',
        m16036 => q[Have been stopped, you may now safely unplug these drives.],
		e16000 => 'Backup Internal System Configuration Information',
		e16001 => 'Cannot find any existing good drives to rebuild data from',
		e16002 => 'You must specify a drive type.',


		# Email alert config page
		#
		m17001 => 'Email Alerts Setup',
		m17002 => 'Please enter up to 5 email address. An email will be sent to these addresses whenever an alert is triggered',
		m17003 => 'Email Address',
		m17004 => 'Mail Server',
		m17005 => 'Update',
		m17006 => 'Test',
		m17007 => 'Test Email Sent',
		m17008 => 'Port Number',
		m17009 => 'Email addresses updated',
		m17010 => 'Send Domain (Optional)',

		e17001 => 'Invalid email address',
		e17002 => 'Invalid domain address',

		# Firmware Upgrade
		#
		m18001 => 'Upgrade Firmware',
		m18002 => 'There is no new firmware available',
		m18003 => 'New firmware available',
		m18004 => 'Click to download and install',
		m18005 => 'Upgrading Firmware',
		m18006 => 'Please wait while the new firmware is downloaded and applied...',
		m18007 => 'Firmware downloaded and applied',
		m18008 => 'Applying new firmware',
		m18009 => 'Downloading firmware',
		m18010 => 'Enter firmware server IP address',
		m18011 => 'Firmware failed to download - try later',
		m18012 => q[
<ul>
	<li> The upgrade process takes approximately 30minutes depending on internet connection speed and general network activity.
	<li> THE USER SHOULD NOT ACCESS THE DEVICE UNTIL THE UPGRADE IS COMPLETE
	<li> The user must NOT power off the device during the upgrade process.
	<li> The user should NOTE, the front panel lights will
	<ul>
		<li>flicker during firmware download
		<li>extinguish for approximately 15 minutes, whilst applying the firmware
		<li>illuminate when firmware upgrade is complete
	</ul/
</ul>
],
		m18013 => 'It appears that one of your drives is faulty or in an inconsistent state. Please make sure your drives are OK before retrying.',
		m18014 => 'This operation will re-flash the device. Status can be monitored by device LEDs. Do you wish to proceed?',
		m18015 => 'Firmware download error. Please make sure the URL is correct.',
		m18016 => 'Firmware unpackaging error.',
		m18017 => 'Firmware downloaded and unpackaged.',
		m18018 => 'View Drive Information',
		m18019 => 'Are you sure you want to reboot the device?',
		m18020 => 'Firmware update initiated. Please monitor LEDs on device.',
		m18021 => 'Rebooting. Browser interface will become unresponsive.',
		m18022 => 'Selected backup will be restored, and system will go down for reboot (browser interface will become unresponsive). Continue?',
		m18023 => 'Selected backup will be deleted. Continue?',
		m18024 => 'Backup of the current configuration will be created. Continue?',
		e18001 => 'Failed to determine if upgrade available',
		e18002 => 'Failed to determine current firmware version',
		e18004 => 'One and only one drive formatted to the ext3 format with X space available',
		e18005 => 'A URL without a password or login to firmware upgrade tar ball',
                m18025 => 'Firmware device error. Please make sure exactly one disk is connected, and it is sda1.  Unplug all disks, wait 30 seconds, and reconnect one disk is one fix to try.',
		
		# reboot
		# 
		m19001 => q[
<ul>
	<li> The rebooting process may take 2 minutes or longer to complete,
	<li> depending on the number of external drives attached.  During this
	<li> time, this administrative screen will stop functioning.
</ul>
],


        # Disk status
        m20001 => 'Drive A Failed', # sdb
        m20002 => 'Drive B Failed', # sda
        m20003 => 'One Drive Has Failed',
        m20004 => 'Failed',
        m20005 => 'OK',
        m20006 => 'Degraded',
        m20007 => 'Synchronizing',
        m20008 => 'Port A', # sdb
        m20009 => 'Port B', # sda
        m20010 => 'New Drive A', # sdb
        m20011 => 'New Drive B', # sda

		#
		# ftp port number
		#
		e21001 => 'Integer from 0 to 65535 is required',
		m21001 => 'New FTP Port Number',
		m21002 => 'Update FTP Port Number',
		m21003 => 'FTP Port Number Updated!',
		m21004 => 'Update FTP Port Number',
                e21005 => 'A value between 0 and 65535 is required',
                e21006 => 'Enter the port number with numeric digits',

		#
		# current network info
		#
		m22001 => 'Host Name',
		m22002 => 'Samba Workgroup',
		m22003 => 'Network Time Server',
		m22004 => 'Network Mode',
		m22005 => 'Hardware Address',
		m22006 => 'Current IPv4 Address',
		m22007 => 'Current IPv4 Gateway',
		m22008 => 'Current IPv4 Nameservers',

		# Device Error Codes. Use these for the times we fail to write config files, etc
		#
		m99001 => 'A Serious Error has Occurred',
		m99002 => 'Error Code:',
		m99003 => 'Please try again',
		m99004 => 'Please try again later',

		f00000 => 'A fatal error occurred. Please check the logs..',
		f00001 => 'Failed to open nas.ini for reading',
		f00002 => 'Failed to open nas.ini for writing',
		f00003 => 'Failed to write nas.ini',
		f00004 => 'Failed to open passwd for reading',
		f00005 => 'Failed to open smbpasswd for reading',
		f00006 => 'Failed to update device date',
		f00007 => 'Failed to update device time',
		f00008 => 'Failed to update device timezone',
		f00009 => 'Failed to update device admin user and password',
		f00010 => 'Failed to set hostname',
		f00011 => 'Failed to configure network interface',
		f00012 => 'Failed to open shares.inc for reading',
		f00013 => 'Failed to write shares.inc',
		f00014 => 'Failed to add a unix/samba user',
		f00015 => 'Failed to add change Samba Access Type',
		f00016 => 'Failed to write smb.conf',
		f00017 => 'Failed to restart Samba',
		f00018 => 'Failed to find uid in passwd file',
		f00019 => 'Failed to make share directory',
		f00020 => 'Failed to change file permissions',
		f00021 => 'Failed to rename shared directory',
		f00022 => 'Failed to open smb.conf for reading',
		f00023 => 'Failed to remove shared directory',
		f00024 => 'Share name not found in shares.inc',
		f00025 => 'Failed to delete a unix/samba user',
		f00026 => 'Failed to open external share directory',
		f00027 => 'User ID out of range',
		f00028 => 'Failed to open mail server config file',
		f00029 => 'The current version of upgrade is not available',
		f00030 => 'Failed to access upgrade site',
		f00031 => 'Failed to open shares.inc for writing',
		f00032 => 'Failed to open the exports file',
		f00033 => 'Failed to refresh the NFS server',
		f00034 => 'Failed to open disk for reading existing folders.  Disk trouble?',
		f00035 => 'A folder of the same name, but containing lower case letters already exists on that partition.',
		f00036 => 'That name is reserved for system use.  Try another.',
		f00037 => 'Couldn\'t delete user from FTP access database.',
		f00038 => 'Couldn\'t add user to FTP access database.',
		f00039 => 'Couldn\'t rebuild FTP access database.',
		f00040 => 'Couldn\'t reconfig FTP server.',
		f00041 => 'Couldn\'t set FTP access options.',
		f00042 => 'Failed to open ftp access database for reading',
		eTooManyUsers => 'There are too many users. Please logout or wait.',
		eWaitTime1 => 'Please try again in ',
		eWaitTime2 => ' seconds.',
		eWaitTime3 => ' minutes.',

		mld001 => 'MLDonkey is currently running.',
		mld002 => 'MLDonkey is not running.',
		mld003 => 'Launch MLDonkey Control Panel',
		mld004 => 'START',
		mld005 => 'STOP',
		mld006 => 'RESTART',
			},


};

