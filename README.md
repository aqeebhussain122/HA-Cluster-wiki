# What is a DRBD Cluster?
A DRBD cluster (Distributed Replicated Block Device) is a cluster. A cluster being an instance of more than one server to achieve the same objective.
In a case where real-time synchronized storage is required between block device storage there is the existence of DRBD. This works in the format of havingv 

## Solution of creating DRBD Cluster:
	1. Integrate VBOX with Vagrant
	2. Configure Vagrant to have each PC carry a seperate IP address
	3. Enable and install repo of DRBD on each node (VM1 & VM2) rpm -ivh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
	4. 
	

### Resources to consult:
https://www.learnitguide.net/2016/07/how-to-install-and-configure-drbd-on-linux.html
https://unix.stackexchange.com/questions/29999/why-are-my-two-virtual-machines-getting-the-same-ip-address

# Troubleshooting network issues in Virtualbox

Virtualbox is known to not share it's IP addresses, a quick fix if you're using CentOS machines is to go into file -> preferences -> Network. From this point you need to select a NatNetwork, going forward you should then go into the settings of the VBOX machine and assign the machine to a NatNetwork. (Do this with both machines)
Once the machine is configured you should then be able to have an individual IP address for each machine involved 

#### Useful commands in CentOS7 glossary
ip addr show - Will show the IP address, ifconfig is not the default command
ssh username@ip-address (Format of accessing the machines via SSH)
