# Configurer l'environnement de TERRAFORM

### ** Installer le Proxmox Provider pour Terraform**

1. **Qu'est-ce qu'un provider ?**  
   Un provider est un plugin Terraform qui permet d'interagir avec une API (dans ce cas, celle de Proxmox) pour gérer des ressources. Le provider Proxmox est indispensable pour que Terraform puisse communiquer avec ton cluster.

2. **Télécharger le Proxmox Provider** :  
   - Le provider officiel pour Proxmox est disponible sur GitHub : [Telmate/terraform-provider-proxmox](https://github.com/Telmate/terraform-provider-proxmox).
   - Cloner le repository dans ton conteneur LXC où Terraform est installé :
     ```bash
     git clone https://github.com/Telmate/terraform-provider-proxmox.git
     cd terraform-provider-proxmox
     ```
   - Compiler le provider :
     ```bash
     go build -o terraform-provider-proxmox
     ```
   - Déplacer le binaire dans le répertoire des plugins Terraform (par défaut : `~/.terraform.d/plugins/`).

3. **Vérifier l'installation du provider** :
   - Créer un fichier de configuration Terraform minimal :
     ```hcl
     provider "proxmox" {
       pm_api_url = "https://<IP_DU_CLUSTER>:8006/api2/json"
       pm_user    = "root@pam"
       pm_password = "ton_mot_de_passe"
       pm_tls_insecure = true
     }
     ```
   - Lancer une commande `terraform init` pour vérifier que Terraform détecte le provider.
