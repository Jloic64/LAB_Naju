# Configurer l'environnement de TERRAFORM

### **Installer le Proxmox Provider pour Terraform**

1. **Qu'est-ce qu'un provider ?**  
   Un provider est un plugin Terraform qui permet d'interagir avec une API (dans ce cas, celle de Proxmox) pour gérer des ressources. Le provider Proxmox est indispensable pour que Terraform puisse communiquer avec ton cluster.

2. **Télécharger et installer le Proxmox Provider** :  
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
   - Lancer la commande `terraform init` pour vérifier que Terraform détecte le provider.

---

### **Configurer la connexion au cluster Proxmox**

1. **Paramètres nécessaires** :
   - **URL de l'API** : `https://<IP_DU_CLUSTER>:8006/api2/json`.
   - **Utilisateur** : Utiliser un utilisateur avec les droits nécessaires, comme `root@pam`.
   - **Mot de passe** : Celui de l’utilisateur.
   - **TLS Insecure** : Si tu n’as pas configuré de certificat SSL, tu peux désactiver la vérification TLS avec `pm_tls_insecure = true`.

2. **Stockage sécurisé des informations sensibles** :
   - Éviter de coder en dur le mot de passe dans le fichier `.tf`. Utiliser des variables ou des fichiers d’environnement :
     - Crée un fichier `variables.tf` :
       ```hcl
       variable "pm_password" {}
       ```
     - Et un fichier `terraform.tfvars` :
       ```hcl
       pm_password = "ton_mot_de_passe"
       ```
   - Alternativement, utiliser une variable d'environnement :
     ```bash
     export PM_PASSWORD="ton_mot_de_passe"
     ```

3. **Tester la connexion** :
   - Créer une ressource simple pour tester que Terraform peut interagir avec le cluster :
     ```hcl
     resource "proxmox_vm_qemu" "test_vm" {
       name       = "vm-test"
       target_node = "node1"
       clone      = "template-base"
       cores      = 2
       memory     = 2048
       disk {
         size = "10G"
       }
       network {
         model  = "virtio"
         bridge = "vmbr0"
       }
     }
     ```
   - Exécuter la commande `terraform plan` pour vérifier la communication avec le cluster.

---

### **Gestion de l'état Terraform**

1. **État local (par défaut)** :
   - Terraform stocke son état dans un fichier local nommé `terraform.tfstate` situé dans le répertoire courant. Ce fichier contient des informations sur les ressources créées et leur état actuel.
   - Exemple de configuration sans backend :
     ```hcl
     terraform {
       required_providers {
         proxmox = {
           source = "Telmate/proxmox"
         }
       }
     }
     ```

2. **Backend distant (recommandé)** :
   - Pour des projets collaboratifs ou des environnements complexes, il est conseillé d'utiliser un backend distant pour stocker l'état de manière sécurisée et partagée.
   - Exemple de configuration pour un backend local sur un partage NFS :
     ```hcl
     terraform {
       backend "local" {
         path = "/chemin/vers/le/partage/terraform.tfstate"
       }
     }
     ```
   - Ajouter la configuration du backend dans le fichier principal Terraform (`main.tf`) et exécuter `terraform init` pour reconfigurer le projet avec le nouveau backend.

3. **Bonnes pratiques avec l'état Terraform** :
   - **Sauvegarde** : Assure-toi de sauvegarder régulièrement le fichier `terraform.tfstate` si tu utilises un état local.
   - **Gestion sécurisée** : Ne jamais partager directement le fichier `terraform.tfstate` car il peut contenir des informations sensibles (ex. mots de passe).
   - **Verrouillage automatique** : Si tu utilises un backend distant, le verrouillage automatique est activé pour éviter des modifications simultanées.

---

### **Configurer les accès réseau**

1. **Vérifier la connectivité réseau** :
   - S'assurer que le conteneur LXC peut communiquer avec le cluster Proxmox :
     - Le port **8006** (utilisé par l’API de Proxmox) doit être accessible depuis ton conteneur.
     - Tester la connectivité avec une commande `curl` ou `ping` :
       ```bash
       curl -k https://<IP_DU_CLUSTER>:8006/api2/json
       ```
       Si tout fonctionne, une réponse JSON devrait être reçue.

2. **Configurer les permissions dans Proxmox** :
   - Aller dans **Datacenter > Permissions > API Tokens** sur ton interface Proxmox.
   - Créer un token spécifique pour Terraform avec des droits limités mais suffisants pour tes besoins.
   - Noter les informations du token (utilisateur et clé d'API) et les utiliser dans ta configuration Terraform.

3. **Configuration d'un utilisateur Terraform dédié (optionnel)** :
   - Pour plus de sécurité, créer un utilisateur dédié à Terraform avec des permissions spécifiques dans Proxmox.

4. **Paramètres TLS** :
   - Si le cluster Proxmox n'a pas de certificat SSL valide, désactiver temporairement la vérification TLS dans ta configuration Terraform avec :
     ```hcl
     pm_tls_insecure = true
     ```
   - Toutefois, il est recommandé de configurer un certificat SSL valide pour sécuriser les communications.

5. **Tester les permissions** :
   - Tester la connexion en exécutant une commande `terraform plan` sur une ressource simple pour vérifier que Terraform peut communiquer avec l'API et dispose des droits nécessaires.

6. **Surveiller les logs pour déboguer** :
   - Si des erreurs surviennent, activer les logs détaillés de Terraform avec :
     ```bash
     TF_LOG=DEBUG terraform plan
     ```
   - Vérifier les journaux de Proxmox dans `/var/log/syslog` pour identifier des erreurs d’accès ou de permissions.
