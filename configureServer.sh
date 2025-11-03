#!/bin/bash

sudo apt update
sudo apt install socat vsftpd iptables  -y
sudo apt install -y iptables-persistent

sudo iptables -I INPUT -p icmp --icmp-type 8 -j DROP
sudo iptables -A INPUT -p tcp --dport 21  -j DROP

ALLOWED_IPS="$1"
IFS=',' read -ra IPS <<< "$ALLOWED_IPS"
for ip in "${IPS[@]}"; do
    sudo iptables -A INPUT -p tcp --dport 21 -s "$ip" -j ACCEPT
    echo "$ip PASS" | tee -a credentials.txt > /dev/null
done

sudo netfilter-persistent save
sudo adduser --disabled-password --gecos "" ftp_user
echo "ftp_user:MyFTPPass!" | sudo chpasswd

mkdir /home/ftp_user
mkdir -p /etc/authServer
cd /home/ftp_user
echo "Hello World!" > 1.txt
echo "Hello World!" > 2.txt
cd -

sudo cp credential.txt /etc/authServer
sudo cp authServer.sh /usr/bin
sudo cp authServer.service /etc/systemd/system/

sudo chmod +x /usr/bin/authServer.sh
sudo chmod 600 /etc/authServer/credentials.txt
sudo chown root:root /etc/authServer/credentials.txt

sudo systemctl daemon-reload
sudo systemctl enable authServer.service
sudo systemctl restart authServer.service