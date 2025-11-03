CLIENT_IP=$SOCAT_PEERADDR

iptables -D INPUT -s $CLIENT_IP -p tcp --dport 21 -j ACCEPT
sudo netfilter-persistent save

FOUND_KEY=""
while read ip key; do
    if [ "$ip" = "$CLIENT_IP" ]; then
        FOUND_KEY="$key"
        break
    fi
done < /etc/authServer/credentials.txt

if [$FOUND_KEY == ""]; then 
    echo "Acces restricted"
    exit
    fi

read -p  "Enter a password: " KEY

if [$KEY != $FOUND_KEY or $FOUND_KEY == "PASS"]; then 
    echo "wrong key"
    exit
    fi

echo "Acces granted"

iptables -I INPUT -p tcp --dport 21 -s $CLIENT_IP -j ACCEPT
sudo netfilter-persistent save
