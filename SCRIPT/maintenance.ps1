# Redirection des erreurs vers un fichier de log
$LogFile = "C:\MaintenanceLog.txt"

# Effacer le fichier de log s'il existe deja
if (Test-Path $LogFile) { Remove-Item $LogFile }

# Fonction pour enregistrer les logs
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Write-Output $logMessage | Out-File -FilePath $LogFile -Append
}

# Verification des droits administratifs
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Log "[ERREUR] Ce script doit etre execute en tant qu'administrateur."
    Write-Output "[ERREUR] Ce script doit etre execute en tant qu'administrateur."
    Pause
    Exit
}

Write-Log "Demarrage du script de maintenance."

# Creation d'un point de restauration systeme
Write-Log "Creation d'un point de restauration systeme..."
try {
    Checkpoint-Computer -Description 'MaintenanceRoutine' -RestorePointType 'MODIFY_SETTINGS'
    Write-Log "[INFO] Point de restauration cree avec succes."
} catch {
    Write-Log "[ERREUR] Echec de la creation du point de restauration : $_"
}
Pause

# Nettoyage des fichiers temporaires
Write-Log "Nettoyage des fichiers temporaires..."
$TempPath = [System.IO.Path]::GetTempPath()
try {
    Get-ChildItem -Path "$TempPath" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "[INFO] Nettoyage des fichiers temporaires termine."
} catch {
    Write-Log "[ERREUR] Echec du nettoyage des fichiers temporaires : $_"
}
Pause

# Nettoyage des fichiers de mise a jour
Write-Log "Nettoyage des fichiers de mise a jour..."
try {
    Stop-Service -Name wuauserv, bits, cryptsvc -Force
    Remove-Item -Path "C:\Windows\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\System32\catroot2" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv, bits, cryptsvc
    Write-Log "[INFO] Nettoyage des fichiers de mise a jour termine."
} catch {
    Write-Log "[ERREUR] Echec du nettoyage des fichiers de mise a jour : $_"
}
Pause

# Nettoyage du dossier Telechargements
$cleanDownloads = Read-Host "Voulez-vous nettoyer le dossier Telechargements ? (y/n)"
if ($cleanDownloads -eq "y") {
    Write-Log "Nettoyage du dossier Telechargements..."
    $DownloadsPath = [Environment]::GetFolderPath('UserProfile') + "\Downloads"
    try {
        Get-ChildItem -Path "$DownloadsPath" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "[INFO] Nettoyage du dossier Telechargements termine."
    } catch {
        Write-Log "[ERREUR] Echec du nettoyage du dossier Telechargements : $_"
    }
} else {
    Write-Log "[INFO] Nettoyage du dossier Telechargements ignore."
}
Pause

# Vidage de la corbeille
$cleanRecycleBin = Read-Host "Voulez-vous vider la corbeille ? (y/n)"
if ($cleanRecycleBin -eq "y") {
    Write-Log "Vidage de la corbeille..."
    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Log "[INFO] Corbeille videe avec succes."
    } catch {
        Write-Log "[ERREUR] Echec du vidage de la corbeille : $_"
    }
} else {
    Write-Log "[INFO] Vidage de la corbeille ignore."
}
Pause

# Nettoyage du cache du navigateur
$cleanBrowserCache = Read-Host "Voulez-vous nettoyer le cache du navigateur ? (y/n)"
if ($cleanBrowserCache -eq "y") {
    Write-Log "Nettoyage du cache du navigateur..."
    $chromeCachePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
    try {
        Get-ChildItem -Path "$chromeCachePath" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "[INFO] Nettoyage du cache du navigateur termine."
    } catch {
        Write-Log "[ERREUR] Echec du nettoyage du cache du navigateur : $_"
    }
} else {
    Write-Log "[INFO] Nettoyage du cache du navigateur ignore."
}
Pause

# Verification de l'integrite des fichiers systeme
$runSfc = Read-Host "Voulez-vous verifier l'integrite des fichiers systeme ? (y/n)"
if ($runSfc -eq "y") {
    Write-Log "Verification de l'integrite des fichiers systeme..."
    try {
        sfc /scannow | Out-File -FilePath $LogFile -Append
        Write-Log "[INFO] Verification de l'integrite des fichiers systeme terminee."
    } catch {
        Write-Log "[ERREUR] Echec de la verification de l'integrite des fichiers systeme : $_"
    }
} else {
    Write-Log "[INFO] Verification de l'integrite des fichiers systeme ignoree."
}
Pause

# Nettoyage des journaux d'evenements
$cleanEventLogs = Read-Host "Voulez-vous nettoyer les journaux d'evenements ? (y/n)"
if ($cleanEventLogs -eq "y") {
    Write-Log "Nettoyage des journaux d'evenements..."
    try {
        wevtutil el | ForEach-Object { wevtutil cl $_ }
        Write-Log "[INFO] Nettoyage des journaux d'evenements termine."
    } catch {
        Write-Log "[ERREUR] Echec du nettoyage des journaux d'evenements : $_"
    }
} else {
    Write-Log "[INFO] Nettoyage des journaux d'evenements ignore."
}
Pause

# Execution de chkdsk
$runChkDsk = Read-Host "Voulez-vous executer chkdsk ? (y/n)"
if ($runChkDsk -eq "y") {
    Write-Log "Execution de chkdsk..."
    try {
        chkdsk C: /F /R | Out-File -FilePath $LogFile -Append
        Write-Log "[INFO] chkdsk termine."
    } catch {
        Write-Log "[ERREUR] Echec de chkdsk : $_"
    }
} else {
    Write-Log "[INFO] chkdsk ignore."
}
Pause

# Defragmentation du disque
$defragDisk = Read-Host "Voulez-vous defragmenter le disque ? (y/n)"
if ($defragDisk -eq "y") {
    Write-Log "Defragmentation du disque..."
    try {
        Optimize-Volume -DriveLetter C -Defrag -Verbose | Out-File -FilePath $LogFile -Append
        Write-Log "[INFO] Defragmentation du disque terminee."
    } catch {
        Write-Log "[ERREUR] Echec de la defragmentation du disque : $_"
    }
} else {
    Write-Log "[INFO] Defragmentation du disque ignoree."
}
Pause

# Lancement d'un scan antivirus rapide
Write-Log "Lancement d'un scan antivirus rapide..."
try {
    Start-MpScan -ScanType QuickScan | Out-File -FilePath $LogFile -Append
    Write-Log "[INFO] Scan antivirus rapide termine."
} catch {
    Write-Log "[ERREUR] Echec du scan antivirus rapide : $_"
}
Pause

# Execution de sysprep
$runSysprep = Read-Host "Voulez-vous executer sysprep ? (y/n)"
if ($runSysprep -eq "y") {
    Write-Log "Execution de sysprep..."
    try {
        Start-Process -FilePath "C:\Windows\System32\Sysprep\Sysprep.exe" -ArgumentList "/oobe /generalize /shutdown" -Wait
        Write-Log "[INFO] sysprep termine."
    } catch {
        Write-Log "[ERREUR] Echec de sysprep : $_"
    }
} else {
    Write-Log "[INFO] sysprep ignore."
}
Pause

Start-Process notepad.exe -ArgumentList $LogFile
