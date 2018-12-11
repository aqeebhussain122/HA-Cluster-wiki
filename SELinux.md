# SELinux – How it works
SELinux is a labelling system used to restrict unauthorised use. Each process in a linux box such as files, objects and directories all carry labels. Each label is then implemented to create policy rules to control access between each label configured.
Why SELinux is needed in our case: 

In order to better understand why SELinux is important and what it can do for you, it is easiest to look at some examples. Without SELinux enabled, only traditional discretionary access control (DAC) methods such as file permissions or access control lists (ACLs) are used to control the file access of users. Users and programs alike are allowed to grant insecure file permissions to others or, conversely, to gain access to parts of the system that should not otherwise be necessary for normal operation. For example:
o	Administrators have no way to control users: A user could set world readable permissions on sensitive files such as ssh keys and the directory containing such keys, customarily: ~/.ssh/
o	Processes can change security properties: A user's mail files should be readable only by that user, but the mail client software has the ability to change them to be world readable
o	Processes inherit user's rights: Firefox, if compromised by a trojaned version, could read a user's private ssh keys even though it has no reason to do so.
Essentially under the traditional DAC model, there are two privilege levels, root and user, and no easy way to enforce a model of least-privilege. Many processes that are launched by root later drop their rights to run as a restricted user and some processes may be run in a chroot jail but all of these security methods are discretionary.
https://wiki.centos.org/HowTos/SELinux

Based upon the section above, the use of SELinux will be mandatory to increase the difficulty of system based attacks. 

There are other attacks which can be done involving elements such as users, file permissions as primary security and ACLs without SELinux
Users: A user which has access to the GRUB bootloader and manages to edit the file, they are able to gain a root shell in which they can re-edit the password at root level, reboot a system and compromise. 
File permissions: With chmod acting as primary security there is the presence of misconfigured file permissions which can be read by Trojan and backdoor processes as well as the use of sticky bits applied within a Linux box. If a sticky bit is found, a root shell can be obtained. 
ACLs: ACLs are good measures of security however there problem is that they are at file level. It may seem impossible to bypass this at user level, however there is nothing stopping an attack coming from kernel level and bypassing all the elements mentioned. SELinux is useful here because it’s embedded inside the kernel with labels. 

## How SELinux Works:
SELinux works in use of policy models using enforcement modes: There are three enforcement modes which carry their own level of security. 

### Enforcement modes:

Enforcing: All actions configured by SELinux will be denied, the security policy is in full enforcement which results in denied access and logs. 
Permissive: All actions are permitted by SELinux module however logs are generated to warn of actions, it is helpful for troubleshooting and even for a mini-honeypot environment. 
Disabled: What it says on the label.

#### SELinux policy:

Strict: By default, the use of SELinux follows use of least-privilege. This defines that everything is denied and policies need to be written in order to allow use of systems to the needed areas. For example, httpd and its directory areas should only be accessible by root but executable only by a normal user.
Targeted: This mode allows interchangeable policies which can coincide. This allows confinement of specific targeted system processes. The use of targeted processes prevent the prevention of user access whilst enforcing the best level of security possible. Targeted allows SELinux to run passively to secure the system without interrupting user experience. 
All processes which are not involved in the SELinux implementation are placed within a domain called unconfined. 


# Troubleshooting
Before continuing on ensure you have policycoreutils-python installed which are the tools needed to continue further. 

Whilst trying to configure DRBD with SELinux there have been some serious complications. Since the SELinux policy has failed to load due to typos in the file, the entire bootup process has completely slowed down and froze. The steps to take to view this troubleshooting step on a test VM are the following:
  1. Enter the grub bootloader screen and press the e key without selecting an OS
  2. Remove the text going along the lines of "rhgb quiet", and add the instance of a shell to your bootup file using the text "init=/bin/bash"
  3. When you get a bash shell, type the command "exec /sbin/init" you will lead into the login screen with a detailed startup screen to notify you of any potential issues. From my current situation, the configuration of SELinux has frozen everything (Because SELinux works with the kernel.)
  4. The following addition of commands should bring you into a "manageable" shell to fix the issue, make sure you remove the rhgb quiet text to ensure you're updated on what's going on. Add the next line of commands within the GRUB file: screen -S drbd -d -m /bin/bash -c "$DRBDADM wait-con-int
$DRBDADM sh-b-pri all
/bin/bash" ALSO ensure you add selinux=0 just to make sure it is disabled. 
  5. According to my attempt you should be presented with a "Dracut Emergency shell", according to minimum research this defines to a problem caused by the filesystem not being found. Your standard commands of fdisk or "df -h" are not going to work, you'll need to type blkid. My filesystem was visible so I exited the dracut shell and I was presented with login. 
 
### Keep reading if you installed DRBD and attempted to put SELinux on to test
1. You've only fixed half of the issue if you have followed the troubleshooting steps from earlier if you have a DRBD installation added. The reason being because once you try to login, the drbd startup script will start and you will experience a loop to prompt yes if you want to abort waiting. This did not stop and you will have problems to type commands, at some point the drbd startup will end up going into a loop, simply kill it with a SIGKILL (ctrl+c)
2. The most efficient solution is to ensure your test VM is assigned to a subnet and add another machine. From there, SSH into the machine; disable and stop DRBD. 

# Important changes to be made in temporary bash shell
These changes are temporary on one session only, you must remount your file system to ensure that the changes remain persistent through reboots and further uses.

Once you've got a temporary session, go to /etc/default/grub

Once you're in the file you will get macro definitions and lines to follow along. The macro which says GRUB_CMDLINE ensure you add selinux=0 in the correct location (Just before the line crashkernel=auto) don't add the whole phrase as defined before in the main config file. Once you've edited the file make sure you run the following command: 

grub2-mkconfig -o /boot/grub2/grub.cfg

The line above will add all the changes you've wrote to the grub in your temporary session which you can then follow on to your working shell which you will reboot into. Ensure you remount the file system with the changes you've made using:

mount -n -o remount,rw / 

Using that line you remount your root file system in read write mode as right now it's read only. 

### SELinux commands to check the status of SE 

sestatus - You should see after doing the needed steps SELinux should be disabled

Name of DRBD process - drbd_tmp_t

All logs which have been analysed are enclosed within the logs folder. 

To enable SELinux - Remove all SELinux declarations from the grub bootup file and go onto overrwriting the grub file
(Command) - grub2-mkconfig -o /boot/grub2/grub.cfg

# Policy creation in SELinux
SELinux must been in action for the production machines, therefore it is imperative for the server to contain some sort of policy which will prevent DRBD from being blocked. Previous tests of DRBD create a very unstable environment with SELinux enabled due to read/write complications between processes. It is visible from the logs. 

.pp files are binary and cannot be read. However once a file has been installed using the semodule command for example:

semodule -i my-drbdadm.pp

Another file following format of .te is now created. This file allows you to read the configuration rulesets to see exactly what's going on. 

## Log alert message creation
Within the logs you will see a lot of bundled however you will be advised to run a command which begins with sealert -l followed by a serial number. If you follow the command and serial number, generating a file you can then have an indiviudal log related to the concerned process. You will need to create an individual policy 

### Auditd logs
Auditd logs are the logs which SELinux has contained with a feature called AVC (Access Vector Cache)

"SELinux decisions, such as allowing or disallowing access, are cached. This cache is known as the Access Vector Cache (AVC). Denial messages are logged when SELinux denies access. These denials are also known as "AVC denials", and are logged to a different location, depending on which daemons are running:"
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security-enhanced_linux/chap-security-enhanced_linux-troubleshooting

### Configuring booleans
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security-enhanced_linux/sect-security-enhanced_linux-booleans-configuring_booleans

### Required daemons
To be able to let DRBD work through with SELinux you must generate a policy for the following daemons:
drbdsetup
drbdadm

Once you have both daemons with generated policies you should then test your boxes with a reboot and a manual failover test (See DRBD doc if unsure)

END OF DOCUMENTATION
