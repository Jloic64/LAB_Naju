<#
    Date : 10/10/2022
    Description : Script permettant la création d'utilisateurs dans Active Directory et la configuration de leur dossier partagé personnel.
#>

# Définition de la fonction pour la création d'un utilisateur
function adduser {


    # Demander et stocker le nom de l'utilisateur
    $nom = Read-Host "Veuillez entrer votre nom"

    # Demander et stocker le prénom de l'utilisateur
    $prenom = Read-Host "Veuillez entrer votre prenom"


    # Construire le nom complet en mettant le nom en majuscules et le prénom en minuscules
    $nom_complet = $nom.ToUpper() + " " + $prenom.ToLower()
    
    # Construire le nom d'utilisateur (login) en utilisant la première lettre du prénom et le nom complet, tous en minuscules
    $login = $prenom.Substring(0,1).ToLower() + "." + $nom.ToLower()
    
    # Afficher les options d'Unité Organisationnelle disponibles
    Write-Host "1. WINDOWS"
    Write-Host "2. LINUX"
    Write-Host "3. VIRTU"
    Write-Host "4. CISCO"
    Write-Host "5. ROUTAGE"
    # Ajouter d'autres options si nécessaire

    # Demander à l'utilisateur de choisir une Unité Organisationnelle
    $UO = Read-Host "Veuillez entrer un numero valide pour l'UO"
    
    # Assigner l'Unité Organisationnelle en fonction du choix de l'utilisateur
    Switch ($UO) {
        1 { $UO = "WINDOWS" }
        2 { $UO = "LINUX" }
        3 { $UO = "VIRTU" }
        4 { $UO = "CISCO" }
        5 { $UO = "ROUTAGE" }
        # Ajouter d'autres cas si nécessaire
    }

    # Demander à l'utilisateur de choisir un groupe
    $groupe = Read-Host "Veuillez entrer le numero de votre groupe"

    # Assigner le groupe en fonction du choix de l'utilisateur
    Switch ($groupe) {
        1 { $groupe = "GR_WINDOWS" }
        2 { $groupe = "GR_LINUX" }
        3 { $groupe = "GR_VIRTU" }
        4 { $groupe = "GR_CISCO" }
        5 { $groupe = "GR_ROUTAGE" }
        # Ajouter d'autres cas si nécessaire
    }

    # Bloc try pour tenter de créer le nouvel utilisateur
    try {
        # Création de l'utilisateur dans Active Directory
        New-ADUser -Name $nom_complet -GivenName $prenom -Surname $nom -SamAccountName $login -Path "OU=$UO,DC=tssr,DC=local" -AccountPassword (Read-Host -AsSecureString "Entrer mot de passe") -Enabled $true -ErrorAction Stop
        Write-Host "Utilisateur cree avec succes" -ForegroundColor Green
    } catch {
        # Gestion des erreurs lors de la création de l'utilisateur
        Write-Host "Une erreur est survenue lors de la creation de l'utilisateur: $_" -ForegroundColor Red
    }

    # Bloc try pour tenter d'ajouter l'utilisateur au groupe
    try {
        # Ajout de l'utilisateur au groupe spécifié
        Add-ADGroupMember -Identity $groupe -Members $login -ErrorAction Stop
        Write-Host "Ajout au groupe reussi" -ForegroundColor Green
    } catch {
        # Gestion des erreurs lors de l'ajout de l'utilisateur au groupe
        Write-Host "Une erreur est survenue lors de l'affectation au groupe: $_" -ForegroundColor Red
    }
}

# Boucle pour créer des utilisateurs jusqu'à ce que l'utilisateur décide d'arrêter
do {
    # Appel de la fonction pour ajouter un utilisateur
    adduser

    # Demander à l'utilisateur s'il souhaite continuer à ajouter des utilisateurs
    $ajout = Read-Host "Voulez-vous creer un nouvel utilisateur ? (Oui/Non)"
} while ($ajout -eq "Oui")

# Fin du script
exit 0
1