Installation de Apache GUACAMOLE en DOCKER sur Debian 12

Cahier des charges :

Nous avons besoin d'un outils de BASTION pour facilité l'administration de nos serveur
il sera installer sur un DOCKER installer sur DEBIAN12
Pour gerer docker nous utiliseront PORTAINER.

Option demandé:
TOTP
Enregistrement des sessions pour les préstataire externe.

Etape 1 :

Sur une VM debian 12 à jour :

Afin d'installer DOCKER ainsi que portainer j'ai creer un script qui automatise l'installation des 2 services :

```bash

#!/bin/bash
# Shebang. Il indique au système d'exploitation que ce script doit être exécuté avec /bin/bash.

# Vérifier que le script est exécuté avec les privilèges root
if [ "$EUID" -ne 0 ]; then
  echo "Veuillez exécuter ce script en tant que root ou avec sudo."
  exit 1
fi

# Arrêter l'exécution du script en cas d'erreur
set -e

# Mettre à jour le système
apt-get update && apt-get upgrade -y

# Installer les paquets nécessaires pour permettre à apt d'utiliser un dépôt sur HTTPS
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common

# Ajouter la clé officielle de Docker GPG
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

# Ajouter le dépôt Docker à la liste des sources APT
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/debian \
  $(lsb_release -cs) \
  stable"

# Mettre à jour l'index des paquets APT
apt-get update

# Installer la dernière version de Docker Engine et containerd
apt-get install -y docker-ce docker-ce-cli containerd.io

# Vérifier que Docker est bien installé en démarrant le service et en l'exécutant au démarrage
systemctl start docker
systemctl enable docker

# Installer Portainer (en utilisant Docker)
docker volume create portainer_data

docker run -d -p 9000:9000 --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data portainer/portainer-ce

# Afficher le message de fin
echo "Installation de Docker et Portainer terminée."
echo "Vous pouvez accéder à Portainer en ouvrant http://<Votre_IP>:9000 dans un navigateur."


```

Pour utiliser ce script :
Ouvrir un éditeur de texte (comme nano ou vim) sur le serveur Debian.
Copiez et collez le contenu du script ci-dessus dans l'éditeur.
Enregistrer le fichier sous un nom significatif, par exemple install-docker-portainer.sh.
Rendre le script exécutable en exécutant la commande chmod +x install-docker-portainer.sh dans le terminal.
Exécuter le script en utilisant la commande ./install-docker-portainer.sh ou sudo ./install-docker-portainer.sh si vous n'êtes pas root.
Remplacer <Votre_IP> par l'adresse IP réelle de votre serveur Debian lorsque vous essayez d'accéder à Portainer via un navigateur web.

