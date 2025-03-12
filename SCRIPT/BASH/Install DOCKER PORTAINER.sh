# Script qui installe Docker et Portainer sur Debian 12
### Ce script se compose de plusieurs commandes que vous exécuterez en tant qu'utilisateur root ou en utilisant sudo pour les privilèges d'administration. 


#Ouvrir un éditeur de texte (comme nano ou vim) sur le serveur Debian.
#Copiez et collez le contenu du script ci-dessus dans l'éditeur.
#Enregistrer le fichier sous un nom significatif, par exemple install-docker-portainer.sh.
#Rendre le script exécutable en exécutant la commande chmod +x install-docker-portainer.sh dans le terminal.
#Exécuter le script en utilisant la commande ./install-docker-portainer.sh ou sudo ./install-docker-portainer.sh si vous n'êtes pas root.
#Remplacer <Votre_IP> par l'adresse IP réelle de votre serveur Debian lorsque vous essayez d'accéder à Portainer via un navigateur web.
#


#!/bin/bash
# Shebang. Il indique au système d'exploitation que ce script doit être exécuté avec /bin/bash.

# Mettre à jour le système
apt-get update

# Met à jour la liste des paquets disponibles à partir des dépôts configurés sur le système.
apt-get upgrade -y

# Met à jour tous les paquets installés sur le système. L'option -y permet de répondre automatiquement "oui" à toutes les questions posées par apt-get.
# Installer les paquets nécessaires pour permettre à apt d'utiliser un dépôt sur HTTPS
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
# Installe plusieurs paquets nécessaires pour ajouter un dépôt sur HTTPS à la liste des sources APT.
# Ajouter la clé officielle de Docker GPG
curl -fsSL https://download.docker.com/linux/debian/gpg |  apt-key add -

# Télécharge la clé GPG officielle de Docker et l'ajoute à la liste des clés de confiance d'APT.
# Ajouter le dépôt Docker à la liste des sources APT
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

# Ajoute le dépôt Docker à la liste des sources APT.
# Mettre à jour l'index des paquets APT
apt-get update

# Met à jour la liste des paquets disponibles à partir des dépôts configurés sur le système.
# Installer la dernière version de Docker Engine et containerd
apt-get install -y docker-ce docker-ce-cli containerd.io

# Vérifier que Docker est bien installé en démarrant le service et en l'exécutant au démarrage
systemctl start docker
systemctl enable docker

# Configure le service Docker pour qu'il démarre automatiquement au démarrage du système.
# Installer Portainer (en utilisant Docker)
docker volume create portainer_data

# Cette commande crée un volume Docker pour stocker les données de Portainer.
docker run -d -p 9000:9000 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data portainer/portainer-ce

# Cette commande lance un conteneur Portainer.
# Afficher le message de fin
echo "Installation de Docker et Portainer terminée."

# Cette commande affiche un message indiquant que l'installation est terminée.
echo "Vous pouvez accéder à Portainer en ouvrant http://<Votre_IP>:9000 dans un navigateur."
# Cette commande indique à l'utilisateur comment accéder à Portainer.

```