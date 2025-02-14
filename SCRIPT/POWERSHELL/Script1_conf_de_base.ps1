######################################################################
#############Script1 : configuration de base
#############ce scipt renomme le serveur et donne une adresse IP
#############fixe puis reboot la machine
#############Date 28/11/2023
######################################################################

#Définie la carte réseau à configurer
$ethalias = "Ethernet"

#variable qui demande l'adresse ip à utilisée
$ethipaddress = "192.168.1.13"

#variable pour indiquer le masque de sous-réseau
$ipmasque = "24"

#l'@ip de la passerelle par défaut
$ethdefaultgw = "192.168.1.254"

#l'@ip du serveur DNS, ici c'est lui même puisqu'il va héberger le rôle DNS
$dnsaddress = "192.168.1.13"

#variable qui récupère le nom du serveur
$servname = "SrvAD"

#Commande pour configurer la carte réseau et l'adresse ip statique ainsi que la passerelle
try {
New-NetIPAddress -IPAddress $ethipaddress -interfaceAlias $ethalias -PrefixLength $ipmasque -DefaultGateway $ethdefaultgw -errorAction Stop

Write-Host "la configuration s'est bien dérouléee" -ForegroundColor Green
}
Catch {
Write-Host "une erreure est survenue" -ForegroundColor DarkMagenta
} 

#l'adresse ip du DNS
Try {
Set-DnsClientServerAddress -InterfaceAlias $ethalias -ServerAddresses $dnsaddress -errorAction Stop

Write-Host "la configuration du DNS s'est bien déroulée"
}
Catch {
Write-Host "une erreure est survenue lors de la configuration du DNS" -ForegroundColor DarkMagenta
} 


#commande pour renommer le serveur 
Rename-Computer -ComputerName $env:computername -NewName $servname

# redémarrage à la fin du processus pour la prise en compte des modifications
Restart-Computer -ComputerName $env:computername