#!/bin/bash
#Script to automate CDOT export entry creation.


echo "Enter hosting cluster name."
read cluster

echo "Enter file system path."
read file_system

echo "enter number of servers"
read server_count


vserver=`echo $file_system | awk -F: '{print $1}'`
volume=`echo $file_system | awk -F/ '{print $2}'`
qtree=`echo $file_system | awk -F/ '{print $3}'`
policy_name="e_"$volume"_pl"

echo "Please enter server FQDNs one by one."
for ((i = 0 ; i < $server_count ; i++));
do

echo "\n Enter server $i." 
read server_list[$i]

j=`nslookup ${server_list[$i]}`
ip=`echo $j | awk '{print $8}'`

flag=`ssh admin@$cluster export-policy rule show -vserver $vserver -policyname $policy_name | grep -w ${server_list[$i]}`

if [ "$flag" == "" ] 
then
ssh admin@$cluster export-policy rule create -vserver $vserver -policyname $policy_name -rorule sys -rwrule sys -superuser sys -protocol nfs -clientmatch ${server_list[$i]}
echo "${server_list[$i]} added to the export list of $policy_name ."
else
echo "${server_list[$i]} is already added to the export list."
fi

done
