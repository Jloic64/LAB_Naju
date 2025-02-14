#######################################################################
#############Script3 : Install et configuration du rôle DHCP
#############ce script va installer le rôle DHCP et créer un pool 
#############d'adresse avec les deux options Gateway et DNS 
#############puis reboot la machine
#############Date 28/11/2023
######################################################################


#Configuration de l'etendue DHCP
#Nom : TSSR_DHCP
#Description ; Etendue DHCP pour les TSSR
#Plage : 192.168.20.20 192.168.20.30
#Masque de sous-réseau : 255.255.255.0
#Passerelle par défaut : 192.168.20.254
#Serveur DNS : 192.168.20.1

#Variables:
$srvname = "SrvAD"
$DhcpName = Read-Host "Veuillez entrer un nom pour votre DHCP"
$description = Read-Host "Veuillez entrer une description DHCP"
$Start_IP = Read-Host "Veuillez entrer l'adresse de début de la plage DHCP"
$End_IP = Read-Host "Veuillez entrer l'adresse de fin de la plage DHCP"
$Mask = Read-Host "Veuillez entrer le masque de sous-réseau"
$bail = Read-Host "Veuillez entrer une durée pour le bail "
$gateway_IP = Read-Host "Veuillez entrer l'adresse de la passerelle"
$DNS_IP = Read-Host "Veuillez entrer l'adresse du DNS"

#installation du rôle DHCP
Add-WindowsFeature DHCP -IncludeManagementTools

#Autoriser le DHCP dans l'AD

add-DHCPServerInDC -DNSName $srvname

#Configure le Pool DHCP

Add-DHCPServerv4Scope -Name $DhcpName -Description $description -StartRange $Start_IP -EndRange $End_IP -Subnet $Mask -LeaseDuration $bail

#Configurer les options Gateway et DNS

Set-DHCPServerv4OptionValue -Router $gateway_IP -DNSServer $DNS_IP 

