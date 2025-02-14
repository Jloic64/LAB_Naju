<#


Date : 10/10/2022
Description : Script permettant la création d'utilisateurs dans l'AD et du dossier partagé personnel

#>

#Fonction pour la création d'un utilisateur
function adduser {
    #Création des variables prenom, nom_complet et login pour permettre à l'utilisateur de s'identifier
    
    $prenom=read-host "Veuillez entrer votre prénom"                   #Variable permettant dé récuperer le prénom du nouvel utilisateur
    $nom=read-host "Veuillez entrer votre nom"                         #Variable permettant de récupérer le nom du nouvel utilisateur
    $nom_complet=$nom.ToUpper() + " " + $prenom.ToLower()              #Variable qui va concaténer le nom complet du nouvel utilisateur
    $login=$prenom.Substring(0,1).ToLower() + "." + $nom.ToLower()     #Variable qui va construire le login depuis le nom et le prénom selon un format spécifique
    
    write-host "{1} WINDOWS"                                         #Affiche les différents unités organisationelles et groupes
    write-host "{2} LINUX"
    write-host "{3} VIRTU"
    write-host "{4} CISCO"
    write-host "{5} ROUTAGE"
    #write-host "{6} Marketing"
    #write-host "{7} Informatique"
    
    $UO=Read-Host "Veuillez entrer un numéro valide"                   #Variable qui va récupérer le numéro de l'UO
    
    Switch ($uo)                                                       #Remplissage des variables UO
    {
    1{$uo="WINDOWS"}
    2{$uo="LINUX"}
    3{$uo="VIRTU"}
    4{$uo="CISCO"}
    5{$uo="ROUTAGE"}
    #6{$uo="UO_Marketing"}
    #7{$uo="UO_Informatique"}
        }
    
    
    #Création de la variable groupe pour permettre à l'utilisateur d'intégrer un groupe.
    $groupe=read-host "Veuillez entrer le numéro de votre groupe"
    
    Switch ($groupe)                                                   #Remplissage des variables GR
    {
    1{$groupe="GR_WINDOWS"}
    2{$groupe="GR_LINUX"}
    3{$groupe="GR_VIRTU"}
    4{$groupe="GR_CISCO"}
    5{$groupe="GR_ROUTAGE"}
    #6{$groupe="GR_Marketing"}
    #7{$groupe="GR_Informatique"}
        }
    
    
    try
    {
    #Création du nouvel utilisateur
    
    new-aduser -name $nom_complet -GivenName $prenom -Surname $nom -SamAccountName $login -path "OU=$UO,DC=axeplane,DC=loc" -AccountPassword (Read-Host -AsSecureString "Entrer mot de passe") -enable $true -ErrorAction stop
    Write-Host "Utilisateur crée avec succès" -ForegroundColor Green
    }
    catch
    { 
    Write-Host "Une erreur est survenue lors de la création de l'utilisateur" -ForegroundColor Red
    exit 1
    }
    
    try
    {
    Add-ADGroupMember -Identity $groupe -Members $login  -ErrorAction stop                      #Affectation de l'utilisateur à un groupe
    Write-host "Ajout au groupe réussi" -ForegroundColor Green
    }
    catch
    {
    Write-Host " Une erreur est survenue lors de l'affectation au groupe" -ForegroundColor Red
    exit 1
    }
}       
do
{
adduser
$ajout = Read-Host "Voulez vous créer un nouvel utilisateur ?"
  
   } 
while ($ajout -eq "Oui")  
                              
exit 0