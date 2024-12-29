### **1.1 Installation de Proxmox**

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