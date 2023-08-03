#!/bin/bash
FILE="/opt/zscaler/var"
provision_key="NULL"
confirm="no"
yes="yes"

if [ "$EUID" -ne 0 ]
    then echo "Run as root!!"
    exit
fi
echo "********************************************************"
echo "*                                                      *"
echo "*          Re-Provision ZPA Connector                   *"
echo "*                                                      *"
echo "********************************************************"
echo 
read -p "Enter the new Provsioning Key: " provision_key
echo
echo
echo
echo "This is the entered key: "
echo
echo $provision_key

echo "Do you wanna proceed (Might cause Damage if entered wrong key !!) " 
echo
read -p " Y/N: " confirm


if [[ "$confirm" =~ ^[Yy]$ ]];then

# Stop the zpa process
echo
echo "Stopping the ZPA Process ....."; sleep 2;
sudo systemctl stop zpa-connector
echo
echo "ZPA process Stopped!"
# Remove the Already provisioned configuration
echo
echo "Removing the previous configuration ....."; sleep 2;
sudo rm -rf $FILE/*
echo
echo "Successfully removed!"


# create a new provisioning key conf
sudo touch $FILE/provision_key
chmod 644 $FILE/provision_key
sudo echo $provision_key > $FILE/provision_key
sleep 2
echo
echo "Starting the service again ......" ;sleep 1
sudo systemctl start zpa-connector
sleep 2
clear
sudo watch -n 1 systemctl status zpa-connector
else
    echo "Cancelling..."
    exit
fi