# PowerShell :

### Pour tester le port TCP (33036) :
```powershell
Test-NetConnection -ComputerName [adresse_IP] -Port 33036
```
### Via nmap sur votre machine et l'exécuter depuis PowerShell :

Installer nmap 
Ensuite, lancez la commande suivante dans PowerShell :
```powershell
nmap -p 33038 -sU [adresse_IP]
```
Via Netstat :

```powershell 
netstat -an | findstr 33036
```
### Script UDP :
```bash 
$udpClient = New-Object System.Net.Sockets.UdpClient
$ipEndPoint = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::Parse("[adresse_IP]"), 33038)
try {
    $udpClient.Connect($ipEndPoint)
    Write-Host "UDP port 33038 is open."
} catch {
    Write-Host "UDP port 33038 is closed."
}
