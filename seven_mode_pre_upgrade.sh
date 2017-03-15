#!/bin/bash
####################################################################################
# Script for taking PreUpgrade logs for filer                                      #
####################################################################################
FILER=`echo $1 `
mkdir /home/agupta64/upgrade/2016/FilerUpgrade_Logs/${FILER}
mkdir /home/agupta64/upgrade/2016/FilerUpgrade_Logs/${FILER}/preUpg_Logs
echo "making directory preUpgrade_path/${FILER}/preUpg_Logs "
preUpgrade_path="/home/gbatra10/upgrade/2016/FilerUpgrade_Logs/${FILER}/preUpg_Logs"


ssh root@${FILER} rdfile /etc/rc > $preUpgrade_path/${FILER}.rc
echo "saving rc file "
sleep 1
ssh root@${FILER} "vfiler run * exportfs " > $preUpgrade_path/${FILER}.exports
echo "saving exports  "
sleep 1 
ssh root@${FILER} rdfile /etc/hosts > $preUpgrade_path/${FILER}.hosts
echo "saving hosts "
sleep 1 
ssh root@${FILER} rdfile /etc/quotas > $preUpgrade_path/${FILER}.quotas
echo "saving quotas "
sleep 1
ssh root@${FILER} storage  array show-config > $preUpgrade_path/${FILER}.array
echo "saving array show-config for V-Series"
sleep 1
ssh root@${FILER} ifconfig -a > $preUpgrade_path/${FILER}.ifconfig
echo "saving ifconfig -a "
sleep 1 
ssh root@${FILER} aggr status -v > $preUpgrade_path/${FILER}.aggr
echo "saving aggr status -v "
sleep 1 
ssh root@${FILER} netstat -rn > $preUpgrade_path/${FILER}.netstat
echo "saving netstat -rn "
sleep 1 
ssh root@${FILER} sysconfig -a > $preUpgrade_path/${FILER}.sysconfig-a
sleep 1
echo "enable NFS persistenet to prevent nfs outage "                    
ssh root@${FILER} "priv set diag;registry set nfs.persistent.enable on;registry get nfs.persistent.enable"

echo "saving sysconfig-a "
sleep 1 
ssh root@${FILER} sysconfig -t > $preUpgrade_path/${FILER}.sysconfig-t
echo "saving sysconfig -t "
sleep 1 
ssh root@${FILER} sysconfig -ca > $preUpgrade_path/${FILER}.sysconfig-ca
echo "configuration error status `cat $preUpgrade_path/${FILER}.sysconfig-ca `"

sleep 1 
ssh root@${FILER} snapmirror status > $preUpgrade_path/${FILER}.snapmirror
echo "saving snapmirror status `cat $preUpgrade_path/${FILER}.snapmirror ` "

ssh root@${FILER} aggr status -f > $preUpgrade_path/${FILER}.failed_disk
echo "Failed disk status `cat $preUpgrade_path/${FILER}.failed_disk ` "


sleep 1
 
ssh root@${FILER} vol status  > $preUpgrade_path/${FILER}.vol
echo "Offline volume status ==> `cat $preUpgrade_path/${FILER}.vol |grep -i Offline ` "

echo "saving vol status  "
sleep 1 
ssh root@${FILER} aggr status -r > $preUpgrade_path/${FILER}.aggr-r
echo "saving aggr status -r "
sleep 1 
ssh root@${FILER} version -b > $preUpgrade_path/${FILER}.version
echo "saving version `cat $preUpgrade_path/${FILER}.version ` "

sleep 1
 
ssh root@${FILER} vif status > $preUpgrade_path/${FILER}.vif
echo "saving vif status "
sleep 1 
ssh root@${FILER} "vfiler run * cifs shares" > $preUpgrade_path/${FILER}.cifs_shares
echo "saving cifs_shares "
sleep 1 
ssh root@${FILER} "vfiler run * options" > $preUpgrade_path/${FILER}.options
echo "saving options "
sleep 1 
ssh root@${FILER} vfiler status -a > $preUpgrade_path/${FILER}.vfiler
echo "saving vfiler status "
sleep 1 
ssh root@${FILER} rlm status > $preUpgrade_path/${FILER}.rlm

ssh root@${FILER} bmc status > $preUpgrade_path/${FILER}.bmc

ssh root@${FILER} sp status  > $preUpgrade_path/${FILER}.sp
echo "saving rlm/sp status "


rootvol=`ssh root@${FILER} vol status | grep -i root |grep -v offline|awk '{print $1}'|head -1`
echo "root volume name is##### $rootvol##### "

echo "creating PreUpgrade_snap "
ssh root@${FILER} snap create $rootvol PreUpgrade_snap_2015


                      test=`ssh root@${FILER} snap list -n $rootvol |grep -i PreUpgrade_snap_2015 `
                      if [ ` echo $test |wc -c ` -gt 2 ]
                      then
                      
                      echo " ########Snapshot creation successful ####$rootvol ###### $test #####"
                      else 
                      
                      echo "###### Snapshot creation failed ,please create manually for $rootvol ####"
                      fi
 


echo "Generating PreUpgrade autosupport "
ssh root@${FILER} options autosupport.doit "starting_NDU_8.2.4P3"

sleep 10


echo "Disabling snapmirror  "
ssh root@${FILER} snapmirror off 

echo "Disabling auto disk FW upgrades "
ssh root@${FILER} "options raid.background_disk_fw_update.enable off"

echo "Running Systat on $FILER "

ssh root@${FILER} sysstat -c 10 -x 3 

sleep 2

echo "Checking Cluster Status "

ssh root@${FILER} cf status 

sleep 2

echo "Disabling autosupport "
ssh root@${FILER} "options autosupport.enable off "

printf "################### Logs Captured in $preUpgrade_path ##################### \n"
printf " PreUpgrade - ASUP & Snapshot Creation completed ########### $FILER - `date ` \n " 

ssh root@${FILER} "aggr status -s ;aggr status -r;sysconfig -a;storage show disk -p;storage array show-config;ifconfig -a;vfiler status -a ;cf status"
exit
