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

---

## 🔐 ÉTAPE 2 — Générer et ajouter une clé SSH

### Sur `runner-host` :

```bash
su - gitlab-runner
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub
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

## 🐳 ÉTAPE 3 — Installer Docker sur `docker-host`

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
```

---

## 🏃 ÉTAPE 4 — Installer GitLab Runner sur `runner-host`

```bash
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
sudo apt install -y gitlab-runner
gitlab-runner --version
```

---

## 🔗 ÉTAPE 5 — Enregistrer le runner via SSH

### Interface GitLab :

- Settings > CI/CD > Runners > New project runner
- Description : runner-docker-najuma
- Tags : ssh, docker
- Cocher : Run untagged jobs, Protected, Lock to current project
- Copier le token

### Sur `runner-host` :

```bash
sudo gitlab-runner register
# ➤ Suivre les instructions et choisir "ssh" comme executor
```

---

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