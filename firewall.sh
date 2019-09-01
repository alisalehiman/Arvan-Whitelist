#!/bin/bash

export RUNTIME_DATE="$(date +%F)"
echo "Removing old ArvanCloud IPs from CSF ..."
sed -i '/##start-arvan-ip/,/##end-arvan-ip/d' /etc/csf/csf.allow


echo "Downloading new IPs From ArvanCloud ..."
wget -O /tmp/arvan_new_ips_$RUNTIME_DATE.txt "https://arvancloud.com/ips.txt"

echo "Adding new IPs to csf allow file ..."
input="/tmp/arvan_new_ips_$RUNTIME_DATE.txt"
echo "##start-arvan-ip" >> /etc/csf/csf.allow
while IFS= read -r line
do
  echo "tcp|in|d=80_443|s=$line" >> /etc/csf/csf.allow
done < "$input"

echo "##end-arvan-ip" >> /etc/csf/csf.allow

echo "Added new IPs to csf allow file successfully."

echo "Restarting CSF ..."
csf -r
echo "Now good to go, ArvanCloud IPs in CSF have been updated successfully. Done!"
