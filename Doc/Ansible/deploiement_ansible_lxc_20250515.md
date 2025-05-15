
# 🚀 Déploiement d’un environnement Ansible sur un conteneur LXC Debian 12

## 🌐 Tableau de l’infrastructure utilisée

| Nom de machine        | Adresse IP       | Rôle / Utilisation                          |
|-----------------------|------------------|---------------------------------------------|
| SRV-DEB-LXCANSIBLE    | 10.108.0.150     | Machine de contrôle Ansible (LXC)           |
| SRV-DEB12             | 10.108.0.151     | Machine cible Debian 12 (VM)                |

## 🧾 Objectif
Ce guide décrit étape par étape l'installation et la configuration d'Ansible sur un conteneur LXC Debian 12,
ainsi que la configuration d'une machine Debian distante (VM) pour être gérée via Ansible. Chaque commande est accompagnée d'explications détaillées.

---

# 🖥️ 0. Création de la machine cible Debian 12 (VM)

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

# 🧱 1. Création du conteneur LXC Debian 12 (Machine de contrôle Ansible)

### 🎯 Objectif :
Créer le poste de contrôle qui exécutera les commandes Ansible.

**À faire sur Proxmox :**
- Créer un LXC Debian 12 avec IP statique `10.108.0.150`
- Accès SSH root
- Nom : `SRV-DEB-LXCANSIBLE`

---

# 🛠️ 2. Préparation du LXC Ansible

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

# 🔐 3. Génération et déploiement de la clé SSH

### 🎯 Objectif :
Permettre à la machine de contrôle d’accéder à la machine cible sans mot de passe.

### 🧑‍💻 Sur le LXC, connecté en tant qu’utilisateur `ansible` :

```bash
ssh-keygen -t ed25519
ssh-copy-id ansible@10.108.0.151
```

---

## 📁 4. Création du fichier d’inventaire Ansible

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
localhost | SUCCESS => { "ping": "pong" }
SRV-DEB12 | SUCCESS => { "ping": "pong" }
```

---

## 📦 Créer et lancer un premier playbook Ansible

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

```bash
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

## 📸 Captures de vérification 

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
  <img src="./td5_htop_screen.png" alt="htop" style="width: 800px;" />
</p>

---

## 🧪 Écrire un playbook Ansible simple

### 📁 Structure du projet

```bash
mkdir -p ~/ansible/td6/files
cd ~/ansible/td6
nano playbook.yaml
```

### 📄 Contenu du fichier `playbook.yaml`

```yaml
- name: Installation de cmatrix et creation d'un utilisateur
  hosts: SRV-DEB12
  remote_user: ansible
  become: yes
  become_method: sudo

  tasks:
    - name: Installer le paquet cmatrix
      ansible.builtin.apt:
        name: cmatrix
        state: present

    - name: Creer l'utilisateur loic_stagiaire
      ansible.builtin.user:
        name: loic_stagiaire
        shell: /bin/bash
        create_home: yes
```

### ▶️ Exécution du playbook

```bash
ansible-playbook -i ~/ansible/inventory.ini playbook.yaml
```

---

### ✅ Résultat dans le terminal

<p align="center">
  <img src="./td6_execution_playbook.png" style="width: 800px;" />
</p>

---

### 🔍 Vérification sur la machine cible Debian

```bash
which cmatrix
getent passwd loic_stagiaire
```

### ✅ Résultat de la vérification

<p align="center">
  <img src="./td6_verification_cm_loic.png" style="width: 800px;" />
</p>

---

## 🧪  Écrire un playbook Ansible simple

Ce playbook Ansible réalise deux tâches :
1. Installe le paquet `cmatrix`
2. Crée un utilisateur `loic_stagiaire` avec un shell `/bin/bash` et un répertoire personnel

---

### 📁 Structure du projet

```bash
mkdir -p ~/ansible/td6/files
cd ~/ansible/td6
nano playbook.yaml
```

---

### 📄 Contenu du fichier `playbook.yaml`

```yaml
- name: Installation de cmatrix et creation d'un utilisateur
  hosts: SRV-DEB12
  remote_user: ansible
  become: yes
  become_method: sudo

  tasks:
    - name: Installer le paquet cmatrix
      ansible.builtin.apt:
        name: cmatrix
        state: present

    - name: Creer l'utilisateur loic_stagiaire
      ansible.builtin.user:
        name: loic_stagiaire
        shell: /bin/bash
        create_home: yes
```

---

### 🧠 Explication ligne par ligne du playbook

```yaml
- name: Installation de cmatrix et creation d'un utilisateur
```
- Définit le début d’un **play**.
- Ce `name` est purement descriptif et apparaîtra dans les logs d'exécution.

```yaml
  hosts: SRV-DEB12
```
- Spécifie la **machine cible**.
- `SRV-DEB12` correspond à un alias défini dans `inventory.ini`.

```yaml
  remote_user: ansible
```
- Indique que la connexion SSH se fera avec l'utilisateur `ansible`.

```yaml
  become: yes
  become_method: sudo
```
- Permet d'exécuter les tâches avec les droits administrateur (via `sudo`).
- `become_method` est précisé pour clarté, bien que ce soit la valeur par défaut.

---

### 🔧 Tâche 1 – Installation de cmatrix

```yaml
    - name: Installer le paquet cmatrix
      ansible.builtin.apt:
        name: cmatrix
        state: present
```
- `ansible.builtin.apt` utilise le gestionnaire de paquets Debian.
- `state: present` : installe `cmatrix` uniquement s’il n’est pas déjà installé (**idempotence**).

---

### 👤 Tâche 2 – Création de l'utilisateur loic_stagiaire

```yaml
    - name: Creer l'utilisateur loic_stagiaire
      ansible.builtin.user:
        name: loic_stagiaire
        shell: /bin/bash
        create_home: yes
```
- `ansible.builtin.user` gère les comptes locaux.
- `name`: nom du compte à créer.
- `shell`: définit le shell par défaut.
- `create_home`: crée automatiquement `/home/loic_stagiaire` s’il n’existe pas.

---

### ▶️ Exécution du playbook

```bash
ansible-playbook -i ~/ansible/inventory.ini playbook.yaml
```

---

### ✅ Résultat dans le terminal

<p align="center">
  <img src="./td6_execution_playbook.png" alt="Execution playbook TD6" style="width: 800px;" />
</p>

---

### 🔍 Vérification sur la machine cible Debian

```bash
which cmatrix
getent passwd loic_stagiaire
```

---

### ✅ Résultat de la vérification

<p align="center">
  <img src="./td6_verification_cm_loic.png" alt="Verification cmatrix et utilisateur loic_stagiaire" style="width: 800px;" />
</p>

---

# 📚– Découverte des rôles Ansible (version enrichie)


Structurer ses automatisations Ansible de manière modulaire, maintenable, réutilisable grâce aux **rôles Ansible**.

Quand les playbooks deviennent longs, il devient difficile de les lire, maintenir et faire évoluer.  
➡️ La solution : **organiser les tâches par fonctionnalité** dans des rôles distincts.

---

## 🧠 Pourquoi utiliser des rôles dans Ansible ?

| Avantage            | Description                                                                 |
|---------------------|---------------------------------------------------------------------------------|
| ✅ **Modularité**    | Chaque rôle s’occupe d’un aspect précis (ex : users, apache, monitoring…)      |
| 🔁 **Réutilisabilité** | Un rôle peut être réutilisé dans plusieurs projets ou sur plusieurs hôtes      |
| 🧼 **Lisibilité**     | On évite les playbooks de 200 lignes. Tout est rangé dans des dossiers clairs. |
| 🔒 **Maintenabilité** | Corriger ou enrichir une fonctionnalité n’impacte pas les autres               |
| 🌐 **Interopérabilité** | Les rôles sont partageables sur Ansible Galaxy                                 |

> 💡 Source : [Playbook Best Practices – Ansible Docs](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

---

## 📁 Structure standard d’un rôle

Quand tu crées un rôle avec :

```bash
ansible-galaxy init mon_role
```

Ansible génère :

```plaintext
mon_role/
├── defaults/          # Variables par défaut
├── files/             # Fichiers statiques
├── handlers/          # Déclencheurs (ex : restart nginx)
├── meta/              # Infos dépendances du rôle
├── tasks/             # Tâches principales (main.yml)
├── templates/         # Modèles Jinja2
├── tests/             # Fichiers de test facultatifs
└── vars/              # Variables prioritaires (non surchargeables)
```

> 📌 `defaults/` est recommandé pour les variables configurables, tandis que `vars/` est prioritaire mais non surchargé.

---

## 🛠 Exemple minimal d’utilisation d’un rôle dans un playbook

```yaml
- name: Déploiement base + utilisateurs
  hosts: SRV-DEB12
  become: yes

  roles:
    - role: base
    - role: users
```

Ce playbook exécute les tâches dans :

- `roles/base/tasks/main.yml`
- puis `roles/users/tasks/main.yml`

Cela permet d’avoir un **playbook principal clair et maintenable**.

---

## 📦 Où trouver ou partager des rôles ?

- 🌐 Ansible Galaxy : [galaxy.ansible.com](https://galaxy.ansible.com)
- 🔍 Exemples :
  - [geerlingguy.apache](https://galaxy.ansible.com/geerlingguy/apache)
  - [dev-sec.ssh-hardening](https://galaxy.ansible.com/dev-sec/ssh-hardening)

---

## 📚 Ressources complémentaires

- 📘 [Documentation officielle des rôles Ansible](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html)
- 🧠 [Best Practices – Ansible Docs](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- ✍️ [Blog de Stéphane Robert – Écrire des rôles Ansible](https://blog.stephane-robert.info/docs/infra-as-code/gestion-de-configuration/ansible/ecrire-roles/)

---

## 🧾 À retenir

Un rôle Ansible est un **module autonome et structuré**, contenant :
- des tâches (dans `tasks/main.yml`)
- des fichiers statiques (`files/`)
- des modèles (`templates/`)
- des variables (`defaults/`, `vars/`)
- des handlers (`handlers/`)

👉 C’est la **méthode recommandée** pour gérer des projets professionnels avec Ansible.

---
