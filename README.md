# rabbitOS



## file

- bzImage : linux内核
- initrd.img : 文件系统
- grub/grub.conf : 启动时选项

## grub install

1、使用fdisk -l查看U盘boot是否带*，如果不是可以使用fdisk /dev/uDisk 进入修改

2、先将u盘挂载到系统目录上，例如mount  /dev/sdb1 /mnt

3、使用grub-install --root-directory=/mount/point  /dev/uDisk向U盘中安装grub，例如：grub-install --root-directory=/mnt /dev/sdb

4、安装完成之后在mnt目录会出现一个boot文件夹，将bzImage和initrd.img文件拷入boot文件夹中，将grub/grub.conf拷入boot/grub/中

5、开机进入从U盘启动，用户名：root 密码：seedclass



## oneKey.sh

一键生成文件系统，可以自己添加所需命令

usage ： sh oneKey.sh fileSystemName

## kernelConfig

​	采用最新的4.20.6 stable内核，make menuconfig选择了我的机器上必要的驱动，可以自行进行二次选择。

usage : 

​	1、cp kernelConfig path/to/kernel/.config

​	2、make - j 4
​	3、make modules_install
​	4、make install

