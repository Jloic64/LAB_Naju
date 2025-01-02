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

### ** Configurer le fichier de connexion au cluster Proxmox**

1. **Paramètres nécessaires** :
   - **URL de l'API** : Normalement, `https://<IP_DU_CLUSTER>:8006/api2/json`.
   - **Utilisateur** : Utilise un utilisateur avec les droits nécessaires, comme `root@pam`.
   - **Mot de passe** : Celui de l’utilisateur.
   - **TLS Insecure** : Si tu n’as pas encore configuré de certificat SSL, tu peux désactiver la vérification TLS avec `pm_tls_insecure = true`.

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
   - Ajouter une ressource simple pour tester que Terraform peut interagir avec le cluster :
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
   - Exécuter `terraform plan` pour voir si Terraform parvient à générer un plan de déploiement.

### ** Tester la connexion**

1. **Commande Terraform init** :
   - Lancer `terraform init` dans le répertoire de travail pour initialiser le projet et vérifier que le provider est correctement configuré.

2. **Validation de la connexion** :
   - Ajouter une ressource simple, comme une machine virtuelle (VM), pour tester que Terraform peut interagir avec le cluster :
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
   - Exécuter la commande suivante pour générer un plan d'exécution :
     ```bash
     terraform plan
     ```
     Cela permet de vérifier si Terraform est capable de communiquer avec le cluster et de préparer une infrastructure.

3. **Appliquer les modifications** :
   - Si le plan est valide, exécuter :
     ```bash
     terraform apply
     ```
     Cela déploiera la machine virtuelle ou toute autre ressource définie dans le fichier de configuration.

4. **Vérifier le résultat** :
   - Se Connecter à l'interface Proxmox pour vérifier que la ressource (par exemple, la VM) a bien été créée.

### ** Gestion de l'état Terraform**

1. **Par défaut : État local**  
   - Par défaut, Terraform stocke son état dans un fichier local nommé `terraform.tfstate` situé dans le répertoire courant. Ce fichier contient des informations détaillées sur les ressources créées et leur état actuel.
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

2. **Recommandé : Backend distant**  
   - Pour des projets collaboratifs ou des environnements complexes, il est conseillé d'utiliser un backend distant pour stocker l'état de manière sécurisée et partagée.
   - Les options de backend incluent des systèmes comme :
     - **NFS** : Un partage réseau accessible depuis le conteneur LXC.
     - **Consul** : Pour les environnements plus dynamiques.
   - Exemple de configuration pour un backend local sur un partage NFS :
     ```hcl
     terraform {
       backend "local" {
         path = "/chemin/vers/le/partage/terraform.tfstate"
       }
     }
     ```
     Cela garantit que l'état est partagé entre plusieurs sessions Terraform et accessible depuis différents utilisateurs ou machines.

3. **Configurer le backend** :
   - Ajouter la configuration du backend dans le fichier principal Terraform (`main.tf`).
   - Exécuter la commande `terraform init` pour reconfigurer le projet avec le nouveau backend :
     ```bash
     terraform init
     ```

4. **Bonnes pratiques avec l'état Terraform** :
   - **Sauvegarde** : Si tu utilises un fichier `terraform.tfstate` local, assure-toi qu’il est sauvegardé régulièrement.
   - **Gestion sécurisée** : Ne jamais partager directement le fichier `terraform.tfstate` car il peut contenir des données sensibles (comme des mots de passe).
   - **Utilisation avec un backend distant** : Permet un verrouillage automatique pour éviter des modifications simultanées par plusieurs utilisateurs.

### ** Configurer les accès réseau**

1. **Vérifier la connectivité réseau** :
   - S'assurer que le conteneur LXC peut communiquer avec le cluster Proxmox :
     - Le port **8006** (utilisé par l’API de Proxmox) doit être accessible depuis ton conteneur.
     - Tester la connectivité avec une commande `curl` ou `ping` :
       ```bash
       curl -k https://<IP_DU_CLUSTER>:8006/api2/json
       ```
       Si tout fonctionne, on devrait recevoir une réponse JSON.

2. **Configurer les permissions dans Proxmox** :
   - Aller dans **Datacenter > Permissions > API Tokens** sur ton interface Proxmox.
   - Crée un token spécifique pour Terraform avec des droits limités mais suffisants pour tes besoins :
     - Exemple de rôles à assigner : `Datastore.AllocateSpace`, `VM.Allocate`, `VM.Config.Disk`, `VM.Config.Network`.
   - Noter les informations du token (utilisateur et clé d'API) et utilise-les dans ta configuration Terraform.

3. **Configuration d'un utilisateur Terraform dédié (optionnel)** :
   - Pour plus de sécurité, créer un utilisateur dédié à Terraform avec des permissions spécifiques :
     1. Aller dans **Datacenter > Permissions > Users** et ajouter un nouvel utilisateur.
     2. Créer un rôle personnalisé dans **Datacenter > Permissions > Roles**.
     3. Associer ce rôle et cet utilisateur à un chemin précis dans la hiérarchie des ressources (par exemple, à un datacenter spécifique).

4. **Paramètres TLS** :
   - Si il y a pas de certificat SSL valide sur le cluster Proxmox, désactiver temporairement la vérification TLS dans ta configuration Terraform avec :
     ```hcl
     pm_tls_insecure = true
     ```
   - Cependant, il est recommandé de configurer un certificat SSL valide pour sécuriser les communications. 
   - 
5. **Tester les permissions** :
   - Après avoir configuré les accès, teste en exécutant une commande `terraform plan` sur une ressource simple pour vérifier que Terraform peut communiquer avec l'API et dispose des droits nécessaires.

6. **Surveiller les logs pour déboguer** :
   - Si des erreurs surviennent, activer les logs détaillés de Terraform pour diagnostiquer les problèmes :
     ```bash
     TF_LOG=DEBUG terraform plan
     ```
   - Vérifier également les journaux de Proxmox dans `/var/log/syslog` pour identifier des erreurs d’accès ou de permissions.
