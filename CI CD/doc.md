# 📘 Documentation complète : Déploiement de GitLab Runner avec Docker sur GitLab auto-hébergé

---

## 🧱 Prérequis

- Une **VM Debian** dédiée pour exécuter les pipelines CI/CD (c’est ta machine GitLab Runner)
- Une instance GitLab auto-hébergée : https://gitlab.techwave.lab
- Un compte GitLab avec droits de création de projet
- Projet cible : [`runner-test-najuma`](https://gitlab.techwave.lab/salle-8/runner-test-najuma.git)

> ⚠️ **Important** :  
> Ne pas installer Docker ni GitLab Runner sur le serveur GitLab (`gitlab.techwave.lab`).  
> Ces outils doivent être installés sur ta **VM Debian**, qui servira de machine GitLab Runner.

---

## 🔎 Comprendre l’architecture

| Machine                  | Rôle                                     | Docker + GitLab Runner |
|--------------------------|------------------------------------------|--------------------------|
| 💻 `gitlab.techwave.lab` | Héberge l’interface GitLab et les projets | ❌ Non                   |
| 🏃 VM Debian             | Exécute les pipelines (GitLab Runner)     | ✅ Oui                   |

---

## 🧪 Étape 1 – Créer un projet GitLab (si ce n'est pas déjà fait)

1. Se connecter à [https://gitlab.techwave.lab](https://gitlab.techwave.lab)
2. Aller dans le groupe `salle-8`
3. Créer un **nouveau projet vide**
4. Nommer : `runner-test-najuma`
5. Cliquer sur **"Créer un projet"**

---

## 🐳 Étape 2 – Installer Docker (sur la VM Debian GitLab Runner)

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```

> 🔁 Déconnecte-toi / reconnecte-toi pour appliquer les droits au groupe `docker`.

Tester Docker :
```bash
docker run hello-world
```

---

## 🏃 Étape 3 – Installer GitLab Runner (sur la même VM Debian)

```bash
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
sudo apt install -y gitlab-runner
```

Vérifie l’installation :
```bash
gitlab-runner --version
```

---

## 🔗 Étape 4 – Enregistrer le runner dans GitLab

1. Aller dans ton projet [`runner-test-najuma`](https://gitlab.techwave.lab/salle-8/runner-test-najuma)
2. Menu **Paramètres > CI/CD > Runners > Développer**
3. Copier :
   - **URL GitLab** : `https://gitlab.techwave.lab/`
   - **Jeton d'enregistrement**

Sur la VM Debian :

```bash
sudo gitlab-runner register
```

Répondre comme suit :

| Question                             | Réponse                                                  |
|--------------------------------------|-----------------------------------------------------------|
| GitLab instance URL                  | `https://gitlab.techwave.lab/`                           |
| Registration token                   | Le token GitLab copié                                    |
| Description                          | `runner-docker-najuma`                                   |
| Tags                                 | `docker` *(optionnel)*                                   |
| Executor                             | `docker`                                                  |
| Default Docker image                 | `alpine:latest` *(ou autre selon ton besoin)*            |

---

## ⚙️ Étape 5 – Créer un fichier `.gitlab-ci.yml` localement

```bash
mkdir runner-test-najuma && cd runner-test-najuma
git init
```

Créer le fichier `.gitlab-ci.yml` :

```yaml
stages:
  - test

test_job:
  stage: test
  image: alpine:latest
  script:
    - echo "🎉 GitLab Runner fonctionne avec Docker !"
    - uname -a
```

---

## 📤 Étape 6 – Lier ton dépôt local au projet GitLab

```bash
git remote add origin https://gitlab.techwave.lab/salle-8/runner-test-najuma.git
git add .
git commit -m "Ajout du pipeline test"
git push -u origin master
```

---

## ✅ Étape 7 – Vérifier le pipeline dans GitLab

1. Accéder au projet : `https://gitlab.techwave.lab/salle-8/runner-test-najuma`
2. Aller dans **CI/CD > Pipelines**
3. Le pipeline se lance automatiquement
4. Cliquer sur le job pour voir les logs d’exécution

---

## 🧩 Exemple de pipeline plus avancé

```yaml
stages:
  - build
  - test

build_image:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  variables:
    DOCKER_DRIVER: overlay2
  script:
    - docker version
    - echo "Build terminé"

test_python:
  stage: test
  image: python:3.11
  script:
    - python --version
    - echo "Tests OK"
```

---

## 📌 Commandes utiles sur la VM Debian (Runner)

Afficher la config :
```bash
sudo cat /etc/gitlab-runner/config.toml
```

Lister les runners :
```bash
sudo gitlab-runner list
```

Redémarrer le runner :
```bash
sudo gitlab-runner restart
```

Mettre à jour GitLab Runner :
```bash
sudo gitlab-runner upgrade
```
