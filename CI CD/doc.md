# 📘 Guide de déploiement GitLab Runner avec Docker distant via SSH
## 🧭 Table des matières

- [📘 Guide de déploiement GitLab Runner avec Docker distant via SSH](#📘-guide-de-déploiement-gitlab-runner-avec-docker-distant-via-ssh)
  - [🧭 PRÉAMBULE : Pourquoi structurer son projet avec des branches ?](#🧭-préambule--pourquoi-structurer-son-projet-avec-des-branches-?)
    - [Avantages de cette structure :](#avantages-de-cette-structure-)
  - [🔎 Comprendre l'architecture de notre déploiement](#🔎-comprendre-l'architecture-de-notre-déploiement)
  - [🧱 PRÉREQUIS](#🧱-prérequis)
- [🔢 ÉTAPES DÉTAILLÉES](#🔢-étapes-détaillées)
  - [1️⃣ Création des utilisateurs dédiés](#1️⃣-création-des-utilisateurs-dédiés)
  - [2️⃣ Configuration de l'authentification SSH par clé](#2️⃣-configuration-de-l'authentification-ssh-par-clé)
  - [3️⃣ Installation et configuration de Docker sur `docker-host`](#3️⃣-installation-et-configuration-de-docker-sur-`docker-host`)
  - [4️⃣ Installation de GitLab Runner sur `runner-host`](#4️⃣-installation-de-gitlab-runner-sur-`runner-host`)
  - [5️⃣ Enregistrement du Runner auprès de GitLab](#5️⃣-enregistrement-du-runner-auprès-de-gitlab)
  - [6️⃣ Préparation des environnements de déploiement](#6️⃣-préparation-des-environnements-de-déploiement)
  - [7️⃣ Initialisation du dépôt Git local](#7️⃣-initialisation-du-dépôt-git-local)
  - [8️⃣ Création de la branche de développement](#8️⃣-création-de-la-branche-de-développement)
  - [9️⃣ Mise en place d'un cycle de développement](#9️⃣-mise-en-place-d'un-cycle-de-développement)
  - [🔟 Configuration du pipeline CI/CD avec .gitlab-ci.yml](#🔟-configuration-du-pipeline-ci/cd-avec-.gitlab-ci.yml)
  - [1️⃣1️⃣ Configuration des variables d'environnement CI/CD](#1️⃣1️⃣-configuration-des-variables-d'environnement-ci/cd)
  - [1️⃣2️⃣ Déploiement en production (fusion vers main)](#1️⃣2️⃣-déploiement-en-production-(fusion-vers-main))
- [🧪 Problèmes rencontrés et solutions](#🧪-problèmes-rencontrés-et-solutions)
 
- [🚀 Bonnes pratiques pour le travail collaboratif avec Git et CI/CD](#🚀-bonnes-pratiques-pour-le-travail-collaboratif-avec-git-et-ci/cd)
- [📚 Explication des concepts clés](#📚-explication-des-concepts-clés)
- [🗓️ Plan de maintenance recommandé](#🗓️-plan-de-maintenance-recommandé)
- [🔄 Procédure de récupération en cas de problème](#🔄-procédure-de-récupération-en-cas-de-problème)

## 🧭 PRÉAMBULE : Pourquoi structurer son projet avec des branches ?

L'organisation du projet avec plusieurs branches Git permet une gestion propre et professionnelle du code. Voici pourquoi c'est important et comment ça fonctionne :

- **main** : C'est votre branche de production, considérée comme "sacrée". Elle contient uniquement du code validé, testé et prêt à être mis en production. Personne ne devrait y pousser directement du code.

- **develop** : C'est votre branche de développement principal. On y intègre les nouvelles fonctionnalités une fois qu'elles sont terminées. Cette branche sert de tampon avant de passer en production.

- **feature/** : Ce sont des branches temporaires créées depuis `develop`, pour développer une fonctionnalité spécifique sans perturber le reste du code. Une fois la fonctionnalité complète, elle est fusionnée dans `develop`.

- **bugfix/** : Branches temporaires dédiées à la correction de bugs identifiés dans `develop`.

- **hotfix/** : Branches urgentes créées directement depuis `main`, pour corriger rapidement un problème critique en production. Une fois le correctif appliqué, elles sont fusionnées à la fois dans `main` et `develop`.

### Avantages de cette structure :

- **Sécurité** : Éviter les erreurs en production en validant d'abord le code dans des environnements de test
- **Collaboration** : Permettre à plusieurs développeurs de travailler simultanément sans se gêner
- **Qualité** : Favoriser l'intégration continue (CI) en testant automatiquement les modifications
- **Revue** : Faciliter les revues de code par l'équipe avant intégration

---

## 🔎 Comprendre l'architecture de notre déploiement

Pour bien comprendre ce que nous allons mettre en place, voici l'architecture complète :

| Machine                  | Rôle                                            | Docker | GitLab Runner |
|--------------------------|--------------------------------------------------|--------|----------------|
| 💻 `gitlab.techwave.lab` | Héberge GitLab, les projets et CI/CD             | ❌     | ❌             |
| 🏃 `runner-host`         | Machine dédiée au GitLab Runner                  | ❌     | ✅             |
| 🐳 `docker-host`         | Machine distante qui exécute les jobs Docker     | ✅     | ❌             |

**Pourquoi cette séparation ?**
- **Sécurité** : Isolation des différents composants
- **Performance** : Répartition de la charge sur plusieurs machines
- **Flexibilité** : Possibilité d'adapter les ressources selon les besoins

**Comment ça fonctionne :**
1. Vous poussez votre code sur GitLab
2. GitLab déclenche un pipeline CI/CD
3. Le GitLab Runner sur `runner-host` prend en charge l'exécution du pipeline
4. Le Runner se connecte via SSH à `docker-host` pour y exécuter des commandes Docker
5. Les applications sont déployées sur `docker-host`

---

## 🧱 PRÉREQUIS

Avant de commencer, assurez-vous d'avoir accès à :

- Une VM Debian 12 pour Docker (`docker-host`)
- Une VM Debian 12 pour GitLab Runner (`runner-host`)
- Une instance GitLab auto-hébergée : https://gitlab.techwave.lab
- Un projet GitLab cible : https://gitlab.techwave.lab/salle-8/runner-test-najuma.git
- Accès administrateur (root ou sudo) aux deux VMs

**Vérifiez que vous pouvez vous connecter en SSH aux deux machines et que vous avez les droits sudo.**

---

# 🔢 ÉTAPES DÉTAILLÉES

## 1️⃣ Création des utilisateurs dédiés

Nous allons créer des utilisateurs spécifiques pour chaque service, suivant le principe de sécurité du moindre privilège.

### Sur `docker-host` - Création de l'utilisateur qui exécutera les commandes Docker :

```bash
sudo useradd runner -m -s /bin/bash
sudo usermod -aG docker runner
```

**Explication :**
- `useradd runner -m -s /bin/bash` : Crée un utilisateur nommé "runner" avec son répertoire personnel (`-m`) et utilisant bash comme shell par défaut (`-s /bin/bash`)
- `usermod -aG docker runner` : Ajoute l'utilisateur "runner" au groupe "docker", ce qui lui permettra d'exécuter des commandes Docker sans sudo

### Sur `runner-host` - Création de l'utilisateur pour le service GitLab Runner :

```bash
sudo useradd gitlab-runner -m -s /bin/bash
sudo usermod -aG sudo gitlab-runner
```

**Explication :**
- Nous créons un utilisateur dédié "gitlab-runner" qui exécutera le service GitLab Runner
- Nous l'ajoutons au groupe sudo pour qu'il puisse effectuer des opérations d'administration si nécessaire

🛠️ **Remarque importante :**  
Si vous avez besoin de vous connecter avec l'utilisateur `gitlab-runner` et que la commande `su - gitlab-runner` retourne une erreur d'authentification (`Authentication failure`), c'est parce qu'aucun mot de passe n'a été défini. Vous pouvez en définir un :

```bash
sudo passwd gitlab-runner
```

### ✓ Vérifiez que les utilisateurs sont correctement créés :

```bash
# Vérifier que l'utilisateur existe
id runner        # Sur docker-host
id gitlab-runner # Sur runner-host

# Vérifier les groupes (docker pour runner, sudo pour gitlab-runner)
groups runner        # Sur docker-host, doit contenir "docker"
groups gitlab-runner # Sur runner-host, doit contenir "sudo"

# Tester la connection avec l'utilisateur gitlab-runner
su - gitlab-runner   # Sur runner-host
```

## 2️⃣ Configuration de l'authentification SSH par clé

Nous allons configurer l'authentification SSH par clé pour permettre au GitLab Runner de se connecter automatiquement au serveur Docker.

### Sur `runner-host` - Génération de la paire de clés SSH :

```bash
su - gitlab-runner    # Se connecter en tant que gitlab-runner
ssh-keygen -t ed25519 # Générer une paire de clés moderne et sécurisée
cat ~/.ssh/id_ed25519.pub   # Afficher la clé publique pour la copier
```

**Explication :**
- L'algorithme ED25519 est recommandé pour sa sécurité et ses performances
- La clé privée reste sur la machine du Runner, tandis que la clé publique sera copiée sur le serveur Docker

### Sur `docker-host` - Installation de la clé publique :

```bash
# En tant que root ou avec sudo :
sudo mkdir -p /home/runner/.ssh
sudo nano /home/runner/.ssh/authorized_keys
# ➤ Collez ici la clé publique copiée depuis le runner-host
```

**Explication :**
- Le dossier `.ssh` contiendra les configurations SSH de l'utilisateur
- Le fichier `authorized_keys` liste les clés publiques autorisées à se connecter

### Définition des permissions correctes pour la sécurité :

```bash
sudo chmod 700 /home/runner/.ssh
sudo chmod 600 /home/runner/.ssh/authorized_keys
sudo chown -R runner:runner /home/runner/.ssh
```

**Explication :**
- `chmod 700` : Seul le propriétaire peut lire, écrire et accéder au dossier
- `chmod 600` : Seul le propriétaire peut lire et écrire le fichier
- `chown -R runner:runner` : L'utilisateur et le groupe "runner" deviennent propriétaires

### ✅ Vérification de la connexion SSH

Sur `runner-host`, en tant que `gitlab-runner`, testez la connexion SSH :

```bash
ssh runner@IP_DU_DOCKER_HOST
```

Si vous vous connectez sans qu'on vous demande de mot de passe, l'authentification par clé fonctionne correctement ! Vous devriez voir apparaître le prompt du serveur Docker.

## 3️⃣ Installation et configuration de Docker sur `docker-host`

Docker est nécessaire sur la machine qui exécutera les conteneurs de notre pipeline CI/CD.

```bash
sudo apt update && sudo apt install -y docker.io
sudo systemctl enable docker && sudo systemctl start docker
sudo usermod -aG docker runner
```

**Explication :**
- `apt update` : Met à jour la liste des paquets disponibles
- `apt install -y docker.io` : Installe Docker, le `-y` répond automatiquement "oui" aux questions
- `systemctl enable docker` : Configure Docker pour démarrer automatiquement au boot
- `systemctl start docker` : Démarre le service Docker immédiatement 
- `usermod -aG docker runner` : Donne à l'utilisateur "runner" les droits d'utiliser Docker

> 🔁 **Important** : Déconnectez-vous puis reconnectez-vous (ou utilisez `newgrp docker`) pour que les changements de groupe prennent effet.

### Vérification de l'installation Docker :

```bash
# Sur docker-host, se connecter en tant que runner
su - runner

# Vérifier que Docker fonctionne et est accessible sans sudo
docker ps
```

Si la commande `docker ps` s'exécute sans erreur et affiche une liste (probablement vide) de conteneurs, Docker est correctement installé et configuré !

## 4️⃣ Installation de GitLab Runner sur `runner-host`

GitLab Runner est l'agent qui va exécuter les jobs de notre pipeline CI/CD.

```bash
# Ajout du dépôt GitLab Runner
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash

# Installation du package
sudo apt install -y gitlab-runner
```

**Explication :**
- La première commande ajoute le dépôt officiel de GitLab Runner à votre système
- La seconde installe le package gitlab-runner depuis ce dépôt

### Vérification de l'installation :

```bash
gitlab-runner --version
```

Cette commande devrait afficher la version de GitLab Runner si l'installation a réussi.

### Configuration DNS pour accéder à GitLab

Pour que le Runner puisse communiquer avec votre instance GitLab, il faut s'assurer que le nom d'hôte `gitlab.techwave.lab` est résolu correctement.

```bash
sudo nano /etc/hosts
```

Ajoutez cette ligne (adaptez l'IP si besoin) :
```
10.100.0.203 gitlab.techwave.lab
```

**Explication :**
- Cette entrée permet de faire correspondre le nom `gitlab.techwave.lab` à l'adresse IP du serveur GitLab
- C'est nécessaire si vous n'avez pas de serveur DNS configuré pour résoudre ce nom

### Vérification de la connectivité :

```bash
ping -c 3 gitlab.techwave.lab
```

Vous devriez recevoir des réponses du serveur GitLab, confirmant que la résolution de nom fonctionne.

## 5️⃣ Enregistrement du Runner auprès de GitLab

Cette étape connecte votre GitLab Runner à votre projet GitLab.

### Dans l'interface web de GitLab :

1. Connectez-vous à GitLab et accédez à votre projet : `Salle-8 / runner-test-Najuma`
2. Allez dans `Paramètres > CI/CD > Runners > Nouveau runner de projet`
3. Remplissez les informations :
   - **Description** : `runner-docker-najuma` (nom convivial pour identifier ce runner)
   - **Tags** : `ssh, docker` (permettra de cibler spécifiquement ce runner dans vos jobs)
   - **Options** : 
     - ✅ Cochez `Exécuter les jobs sans étiquette` (ce runner exécutera aussi les jobs sans tag spécifique)
     - ✅ Cochez `Protégé` (ce runner n'exécutera que les jobs des branches protégées)
     - ✅ Cochez `Limiter au projet actuel` (pour des raisons de sécurité, limiter le runner à ce projet)

4. Notez le jeton (token) qui s'affiche, vous en aurez besoin à l'étape suivante.

### Sur la machine `runner-host` :

Enregistrez le runner avec GitLab :

```bash
sudo gitlab-runner register
```

Répondez aux questions comme suit :
- **URL GitLab** : `https://gitlab.techwave.lab/`
- **Token / Jeton** : (collez le jeton copié depuis l'interface GitLab)
- **Description** : `runner-docker-najuma`
- **Tags** : `ssh,docker` (sans espace, séparés par des virgules)
- **Executor** : `ssh` (nous utiliserons SSH pour nous connecter à la machine Docker)
- **SSH user** : `runner` (l'utilisateur créé précédemment sur docker-host)
- **SSH host** : `10.108.0.102` (l'adresse IP de votre docker-host)
- **Key path** : `/home/gitlab-runner/.ssh/id_ed25519` (chemin vers la clé privée SSH)

### En cas d'erreur de certificat TLS

Si vous rencontrez cette erreur :
```
tls: failed to verify certificate: x509: certificate relies on legacy Common Name field, use SANs instead
```

C'est généralement dû à un certificat SSL auto-signé ou mal configuré. Il y a deux solutions :

#### Option 1 : Ignorer la vérification SSL lors de l'enregistrement :
```bash
sudo gitlab-runner register --tls-skip-verify --url https://gitlab.techwave.lab --token VOTRE_TOKEN_ICI
```

**Explication :** Le paramètre `--tls-skip-verify` indique au Runner d'ignorer les problèmes de certificat lors de la communication avec GitLab.

#### Option 2 : Configuration manuelle du runner :

1. Créez un fichier de configuration temporaire :
```bash
mkdir -p ~/runner-register-tmp
cd ~/runner-register-tmp
nano config.toml
```

2. Copiez-collez cette configuration (adaptez les valeurs selon votre environnement) :
```toml
[[runners]]
  name = "runner-docker-najuma"
  url = "https://gitlab.techwave.lab"
  token = "glrt-t3_Jx3AdWooQETz35Zwvrjs"
  tls_skip_verify = true
  executor = "ssh"
  [runners.ssh]
    user = "runner"
    host = "10.108.0.102"
    identity_file = "/home/gitlab-runner/.ssh/id_ed25519"
    disable_strict_host_key_checking = true
```

3. Appliquez cette configuration :
```bash
sudo cp config.toml /etc/gitlab-runner/config.toml
sudo chown gitlab-runner:gitlab-runner /etc/gitlab-runner/config.toml
sudo gitlab-runner restart
sudo gitlab-runner verify
```

**Explication :**
- `config.toml` est le fichier de configuration principal de GitLab Runner
- `chown gitlab-runner:gitlab-runner` s'assure que l'utilisateur gitlab-runner a les droits sur ce fichier
- `gitlab-runner restart` redémarre le service pour appliquer la configuration
- `gitlab-runner verify` vérifie que le runner peut communiquer avec GitLab

### Vérification de l'enregistrement :

Dans l'interface web GitLab, retournez à `Paramètres > CI/CD > Runners`. Votre runner devrait maintenant apparaître dans la liste des runners disponibles avec un point vert, indiquant qu'il est actif et connecté.

## 6️⃣ Préparation des environnements de déploiement

Nous allons créer les répertoires où seront déployées nos applications sur le serveur Docker.

```bash
# Sur docker-host, en tant que root ou avec sudo :
sudo mkdir -p /opt/app/test /opt/app/prod
sudo chmod -R 770 /opt/app
sudo chgrp -R docker /opt/app
```

**Explication :**
- `/opt/app/test` : Répertoire pour l'environnement de test (branche develop)
- `/opt/app/prod` : Répertoire pour l'environnement de production (branche main)
- `chmod -R 770` : Donne les droits de lecture/écriture/exécution au propriétaire et au groupe, rien aux autres
- `chgrp -R docker` : Attribue la propriété des répertoires au groupe docker (dont l'utilisateur runner fait partie)

### Vérification des permissions :

```bash
# Vérifier que l'utilisateur runner peut écrire dans ces répertoires
su - runner -c "touch /opt/app/test/test-file"
su - runner -c "touch /opt/app/prod/test-file"
ls -la /opt/app/test/
ls -la /opt/app/prod/
```

Si les fichiers de test ont été créés avec succès, les permissions sont correctement configurées !

## 7️⃣ Initialisation du dépôt Git local

Nous allons configurer un dépôt Git local connecté à notre projet GitLab pour y pousser notre code.

```bash
cd /home/loic/code_source
git init
git remote add origin https://gitlab.techwave.lab/salle-8/runner-test-najuma.git
```

**Explication :**
- `git init` : Initialise un nouveau dépôt Git dans le répertoire actuel
- `git remote add origin` : Configure l'URL du dépôt distant (notre projet GitLab)

### Configuration de votre identité Git :

```bash
git config user.name "Votre Nom"
git config user.email "votre.email@example.com"
```

Ces informations seront associées à vos commits.

### Vérification de la configuration :

```bash
git remote -v
```

Cette commande doit afficher l'URL de votre dépôt GitLab.

## 8️⃣ Création de la branche de développement

Nous allons créer la branche `develop` qui servira de base pour notre travail de développement.

```bash
git checkout -b develop
git push -u origin develop
```

**Explication :**
- `git checkout -b develop` : Crée une nouvelle branche locale nommée "develop" et bascule dessus
- `git push -u origin develop` : Pousse cette branche sur le dépôt distant et configure le suivi

### Vérification des branches :

```bash
git branch -vv
```

Vous devriez voir votre branche `develop` avec l'indication qu'elle suit `origin/develop`.

## 9️⃣ Mise en place d'un cycle de développement

Voici comment travailler selon la méthodologie Git Flow pour ajouter de nouvelles fonctionnalités :

```bash
# Partir toujours de develop à jour
git checkout develop
git pull origin develop

# Créer une branche de fonctionnalité
git checkout -b feature/ma-nouvelle-fonctionnalite

# Faire vos modifications...

# Enregistrer les modifications
git add .
git commit -m "feat: ajout de la fonction X qui permet Y"

# Pousser sur le dépôt distant
git push origin feature/ma-nouvelle-fonctionnalite
```

**Explication :**
- Toujours partir d'une branche `develop` à jour pour éviter les conflits
- Utiliser des préfixes dans les noms de branches (`feature/`, `bugfix/`, etc.) pour organiser le travail
- Suivre une convention de message de commit (ex: "feat:", "fix:", "docs:") pour la clarté
- Pousser régulièrement sur le dépôt distant pour sauvegarder votre travail

### Dans l'interface GitLab :

Une fois votre fonctionnalité prête, créez une Merge Request (ou Pull Request) de votre branche `feature/xxx` vers `develop`. Cela permettra :
- De déclencher les tests automatiques
- De faire une revue de code
- De fusionner proprement votre code

## 🔟 Configuration du pipeline CI/CD avec .gitlab-ci.yml

Le fichier `.gitlab-ci.yml` définit les étapes de votre pipeline d'intégration et déploiement continus.

Créez ce fichier à la racine de votre projet :

```yaml
stages:
  - test
  - deploy_preprod
  - deploy_prod

test:
  stage: test
  tags:
    - ssh
    - docker
  script:
    - docker ps
  rules:
    - if: '$CI_COMMIT_BRANCH == "develop"'

deploy_preprod:
  stage: deploy_preprod
  tags:
    - ssh
    - docker
  script:
    - cp app.py Dockerfile requirements.txt docker-compose_test.yml /opt/app/test
    - cd /opt/app/test
    - docker compose -f docker-compose_test.yml up -d
  rules:
    - if: '$CI_COMMIT_BRANCH == "develop"'

deploy_prod:
  stage: deploy_prod
  tags:
    - ssh
    - docker
  script:
    - cp app.py Dockerfile requirements.txt docker-compose.yml /opt/app/prod
    - cd /opt/app/prod
    - docker compose down || true
    - docker compose up -d
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
```

**Explication du fichier :**
- `stages` définit l'ordre d'exécution des étapes du pipeline
- Chaque job (test, deploy_preprod, deploy_prod) est associé à une étape
- `tags` spécifie quels runners peuvent exécuter ce job (ceux avec les tags "ssh" et "docker")
- `script` contient les commandes à exécuter
- `rules` définit quand le job doit s'exécuter (ici, selon la branche)

### Test du pipeline avec un job simple

Pour vérifier que tout fonctionne, commencez par un pipeline minimal :

```yaml
stages:
  - test

test_job:
  stage: test
  tags:
    - ssh
    - docker
  script:
    - echo "🎉 Runner SSH + Docker opérationnel"
    - docker ps
```

Enregistrez ce fichier et poussez-le sur votre branche principale :

```bash
git add .gitlab-ci.yml
git commit -m "test: configuration initiale du pipeline CI/CD"
git push origin main
```

Vérifiez dans l'interface GitLab (`CI/CD > Pipelines`) que le job se lance et s'exécute avec succès.


## 1️⃣1️⃣ Ajout des variables d'environnement GitLab

### 🎯 Ajout et utilisation de la variable APP_ENV dans tout le pipeline CI/CD

1. Dans GitLab, aller dans `Settings > CI/CD > Variables`
2. Cliquer sur **"Add variable"**
3. Renseigner les champs suivants :
   - **Key** : `APP_ENV`
   - **Value** : `preprod` (pour `develop`) ou `prod` (pour `main`)
   - **Environment scope** : `preprod` ou `production`
   - **Type** : `Variable`
   - ❌ Ne pas cocher "Protected" pour `preprod`
   - ✅ Cocher "Protected" pour `production`

| Key     | Value   | Environment scope | Protected |
|---------|---------|-------------------|-----------|
| APP_ENV | preprod | preprod           | ❌         |
| APP_ENV | prod    | production        | ✅         |

---

### 🧪 Intégration dans le pipeline et l'application

✅ Dans `.gitlab-ci.yml` :
```yaml
script:
  - echo "🏷️ APP_ENV (vue GitLab) = ${APP_ENV}"
  - export APP_ENV=${APP_ENV}
  - docker compose ...
```

✅ Dans `docker-compose_test.yml` :
```yaml
environment:
  APP_ENV: ${APP_ENV}
```

✅ Dans `app.py` :
```python
env = os.getenv("APP_ENV", "inconnu")
```

Et dans le HTML généré :
```html
<h1>👋 Bonjour depuis l’environnement <span style='color:#007bff'>{env}</span> !</h1>
<p><strong>Environnement :</strong> {env}</p>
```

✅ Supprimer toute référence à `NOM` dans le code et dans les variables GitLab

➡️ Résultat attendu dans le navigateur :
```html
Bonjour depuis l’environnement preprod !
```


## 1️⃣2️⃣ Déploiement en production (fusion vers main)

Une fois que vos développements sur la branche `develop` sont prêts pour la production :

```bash
# S'assurer que tout est à jour
git checkout develop
git pull origin develop

git checkout main
git pull origin main

# Fusionner develop dans main
git merge develop

# Pousser sur le dépôt distant
git push origin main
```

**Explication :**
- Nous mettons d'abord à jour nos branches locales
- Nous fusionnons `develop` dans `main`
- Nous poussons les changements sur le dépôt distant, ce qui déclenchera le job `deploy_prod`

### Vérification du déploiement :

1. Vérifiez dans GitLab (`CI/CD > Pipelines`) que le pipeline s'exécute correctement
2. Sur le serveur Docker, vérifiez que les conteneurs sont en cours d'exécution :
   ```bash
   docker ps
   ```
3. Testez l'application déployée pour vous assurer qu'elle fonctionne comme prévu

---

# 🧑‍💼 Mode d'emploi utilisateur 

## 🔧 Pour modifier le projet en développement

1. **Cloner le dépôt** (la première fois seulement) :  
   ```bash
   git clone https://gitlab.techwave.lab/salle-8/runner-test-najuma.git
   cd runner-test-najuma
   ```

2. **Créer une branche de fonctionnalité** :
   ```bash
   # Mettre à jour la branche develop
   git checkout develop
   git pull origin develop
   
   # Créer votre branche de fonctionnalité
   git checkout -b feature/ma-nouvelle-fonctionnalite
   ```
   > ℹ️ Remplacez "ma-nouvelle-fonctionnalite" par un nom court mais descriptif de ce que vous allez faire

3. **Modifier les fichiers** dans vs code
   - Travaillez dans le répertoire `/home/loic/code_source/`
   - Testez vos modifications localement avant de les pousser

4. **Enregistrer vos modifications** :
   ```bash
   # Voir les fichiers modifiés
   git status
   
   # Ajouter les fichiers modifiés
   git add .
   
   # Créer un commit avec un message descriptif
   git commit -m "feat: ajout de la fonction d'authentification par email"
   
   # Pousser sur le dépôt distant
   git push origin feature/ma-nouvelle-fonctionnalite
   ```

5. **Créer une Merge Request** dans l'interface GitLab :
   - Allez sur https://gitlab.techwave.lab/salle-8/runner-test-najuma
   - Cliquez sur "Merge Requests" puis "New Merge Request"
   - Sélectionnez votre branche comme source, et `develop` comme destination
   - Ajoutez une description détaillant vos modifications
   - Assignez des reviewers si nécessaire
   - Cliquez sur "Create Merge Request"

## 🚀 Pour déployer en production (fusion manuelle)

Lorsque toutes les fonctionnalités dans `develop` sont testées et prêtes :

1. **Mettre à jour les branches locales** :
   ```bash
   cd /home/loic/code_source/
   
   # Mettre à jour develop
   git checkout develop
   git pull origin develop
   
   # Mettre à jour main
   git checkout main
   git pull origin main
   ```

2. **Fusionner develop dans main** :
   ```bash
   # Vous êtes déjà sur main
   git merge develop
   
   # En cas de conflit, résolvez-les puis:
   # git add .
   # git commit -m "Merge develop into main"
   
   # Pousser vers le dépôt distant
   git push origin main
   ```

3. **Surveiller le déploiement** :
   - Allez sur GitLab > CI/CD > Pipelines pour voir l'avancement
   - Vérifiez que le job `deploy_prod` s'exécute correctement
   - Une fois terminé, testez que l'application fonctionne en production

---

# 🛠️ Commandes utiles GitLab Runner

```bash
# Afficher la configuration du runner
sudo cat /etc/gitlab-runner/config.toml

# Lister les runners enregistrés
sudo gitlab-runner list

# Redémarrer le service GitLab Runner
sudo gitlab-runner restart

# Mettre à jour GitLab Runner
sudo gitlab-runner upgrade
```

---

# 🧪 Problèmes rencontrés et solutions

## ❌ Erreur : certificat SSL auto-signé (curl / GitLab Runner)

**Symptôme :** Erreurs de type "certificate verification failed"

### Solution :
1. Exportez le certificat de votre serveur GitLab :
   ```bash
   openssl s_client -connect gitlab.techwave.lab:443 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > gitlab.crt
   ```

2. Installez-le dans les certificats de confiance :
   ```bash
   sudo cp gitlab.crt /usr/local/share/ca-certificates/
   sudo update-ca-certificates
   ```

## ❌ Erreur : `tls: failed to verify certificate: x509: ...`

**Symptôme :** Erreur lors de l'enregistrement du runner

### Solution :
```bash
sudo gitlab-runner register --tls-skip-verify --url https://gitlab.techwave.lab --token VOTRE_TOKEN_ICI
```

## ❌ Job failed: prepare environment

**Symptôme :** Les jobs échouent avec un message "prepare environment"

### Cause :
Contenu dans `.bashrc`, `.profile` ou `.bash_logout` qui génère du texte ou des commandes interactives.

### Solution :
1. Vérifiez ces fichiers sur la machine `docker-host` pour l'utilisateur `runner` :
   ```bash
   sudo cat /home/runner/.bashrc
   sudo cat /home/runner/.profile
   sudo cat /home/runner/.bash_logout
   ```

2. Commentez ou supprimez toute ligne qui produit un affichage (comme `echo`, `clear`, etc.) :
   ```bash
   sudo nano /home/runner/.bashrc
   # Commentez les lignes problématiques avec # au début
   ```

3. Testez que SSH fonctionne sans produire de sortie texte :
   ```bash
   ssh runner@docker-host echo OK
   # Si vous voyez uniquement "OK", c'est bon
   ```

## ❌ Git : push refusé / force-push impossible

**Symptôme :** Message d'erreur `! [rejected] main -> main (fetch first)` lors d'un push

### Cause :
Le dépôt distant contient des commits que vous n'avez pas en local, ou la branche est protégée contre les force-push.

### Solution :
1. **Pull avec rebase** (méthode recommandée) :
   ```bash
   git pull --rebase origin main
   ```
   
   **Explication :** Cette commande récupère les changements distants et tente de replacer vos commits par-dessus. S'il y a des conflits, Git vous demandera de les résoudre.

2. **En cas de conflits :**
   ```bash
   # Ouvrez les fichiers marqués comme conflictuels et résolvez les conflits
   # Ils sont marqués avec <<<<<<<, =======, >>>>>>>
   
   # Une fois résolu, marquez-les comme résolus
   git add fichier_avec_conflit
   
   # Continuez le rebase
   git rebase --continue
   
   # Poussez vos changements
   git push origin main
   ```

3. **Évitez d'utiliser `git push --force`** sur une branche partagée ou protégée. Cela peut effacer le travail d'autres personnes ou déclencher des protections de branche.

---

# 🚀 Bonnes pratiques pour le travail collaboratif avec Git et CI/CD

## 📊 Flux de travail recommandé

1. **Partir d'une base propre** :
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/ma-fonctionnalite
   ```

2. **Faire des commits fréquents et atomiques** :
   - Commitez souvent, avec des messages clairs
   - Chaque commit devrait faire une seule chose
   - Format recommandé : `type: description courte`
     - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

3. **Pousser régulièrement** :
   ```bash
   git push origin feature/ma-fonctionnalite
   ```
   Cela sauvegarde votre travail et permet aux autres de voir votre progression.

4. **Merge Request avec revue de code** :
   - Créez une MR quand la fonctionnalité est prête
   - Demandez à un collègue de relire votre code
   - Le pipeline CI/CD vérifiera automatiquement votre code

5. **Mettre à jour régulièrement depuis develop** :
   ```bash
   git checkout develop
   git pull origin develop
   git checkout feature/ma-fonctionnalite
   git rebase develop
   ```
   Cela évite les conflits massifs lors de la fusion finale.

## 🔍 Comment déboguer le pipeline CI/CD

Si un job échoue dans votre pipeline, voici les étapes à suivre :

1. **Examiner les logs** :
   - Dans GitLab, allez dans CI/CD > Pipelines
   - Cliquez sur le pipeline échoué
   - Cliquez sur le job échoué pour voir les logs détaillés

2. **Problèmes courants à vérifier** :
   - **Permissions** : l'utilisateur `runner` a-t-il accès aux fichiers/dossiers nécessaires ?
   - **Variables manquantes** : avez-vous configuré toutes les variables nécessaires ?
   - **Erreurs Docker** : vérifiez que les images Docker existent et sont accessibles
   - **Connexion SSH** : vérifiez que la connexion SSH fonctionne

3. **Tester localement** :
   - Connectez-vous en SSH au `docker-host` en tant que `runner`
   - Essayez d'exécuter manuellement les commandes qui échouent

4. **Journaux du Runner** :
   ```bash
   # Sur runner-host
   sudo gitlab-runner --debug run
   ```
   Cette commande lance le runner en mode debug et affiche des logs détaillés.

## 🔒 Sécurité et bonnes pratiques

1. **Ne jamais stocker de secrets dans le code** :
   - Utilisez les variables CI/CD de GitLab pour les secrets
   - Marquez-les comme "protégées" et "masquées"

2. **Limiter les permissions** :
   - Le principe du moindre privilège : donnez uniquement les droits nécessaires
   - Vérifiez régulièrement les permissions des dossiers

3. **Sauvegarde des configurations** :
   - Documentez et sauvegardez votre configuration de runner
   - Automatisez le déploiement des runners si possible

4. **Maintenance régulière** :
   - Mettez à jour GitLab Runner régulièrement
   - Vérifiez l'espace disque disponible sur vos machines

---

# 📚 Explication des concepts clés

## 🔄 Intégration Continue (CI)
L'intégration continue est une pratique de développement qui consiste à intégrer fréquemment les modifications de code dans un dépôt partagé. Chaque intégration est validée par des tests automatisés.

**Avantages :**
- Détection précoce des bugs
- Qualité de code améliorée
- Intégrations plus faciles et plus rapides

## 🚀 Déploiement Continu (CD)
Le déploiement continu étend l'intégration continue en déployant automatiquement toutes les modifications qui passent la batterie de tests.

**Étapes typiques d'un pipeline CD :**
1. Build (construction de l'application)
2. Test (tests unitaires, d'intégration, etc.)
3. Package (création d'artefacts déployables)
4. Deploy (déploiement en environnement)

## 🐳 Docker et containerisation
Docker permet d'encapsuler une application et ses dépendances dans un "conteneur" qui peut s'exécuter de manière isolée.

**Avantages :**
- Environnements cohérents
- Isolation des applications
- Déploiements rapides et légers
- Scalabilité facile

## 🏃 GitLab Runner et exécuteurs
Le GitLab Runner est l'agent qui exécute les jobs de votre pipeline CI/CD. Il existe plusieurs types d'exécuteurs :

- **Shell** : Exécute les commandes directement sur la machine du runner
- **Docker** : Exécute chaque job dans un conteneur Docker frais
- **Docker Machine** : Crée dynamiquement des machines Docker pour exécuter les jobs
- **Kubernetes** : Exécute les jobs dans des pods Kubernetes
- **SSH** : Se connecte à une machine distante via SSH pour exécuter les jobs (notre cas)

---

# 🗓️ Plan de maintenance recommandé

## 📋 Tâches hebdomadaires
- Vérifier que les runners sont toujours connectés et fonctionnels
- Examiner les logs à la recherche d'erreurs récurrentes
- S'assurer que l'espace disque est suffisant

## 📋 Tâches mensuelles
- Mettre à jour GitLab Runner vers la dernière version
- Vérifier les permissions des dossiers
- Tester manuellement la connexion SSH entre machines

## 📋 Tâches trimestrielles
- Renouveler les certificats SSL si nécessaire
- Faire une sauvegarde complète de la configuration
- Réviser les variables CI/CD et supprimer celles qui ne sont plus utilisées

---

# 🔄 Procédure de récupération en cas de problème

## 🔧 Si le Runner ne se connecte pas à GitLab
1. Vérifier la connectivité réseau : `ping gitlab.techwave.lab`
2. Vérifier le statut du service : `sudo systemctl status gitlab-runner`
3. Consulter les logs : `sudo gitlab-runner --debug run`
4. Redémarrer le service : `sudo gitlab-runner restart`

## 🔧 Si les jobs échouent systématiquement
1. Vérifier la connexion SSH : `ssh runner@docker-host echo "Test OK"`
2. Vérifier que Docker fonctionne : `ssh runner@docker-host docker ps`
3. Examiner les permissions des dossiers : `ssh runner@docker-host ls -la /opt/app`
4. Relancer le runner en mode debug : `sudo gitlab-runner --debug run`

## 🔧 Pour réenregistrer un runner
1. Désinscrire l'ancien runner : `sudo gitlab-runner unregister --name "runner-docker-najuma"`
2. Suivre à nouveau la procédure d'enregistrement (section 5)



