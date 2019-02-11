#!/bin/bash

# usage ./oneKey.sh /path/to/linux/root/file

useAutoInsmod=0
TRUE=1

KERNEL=4.20.6
TARGET=initrd.img

# cp link library dependencies
ldd_cp_func(){
    for m in $(ls $1)
    do
        if [ -d "$1/$m" ];then
            echo "$1/$m is a dir"
            continue
        fi
        dependList=$( ldd $1/$m | awk '{if (match($3,"/")){ print $3}}' )
        echo $dependList
        cp $dependList $2/
    done
}

########################## create dir ##########################
# create root dir
mkdir $1
# create cmd dir
mkdir $1/bin
mkdir $1/sbin
mkdir -p $1/usr/bin
mkdir $1/usr/sbin
# create boot dir
mkdir $1/boot
# create system configuration dir
mkdir $1/etc
# create function library
mkdir -p $1/lib/modules
mkdir $1/lib64
# create user dir
mkdir $1/home
mkdir $1/root
# create devide dir
mkdir $1/dev
# create other dir
mkdir $1/var
mkdir $1/sys
mkdir $1/proc

########################## copy cmd ##########################
# start terminal  -- 0.5
cp /bin/bash $1/bin/

# load file system -- 0.55
cp /bin/mount /bin/umount $1/bin/
cp /sbin/insmod /sbin/modprobe $1/sbin/

# manage device -- 0.6
cp -r /lib/udev $1/lib/
cp -r /etc/udev $1/etc/
cp /etc/nsswitch.conf $1/etc/
cp /lib64/libnss_* $1/lib64/
# passwd & group 
cp -r /etc/init.d /etc/sysconfig /etc/rc.d /etc/passwd /etc/group $1/etc/
cp /sbin/udevd /sbin/udevadm /sbin/consoletype /sbin/fstab-decode $1/sbin/
cp /bin/mknod /bin/chown /bin/cat /bin/mkdir /bin/ln /bin/awk /bin/fgrep $1/bin/
cp -r /etc/security $1/etc/

# muti users login  -- 0.7
cp /bin/login $1/bin/
cp -r /etc/pam.d /etc/shadow /etc/passwd /etc/login.defs $1/etc/
cp -r /lib64/security $1/lib64/
ldd_cp_func $1/lib64/security $1/lib64/

# start with /sbin/init  -- 0.9
cp /bin/sh /bin/rm /bin/find /bin/touch /bin/chgrp /bin/chmod /bin/plymouth /bin/hostname /bin/sed /bin/echo $1/bin/
cp /sbin/init /sbin/mingetty /sbin/fstab-decode /sbin/swapon /sbin/fsck /sbin/telinit /sbin/runlevel $1/sbin/
cp /usr/bin/id $1/usr/bin/
cp /bin/basename /bin/grep /bin/dmesg $1/bin/
cp /sbin/lsmod /sbin/initctl $1/sbin/ 
cp -r /etc/rc*.d /etc/rc /etc/rc.sysinit /etc/inittab /etc/init /etc/fstab /etc/mtab /etc/system-release $1/etc/
cp -r /lib64/xtables $1/lib64/

# with reboot
cp /sbin/reboot /sbin/shutdown $1/sbin/

# connnect net
cp /bin/ipcalc /bin/cut /bin/mktemp /bin/netstat $1/bin/
cp /usr/bin/logger $1/usr/bin/
cp /sbin/ifconfig /sbin/ip /sbin/arping /sbin/dhclient /sbin/restorecon $1/sbin/
cp -r /etc/dhcp $1/etc/
# ssh connect
cp /bin/env /bin/usleep $1/bin/
cp /usr/bin/dirname $1/usr/bin/
cp /usr/sbin/sshd $1/usr/sbin/
cp -r /etc/ssh /etc/ld.so.cache /etc/ld.so.conf /etc/profile.d $1/etc/
cp /usr/bin/ssh /usr/bin/ssh-keygen $1/usr/bin/
mkdir -p $1/var/empty/sshd
# network test cmd
cp /bin/ping $1/bin/

# rewrite config of eth0
echo '
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=dhcp' > $1/etc/sysconfig/network-scripts/ifcfg-eth0

# set auto insmod
mkdir -p $1/lib/modules/2.6.32-754.el6.x86_64/
cp /lib/modules/2.6.32-754.el6.x86_64/modules.* $1/lib/modules/2.6.32-754.el6.x86_64/

# create run var dir
mkdir $1/var/run
mkdir $1/var/log
mkdir $1/var/lib
mkdir -p $1/var/lock/subsys

# rewrite /etc/fstab
echo '
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0' > $1/etc/fstab

# rewrite /etc/system-release
echo 'rabbitOS 0.9' > $1/etc/system-release

# base cmd
cp /bin/ls $1/bin/
cp /usr/bin/strace $1/usr/bin/

##################### copy link library ######################
cp /lib64/ld-linux-x86-64.so.2 /lib64/libfreeblpriv3.so $1/lib64/
ldd_cp_func $1/bin/ $1/lib64/
ldd_cp_func $1/sbin/ $1/lib64/
ldd_cp_func $1/usr/bin/ $1/lib64/
ldd_cp_func $1/usr/sbin/ $1/lib64/

######################## copy script #########################
cp /sbin/start_udev $1/sbin/
# net script
cp /sbin/ifup /sbin/ifdown /sbin/dhclient-script /sbin/service $1/sbin/

######################## copy kernel ########################
kernelPath='/lib/modules/2.6.32-754.el6.x86_64/kernel/'
# spi driver
mkdir -p $1/$kernelPath/drivers/scsi/
mkdir -p $1/$kernelPath/drivers/message/fusion/
mkdir -p $1/$kernelPath/lib/
mkdir -p $1/$kernelPath/fs/ext4/
mkdir -p $1/$kernelPath/fs/jbd2/
cp $kernelPath/drivers/scsi/scsi_transport_spi.ko $1/$kernelPath/drivers/scsi/
cp $kernelPath/drivers/scsi/sd_mod.ko $1/$kernelPath/drivers/scsi//
cp $kernelPath/drivers/message/fusion/mptbase.ko $1/$kernelPath/drivers/message/fusion/
cp $kernelPath/drivers/message/fusion/mptscsih.ko $1/$kernelPath/drivers/message/fusion/
cp $kernelPath/drivers/message/fusion/mptspi.ko $1/$kernelPath/drivers/message/fusion/
cp $kernelPath/lib/crc-t10dif.ko $1/$kernelPath/lib/
# file system driver
cp $kernelPath/fs/mbcache.ko $1/$kernelPath/fs/
cp $kernelPath/fs/ext4/ext4.ko $1/$kernelPath/fs/ext4/
cp $kernelPath/fs/jbd2/jbd2.ko $1/$kernelPath/fs/jbd2/
# net driver
mkdir -p $1/$kernelPath/net/ipv4/netfilter/
mkdir -p $1/$kernelPath/net/ipv6/netfilter/
cp $kernelPath/net/ipv6/ipv6.ko $1/$kernelPath/net/ipv6/
#cp $kernelPath/net/ipv4/netfilter/ip_tables.ko $1/$kernelPath/net/ipv4/netfilter/
#cp $kernelPath/net/ipv4/netfilter/iptable_filter.ko $1/$kernelPath/net/ipv4/netfilter/
#cp $kernelPath/net/ipv6/netfilter/ip6_tables.ko $1/$kernelPath/net/ipv6/netfilter/
#cp $kernelPath/net/ipv6/netfilter/ip6table_filter.ko $1/$kernelPath/net/ipv6/netfilter/
mkdir -p $1/$kernelPath/drivers/net/e1000/
cp $kernelPath/drivers/net/e1000/e1000.ko $1/$kernelPath/drivers/net/e1000/

######################### boot init ##########################
echo '#!/bin/bash' >> $1/init
echo '' >> $1/init
echo '# set env' >> $1/init
echo 'export PATH=/sbin:/bin:/usr/sbin:/usr/bin' >> $1/init
echo '' >> $1/init
if [ $useAutoInsmod == $TRUE ]
then
    echo '#Mounting driver'  >> $1/init
    echo '# spi driver' >> $1/init
    echo 'insmod /lib/modules/2.6.32-754.el6.x86_64/kernel/drivers/scsi/scsi_transport_spi.ko' >> $1/init
    echo 'insmod /lib/modules/2.6.32-754.el6.x86_64/kernel/drivers/message/fusion/mptbase.ko' >> $1/init
    echo 'insmod /lib/modules/2.6.32-754.el6.x86_64/kernel/drivers/message/fusion/mptscsih.ko' >> $1/init
    echo 'insmod /lib/modules/2.6.32-754.el6.x86_64/kernel/drivers/message/fusion/mptspi.ko' >> $1/init
    echo 'insmod /lib/modules/2.6.32-754.el6.x86_64/kernel/lib/crc-t10dif.ko' >> $1/init
    echo 'insmod /lib/modules/2.6.32-754.el6.x86_64/kernel/drivers/scsi/sd_mod.ko' >> $1/init
    echo '# file system driver' >> $1/init
    echo 'insmod /lib/modules/2.6.32-754.el6.x86_64/kernel/fs/mbcache.ko' >> $1/init
    echo 'insmod /lib/modules/2.6.32-754.el6.x86_64/kernel/fs/jbd2/jbd2.ko' >> $1/init
    echo 'insmod /lib/modules/2.6.32-754.el6.x86_64/kernel/fs/ext4/ext4.ko' >> $1/init
    echo 'insmod /lib/modules/2.6.32-754.el6.x86_64/kernel/drivers/net/e1000e/e1000e.ko' >> $1/init
    echo '' >> $1/init
fi
echo '# mount file' >> $1/init
echo 'mount -t proc proc /proc > /dev/null 2>&1' >> $1/init
echo 'mount -t sysfs sysfs /sys > /dev/null 2>&1' >> $1/init
echo '' >> $1/init
#echo '# start' >> $1/init
#echo '/sbin/start_udev' >> $1/init
#echo '/bin/bash' >> $1/init
#echo '' >> $1/init
echo '# checkout process' >> $1/init
echo 'exec /sbin/init' >> $1/init
chmod a+x $1/init

########################## generate img ##########################
cd $1
rm -rf ./lib/modules/*
cp -r /lib/modules/${KERNEL} ./lib/modules/
find . | cpio -H newc -o | gzip > /boot/${TARGET}
cd ../