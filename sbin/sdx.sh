#!/system/bin/sh
# DRockstar Clean Kernel sdx.sh script called from init.rc
# Updated with the Epic 4G Touch partition structure by bubby323.

/sbin/busybox mount -o remount,rw /dev/block/mmcblk0p9 /system
/sbin/busybox mount -o remount,rw / /

# Install busybox
/sbin/busybox mkdir /bin
/sbin/busybox --install -s /bin
rm -rf /system/xbin/busybox
ln -s /sbin/busybox /system/xbin/busybox
rm -rf /res
sync

# Fix permissions in /sbin, just in case
chmod 755 /sbin/*

# Fix screwy ownerships
for blip in lib res sbin default.prop fota.rc init init.goldfish.rc init.rc init.smdkc210.rc init_kernel_only.rc lpm.rc recovery.rc ueventd.goldfish.rc ueventd.rc ueventd.smdkc210.rc
do
  chown root.system /$blip
  chown root.system /$blip/*
done

chown root.system /lib/modules/*
chown root.system /res/images/*

# Enable init.d support
if [ -d /system/etc/init.d ]
then
  logwrapper busybox run-parts /system/etc/init.d
fi
sync

# setup tmpfs for su
mkdir /sdx
mount -o size=30k -t tmpfs tmpfs /sdx
cat /sbin/su > /sdx/su
chmod 06755 /sdx/su
# establish root in common system directories for 3rd party applications
rm /system/bin/su
rm /system/xbin/su
rm /system/bin/jk-su
ln -s /sdx/su /system/bin/su
ln -s /sdx/su /system/xbin/su
# remove su in problematic locations
rm -rf /bin/su
rm -rf /sbin/su

# fix busybox DNS while system is read-write
if [ ! -f "/system/etc/resolv.conf" ]; then
  echo "nameserver 8.8.8.8" >> /system/etc/resolv.conf
  echo "nameserver 8.8.4.4" >> /system/etc/resolv.conf
fi

# setup proper passwd and group files for 3rd party root access
if [ ! -f "/system/etc/passwd" ]; then
  echo "root::0:0:root:/data/local:/system/bin/sh" > /system/etc/passwd
  chmod 0666 /system/etc/passwd
fi
if [ ! -f "/system/etc/group" ]; then
  echo "root::0:" > /system/etc/group
  chmod 0666 /system/etc/group
fi

# provide support for a shell script to protect root access
if [ ! -f "/system/app/Superuser.apk" ]; then
  cp /sbin/Superuser.apk /system/app/Superuser.apk
fi
rm /sbin/Superuser.apk

# patch to prevent certain malware apps
. > /system/bin/profile
chmod 644 /system/bin/profile

sync

mount -o remount,ro /dev/block/mmcblk0p9 /system
mount -o remount,ro / /

