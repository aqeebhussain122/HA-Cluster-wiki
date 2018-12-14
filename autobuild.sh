#!/bin/bash

# Root is required so password prompts are left out
rootCheck() {
	# Check which launches USer ID variable and will exit if not 0
	if [ $EUID != 0 ]; then
		echo "$USER you need to be root";
		exit 1;
	else 
		main
	fi
}

# Check the OS flavor used and ensure the 
checkOS() {
	#Variable to produce output needed
	OS=$(lsb_release -i | cut -f 2-)
	if [ $OS == "CentOS" ]; then 
		echo "The OS used is $OS, I will continue";
	elif [ $OS == "Redhat" ]; then
		echo "The used is $OS, I will continue";
	elif [ ! -f /usr/bin/lsb_release ]; then
		echo "I didn't lsb_release so I will install it";
		yum -y install redhat-lsb-core
	else 
		echo "Incompatible install, exiting...";
		exit 1;
	fi

	# To run the installation and find the release, a presence check and installation is done if required
	if [ ! -f /usr/bin/lsb_release ]; then
		echo "Can't find the release program, I will install it for you";
		sleep 2;
		yum -y install redhat-lsb-core
	fi
	
}

installEssentials()
{
	# Update the box before doing any updates
	yum -y update
	yum -y install gcc make automake autoconf libxslt libxslt-devel flex rpm-build kernel-devel
	# Import GPG Keys
	rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
	# Install DRBD repo
	rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
	yum -y install drbd90-utils kmod-drbd90
	# Inputs phrase drbd and creates a file called drbd.conf
	echo drbd > /etc/modules-load.d/drbd.conf
}

# Function searches for the presence of /dev/sdb to create a partition
checkBlockDisk()
{
	ls /dev/sdb
	# Error handling judging the previous output of the /dev/sdb search
	if [ $? -eq 0 ]; then
		echo "I found the block disk for you.";
	else
		echo "I didn't find /dev/sdb, I can't go on";
		exit 1;	
	fi
	# Creates a whole parition on /dev/sdb for the drbd, disk should be 8GB for script
	(echo n; echo p; echo 1; echo 2048; echo 16777215; echo w) | fdisk /dev/sdb	
}

findKernelFile()
{
	echo "Searching for kernel files";
	lsmod | grep drbd
	if [ $? != 0 ]; then
		findVar=$(find / -name drbd.ko)
		echo "$findVar";
		echo "Install the listed files to continue";
	fi
}

drbdCopyFiles()
{
	# List the files in /etc directory and copy the conf file to drbd.d directory
	ls /etc/ | grep drbd && cp /etc/drbd.conf /etc/drbd.d/drbd.conf;
	ls /etc/drbd.d | echo "The copy has been done";

	cp /etc/drbd.d/global_common.conf /etc/drbd.d/global_common.org
	# Empty the file
	if [ $? == 0 ]; then
		echo -n "" > /etc/drbd.d/global_common.conf		
	else
		echo "Error...";
	fi
	# Once empty then write the echo output to the file
	echo "global { usage-count yes; } common { net { protocol C; } }" >> /etc/drbd.d/global_common.conf
	
}	

# Config details which should be inserted into the template file
drbdConfig() 
{
	read -p "Enter a resource name for your file: " resName
	touch /etc/drbd.d/$resName.res && ls /etc/drbd.d/
	echo "'include /etc/drbd.d/*.res';"; >> /etc/drbd.d/$resName.res
        echo "'include /etc/drbd.d/global_common.conf';"; >> /etc/drbd.d/$resName.res
	ipAddress=$(hostname --ip-address | awk {'print $2'})
	echo "Your IP is $ipAddress";
	echo "Hostname: $HOSTNAME";
	read -p "Hostname of second node: " hostnameNode2
	read -p "Enter IP address of second node: " ipAddressNode2
	echo "Node 2 IP: $ipAddressNode2"
	read -p "Enter a port number: " portNum
	read -p "Enter port number for host 2" portNumNode2
	device=$(ls /dev/ | grep 'drbd0')
	echo "Your device is $device";
	read -p "Enter your disk name: " diskName
	echo "$diskName";
	echo "resource $resName { device /dev/$device; disk /dev/$diskName; meta-disk internal; protocol C; on $HOSTNAME { address $ipAddress:$portNum; meta-disk internal; } on $hostnameNode2 { address $ipAddressNode2:$portNumNode2; meta-disk internal; } }" >> /etc/drbd.d/$resName.res
}

main() 
{
	checkOS
	installEssentials
	checkBlockDisk 
	findKernelFile
	drbdCopyFiles
	drbdConfig
}

rootCheck
