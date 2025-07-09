#!/bin/bash

case "$1" in
install)
  systemctl stop vsound
  modprobe -r vsound

  echo "*Copy Modules*"
  cp -v ./aoe /usr/bin
  if [ ! -d /lib/modules/`uname -r`/kernel/drivers/aoe ]; then
    mkdir /lib/modules/`uname -r`/kernel/drivers/aoe
  fi
#read -p "Hit enter: "
  cp -v ./vsound.ko /lib/modules/`uname -r`/kernel/drivers/aoe/
  cp -v ./modules.conf /etc/modules-load.d/modules.conf
  if [ ! -f /lib/systemd/system/vsound.service ]; then
    cp -v ./vsound.service /lib/systemd/system/
  fi
#read -p "Hit enter: "
  depmod -a
  systemctl daemon-reload
  systemctl enable vsound.service

  echo ""
  echo "*Copy Helper Command*"
  cp -v ./aoe_profile.sh /etc/profile.d/
  sync
#read -p "Hit enter: "

#  echo ""
#  echo "*Check MD5 checksums*"
#  md5sum -c ./md5
#
#  if [ ! $? = 0 ]; then
#    echo "ERROR!!!!!!?"
#    exit
#  fi

  . /etc/profile.d/aoe_profile.sh
  modprobe vsound
  systemctl start vsound

  echo ""
  echo "*Audio over Ether module installation is complete*"
  echo ""
  echo "Please set up the playback software manually.　(e.g. mpd)"
  ;;

uninstall)
  systemctl stop vsound
  systemctl disable vsound.service
  rm /lib/systemd/system/vsound.service
  rm /usr/bin/aoe

  modprobe -r vsound
  rm /lib/modules/`uname -r`/kernel/drivers/aoe/vsound.ko
#  cp ./modules.conf.orig /etc/modules-load.d/modules.conf
  rm /etc/profile.d/aoe_profile.sh

#  systemctl enable pipe.service

  echo "Uninstall completed."
  echo "Please reboot now."
  ;;
*)
  echo "install | uninstall"
  ;;
esac
