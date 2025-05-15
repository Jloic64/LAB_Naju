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
usermod -aG sudo ansible
apt install -y sudo
echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible
```

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
apt install -y openssh-server sudo
adduser ansible
usermod -aG sudo ansible
echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible
```

---

## 🔐 3. Génération et déploiement de la clé SSH

### 🎯 Objectif :
Permettre à la machine de contrôle d’accéder à la machine cible sans mot de passe.

### 🧑‍💻 Sur le LXC, connecté en tant qu’utilisateur `ansible` :

```bash
ssh-keygen -t ed25519
ssh-copy-id ansible@10.108.0.151
```

---

## 📁 4. Création du fichier d’inventaire Ansible

### 📂 Sur le LXC, toujours avec l'utilisateur `ansible` :

```bash
mkdir -p ~/ansible
cd ~/ansible
nano inventory.ini
```

### 📝 Contenu du fichier `inventory.ini` :
```ini
[local]
localhost ansible_connection=local

[debian]
SRV-DEB12 ansible_host=10.108.0.151 ansible_user=ansible
```

---

## 🧪 5. Test de connectivité avec le module `ping`

```bash
ansible all -i ~/ansible/inventory.ini -m ping
```

Résultat attendu :
```json
localhost | SUCCESS => {
    "ping": "pong"
}
SRV-DEB12 | SUCCESS => {
    "ping": "pong"
}
```

---

## 📦 TD 5 – Créer et lancer un premier playbook Ansible

### 📁 Structure

```bash
mkdir -p ~/ansible/projet-1/files
cd ~/ansible/projet-1
```

### ✍️ Contenu du fichier `setup.yaml`

```yaml
- name: Installation de base et creation d'utilisateur
  hosts: SRV-DEB12
  remote_user: ansible
  become: yes
  become_method: sudo

  tasks:
    - name: Installer le paquet htop
      ansible.builtin.apt:
        name: htop
        state: present

    - name: Creer l'utilisateur loic_adm
      ansible.builtin.user:
        name: loic_adm
        shell: /bin/bash
        create_home: yes

    - name: Autoriser la cle SSH pour loic_adm
      ansible.posix.authorized_key:
        user: loic_adm
        state: present
        manage_dir: yes
        key: "{{ lookup('file', 'files/id_rsa.pub') }}"
```

### 🔐 Clé SSH publique à placer dans :

```
~/ansible/projet-1/files/id_rsa.pub
```

Utiliser :
```bash
cat ~/.ssh/id_ed25519.pub > ~/ansible/projet-1/files/id_rsa.pub
```

### ▶️ Exécution du playbook :

```bash
ansible-playbook -i ~/ansible/inventory.ini setup.yaml
```

---

## 📸 Résultats (captures)

---

## 📸 Captures de vérification du TD 5

### ✅ Résultat de l'exécution du playbook
<p align="center">
  <img src="./td5_execution_playbook.png"  style="width: 800px;" />
</p>

---

### 👤 Vérification de l'utilisateur `loic_adm` et du paquet `htop`
<p align="center">
  <img src="./td5_verification_user_htop.png"  style="width: 800px;" />
</p>

---

### 📊 Affichage de `htop` en temps réel
<p align="center">
  <img src=".\td5_htop_screen.png" alt="htop" style="width: 800px;" />
</p>

---