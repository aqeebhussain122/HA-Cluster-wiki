# This guide is for RHEL/CentOS machines only

## What is a DRBD Cluster?
A DRBD cluster (Distributed Replicated Block Device) is a cluster. A cluster being an instance of more than one server to achieve the same objective.
In a case where real-time synchronized storage is required between block device storage there is the existence of DRBD. This works in the format of having two nodes which require a real-time rate of high availabilty. DRBD is mostly used within data center disaster recovery situations. The DRBD component allows two nodes to be synced meaning if one node within a data center location was destroyed, then with regards to DRBD; the data which is managed is still accessible by one of the remaining nodes thanks to the presence of DRBD.

### Resources to consult:
https://www.learnitguide.net/2016/07/how-to-install-and-configure-drbd-on-linux.html
https://unix.stackexchange.com/questions/29999/why-are-my-two-virtual-machines-getting-the-same-ip-address

# Troubleshooting network issues in Virtualbox

Virtualbox is known to not share it's IP addresses and instead allocates a default IP of 10.0.2.15, a quick fix if you're using CentOS machines is to go into file -> preferences -> Network. From this point you need to select a NatNetwork, going forward you should then go into the settings of the VBOX machine and assign the machine to a NatNetwork. (Do this with both machines)
Once the machine is configured you should then be able to have an individual IP address for each machine involved 

#### Useful commands in CentOS7 glossary
ip addr show - Will show the IP address, ifconfig is not the default command

ssh username@ip-address (Format of accessing the machines via SSH)

## Configuration and Installation of DRBD Cluster
1. Install required packages and update both nodes. 
	sudo yum -y update 
	
	yum -y install gcc make automake autoconf libxslt libxslt-devel flex rpm-build kernel-devel
	
	rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
	
	rpm -Uvh
2. Install DRBD repository and import GPG key  
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
3. Install drbd
yum install drbd90-utils kmod-drbd90

Ensuring the modules at boot, ensure you can access your root account and enter the following command: echo drb > /etc/modules-load.d/drbd.conf 

(Do this for both nodes)
A seperate disk will be needed for DRDB as it is an entire block device which is what we need
In virtual box do the following:
1. Power off the VM 
2. Access the storage section and add a new hard disk titled by /dev/sdb for clarity
	We have added a second disk which will act as the block device for the DRDB to be configured upon
	
3. Once the installation is done issue the next command to ensure the configuration is picked up by the system kernel: lsmod | grep -i drbd

4. If that does not work and nothing is found then issue the following command: sudo find / -name drbd.ko
	The use of this command is to search the entire filesystem from root directory level to locate the location of the drbd.ko file 	which is the kernel file associated to drbd.ko. Once the file is found, use the command insmod to add the appropriate kernel 		files.
	
5. Once the first four steps are done it's now time for the steps of configuration. Change your directory to /etc and you should find drbd.conf, this is the sample configuration for you to fill in; in addition there is a directory called drbd.d. At this point you should now copy the drbd.conf file into the drbd.d directory.

6. Open the file global_common.conf, create a backup of this file before editing it. And then insert the following into the file
global {
  usage-count yes;
}
common {
  net {
    protocol C;
  }
}

#global_common.conf file troubleshooting
Ensure the file path is exact to your files such as "/etc/drbd.d/global_common.conf" do not have a file path which is incomplete as this will result in a failure to load the file up 

Protocol C is one of three protocols which DRBD can use. In our case the use of protocol C is important because it is asynchronous data transfer.

7. Open the .res file which can have any name of your choice on the start of it for example: name.res. You should then add the following data:

resource (name of resource) {
device (name of device);
disk (name of disk used);
meta-disk internal;
protocol C;
	on (hostname of your first VM) {
	address: (YOUR IP ADDRESS);
	meta-disk internal;
	}
	on (hostname of your first VM) {
	address: (YOUR IP ADDRESS);
	meta-disk internal;
	}
}

8. Once the configuration is done and all troubleshooting is finished, it is then time to create the metadata for the associated device before you can start the drbd service using the following command: (Use sudo if you're not in root) (This must be done on both nodes)

sudo drbdaddm create-md (name of resource) - in my case it will be drbd0 

It is then time process the command to start the service again on BOTH NODES: sudo systemctl start drbd and to ensure that the access to drbd will be constant after reboot ensure you enter: sudo systemctl enable drbd. This will create a symbolic link for you to access the drbd service easier. 

9. Now that everything has been created and started it's now time to setup your primary server. Enter the following command to firstly ensure that the status of your drbd is active: drbdadm up (name of resource)

10. Add the firewall rules to ensure the port number is open for your two nodes to communicate over the network: 

### firewall rule: 
firewall-cmd --permanent --add-rich-rules='rule family="ipv4" source address ="(Your IP address) port port="7788" protocol="tcp" accept

# BEWARE
Your DRBD process will not remain in the next boot-up if you do not add the following:
 echo drbd > /etc/modules-load.d/drbd.conf
 
Ensure this line is added so that you're able to keep your kernel file included every time you boot up, if you don't include the above command you will have issues to keep the drbd in a constant working state. 

#### Resources used
http://prolinuxhub.com/building-simple-drbd-cluster-on-linux-centos-6-5/

https://www.atlantic.net/hipaa-compliant-database-hosting/how-to-configure-lvm-drbd/

https://www.digitalocean.com/community/tutorials/how-to-use-lvm-to-manage-storage-devices-on-ubuntu-16-04

https://www.techrepublic.com/article/how-to-add-new-drives-to-a-virtualbox-virtual-machine/

https://serverstack.wordpress.com/2017/05/31/install-and-configure-drbd-cluster-on-rhel7-centos7/

https://docs.linbit.com/man/v9/drbd-conf-5/

https://linuxhandbook.com/install-drbd-linux/

http://yallalabs.com/linux/how-to-install-and-configure-drbd-cluster-on-rhel7-centos7/

https://www.quora.com/What-is-a-Linux-block-device

https://www.youtube.com/watch?time_continue=337&v=oGIpo1SoSdY

#Troubleshooting connections:

Since there are ports involved, check the port availability and if the port is closed then allow it through the firewall

#### To further understand LVMs consult this guide:
https://www.howtoforge.com/linux_lvm
