# 🚀 Déploiement d’un environnement Ansible sur un conteneur LXC Debian 12

## 🧾 Objectif
Ce guide décrit étape par étape l'installation et la configuration d'Ansible sur un conteneur LXC Debian 12,
ainsi que la configuration d'une machine Debian distante (VM) pour être gérée via Ansible. Chaque commande est accompagnée d'explications détaillées.

---

## 🖥️ 0. Création de la machine cible Debian 12 (VM)

### 🎯 Objectif :
Préparer une machine distante que le LXC Ansible pourra gérer via SSH.

### ⚙️ Étapes :
**À faire depuis Proxmox :**
- Créer une VM Debian 12 avec IP statique `10.108.0.151`
- Activer SSH
- Créer un utilisateur `ansible`

### 🔧 Commandes à exécuter (sur la VM, connecté en root) :
```bash
adduser ansible
```
> Crée l'utilisateur `ansible` avec son répertoire personnel et te demande de définir un mot de passe.

```bash
usermod -aG sudo ansible
```
> Ajoute l'utilisateur `ansible` au groupe `sudo`, lui permettant d'utiliser `sudo` pour les commandes administratives.

```bash
apt install -y sudo
```
> Si `sudo` n’est pas encore installé.

```bash
echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible
```
> Permet à `ansible` d’utiliser `sudo` sans mot de passe.

---

## 🧱 1. Création du conteneur LXC Debian 12 (Machine de contrôle Ansible)

### 🎯 Objectif :
Créer le poste de contrôle qui exécutera les commandes Ansible.

**À faire sur Proxmox :**
- Créer un LXC Debian 12 avec IP statique `10.108.0.150`
- Accès SSH root
- Nom : `SRV-DEB-LXCANSIBLE`

---

## 🛠️ 2. Préparation du LXC Ansible

### 🔧 Étapes à réaliser connecté en root :

```bash
apt update
```
> Met à jour la liste des paquets disponibles.

```bash
apt install -y openssh-server sudo
```
> Installe le serveur SSH et sudo sur le conteneur.

```bash
adduser ansible
usermod -aG sudo ansible
```
> Crée l’utilisateur `ansible` et lui accorde les droits administratifs.

```bash
echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible
```
> Permet à l'utilisateur `ansible` d'exécuter `sudo` sans saisie de mot de passe.

---

## 🔐 3. Génération et déploiement de la clé SSH

### 🎯 Objectif :
Permettre à la machine de contrôle d’accéder à la machine cible sans mot de passe.

### 🧑‍💻 Sur le LXC, connecté en tant qu’utilisateur `ansible` :

```bash
ssh-keygen -t ed25519
```
> Génère une paire de clés SSH (privée/publique). Appuie sur Entrée pour tous les choix.

```bash
ssh-copy-id ansible@10.108.0.151
```
> Copie la clé publique vers la machine cible dans `/home/ansible/.ssh/authorized_keys`.

---

## 📁 4. Création du fichier d’inventaire Ansible

### 📂 Sur le LXC, toujours avec l'utilisateur `ansible` :

```bash
mkdir -p ~/ansible
cd ~/ansible
nano inventory.ini
```
> Crée un dossier pour stocker les fichiers Ansible et ouvre le fichier d’inventaire.

### 📝 Contenu du fichier `inventory.ini` :
```ini
[local]
localhost ansible_connection=local

[debian]
SRV-DEB12 ansible_host=10.108.0.151 ansible_user=ansible
```
> `ansible_connection=local` indique d’exécuter les commandes en local pour `localhost`.  
> `ansible_host` spécifie l’IP de la machine cible et `ansible_user` l’utilisateur utilisé pour la connexion SSH.

---

## 🧪 5. Test de connectivité avec le module `ping`

```bash
ansible all -i ~/ansible/inventory.ini -m ping
```
> Envoie une commande `ping` à toutes les machines définies dans l'inventaire.  
> Résultat attendu :
```json
localhost | SUCCESS => {
    "ping": "pong"
}
SRV-DEB12 | SUCCESS => {
    "ping": "pong"
}
```

---

Ton environnement Ansible est prêt à exécuter des playbooks sur ta machine Debian distante.
