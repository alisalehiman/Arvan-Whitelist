#!/bin/bash

export RUNTIME_DATE="$(date +%F)"
echo "Removing old ArvanCloud IPs from CSF ..."
sed -i '/##start-arvan-ip/,/##end-arvan-ip/d' /etc/csf/csf.allow

if [ $? -ne 0 ]
then
    echo "Removed old IPs sucessfully."
else
    echo "Couldn't remove old IPs from /etc/csf/csf.allow."
fi

echo "Downloading new IPs From ArvanCloud ..."
wget -O /tmp/arvan_new_ips_$RUNTIME_DATE.txt "https://arvancloud.com/ips.txt"

echo "Adding new IPs to csf allow file ..."
input="/tmp/arvan_new_ips_$RUNTIME_DATE.txt"
echo "##start-arvan-ip" >> /etc/csf/csf.allow
while IFS= read -r line
do
  echo "tcp|in|d=80_443|s=$line" >> /etc/csf/csf.allow
done < "$input"

if [ $? -ne 0 ]
then
    echo "Added new IPs to csf allow file successfully."
else
    echo "Couldn't add new IPs to /etc/csf/csf.allow."
fi

echo "##end-arvan-ip" >> /etc/csf/csf.allow

echo "Restarting CSF ..."
csf -r

if [ $? -ne 0 ]
then
    echo "ArvanCloud IPs in CSF have been updated successfully. Done!"
else
    echo "Couldn't restart CSF, trying to start and stop it ..."
    csf -f && csf -s
    if [ $? -ne 0 ]
      then
      echo "Now good to go, ArvanCloud IPs in CSF have been updated successfully. Done!"
    else
      echo "Couldn't start CSF, please check out logs for error ..."
    fi
fi