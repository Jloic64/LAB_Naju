# **Résumé de la Configuration du Cluster Proxmox - Hall of Justice**

## **1. Matériel à Disposition**

### **Serveurs et Machines**
- **Serveur Dell T430 (BRUCE)** :
  - **RAM** : 108 Go.
  - **Processeur** : 8 cœurs (2 sockets) - Intel Xeon E5-2403 @ 1.80GHz.
  - **Disques** :
    - SSD de 250 Go pour l’hyperviseur Proxmox.
      - Stockage des ISOs.
      - Stockage des sauvegardes.

- **Serveur Dell T330 (CLARK)** :
  - **RAM** : 32 Go.
  - **Processeur** : 8 cœurs (1 socket) - Intel Xeon E5-1410 @ 2.80GHz.
  - **Disques** :
    - SSD de 250 Go pour l’hyperviseur Proxmox.

- **Mini PC type NUKE (DIANA)** :
  - **RAM** : 8 Go.
  - **Processeur** : 20 cœurs - Intel Core i5.
  - **Disques** :
    - NVMe SSD de 250 Go pour l’hyperviseur.

### **Répartition des Disques**
- **7 SSD de 1 To** :
  - BRUCE : 4 SSD.
  - CLARK : 3 SSD.
- **2 disques SAS de 2 To** (tous sur BRUCE) :
  - 1 disque pour les ISOs.
  - 1 disque pour les sauvegardes.

---
## **1.1 Installation de Proxmox**

#### **Étapes pour chaque nœud :**

1. **Télécharger l'ISO Proxmox** :  
   - Télécharger l'image ISO de Proxmox depuis [le site officiel](https://www.proxmox.com/en/downloads).  

2. **Créer une clé USB bootable** :  
   - Utiliser un outil tel que **Rufus** (Windows) ou la commande `dd` (Linux) :  
     ```bash
     sudo dd if=proxmox-ve.iso of=/dev/sdX bs=4M
     ```  

3. **Démarrer l'installation** :  
   - Insérer la clé USB et configurer le BIOS/UEFI pour démarrer dessus.  
   - Suivre les étapes de l'installation :  
     - Sélectionner le disque cible (par exemple, SSD de 250 Go).  
     - Configurer un mot de passe pour `root` et définir une adresse IP statique pour chaque nœud.  

4. **Mise à jour de Proxmox après installation** :  
   ```bash
   apt update && apt full-upgrade -y
    ``` 
5. **Désactiver l'abonnement commercial (optionnel)** :  
   - Ne possédant pas d'abonnement Proxmox, modifier le fichier des sources :
   ```bash
   nano /etc/apt/sources.list.d/pve-enterprise.list
	 ``` 
   -  Commenter la ligne existante :
    ```bash
   #deb https://enterprise.proxmox.com/debian/pve bullseye pve-enterprise
    ```      
- Ajouter les sources gratuites :
	
    ```bash
    echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
    ```
- Mettre à jour la liste des paquets :
	```bash
   apt update
    ```
- Redémarrer le service réseau pour appliquer les changements :
	```bash
   systemctl restart networking
    ```
## **2. Configuration et Commandes**

### **2.1 Création du Cluster**
- Sur **BRUCE** (nœud principal) :
 ```bash
pvecm create HallOfJustice
```

## 2.2 Ajout de CLARK et DIANA au Cluster
Commande pour ajouter CLARK et DIANA au cluster :
```bash
pvecm add 192.168.1.245
```
## 2.3 Vérification du Cluster
Vérification de l’état du cluster :
```bash
pvecm status
```
## 3. Configuration de Ceph
### 3.1 Installation de Ceph sur Tous les Nœuds
Commande à exécuter sur tous les nœuds :
```bash
pveceph install
```
### 3.2 Initialisation de Ceph sur BRUCE
Initialisation de Ceph sur BRUCE :
```bash
pveceph init --network 10.10.10.0/24
```
### 3.3 Ajout des Moniteurs Ceph
Sur CLARK et DIANA :
```bash
pveceph createmon
```
### 3.4 Création des OSD
#### Sur BRUCE (4 SSD) :
```bash
pveceph osd create /dev/sdb
pveceph osd create /dev/sdc
pveceph osd create /dev/sdd
pveceph osd create /dev/sde
```
#### Sur CLARK (3 SSD) :
```bash
pveceph osd create /dev/sda
pveceph osd create /dev/sdb
pveceph osd create /dev/sdc
```
## 4. Configuration des Disques SAS sur BRUCE
### 4.1 Disque pour les ISOs
Configuration :
```bash
mkfs.ext4 /dev/sda
mkdir -p /mnt/iso-storage
mount /dev/sda /mnt/iso-storage
echo '/dev/sda /mnt/iso-storage ext4 defaults 0 2' >> /etc/fstab
mount -a
pvesm add dir iso-storage --path /mnt/iso-storage --content iso
```
### 4.2 Disque pour les Sauvegardes
Configuration :
```bash
mkfs.ext4 /dev/sdb
mkdir -p /mnt/backup-storage
mount /dev/sdb /mnt/backup-storage
echo '/dev/sdb /mnt/backup-storage ext4 defaults 0 2' >> /etc/fstab
mount -a
pvesm add dir backup-storage --path /mnt/backup-storage --content backup
```
## 5. Personnalisation des MOTD
### 5.1 Commandes Générales
Créer le fichier MOTD :
```bash
nano /etc/update-motd.d/99-custom
```
Rendre le script exécutable :
```bash
chmod +x /etc/update-motd.d/99-custom
```
Appliquer le MOTD :
```bash
run-parts /etc/update-motd.d/ > /etc/motd
```

### Personnalisations par Nœud

#### BRUCE (Batman)
Contenu du script `/etc/update-motd.d/99-custom` :
```bash
#!/bin/bash
# Logo Batman ASCII
echo ""
echo "                          @@                                             @@"
echo "                     @@@@@@@                                              @@@@@@"
echo "                 @@@@@@@@@                                                 @@@@@@@@@"
echo "             @@@@@@@@@@@@                     @       @                     @@@@@@@@@@@"
echo "           @@@@@@@@@@@@@@                    @@@     @@                    @@@@@@@@@@@@@@@"
echo "         @@@@@@@@@@@@@@@@@                   @@@@   @@@@                   @@@@@@@@@@@@@@@@@"
echo "       @@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@"
echo "      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " @@@            @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@            @@@"
echo "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "                       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "                        @@            @@@@@@@@@@@@@@@@@@@@@@@             @@@"
echo "                                         @@@@@@@@@@@@@@@@@"
echo "                                           @@@@@@@@@@@@@"
echo "                                             @@@@@@@@@@"
echo "                                               @@@@@@"
echo "                                                @@@@"
echo "                                                  @"
echo ""
echo "***************************************************"
echo "Bienvenue sur BRUCE" 
echo "***************************************************"
echo "Cluster : "Hall of Justice"
echo "Uptime : $(uptime -p)"
echo "Utilisation du disque :"
df -h | grep '^/dev'
```

#### CLARK (Superman)
Contenu du script `/etc/update-motd.d/99-custom` :
```bash
echo ""
echo "                                                                                                   "
echo "                                                                                                   "
echo "                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  "
echo "                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                "
echo "              @@@@@                                                              @@@@@              "
echo "            @@@@@    @@@@@@@@@             @@@@@@@@               @@@@@@@         @@@@@            "
echo "          @@@@@    @@@@@@@@@@@       @@@@@@@@@@@@@@@@@@@@@        @@@@@@@@          @@@@@           "
echo "        @@@@@    @@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@       @@@@@      @@@    @@@@@         "
echo "       @@@@     @@@@@@@@@       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     @@        @@@@@    @@@@@       "
echo "     @@@@@    @@@@@@@@@       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@    @@@@@     "
echo "   @@@@@    @@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@    @@@@    "
echo " @@@@@    @@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@   @@@@@  "
echo " @@@@    @@@@@@@@@@            @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@ "
echo "  @@@@@   @@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@   "
echo "    @@@@    @@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@    "
echo "     @@@@@    @@@@                                                  @@@@@@@@@@@@@@@@@@    @@@@      "
echo "       @@@@@   @@@                                                      @@@@@@@@@@@@    @@@@@       "
echo "        @@@@@                                                             @@@@@@@@@   @@@@@         "
echo "          @@@@@                                                             @@@@@    @@@@@          "
echo "            @@@@                                                             @@    @@@@@            "
echo "             @@@@@    @@@@@@@@@@@@@@@@@@                                          @@@@@             "
echo "               @@@@     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@              "
echo "                @@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@            @@@@                "
echo "                  @@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@                 "
echo "                   @@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@                   "
echo "                     @@@@@    @@@            @@@@@@@@@@@@@@@@@@@@@@@      @@@@@                    "
echo "                       @@@@                    @@@@@@@@@@@@@@@@@        @@@@@                      "
echo "                        @@@@@                                         @@@@@                        "
echo "                          @@@@@                                      @@@@@                         "
echo "                           @@@@@     @@@@@               @@@@@@     @@@@                           "
echo "                             @@@@@    @@@@@@@@@@@@@@@@@@@@@@@     @@@@@                            "
echo "                              @@@@@     @@@@@@@@@@@@@@@@@@@     @@@@@                              "
echo "                                @@@@@    @@@@@@@@@@@@@@@@@     @@@@@                               "
echo "                                  @@@@@    @@@@@@@@@@@@@     @@@@@                                 "
echo "                                   @@@@@     @@@@@@@@@@    @@@@@                                   "
echo "                                     @@@@@    @@@@@@@     @@@@@                                    "
echo "                                       @@@@     @@@     @@@@@                                      "
echo "                                        @@@@@          @@@@@                                       "
echo "                                          @@@@@      @@@@@                                         "
echo "                                           @@@@@    @@@@@                                          "
echo "                                             @@@@@@@@@@                                            "
echo "                                               @@@@@@                                              "
echo "                                                @@@@                                               "
echo "                                                                                                   "
echo "                                                                                                   "

# Informations du Cluster
echo "***************************************************"
echo "Bienvenue sur CLARK"
echo "***************************************************"
echo "Cluster : "Hall of Justice"
echo "Uptime : $(uptime -p)"
echo "Utilisation du disque :"
df -h | grep '^/dev'
```

#### DIANA (Wonder Woman)
Contenu du script `/etc/update-motd.d/99-custom` :
```bash
#!/bin/bash

# Nouveau Logo Diana ASCII
echo ""
echo "                                                                                                   "
echo "                                                                                                   "
echo "                                                                                                   "
echo "                                                                                                   "
echo "                                                                                                   "
echo "                                                                                                   "
echo "  @@@@@@@@@@@@@@@@@@@@@                          @@                                                  "
echo " @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ "
echo "  @@@                              @@@         @@  @@         @@@                             @@@   "
echo "   @@@@                              @@@      @@%   @@@      @@                             @@@@    "
echo "     @@@@@@@@@@@@@@@@@@@@@@@@@@%      @@@    @@      @@@    @@      @@@@@@@@@@@@@@@@@@@@@@@@@@@     "
echo "       @@@%                   @@@@     @@%  @@@       @@   @@     @@@@                   @@@        "
echo "        @@@@                    %@@     @@@@@          @@%@@     @@@                    @@@         "
echo "         @@@@@                   @@@     @@@      @     @@@     @@@                  @@@@@          "
echo "           @@@@@@@@@@@@@@@@@@@@@@@@@@     @     @@@@     @     @@@@@@@@@@@@@@@@@@@@@@@@@@           "
echo "              @@@                 @@@@         @@@@@@         @@@@                 @@@              "
echo "               @@@                  @@@        @@@ @@@       @@@                 %@@@               "
echo "                @@@@@                @@@     %@@@   @@@     @@@               %@@@@@                "
echo "                   @@@@@@@@@@@@@@     @@@    @@      @@@   @@@      @@@@@@@@@@@@@                    "
echo "                               @@@     @@@  @@@       @@%  @@     %@@                                "
echo "                                 @@     @@@@@@        %@@@@@@    @@@                                 "
echo "                                 @@@     @@@@           @@@      @@                                  "
echo "                                  @@@     @@     @@@    @@@     @@                                   "
echo "                                   @@@          @@@@@          @@                                    "
echo "                                    @@         @@@ @@         @@@                                    "
echo "                                     @@@      @@@   @@@      @@@                                     "
echo "                                      @@@    @@%     @@@    @@%                                      "
echo "                                       @@   @@@       @@   @@@                                       "
echo "                                        @@ @@@         @@@@@@                                        "
echo "                                         @@@@           @@@@                                         "
echo "                                          @@             @@                                          "
echo "                                                                                                   "
echo "                                                                                                   "

# Informations du Cluster
echo "***************************************************"
echo "Bienvenue sur DIANA"
echo "***************************************************"
echo "Cluster : "Hall of Justice"
echo "Uptime : $(uptime -p)"
echo "Utilisation du disque :"
df -h | grep '^/dev'
``` 