#!/bin/bash
echo Remove Old IP from CSF...
sed -i '/##start-arvan-ip/,/##end-arvan-ip/d' /etc/csf/csf.allow

echo Download New IP From Abrarvan...
wget -O /tmp/arvan.txt https://arvancloud.com/ips.txt

echo "Add To csf allow "
input="/tmp/arvan.txt"
echo "##start-arvan-ip" >> /etc/csf/csf.allow
while IFS= read -r line
do
  echo "tcp|in|d=80_443|s=$line" >> /etc/csf/csf.allow
done < "$input"
echo "##end-arvan-ip" >> /etc/csf/csf.allow

echo "restart csf"
csf -r
