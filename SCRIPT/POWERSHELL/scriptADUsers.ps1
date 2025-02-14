$CSVFile = "C:\Scripts\AD_USERS\Utilisateurs.csv"
$CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8

Foreach($Utilisateur in $CSVData){

    $UtilisateurPrenom = $Utilisateur.Prenom
    $UtilisateurNom = $Utilisateur.Nom
    $UtilisateurLogin = ($UtilisateurPrenom).Substring(0,1) + "." + $UtilisateurNom
    $UtilisateurEmail = "$UtilisateurLogin@Salomi.lan"
    $UtilisateurMotDePasse = "Simplon@64"
    $UtilisateurFonction = $Utilisateur.Fonction

    # Vérifier la présence de l'utilisateur dans l'AD
    if (Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin})
    {
        Write-Warning "L'identifiant $UtilisateurLogin existe déjà dans l'AD"
    }
    else
    {
        New-ADUser -Name "$UtilisateurNom $UtilisateurPrenom" `
                    -DisplayName "$UtilisateurNom $UtilisateurPrenom" `
                    -GivenName $UtilisateurPrenom `
                    -Surname $UtilisateurNom `
                    -SamAccountName $UtilisateurLogin `
                    -UserPrincipalName "$UtilisateurLogin@Salomi.lan" `
                    -EmailAddress $UtilisateurEmail `
                    -Title $UtilisateurFonction `
                    -Path "OU=Personnel,DC=SALOMI,DC=LOCAL" `
                    -AccountPassword(ConvertTo-SecureString $UtilisateurMotDePasse -AsPlainText -Force) `
                    -ChangePasswordAtLogon $true `
                    -Enabled $true

        Write-Output "Création de l'utilisateur : $UtilisateurLogin ($UtilisateurNom $UtilisateurPrenom)"
    }
}