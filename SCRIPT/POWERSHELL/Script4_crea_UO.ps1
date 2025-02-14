#######################################################################
#############Script4 : Création de la structure de l'AD
#############ce script va créer les Unités Organisationnelles 
#############de notre domaine 
#############puis reboot la machine
#############Date 28/11/2023
######################################################################


#Fonction qui va créer une unité organisationnelle
function CreaUO {

#variable qui va récupérer le nom du domaine
$domain = Read-Host "Veuillez entrer le nom de votre domaine"

#variable qui va récupérer l'extension du nom du domaine
$ext = Read-Host "Veuillez entrer l'extention de votre domaine"

#variable qui va demander le nom de l'UO à créer
$UO = Read-Host "Veuillez entrer le nom de la nouvelle UO"

#Bloc Try qui va tester la fonctionnalité de création de l'UO
Try {

#commande de création de l'UO avec le paramètre chemin qui définie le chemin vers l'UO
New-ADOrganizationalUnit $UO -Path "DC=$domain, DC=$ext" -ErrorAction Stop

Write-Host "La création de l'UO $UO s'est déroulée avec succès" -ForegroundColor Green
}

Catch {
Write-Host "une erreur est survenue lors de la création de l'OU" -ForegroundColor Red
} 

}

#Boucle qui va demander s'il faut créer une nouvelle UO à la fin de chaque création d'UO 
do
{
CreaUO
$ajout = Read-Host "Voulez-vous rajouter une autre UO ?"
}
while ($ajout -eq "Oui")