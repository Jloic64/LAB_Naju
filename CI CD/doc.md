# 📘 Déploiement GitLab Runner avec Docker distant via SSH

## 🧭 PRÉAMBULE : Pourquoi structurer son projet avec des branches ?

L’organisation du projet avec plusieurs branches Git permet une gestion propre et professionnelle du code :

- **main** : branche de production. Contient uniquement du code validé, testé, prêt à être mis en production.
- **develop** : branche de développement. On y intègre les nouvelles fonctionnalités, elle précède `main`.
- **feature/** : branches temporaires créées depuis `develop`, pour ajouter une fonctionnalité.
- **bugfix/** : branches correctives temporaires.
- **hotfix/** : branches urgentes créées depuis `main`, pour des corrections en prod.

Avantages :
- Éviter les erreurs en production
- Permettre le travail en équipe
- Favoriser l’intégration continue (CI)
- Faciliter les revues de code

---

## 🔎 Comprendre l’architecture

| Machine                  | Rôle                                            | Docker | GitLab Runner |
|--------------------------|--------------------------------------------------|--------|----------------|
| 💻 `gitlab.techwave.lab` | Héberge l’interface GitLab, les projets et CI/CD | ❌     | ❌             |
| 🏃 `runner-host`         | Machine dédiée au GitLab Runner                  | ❌     | ✅             |
| 🐳 `docker-host`         | Machine distante qui exécute les jobs Docker     | ✅     | ❌             |

---

## 🧱 PRÉREQUIS

- Une VM Debian 12 pour Docker (`docker-host`)
- Une VM Debian 12 pour GitLab Runner (`runner-host`)
- Une instance GitLab auto-hébergée : https://gitlab.techwave.lab
- Un projet GitLab cible : https://gitlab.techwave.lab/salle-8/runner-test-najuma.git
- Accès administrateur aux deux VMs

---

## 👤 ÉTAPE 1 — Créer les utilisateurs nécessaires

### Sur `docker-host` (machine Docker) :

```bash
sudo useradd runner -m -s /bin/bash
sudo usermod -aG docker runner
```

### Sur `runner-host` (machine GitLab Runner) :

```bash
sudo useradd gitlab-runner -m -s /bin/bash
```

🛠️ **Remarque importante : Donner les droits sudo à gitlab-runner**

Sur `runner-host`, connectez-vous avec un utilisateur ayant les droits administrateur (ex : `loic`) et exécutez :

```bash
sudo usermod -aG sudo gitlab-runner
```

Ensuite, reconnectez-vous avec `gitlab-runner` :

```bash
su - gitlab-runner
```
🛠️ **Remarque importante :**  
Si la commande `su - gitlab-runner` retourne une erreur d'authentification (`Authentication failure`), cela signifie que l'utilisateur `gitlab-runner` n'a pas encore de mot de passe défini.

### ➤ Solution :

```bash
sudo passwd gitlab-runner
```

👉 Entrez un mot de passe sécurisé, puis réessayez :

```bash
su - gitlab-runner
```

---

## 🔐 ÉTAPE 2 — Générer et ajouter une clé SSH

### Sur `runner-host` :

```bash
su - gitlab-runner
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub
---

---

## 📥 ÉTAPE 2.1 — Copier la clé publique sur le `docker-host`

### Sur `runner-host` :

Afficher la clé publique générée :

```bash
cat /home/gitlab-runner/.ssh/id_ed25519.pub
```

👉 **Copier tout le contenu affiché** (c’est une ligne qui commence par `ssh-ed25519 ...`).

---

### Sur `docker-host` :

Créer le dossier `.ssh` et coller la clé :

```bash
sudo mkdir -p /home/runner/.ssh
sudo nano /home/runner/.ssh/authorized_keys
```

📌 Colle la clé copiée dans ce fichier, puis enregistre.

Configurer les permissions correctement :

```bash
sudo chmod 700 /home/runner/.ssh
sudo chmod 600 /home/runner/.ssh/authorized_keys
sudo chown -R runner:runner /home/runner/.ssh
```

---

### ✅ Vérification de la connexion SSH

Depuis `runner-host`, toujours sous l’utilisateur `gitlab-runner` :

```bash
ssh runner@IP_DU_DOCKER_HOST
```

👉 **Tu dois être connecté directement sans que le système demande de mot de passe.**  
C’est le signe que **l’authentification par clé fonctionne correctement** et que le GitLab Runner pourra s’y connecter automatiquement pour exécuter des jobs Docker à distance.**
```

> Copie la clé affichée pour la coller sur le serveur Docker.

### Sur `docker-host` :

```bash
sudo mkdir -p /home/runner/.ssh
sudo nano /home/runner/.ssh/authorized_keys
# ➤ Colle ici la clé copiée depuis le runner-host
sudo chmod 700 /home/runner/.ssh
sudo chmod 600 /home/runner/.ssh/authorized_keys
sudo chown -R runner:runner /home/runner/.ssh
```

### Vérification :

```bash
ssh runner@IP_DU_DOCKER_HOST
```

---

---

## 🐳 ÉTAPE 3 — Installer Docker sur `docker-host`

### Connexion à la machine `SRV-DEB12-DOCKER` :

```bash
ssh runner@IP_DU_DOCKER_HOST
```

### Installation de Docker :

```bash
sudo apt update
sudo apt install -y docker.io
```

### Activer et démarrer le service Docker :

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

### Ajouter l’utilisateur `runner` au groupe `docker` :

```bash
sudo usermod -aG docker runner
```

> 🔁 **Déconnecte-toi puis reconnecte-toi** (ou utilise `newgrp docker`) pour que les changements de groupe prennent effet.

### Vérification :

```bash
docker ps
```

---

## 🏃 ÉTAPE 4 — Installer GitLab Runner sur `runner-host`

### Ajouter l'utilisateur `gitlab-runner` au groupe sudo (à faire depuis un utilisateur avec privilèges, ex. `loic`) :

```bash
sudo usermod -aG sudo gitlab-runner
```

> 🔁 Ensuite, reconnecte-toi avec :  
> `su - gitlab-runner`

---

### Installation du dépôt GitLab Runner :

```bash
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
```

### Installation du paquet :

```bash
sudo apt install -y gitlab-runner
```

### Vérification de l'installation :

```bash
gitlab-runner --version
```

---

---

---

## 🛠️ AVANT ÉTAPE 5 — Assurer la résolution DNS de GitLab

Si votre GitLab auto-hébergé n'est pas enregistré dans un DNS public ou interne, vous devez forcer sa résolution dans le fichier `/etc/hosts` de la machine `runner-host`.

### Sur `runner-host` :

```bash
sudo nano /etc/hosts
```

Ajouter cette ligne tout en bas (⚠️ adaptez l'IP si besoin) :

```bash
10.100.0.203 gitlab.techwave.lab
```

💡 Cela permet à la commande `gitlab-runner register` de contacter votre instance GitLab.

---

## 🔗 ÉTAPE 5 — Enregistrer le runner via SSH

### Depuis l’interface GitLab :

Rends-toi dans le projet :

**Projet :** `Salle-8 / runner-test-Najuma`  
Navigue vers :

- **Français** : `Paramètres > CI/CD > Runners > Nouveau runner de projet`
- **English** : `Settings > CI/CD > Runners > New project runner`

Remplis les champs suivants :

- **Description / Description** : `runner-docker-najuma`
- **Tags / Étiquettes** : `ssh, docker`
- **Options** :
  - ✅ **Français** : Cocher `Exécuter les jobs sans étiquette`, `Protégé`, et `Limiter au projet actuel`
  - ✅ **English** : Check `Run untagged jobs`, `Protected`, and `Lock to current project`
- **Token / Jeton** : Copier le jeton affiché

---

### Depuis `runner-host` (machine GitLab Runner) :

Lancer l’enregistrement du runner :

```bash
sudo gitlab-runner register
```

Répondre aux questions comme suit :

- **URL GitLab** : `https://gitlab.techwave.lab/`
- **Token / Jeton** : (coller le jeton copié)
- **Description / Description** : `runner-docker-najuma`
- **Tags / Étiquettes** : `ssh,docker`
- **Executor / Exécuteur** : `ssh`
- **Adresse SSH** : `runner@10.108.0.102`
- **Chemin de la clé privée SSH / Private key path** : `/home/gitlab-runner/.ssh/id_ed25519`

---

## ❗ Problème possible — Erreur de vérification TLS (x509 SAN)

Si vous obtenez cette erreur lors de l'enregistrement du runner :

```
tls: failed to verify certificate: x509: certificate relies on legacy Common Name field, use SANs instead
```

### 🧠 Explication :

Depuis Go 1.15+, utilisé par GitLab Runner, les certificats SSL **doivent** inclure un champ `Subject Alternative Name (SAN)`.  
Un certificat qui n’a qu’un `Common Name` (CN) est considéré comme invalide.

Cela peut arriver si votre GitLab auto-hébergé utilise un certificat SSL auto-signé ou mal généré.

---

### ✅ Solution rapide (si GitLab est de confiance) : ignorer la vérification TLS

Ajoutez l’option `--tls-skip-verify` à la commande `register` :

```bash
sudo gitlab-runner register --tls-skip-verify   --url https://gitlab.techwave.lab   --token VOTRE_TOKEN_ICI
```

⚠️ À n'utiliser que si :
- le GitLab est en interne
- vous faites confiance à votre certificat

---

### 🔐 Solution recommandée (production) : recréer un certificat valide

Il faut générer un certificat avec une section `[ alt_names ]` :

```ini
[ alt_names ]
DNS.1 = gitlab.techwave.lab
```

Et inclure cette section dans la configuration OpenSSL lors de la création du certificat.

---

## ⚠️ Note : `gitlab-runner verify` peut échouer malgré une configuration correcte

Même si le fichier `/etc/gitlab-runner/config.toml` contient bien `tls_skip_verify = true`,  
la commande suivante peut toujours échouer :

```bash
sudo gitlab-runner verify
```

Erreur typique :

```
tls: failed to verify certificate: x509: certificate relies on legacy Common Name field, use SANs instead
```

### ✅ Pourquoi ce n’est pas bloquant :

La commande `verify` utilise une vérification TLS stricte **qui ne respecte pas le champ `tls_skip_verify`**, mais **le runner fonctionnera quand même dans les jobs CI/CD**, car cette vérification est contournée au moment de l'exécution réelle.

---

## ✅ Étape recommandée : tester avec un pipeline GitLab

Ajoute ce fichier `.gitlab-ci.yml` à la racine de ton dépôt :

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

Puis pousse sur ta branche GitLab :

```bash
git add .gitlab-ci.yml
git commit -m "test: runner SSH + Docker"
git push origin main
```

➡️ Vérifie dans **GitLab > CI/CD > Pipelines** que le job se lance.

## 🗂️ ÉTAPE 6 — Préparer les environnements `/opt/app/test` et `/opt/app/prod` sur `docker-host`

```bash
sudo mkdir -p /opt/app/test /opt/app/prod
sudo chmod -R 770 /opt/app
sudo chgrp -R docker /opt/app
```
---

## 📁 ÉTAPE 7 — Initialiser un dépôt Git

```bash
mkdir mon-projet && cd mon-projet
git init
git add .
git remote add origin https://gitlab.com/VOTRE_USER/NOM_DEPOT.git
git branch -M main
git push -u origin main
```

📌 **Pourquoi ?**  
Permet de versionner le code, collaborer, activer les pipelines et gérer les livraisons dans GitLab.

---

## 🌱 ÉTAPE 8 — Créer et protéger la branche develop

```bash
git checkout -b develop
git push -u origin develop
```

📌 **Pourquoi ?**  
Développer sans impacter la prod. Permet de préparer le code avant sa validation finale.

---

## 🔄 ÉTAPE 9 — Cycle de développement

```bash
git checkout develop
git checkout -b feature/ma-feature
# modifications
git add .
git commit -m "feat: ajout"
git push origin feature/ma-feature
```

📌 **Pourquoi ?**  
Isoler chaque évolution dans une branche claire pour faciliter la review et garder un historique propre.

---

## 🧪 ÉTAPE 10 — Fichier `.gitlab-ci.yml`

```yaml
stages:
  - test

test_job:
  stage: test
  script:
    - echo "🎉 Runner SSH + Docker opérationnel"
    - docker ps
```

📌 **Pourquoi ?**  
Déclenche une action automatique à chaque push : base d'un pipeline CI/CD.

---

## 🔐 ÉTAPE 11 — Ajouter des variables d’environnement

📌 **Pourquoi ?**  
Stocker des secrets, des configs ou chemins selon l’environnement sans exposer de données sensibles dans le code.

---

## 🚀 ÉTAPE 12 — Déploiement en production

```bash
git checkout develop
git pull origin develop
git checkout main
git pull origin main
git merge develop
git push origin main
```

📌 **Pourquoi ?**  
Livrer manuellement en production après validation. Le pipeline associé à `main` déclenche le déploiement final.

---

## 🛠️ Commandes utiles GitLab Runner

```bash
sudo cat /etc/gitlab-runner/config.toml
sudo gitlab-runner list
sudo gitlab-runner restart
sudo gitlab-runner upgrade
```

---

## 🛠️ Alternative — Enregistrer un runner avec certificat TLS invalide

Si votre GitLab auto-hébergé utilise un certificat sans SAN (erreur `x509: certificate relies on legacy Common Name field`), l’enregistrement `gitlab-runner register` échouera même avec `GITLAB_RUNNER_TLS_SKIP_VERIFY`.

Voici une méthode manuelle pour contourner ce problème :

---

### 1. Créer un fichier de configuration temporaire

```bash
mkdir -p ~/runner-register-tmp
cd ~/runner-register-tmp
nano config.toml
```

### 2. Contenu à coller dans `config.toml` :

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

Enregistre le fichier (`Ctrl + O`, `Entrée`, puis `Ctrl + X` pour quitter).

---

### 3. Copier ce fichier dans la configuration GitLab Runner

```bash
sudo cp config.toml /etc/gitlab-runner/config.toml
sudo chown gitlab-runner:gitlab-runner /etc/gitlab-runner/config.toml
```

---

### 4. Redémarrer et vérifier le runner

```bash
sudo gitlab-runner restart
sudo gitlab-runner verify
```

---

## 🧪 Créer le fichier `.gitlab-ci.yml` de test

Sur ta machine locale (ou sur une VM clonée du repo GitLab), crée un fichier `.gitlab-ci.yml` pour tester le runner :

```bash
cd ~/chemin/vers/ton/projet
nano .gitlab-ci.yml
```

Colle ce contenu dans le fichier :

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

Sauvegarde avec `Ctrl + O`, puis quitte `nano` avec `Ctrl + X`.

---

### 💾 Enregistre et pousse le fichier dans GitLab

```bash
git add .gitlab-ci.yml
git commit -m "test: runner SSH + Docker"
git push origin main
```

➡️ Puis vérifie dans l’interface GitLab que le pipeline est bien lancé :  
**GitLab > CI/CD > Pipelines**