#!/bin/bash
####################################################################################
# Script for taking PostUpgrade steps and logs for filer                           #
####################################################################################

FILER=`echo $1 `
mkdir /home/agupta64/upgrade/2016/FilerUpgrade_Logs/${FILER}
mkdir /home/agupta64/upgrade/2016/FilerUpgrade_Logs/${FILER}/postUpg_Logs
echo "making directory postUpgrade_path/${FILER}/postUpg_Logs "
postUpgrade_path="/home/gbatra10/upgrade/2016/FilerUpgrade_Logs/${FILER}/postUpg_Logs"

ssh root@${FILER} "options autosupport.enable on "
echo "Enabling autosupport "
sleep 1
ssh root@${FILER} "options autosupport.enable"
echo "checking  autosupport "
sleep 1
ssh root@${FILER} options autosupport.doit "finishing_NDU_8.2.4P3"
echo "Generating PostUpgrade autosupport "
sleep 1

ssh root@${FILER} "options cf.giveback.auto.after.panic.takeover off;options cf.giveback.auto.after.panic.takeover"
echo "Changing option cf.giveback.auto.after.panic.takeover to OFF as per UHG standard "
sleep 1
echo "Enabling auto disk FW upgrades "
ssh root@${FILER} "options raid.background_disk_fw_update.enable on"

echo "Enabling snapmirror  "
ssh root@${FILER} snapmirror on
ssh root@${FILER} snapmirror status 

ssh root@${FILER} rdfile /etc/rc > $postUpgrade_path/${FILER}.rc
echo "saving rc file "
sleep 1 
ssh root@${FILER} "vfiler run * exportfs " > $postUpgrade_path/${FILER}.exports
echo "saving exports  "
sleep 1 
ssh root@${FILER} rdfile /etc/hosts > $postUpgrade_path/${FILER}.hosts
echo "saving hosts "
sleep 1 
ssh root@${FILER} rdfile /etc/quotas > $postUpgrade_path/${FILER}.quotas
echo "saving quotas "
sleep 1 
ssh root@${FILER} ifconfig -a > $postUpgrade_path/${FILER}.ifconfig
echo "saving ifconfig -a "
sleep 1

ssh root@${FILER} storage array show-config > $postUpgrade_path/${FILER}.array
echo "saving array show-config for V-Series"
sleep 1
ssh root@${FILER} sysconfig -ca > $postUpgrade_path/${FILER}.sysconfig-ca
echo "configuration error status `cat $postUpgrade_path/${FILER}.sysconfig-ca `"

sleep 1 
ssh root@${FILER} aggr status -v > $postUpgrade_path/${FILER}.aggr
echo "saving aggr status -v "
sleep 1 
ssh root@${FILER} netstat -rn > $postUpgrade_path/${FILER}.netstat
echo "saving netstat -rn "
sleep 1 
ssh root@${FILER} sysconfig -a > $postUpgrade_path/${FILER}.sysconfig-a
echo "saving sysconfig-a "
sleep 1 
ssh root@${FILER} sysconfig -t > $postUpgrade_path/${FILER}.sysconfig-t
echo "saving sysconfig -t "
sleep 1 
ssh root@${FILER} sysconfig -ca > $postUpgrade_path/${FILER}.sysconfig-ca
echo "saving sysconfig -ca "
sleep 1 
ssh root@${FILER} snapmirror status > $postUpgrade_path/${FILER}.snapmirror
echo "saving snapmirror status `cat $postUpgrade_path/${FILER}.snapmirror ` "

ssh root@${FILER} aggr status -f > $postUpgrade_path/${FILER}.failed_disk
echo "Failed disk status `cat $postUpgrade_path/${FILER}.failed_disk ` "


sleep 1 
ssh root@${FILER} vol status  > $postUpgrade_path/${FILER}.vol
echo "saving vol status  "
sleep 1 
ssh root@${FILER} aggr status -r > $postUpgrade_path/${FILER}.aggr-r
echo "saving aggr status -r "
sleep 1 
ssh root@${FILER} version -b > $postUpgrade_path/${FILER}.version
echo "saving version `cat $postUpgrade_path/${FILER}.version ` "

sleep 1
 
ssh root@${FILER} vif status > $postUpgrade_path/${FILER}.vif
echo "saving vif status "
sleep 1 
ssh root@${FILER} "vfiler run * cifs shares" > $postUpgrade_path/${FILER}.cifs_shares
echo "saving cifs_shares "
sleep 1 
ssh root@${FILER} "vfiler run * options" > $postUpgrade_path/${FILER}.options
echo "saving options "
sleep 1 
ssh root@${FILER} vfiler status -r > $postUpgrade_path/${FILER}.vfiler
echo "saving vfiler status "
sleep 1 
ssh root@${FILER} rlm status > $postUpgrade_path/${FILER}.rlm

ssh root@${FILER} bmc status > $postUpgrade_path/${FILER}.bmc

ssh root@${FILER} sp status  > $postUpgrade_path/${FILER}.sp
echo "saving rlm/sp status "
ssh root@${FILER} aggr status -f > $postUpgrade_path/${FILER}.failed_disk
echo "Failed disk status `cat $postUpgrade_path/${FILER}.failed_disk ` "

echo "Checking Global status for $FILER  "
ssh root@${FILER} rdfile /etc/messages |grep -i global

ssh root@${FILER} "aggr status -s ;aggr status -r;sysconfig -a;storage show disk -p;storage array show-config;ifconfig -a;vfiler status -a ;cf status"

printf "################### Logs Captured in $postUpgrade_path ##################### \n"
printf "#####PostUpgrade - ASUP  completed ########### $FILER - `date ` \n " 

exit
