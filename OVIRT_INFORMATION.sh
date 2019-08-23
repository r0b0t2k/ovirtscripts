#!/bin/bash
### This script for the time being only collects information from the OVIRT API and displays it, when the need arises it will be easy to convert it to actually shutdown all the VMs in ovirt.

#First we need to gather some information from the user.

echo -e "What is the host of the ovirt engine you would like VM information from? I.E. (host.myovirt.net): \c"
read OVIRTHOST
echo
echo
echo -e "Hey what is the username you would authenticate to OVIRT with?: \c"
read USERNAME
echo
echo
echo -e "Please type your password to authenticate with ovirt.:"
read -s PASSWORD
echo
echo
echo "First I am going to use the username and password provided to extraxt VM information from OVirt and then list it for you."
read -p "Press [Enter] to continue.....:"



####
#####################
#####################
#####################
#####################
#####################
#####################
#####################
#### The following code attempts to retrive all the VMs currently in your OVIRT cluster, and places the VMIDs neatly into a varible.
####

curl -vk -u "$USERNAME@internal:$PASSWORD" -H "Content-type: application/xml" -X GET https://$OVIRTHOST:443/ovirt-engine/api/vms > /tmp/vmlist.txt
VMIDS=`cat /tmp/vmlist.txt | grep 'vm href="/ovirt-engine/api/vms/' | awk -F '"' '{print $4}'`

####
#####################
#####################
#####################
#####################
#####################
#####################
#####################
#### This code is responsible for organizing the VMIDs with name pairings. For easier lookup/understandability.
####

for i in $VMIDS
do
curl -vk -u "$USERNAME@internal:$PASSWORD" -H "Content-type: application/xml" -X GET https://$OVIRTHOST:443/ovirt-engine/api/vms/$i > /tmp/VMID.txt
VMIDX=`cat /tmp/VMID.txt | grep '<name>' | awk -F '>' {'print $2'} | awk -F '<' {'print $1'} | head -n1`
echo "$VMIDX=$i" >> /tmp/nameids.txt
echo
echo
done


echo "The following are the VMID to name mappings."
echo
echo
cat /tmp/nameids.txt
VMIDCOUNT=`cat /tmp/nameids.txt | wc -l`
rm -f /tmp/vmlist.txt
rm -f /tmp/VMID.txt
echo
echo
echo $VMIDCOUNT
read -p "Press [Enter] once you have finished reviewing the list."

####
#####################


#####################
#### this part of the code will tell you its about to shutdown a VM.
VMNAMEIDS=`cat /tmp/nameids.txt`
for d in $VMNAMEIDS
do
#VMNAME1=`echo $d | awk -F '=' {'print $1'}`
#VMID2=`echo $d | awk -F '=' {'print $2'}`
        while true
#       VMNAME1=`echo $d | awk -F '=' {'print $1'}`
#       VMID2=`echo $d | awk -F '=' {'print $2'}`
                do
                        VMNAME1=`echo $d | awk -F '=' {'print $1'}`
                        VMID2=`echo $d | awk -F '=' {'print $2'}`
                        /usr/bin/clear
                        echo "                   Menu "
                        echo " ________________________________________"
                        echo " [1] Shutdown $VMNAME1"
                        echo " [2] Do not shutdown $VMNAME1"
                        echo " [3] Exit the script and do not make any changes."
                        echo " ________________________________________"
                        echo
                        echo -e "Enter your choice [1-3]: \c"
                        read VAR
                        case $VAR in
                                1) echo "We would normally shutdown $VMNAME1 here"
                                   #read
                                   sleep 1
                                   break
                                ;;

                                2) echo "We would forego shutting down $VMNAME1 here"
                                   #read
                                   sleep 1
                                   break

                                ;;
                                3) echo "We would exit the script and not do anything."
                                   exit
                                   ;;
                                *) echo "You have not selected a valid option please retry"
                                   echo
                                   #read
                                   ;;
                        esac
            done
done





#curl -vk -u "$USERNAME@internal:$PASSWORD" -H "Content-type: application/xml" -X GET https://$OVIRTHOST:443/ovirt-engine/api/vms/$VMIDS





#echo "Theoretically I have dumped the entire VMLIST into a varible then from a varible to a file to testing."
rm -f /tmp/nameids.txt
echo
exit

