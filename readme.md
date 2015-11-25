#SSH Jumpstation  
SSH Jumpstation was written to allow for a secure way to provide access to multiple systems while controlling what system and what users have access to those remote systems.  This allows you to limit the source IPs on remote infrastructure.  Once a user SSHs to your server, it will allow provide a them with a menu of choices and destinations they can connect to.

###Requirements  
Linux Server  
SSHConnect Bash scripts  
Flat File Database Manager - Based on [http://www.zubrag.com/scripts/flatfile-database-manager.php](http://www.zubrag.com/scripts/flatfile-database-manager.php)  
Apache  
PHP  

###SSHConnect Main Files
* sshconnect.sh – Core script to display menuing system and to create SSH connections
* list files – The files containing the hostnames of devices to connect to
* profile.local (or just "profile" on RaspberryPI) – The file to ensure that all users except admins can only access the jumpstation menu
* rysnc_sshjump.sh – A script that can be placed in cron.hourly to ensure any redundant devices are maintained (optional file)
* sshcp.sh – A script used to manually copy files to redundant devices  (optional file)

###Setup  
The profile.local should be copied into the /etc folder or the existing /etc/local.profile file should be updated.  This file is what forces users to run the sshconnect.sh script and never obtain local command line access.  Any user listed in this file will NOT be forced into using the jumpstation and will have the ability to obtain command line access.

The $USER variable should be compared against the UserID of the person logging in:  
```
if test "$USER" != "root" -a "$USER" != "UserID1" -a "$USER" != "UserID2" ; then  
	exec /opt/sshjump/sshconnect.sh  
fi
```
**!!! If you use the profile.local file, make sure that you add the primary user ID you use to manage your linux server or you will not be able to regain access to the command line!  If you choose not to use the profile.local file, users would need to manually run the script and they will have command line access to your server.!!!**  

Create a folder in /opt for the scripts and configuration files:    
_mkdir /opt/sshjump_

The following are the main files that should exist within the _sshjump_ folder:

[root@yourhost ~]# ls -la /opt/sshjump/  
drwxr-xr-x 2 root root  4096 Jan 19 06:43 files  
-rwxr-xr-x 1 root root  3900 Dec 14 06:26 sshconnect.sh  
-rwxr-xr-x 1 root root   303 Dec 23  2009 sshcp.sh  

The shell scripts must have execute permissions enabled.

The _files_ folder should contain all of the list files which contain the various hostnames and descriptions for the devices that will be displayed in the menuing system:


[root@yourhost ~]# ls -la /opt/sshjump/files/  
-rw-rw-rw- 1 root root  159 Nov 23 15:39 callcenter  
-rw-rw-rw- 1 root root   89 Jan 18 17:12 device_categories  
-rw-rw-rw- 1 root root  497 Feb 23  2011 routers  
-rw-rw-rw- 1 root root 2252 Jan 12 16:32 misc_devices   

If the files are to be maintained with the Flat File Database Manager and managed via a web interface, then you must set up the appropriate read/write permissions:

_chmod 666 /opt/sshjump/files/*_

The *device_categories* file is a list which contains the names of the other filenames.  This is so that the initial menu will provide options of which list to display.

<img src="https://github.com/csawall/sshjumphost/blob/master/images/sshconnect_mainmenu.jpg" width="50%">

<img src="https://github.com/csawall/sshjumphost/blob/master/images/sshconnect_submenu.jpg" width="50%">

Copy and configure the _rsync_ssh.sh_ file if necessary so that all files can be copied to redundant systems.

[root@yourhost ~]# ls -la /etc/cron.hourly/  
-rwxr-xr-x  1 root root  1955 Apr  1  2010 rsync_sshjump.sh

###Flat File Database Manager (FFDM)  
If this program is being used, it must be installed in the Apache root directory.  Having this installed allows for easier management and allows for the network team to make their own updates as they add devices.

[root@yourhost ~]# ls -la /var/www/html/  
drwxr-xr-x 2 root root 4096 Jan 19 06:41 sshconnect  
-rw-r--r-- 1 root root   64 Dec 18  2009 index.php  

The index.php file simply redirects the user to the _sshconnect_ folder.  If this is a shared web server you will not want to copy this file.  

<?php header( 'Location: http://**{servername}**/sshconnect/' ); ?>

Create symbolic link to the sshjump database files within the _sshconnect_ folder:  
_ln -s /opt/sshjump/files/ sshjump_

The sshconnect folder contains the following files:

[root@yourhost ~]# ls -la /var/www/html/sshconnect/  
-rw-r--r-- 1 root root 7367 Jan  3  2010 flatfile.inc.php  
-rw-r--r-- 1 root root 1058 Dec 17  2009 index.php  
lrwxrwxrwx 1 root root   17 Dec 17  2009 sshjump -> /opt/sshjump/files/  
-rw-r--r-- 1 root root   99 Dec 17  2009 sshjump.def  

###FFDM Files  
The _sshjump_ folder is a link to the actual files sub-folder in the main _sshjump_ program folder.  This is configured within FFDM so that it knows where the files are that it will be managing.  The only file that FFDM cannot manage is the *device_categories* file.  If a new category (list) needs to be added, this file will need to be manually updated and appropriate permissions set.

The _sshjump.def_ file tells FFDM how to structure the web interface to obtain appropriate input.  This is also explained in more detail in the _flatfile.inc.php_ file.

Device,STRING,20  
City,STRING,20  
State,LIST,1,NY:GA:CO  
Facility,STRING,20  
Description,TEXT,30:1

You can see how the above data structure is displayed in the below screenshot.

<img src="https://github.com/csawall/sshjumphost/blob/master/images/sshconnect_main.jpg" width="50%">

The _flatfile.inc.php_ file is used by the main _index.php_ file and functions to read in and interpret the various "database" flat files.  There should be no need to modify this file.  _It should be noted that several custom updates have been made to this file.  If it is replaced with a newer version, those updates should be reviewed and moved into the newer version if applicable.  A comment has been added in several locations where customization has taken place._

The _index.php_ file has a few configurable sections.   The directory / path information can be modified at the top of the php file.

$catpath = "**sshjump**";
$mainlist = "**sshjump/device_categories**";

The various ancillary configuration files and delimiters can be configured as well:

// Database definition file. You have to describe database format in this file.  
// See flatfile.inc.php header for sample.  
$structure_file = '**sshjump.def**';

// Fields delimiter  
$delimiter = '**|**';  

// Number of header lines to skip. This is needed if you have some heder saved in the  
// database file, like comment or description  
$skip_lines = 0;

// run flatfile manager  
include ('**flatfile.inc.php**');  

Once configured, you'll be able to edit your files from the FFDM web interface.  The various categories you define will be in the upper lefthand dropdown.  You can clear the screen back to default by clicking on the "clear" link.  
<img src="https://github.com/csawall/sshjumphost/blob/master/images/sshconnect_dropdown.jpg" width="50%">
<img src="https://github.com/csawall/sshjumphost/blob/master/images/sshconnect_exp.jpg" width="50%">

###Other Information
Care should be taken to set up your web service securely.  If you use the FFDM, you should ensure you enable SSL as well as some type of user authentication.

###Acknowledgements
I should note that the sshconnect.sh script was modeled after another script I found years ago, but did not document the source and can not find any trace of it online any longer.  It was heavily modified to provide the functionality I needed, such as multiple screens, a tie into the FFDM, locking out users from escaping from the script, clearing SSH keys, and so on.
