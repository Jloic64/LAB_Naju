#######################################################################
#############Script5 : Création des groupes dans l'AD
#############ce script va créer les groupes et les mettre dans leurs
#############Unités Organisationnelles  
#############Date 28/11/2023
######################################################################

$groupe = Read-Host "Veuillez rentrer le nom du groupe à créer"

#variable qui va récupérer le nom du domaine
$domain = Read-Host "Veuillez entrer le nom de votre domaine"

#variable qui va récupérer l'extension du nom du domaine
$ext = Read-Host "Veuillez entrer l'extention de votre domaine"

#variable qui va demander le nom de l'UO à créer
$UO = Read-Host "Veuillez rentrer l'UO du groupe"

$group_scope = Read-Host "Veuillez entrer l'etendu du groupe"

switch ($UO)
{
1{$UO="UO_WINDOWS"}
2{$UO="UO_LINUX"}
3{$UO="UO_CISCO"}
4{$UO="UO_VIRTU"}
5{$UO="UO_ROUTAGE"}
}

New-ADGroup -Name $groupe -GroupScope $group_scope -Path "OU=$UO, DC=$domain , DC=$ext"