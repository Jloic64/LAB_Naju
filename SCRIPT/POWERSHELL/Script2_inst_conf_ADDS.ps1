######################################################################
#############Script2 : Install et configuration de l'ADDS
#############ce scipt va installer le rôle ADDS et créer un domaine 
#############puis reboot la machine
#############Date 28/11/2023
######################################################################

$nomdomaine = "tssr.local"


#Ajouter le rôle ADDS au serveur
Try {
Add-WindowsFeature AD-Domain-Services -ErrorAction Stop
Write-Host "L'installation s'est bien déroulée" -ForegroundColor Green
}
Catch {
Write-Host "L'installation a rencontrée un problème" -ForegroundColor DarkMagenta
}

#Configurer l'ADDS
Try {
Install-ADDSForest -DomainName $nomdomaine -InstallDNS -ErrorAction stop
Write-Host "La configuration de l'AD s'est bien déroulée" -ForegroundColor Green
}

Catch {
Write-Host "La configuration a rencontrée un problème" -ForegroundColor DarkMagenta
}

Sleep 180

# redémarrage à la fin du processus pour la prise en compte des modifications
Restart-Computer -ComputerName $env:computername