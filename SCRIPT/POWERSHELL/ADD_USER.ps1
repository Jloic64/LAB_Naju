$CSVFile = "C:\Scripts\AD_USERS\Utilisateurs.csv"
$CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8

$CSVData | ForEach-Object {
    $UtilisateurPrenom = $_."Nom complet".Split(" ")[0]
    $UtilisateurNom = $_."Nom complet".Split(" ")[1]
    $UtilisateurLogin = $_."Login"
    $UtilisateurEmail = "$UtilisateurLogin@TSSR.INFO"
    $UtilisateurMotDePasse = $_."Mot de passe"
    $UtilisateurGroupe = $_."Groupe"
    $UtilisateurUO = $_."UO"

    # Vérifier la présence de l'utilisateur dans l'AD
    if (Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin})
    {
        Write-Warning "L'identifiant $UtilisateurLogin existe déjà dans l'AD"
    }
    else
    {
        $ouPath = $UtilisateurUO

        New-ADUser -Name "$UtilisateurNom $UtilisateurPrenom" `
                    -DisplayName "$UtilisateurNom $UtilisateurPrenom" `
                    -GivenName $UtilisateurPrenom `
                    -Surname $UtilisateurNom `
                    -SamAccountName $UtilisateurLogin `
                    -UserPrincipalName "$UtilisateurLogin@TSSR.INFO" `
                    -EmailAddress $UtilisateurEmail `
                    -Path $ouPath `
                    -AccountPassword (ConvertTo-SecureString $UtilisateurMotDePasse -AsPlainText -Force) `
                    -ChangePasswordAtLogon $true `
                    -Enabled $true

        Add-ADGroupMember -Identity $UtilisateurGroupe -Members $UtilisateurLogin

        Write-Output "Création de l'utilisateur : $UtilisateurLogin ($UtilisateurNom $UtilisateurPrenom)"
    }
}
