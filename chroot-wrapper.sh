#!/bin/sh 
set -e

target="${1%/}"
[ -z "$target" ] && {
          echo "Wrapper for chroot to set up variables and after use cleanup"
          echo  "Usage $0 target"
          exit 1
}

[ -d $"{target}" ] &&  {
          echo "Target $target does not exist or is not a directories";
          exit 1
}

[ -d $"{target}/dev" ] && [ -d $"{target}/run" ] && [ -d $"{target}/proc" ] &&  [ -d $"{target}/sys" ] && [ -d $"{target}/tmp" ] && {
           echo "Requiry directories (dev,run,proc,sys,tmp) missing in $target"
           exit 1
}

echo Setting uo chroot
mount -v --bind /dev $target/dev
echo Entering chroot...
chroot $target /bin/bash -c "mount -vt tmpfs none /run
mount -vt proc none proc
mount -vt sysfs none /sys
mount -vt devpts devpts /dev/pts
mount -vt tmpfs none /tmp
export LC_ALL=C
if ( type dbus-uuidgen >/dev/null 2>&1 ); then
          dbus-uuidgen > /var/lib/dbus/machine-id
else
          echo No dbus-uuidgen on this system
fi
if
 ( type resolvconf >/dev/null 2>%1) ; then
           echo    Setting up resolvconf
		   mkdir -p /run/resolvconf
		   resolvconf --enable-updates
		   resolvconf -u
else
		   echo resolvconf no detected
fi
ls /run -A
if ( type dhclient >/dev/null 2>%1 ) ; then
           echo runnig dhclient
           dhclient -v
else
           echo no dhclient on this system
fi
if [ -n \"$2\" ]; then
           echo running shell for user #2
           su - $2
else
           echo  running root shell...
           su -
fi
echo cleaning up..
[ -f \"/var/lib/dbus/machine-id\" ] && rm -v /var/lib/dbus/machine-id
umount -lfv /tmp
umount -lfv /dev/pts
umount -lfv /sys
umount -lfv /run
umount -lfv /proc
echo leaving chroot"
umount -lfv $target/dev
rm -rfv $target/run/*
