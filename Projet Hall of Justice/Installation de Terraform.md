# Installation de TERRAFORM dans un conteneur LXC Debian12

### Étape 1 : Création du conteneur LXC sous Debian 12

#### Télécharger le template Debian 12 (si ce n'est pas déjà fait) :
```bash
pveam update
pveam available | grep debian-12
pveam download local debian-12-standard_12-*.tar.zst
```
### Créer le conteneur LXC

Remplace `<ID>` par un numéro d'identification unique pour le conteneur, et `<Nom>` par un nom significatif.

```bash
pct create <ID> local:vztmpl/debian-12-standard_12-*.tar.zst --hostname <Nom> --storage local-lvm --rootfs 8 --memory 1024 --cores 2 --net0 name=eth0,bridge=vmbr0,ip=dhcp
```

- `--rootfs 8` : Assigne 8 Go d'espace disque.
- `--memory 1024` : Assigne 1 Go de RAM.
- `--cores 2` : Assigne 2 cœurs de processeur.
- `--net0` : Configure une interface réseau avec une adresse IP obtenue via DHCP.

### Démarrer le conteneur :

```bash
pct start <ID>
```

### Étape 2 : Configuration initiale dans le conteneur

#### Mettre à jour le conteneur :
```bash
apt update && apt upgrade -y
```

### Installer les outils nécessaires : 
```bash
apt install -y wget unzip
```
### Étape 3 : Installation de Terraform

#### Télécharger la version la plus récente de Terraform : Remplace <VERSION> par la version que tu veux installer (par exemple, 1.6.0).
```bash
 wget https://releases.hashicorp.com/terraform/<VERSION>/terraform_<VERSION>_linux_amd64.zip
```
#### Décompresser l'archive :
``` bash
unzip terraform_<VERSION>_linux_amd64.zip
```
#### Déplacer l'exécutable dans /usr/local/bin :
```bash
mv terraform /usr/local/bin/
```
#### Vérifier l'installation :
``` bash
terraform --version
```
