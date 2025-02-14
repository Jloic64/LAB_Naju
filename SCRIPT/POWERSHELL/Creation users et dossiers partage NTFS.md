<#
Description: Ce script crée des utilisateurs dans Active Directory, génère un dossier partagé personnel pour chaque utilisateur, et configure les permissions NTFS du dossier. Il assure également l'installation du module NTFSSecurity si ce dernier n'est pas déjà installé.
#>

# Vérifie si le module NTFSSecurity est installé, l'installe si nécessaire, puis l'importe pour utilisation.
if (-not (Get-Module -ListAvailable -Name NTFSSecurity)) {
    Write-Host "Le module NTFSSecurity n'est pas installé. Tentative d'installation..."
    try {
        Install-Module -Name NTFSSecurity -Force -Scope CurrentUser
        Write-Host "Module NTFSSecurity installé avec succès." -ForegroundColor Green
    } catch {
        Write-Host "L'installation du module NTFSSecurity a échoué : $_" -ForegroundColor Red
        exit 1
    }
}
Import-Module NTFSSecurity

# Fonction pour ajouter un utilisateur
function Add-User {
    # Demande à l'utilisateur d'entrer le prénom et le nom, puis construit le nom complet et le login.
    $prenom = Read-Host "Veuillez entrer votre prénom"
    $nom = Read-Host "Veuillez entrer votre nom"
    $nom_complet = $nom.ToUpper() + " " + $prenom.ToLower()
    $login = $prenom.Substring(0,1).ToLower() + "." + $nom.ToLower()

    # Affiche les options d'unité organisationnelle disponibles.
    Write-Host "1 WINDOWS" "2 LINUX" "3 VIRTU" "4 CISCO" "5 ROUTAGE"

    # Demande à l'utilisateur de choisir une unité organisationnelle.
    $UO = Read-Host "Veuillez entrer un numéro valide"
    Switch ($UO) {
        1 { $UO = "WINDOWS" }
        2 { $UO = "LINUX" }
        # Plus d'options peuvent être ajoutées ici
    }

    # Demande à l'utilisateur de choisir un groupe pour l'utilisateur.
    $groupe = Read-Host "Veuillez entrer le numéro de votre groupe"
    Switch ($groupe) {
        1 { $groupe = "GR_WINDOWS" }
        2 { $groupe = "GR_LINUX" }
        # Plus d'options de groupes peuvent être ajoutées ici
    }

    # Tente de créer l'utilisateur dans Active Directory avec les informations fournies.
    try {
        New-ADUser -Name $nom_complet -GivenName $prenom -Surname $nom -SamAccountName $login -Path "OU=$UO,DC=exemple,DC=com" -AccountPassword (Read-Host -AsSecureString "Entrer le mot de passe") -Enabled $true -ErrorAction Stop
        Write-Host "Utilisateur créé avec succès" -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors de la création de l'utilisateur : $_" -ForegroundColor Red
    }

    # Tente d'ajouter l'utilisateur au groupe spécifié.
    try {
        Add-ADGroupMember -Identity $groupe -Members $login -ErrorAction Stop
        Write-Host "Ajout au groupe réussi" -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors de l'ajout au groupe : $_" -ForegroundColor Red
    }

    # Crée un dossier personnel pour l'utilisateur et partage ce dossier.
    $path = "E:\Partages_personnels_utilisateurs\$login"
    try {
        New-Item -ItemType Directory -Path $path -ErrorAction Stop
        New-SmbShare -Name $nom_complet -Path $path -FullAccess "Administrateurs" -ReadAccess "Utilisateurs" -ErrorAction Stop
        Write-Host "Dossier partagé créé avec succès" -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors de la création du dossier partagé : $_" -ForegroundColor Red
    }

    # Configure les permissions NTFS pour le dossier utilisateur.
    try {
        Add-NTFSAccess -Path $path -Account "$login" -AccessRights FullControl -ErrorAction Stop
        Write-Host "Permissions NTFS configurées avec succès" -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors de la configuration des permissions NTFS : $_" -ForegroundColor Red
    }
}

# Boucle principale pour créer des utilisateurs jusqu'à ce que l'utilisateur décide d'arrêter.
do {
    Add-User
    $ajout = Read-Host "Voulez-vous créer un nouvel utilisateur ? (Oui/Non)"
} while ($ajout -eq "Oui")

