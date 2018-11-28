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
1. Install and update both nodes. 
	sudo yum -y update 
	yum -y install gcc make automake autoconf libxslt libxslt-devel flex rpm-build kernel-devel
	
#### Resources used
http://prolinuxhub.com/building-simple-drbd-cluster-on-linux-centos-6-5/
