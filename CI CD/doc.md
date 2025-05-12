# 📘 Documentation complète : Déploiement de GitLab Runner avec Docker sur GitLab auto-hébergé

---

## 🧱 Prérequis

- Une machine Linux avec accès `sudo`
- Docker installé
- GitLab auto-hébergé : https://gitlab.techwave.lab
- Un compte GitLab avec droits de création de projet

---

## 🧪 Étape 1 – Créer un projet GitLab

1. Se connecter à https://gitlab.techwave.lab
2. Cliquer sur **"Nouveau projet"**
3. Sélectionner **"Projet vide"**
4. Nommer le projet `runner-test`
5. Choisir la visibilité (privé ou public)
6. Cliquer sur **"Créer un projet"**

---

## 🐳 Étape 2 – Installer Docker

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```

> ℹ️ Déconnecte-toi / reconnecte-toi après l’ajout au groupe `docker`.

Test Docker :
```bash
docker run hello-world
```

---

## 🏃 Étape 3 – Installer GitLab Runner

```bash
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
sudo apt install -y gitlab-runner
```

Vérifie l’installation :
```bash
gitlab-runner --version
```

---

## 🔗 Étape 4 – Enregistrer le Runner dans GitLab

1. Aller dans ton projet `runner-test`
2. Menu **Paramètres > CI/CD > Runners > Développer**
3. Copier :
   - **URL GitLab** : `https://gitlab.techwave.lab/`
   - **Jeton d'enregistrement**

Enregistrement du runner :
```bash
sudo gitlab-runner register
```

Répondre comme suit :

| Question                             | Réponse                                        |
|--------------------------------------|------------------------------------------------|
| GitLab instance URL                  | `https://gitlab.techwave.lab/`                |
| Token d'enregistrement               | Le token GitLab copié                         |
| Description du runner                | `runner-docker-local`                         |
| Tags                                 | `docker` (optionnel)                          |
| Executor                             | `docker`                                      |
| Image Docker par défaut              | `alpine:latest` (ou `python:3.11`, etc.)      |

---

## ⚙️ Étape 5 – Créer le fichier `.gitlab-ci.yml`

Sur ta machine locale :

```bash
mkdir runner-test && cd runner-test
git init
```

Créer le fichier :
```yaml
stages:
  - test

test_job:
  stage: test
  image: alpine:latest
  script:
    - echo "🎉 GitLab CI avec Docker fonctionne !"
    - uname -a
```

---

## 📤 Étape 6 – Pousser le projet dans GitLab

Ajouter l’origine Git et pousser :

```bash
git remote add origin https://gitlab.techwave.lab/<ton-user>/runner-test.git
git add .
git commit -m "Test pipeline avec Docker"
git push -u origin master
```

> Remplacer `<ton-user>` par ton nom d’utilisateur GitLab.

---

## ✅ Étape 7 – Vérifier l’exécution du pipeline

1. Aller sur https://gitlab.techwave.lab
2. Accéder à ton projet > **CI/CD > Pipelines**
3. Un pipeline doit s'exécuter automatiquement
4. Cliquer dessus pour visualiser les logs du job

---

## 🧩 Exemple de `.gitlab-ci.yml` plus avancé

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
    - echo "build OK"

test_python:
  stage: test
  image: python:3.11
  script:
    - python --version
    - echo "tests OK"
```

---

## 📌 Commandes utiles

Voir la config locale :
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

Mettre à jour le runner :
```bash
sudo gitlab-runner upgrade
```


