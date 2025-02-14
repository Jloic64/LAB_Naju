@echo off
:: Script de maintenance complet
:: Vérifie les droits administrateurs
whoami /groups | find "S-1-16-12288" >nul
if errorlevel 1 (
    echo Ce script doit être exécuté en tant qu'administrateur.
    pause
    exit /b
)

:: Définit le chemin du fichier de log sur le Bureau
set "LOGFILE=%USERPROFILE%\Desktop\MaintenanceLog.txt"

:: Création d'un point de restauration système
powershell -Command "Checkpoint-Computer -Description 'MaintenanceRoutine' -RestorePointType 'MODIFY_SETTINGS'"
echo [INFO] Point de restauration créé. >> "%LOGFILE%"

:: Nettoyage des fichiers inutiles
echo Suppression des fichiers temporaires et inutiles...
del /s /q %TEMP%\* >nul 2>&1
del /s /q C:\Windows\Temp\* >nul 2>&1
del /s /q C:\Windows\Prefetch\* >nul 2>&1
for /d %%i in (%TEMP%\* C:\Windows\Temp\* C:\Windows\Prefetch\*) do rmdir /s /q "%%i" >nul 2>&1
echo [INFO] Fichiers temporaires et inutiles supprimés. >> "%LOGFILE%"

:: Nettoyage des fichiers Windows Update
echo Nettoyage des fichiers de mise à jour...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
net stop cryptsvc >nul 2>&1
rd /s /q C:\Windows\SoftwareDistribution\Download >nul 2>&1
rd /s /q C:\Windows\System32\catroot2 >nul 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
net start cryptsvc >nul 2>&1
echo [INFO] Nettoyage de Windows Update effectué. >> "%LOGFILE%"

:: Analyse antivirus rapide
echo Lancement d'une analyse antivirus...
"C:\Program Files\Windows Defender\MpCmdRun.exe" -Scan -ScanType 1 >nul 2>&1
if errorlevel 0 (
    echo [INFO] Analyse antivirus terminée sans problème. >> "%LOGFILE%"
) else (
    echo [ERREUR] Une erreur s'est produite lors de l'analyse antivirus. >> "%LOGFILE%"
)

:: Vérification du disque et fichiers système
echo Vérification du disque et des fichiers système...
chkdsk C: /F /R >nul 2>&1
if errorlevel 0 (
    echo [INFO] Vérification du disque terminée sans problème. >> "%LOGFILE%"
) else (
    echo [ERREUR] Une erreur s'est produite lors de la vérification du disque. >> "%LOGFILE%"
)

DISM /Online /Cleanup-Image /RestoreHealth >nul 2>&1
if errorlevel 0 (
    echo [INFO] Réparation de l'image système réussie. >> "%LOGFILE%"
) else (
    echo [ERREUR] Une erreur s'est produite lors de l'exécution de DISM. >> "%LOGFILE%"
)

SFC /scannow >nul 2>&1
if errorlevel 0 (
    echo [INFO] Vérification des fichiers système réussie. >> "%LOGFILE%"
) else (
    echo [ERREUR] Une erreur s'est produite lors de l'exécution de SFC. >> "%LOGFILE%"
)

:: Rapport de maintenance
echo [INFO] Maintenance réalisée le %date% à %time%. >> "%LOGFILE%"
echo Rapport de maintenance enregistré sur le Bureau : %LOGFILE%.
pause
