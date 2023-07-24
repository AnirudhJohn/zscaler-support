#!/bin/bash

# Function to display the main menu
function display_menu() {
  clear
  echo "This is a standalone App Connector Troubleshooting Script"
  echo "Created and managed by Anirudh"
  echo
  echo  
  echo "-----------------------------------------------------------------------------------------------"
  echo "Main Menu"
  echo "-----------------------------------------------------------------------------------------------"
  echo
  echo "1. Show App Connector status"
  echo "2. Reprovision App Connector"
  echo "3. Export Journal Logs"
  echo "4. Share Journal logs with Zscaler Support"
  echo "5. Start Packet Capture"
  echo "6. Capture and ZIP PCAP and Journal logs for sharing with Zscaler Support"
  echo "4. Exit"
  echo "-----------------------------------------------------------------------------------------------"
  echo
  read -p "Enter your choice: " choice
  echo 
  echo "-----------------------------------------------------------------------------------------------"
  echo
}


# Function for Task 1
function task1() {
  echo "App Connetor Status"
  # Add your task 1 command here
  systemctl status zpa-connector -l
  echo
}

# Function for Task 2
function task2() {
  echo "Running Task 2..."
  # Add your task 2 command here
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

read -p "Do you wanna proceed (Might cause Damage if entered wrong key !!) Yes/No: " confirm

if [ "$confirm" = "$yes" ];then

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
  echo
}

# Function for Task 3
function task3() {
    read -p "Enter --since parameter (leave empty for all logs): " since_param
    #read -p "Enter the output file path with filename (default: /tmp/journal-<timestamp>.log): " output_file
    output_file=${output_file:-"/tmp/journal-$(date +'%Y%m%d%H%M%S').log"}

    # Run journalctl with the specified --since parameter and write to the output file
    sudo journalctl -u zpa-connector ${since_param:+--since="$since_param"} > "$output_file"
}

# Function for Task 5
function task5() {
    local default_interface="eth0"

    read -p "Enter the host (leave empty for all hosts): " host
    read -p "Enter the port (leave empty for all ports): " port
    read -p "Enter the interface (default: $default_interface): " interface
    interface=${interface:-$default_interface}

    #read -p "Enter the output file path with filename (default: /tmp/zscaler-<timestamp>.pcap): " output_file
    output_file=${output_file:-"/tmp/zscaler-pcap-$(date +'%Y%m%d%H%M%S').pcap"}

    # Build the tcpdump filter based on the user input
    filter=""
    if [[ -n "$host" ]]; then
        filter+="host $host "
    fi

    if [[ -n "$port" ]]; then
        filter+="port $port "
    fi

    # Run tcpdump with the generated filter and write to the specified output file
    sudo tcpdump -i "$interface" $filter -w "$output_file"
}

# Function for Task 6 

function task6() {
    echo "Starting the Pcap ..."
    sleep 2
        local default_interface="eth0"

    read -p "Enter the host (leave empty for all hosts): " host
    echo
    read -p "Enter the port (leave empty for all ports): " port
    echo
    read -p "Enter the interface (default: $default_interface): " interface
    echo
    echo "Please replicate the issue. Once done you can stop the capture with Ctrl^c "
    echo
    interface=${interface:-$default_interface}

    #read -p "Enter the output file path with filename (default: /tmp/zscaler-<timestamp>.pcap): " output_file
    output_file=${output_file:-"/tmp/zscaler-pcap-$(date +'%Y%m%d%H%M%S').pcap"}

    # Build the tcpdump filter based on the user input
    filter=""
    if [[ -n "$host" ]]; then
        filter+="host $host "
    fi

    if [[ -n "$port" ]]; then
        filter+="port $port "
    fi

    # Run tcpdump with the generated filter and write to the specified output file
    sudo tcpdump -i "$interface" $filter -w "$output_file"
    
    echo 
    echo "Pcap terminated !!"
    echo 
    echo "-----------------------------------------------------------------------------------------------"

   echo "Extracting Journal for ZPA process..."
  # Add your task 3 command here
  output_file2=${output_file2:-"/tmp/journal-$(date +'%Y%m%d%H%M%S').log"}
  journalctl -u zpa-connector > "$output_file2"
  echo    

output_zip="/tmp/App_Connector_Journal_and_pcap-$(date +'%Y%m%d%H%M%S').zip"
  # Check if both files exist before zipping
if [ -f "$output_file" ] && [ -f "$output_file2" ]; then
  # Zip the two files into the output zip archive
  zip "$output_zip" "$output_file" "$output_file2"
  echo
  echo "Files zipped successfully!!! Please share these with Zscaler Support for further analysis !!"
  echo
  echo "Exiting out of the script !!"
  sleep 2
  exit
else
  echo
  echo "One or both files do not exist. Please check the file paths."
fi
    

    
}


echo "This is a standalone App Connector Troubleshooting Script"
echo "Created and managed by Anirudh"

echo "Dependency packages: zip"

yum install zip -y &>/dev/null

sleep 2

# Main script
while true; do
  display_menu
  case $choice in
    1)
      task1
      ;;
    2)
      task2
      ;;
    3)
      task3
      ;;
    4)
      echo "Exiting..."
      exit 0
      ;;
    5)
      task5
      ;;
    6)
      task6
      ;;
    *)
      echo "Invalid choice. Please try again."
      ;;
  esac

  read -p "Press Enter to continue..."
done

