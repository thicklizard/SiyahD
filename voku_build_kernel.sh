#!/bin/sh

# location
export KERNELDIR=`readlink -f .`
export PARENT_DIR=`readlink -f ..`
export INITRAMFS_SOURCE=`readlink -f $KERNELDIR/../initramfs3`

# kernel
export ARCH=arm
export EXTRA_AFLAGS=-mfpu=neon
export USE_SEC_FIPS_MODE=true

# compiler
# gcc system
# export CROSS_COMPILE=/usr/bin/arm-linux-gnueabi-
# gcc 4.5.2
#export CROSS_COMPILE=$PARENT_DIR/toolchain/bin/arm-none-eabi-
# gcc 4.4.3 (CM9)
# export CROSS_COMPILE=/media/Source-Code/android/system/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-
# gcc 4.7 (Linaro 12.04)
# export CROSS_COMPILE=$PARENT_DIR/linaro/bin/arm-eabi-
# gcc 4.7.2 (Linaro 12.07)
export CROSS_COMPILE=$KERNELDIR/android-toolchain/bin/arm-eabi-

# Importing PATCH for GCC depend on GCC version.
GCCVERSION_OLD=`${CROSS_COMPILE}gcc --version | cut -d " " -f3 | cut -c3-5 | grep -iv "09" | grep -iv "ee" | grep -iv "en"`
GCCVERSION_NEW=`${CROSS_COMPILE}gcc --version | cut -d " " -f4 | cut -c1-3 | grep -iv "Fre" | grep -iv "sof" | grep -iv "for" | grep -iv "auc"`
GCCVERSION_NEWER=`${CROSS_COMPILE}gcc --version | cut -d " " -f3 | cut -c1-3 | grep -iv "Fre" | grep -iv "sof" | grep -iv "for" | grep -iv "auc" | grep -iv "201" | grep -iv "eve"`

if [ "a$GCCVERSION_OLD" = "a4.3" ]; then
	cp $KERNELDIR/arch/arm/boot/compressed/Makefile_old_gcc $KERNELDIR/arch/arm/boot/compressed/Makefile;
	USED_GCC=$GCCVERSION_OLD;
elif [ "a$GCCVERSION_OLD" = "a4.4" ]; then
	cp $KERNELDIR/arch/arm/boot/compressed/Makefile_old_gcc $KERNELDIR/arch/arm/boot/compressed/Makefile;
	USED_GCC=$GCCVERSION_OLD;
elif [ "a$GCCVERSION_OLD" = "a4.5" ]; then
	cp $KERNELDIR/arch/arm/boot/compressed/Makefile_old_gcc $KERNELDIR/arch/arm/boot/compressed/Makefile;
	USED_GCC=$GCCVERSION_OLD;
elif [ "a$GCCVERSION_OLD" = "a4.6" ]; then
	cp $KERNELDIR/arch/arm/boot/compressed/Makefile_linaro $KERNELDIR/arch/arm/boot/compressed/Makefile;
	USED_GCC=$GCCVERSION_OLD;
elif [ "a$GCCVERSION_OLD" = "a4.7" ]; then
	cp $KERNELDIR/arch/arm/boot/compressed/Makefile_linaro $KERNELDIR/arch/arm/boot/compressed/Makefile;
	USED_GCC=$GCCVERSION_OLD;
elif [ "a$GCCVERSION_NEW" = "a4.3" ]; then
    cp $KERNELDIR/arch/arm/boot/compressed/Makefile_old_gcc $KERNELDIR/arch/arm/boot/compressed/Makefile;
	USED_GCC=$GCCVERSION_NEW;
elif [ "a$GCCVERSION_NEW" = "a4.4" ]; then
    cp $KERNELDIR/arch/arm/boot/compressed/Makefile_old_gcc $KERNELDIR/arch/arm/boot/compressed/Makefile;
	USED_GCC=$GCCVERSION_NEW;
elif [ "a$GCCVERSION_NEW" = "a4.5" ]; then
    cp $KERNELDIR/arch/arm/boot/compressed/Makefile_old_gcc $KERNELDIR/arch/arm/boot/compressed/Makefile;
	USED_GCC=$GCCVERSION_NEW;
elif [ "a$GCCVERSION_NEW" = "a4.6" ]; then
    cp $KERNELDIR/arch/arm/boot/compressed/Makefile_linaro $KERNELDIR/arch/arm/boot/compressed/Makefile;
	USED_GCC=$GCCVERSION_NEW;
elif [ "a$GCCVERSION_NEW" = "a4.7" ]; then
    cp $KERNELDIR/arch/arm/boot/compressed/Makefile_linaro $KERNELDIR/arch/arm/boot/compressed/Makefile;
	USED_GCC=$GCCVERSION_NEW;
elif [ "a$GCCVERSION_NEWER" = "a4.3" ]; then
    cp $KERNELDIR/arch/arm/boot/compressed/Makefile_old_gcc $KERNELDIR/arch/arm/boot/compressed/Makefile;
	USED_GCC=$GCCVERSION_NEWER;
elif [ "a$GCCVERSION_NEWER" = "a4.4" ]; then
    cp $KERNELDIR/arch/arm/boot/compressed/Makefile_old_gcc $KERNELDIR/arch/arm/boot/compressed/Makefile;
	USED_GCC=$GCCVERSION_NEWER;
elif [ "a$GCCVERSION_NEWER" = "a4.5" ]; then
    cp $KERNELDIR/arch/arm/boot/compressed/Makefile_old_gcc $KERNELDIR/arch/arm/boot/compressed/Makefile;
	USED_GCC=$GCCVERSION_NEWER;
elif [ "a$GCCVERSION_NEWER" = "a4.6" ]; then
    cp $KERNELDIR/arch/arm/boot/compressed/Makefile_linaro $KERNELDIR/arch/arm/boot/compressed/Makefile;
	USED_GCC=$GCCVERSION_NEWER;
elif [ "a$GCCVERSION_NEWER" = "a4.7" ]; then
    cp $KERNELDIR/arch/arm/boot/compressed/Makefile_linaro $KERNELDIR/arch/arm/boot/compressed/Makefile;
	USED_GCC=$GCCVERSION_NEWER;
else
	echo "Compiler not recognized! please fix the CUT function to match your compiler.";
	exit 0;
fi;
echo "build with gcc ${USED_GCC} ...";

# build script
export USER=`whoami`

NAMBEROFCPUS=`grep 'processor' /proc/cpuinfo | wc -l`
INITRAMFS_TMP="/tmp/initramfs-source"

if [ "${1}" != "" ];
then
	export KERNELDIR=`readlink -f ${1}`
fi;

if [ ! -f $KERNELDIR/.config ]; then
	cp $KERNELDIR/arch/arm/configs/dorimanx_defconfig .config
	make dorimanx_defconfig
fi;

. $KERNELDIR/.config

# remove previous zImage files
if [ -e $KERNELDIR/zImage ]; then
	rm $KERNELDIR/zImage
fi;

if [ -e $KERNELDIR/arch/arm/boot/zImage ]; then
	rm $KERNELDIR/arch/arm/boot/zImage
fi;

# remove all old modules before compile
cd $KERNELDIR
OLDMODULES=`find -name *.ko`
for i in $OLDMODULES; do
	rm -f $i
done;

# remove previous initramfs files
if [ -d $INITRAMFS_TMP ]; then
	echo "removing old temp iniramfs"
	rm -rf $INITRAMFS_TMP
fi;

if [ -f "/tmp/cpio*" ]; then
	echo "removing old temp iniramfs_tmp.cpio"
	rm -rf /tmp/cpio*
fi;

# clean initramfs old compile data
rm -f usr/initramfs_data.cpio
rm -f usr/initramfs_data.o

cd $KERNELDIR/
if [ $USER != "root" ]; then
	make -j$NAMBEROFCPUS modules || exit 1
else
	nice -n 10 make -j$NAMBEROFCPUS modules || exit 1
fi;

# copy initramfs files to tmp directory
cp -ax $INITRAMFS_SOURCE $INITRAMFS_TMP
# clear git repositories in initramfs
if [ -e $INITRAMFS_TMP/.git ]; then
	rm -rf /tmp/initramfs-source/.git
fi;
# remove empty directory placeholders
find $INITRAMFS_TMP -name EMPTY_DIRECTORY -exec rm -rf {} \;
# remove mercurial repository
if [ -d $INITRAMFS_TMP/.hg ]; then
	rm -rf $INITRAMFS_TMP/.hg
fi;

#For now remove the VLM binary from initramfs till it's will be used for something.
if [ -e $INITRAMFS_TMP/sbin/lvm ]; then
	rm -f $INITRAMFS_TMP/sbin/lvm
fi;

# copy modules into initramfs
mkdir -p $INITRAMFS/lib/modules
mkdir -p $INITRAMFS_TMP/lib/modules
find -name '*.ko' -exec cp -av {} $INITRAMFS_TMP/lib/modules/ \;
${CROSS_COMPILE}strip --strip-debug $INITRAMFS_TMP/lib/modules/*.ko
chmod 755 $INITRAMFS_TMP/lib/modules/*
if [ $USER != "root" ]; then
	make -j$NAMBEROFCPUS zImage CONFIG_INITRAMFS_SOURCE="$INITRAMFS_TMP" || exit 1
else
	nice -n 10 make -j$NAMBEROFCPUS zImage CONFIG_INITRAMFS_SOURCE="$INITRAMFS_TMP" || exit 1
fi;

if [ -e $KERNELDIR/arch/arm/boot/zImage ]; then
	$KERNELDIR/mkshbootimg.py $KERNELDIR/zImage $KERNELDIR/arch/arm/boot/zImage $KERNELDIR/payload.tar $KERNELDIR/recovery.tar.xz

	# restore clean arch/arm/boot/compressed/Makefile_clean till next time.
	cp $KERNELDIR/arch/arm/boot/compressed/Makefile_clean $KERNELDIR/arch/arm/boot/compressed/Makefile

	# copy all needed to ready kernel folder.
	cp $KERNELDIR/.config $KERNELDIR/arch/arm/configs/dorimanx_defconfig
	cp $KERNELDIR/.config $KERNELDIR/READY/
	rm $KERNELDIR/READY/boot/zImage
	rm $KERNELDIR/READY/Kernel_Dorimanx-*
	stat $KERNELDIR/zImage
	GETVER=`grep 'Siyah-Dorimanx-V' arch/arm/configs/dorimanx_defconfig | cut -c 38-42`
	cp $KERNELDIR/zImage /$KERNELDIR/READY/boot/
	cd $KERNELDIR/READY/
	zip -r Kernel_Dorimanx-$GETVER-`date +"-%H-%M--%d-%m-12-SGII-PWR-CORE"`.zip .
else
	echo "Kernel STUCK in BUILD! no zImage exist"
fi;

