# What is a DRBD Cluster?
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

(Do this for both nodes)
A seperate disk will be needed for DRDB as it is an entire block device which is what we need
In virtual box do the following:
1. Power off the VM 
2. Access the storage section and add a new hard disk titled by /dev/sdb for clarity
	We have added a second disk which will act as the block device for the DRDB to be configured upon
	
3. Once the installation is done issue the next command to ensure the configuration is picked up by the system kernel: lsmod | grep -i drbd

4. If that does not work and nothing is found then issue the following command: sudo find / -name drbd.ko
	The use of this file is 
	
#### Resources used
http://prolinuxhub.com/building-simple-drbd-cluster-on-linux-centos-6-5/

https://www.atlantic.net/hipaa-compliant-database-hosting/how-to-configure-lvm-drbd/

https://www.digitalocean.com/community/tutorials/how-to-use-lvm-to-manage-storage-devices-on-ubuntu-16-04

https://www.techrepublic.com/article/how-to-add-new-drives-to-a-virtualbox-virtual-machine/

https://serverstack.wordpress.com/2017/05/31/install-and-configure-drbd-cluster-on-rhel7-centos7/

#### To further understand LVMs consult this guide:
https://www.howtoforge.com/linux_lvm
