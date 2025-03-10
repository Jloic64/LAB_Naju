<p align="center">
    <img src="Images/logo.png" width="850" />
</p>

# 🐳 Commandes essentielles Docker  

---

## 🔑 1. Gestion des Conteneurs  

### 📜 1.1. Lister les conteneurs  
- Conteneurs en cours d'exécution :  
  ```sh
  docker ps
  ```
- Tous les conteneurs (y compris arrêtés) :  
  ```sh
  docker ps -a
  ```

### 🚀 1.2. Démarrer un conteneur  
- Démarrer un conteneur existant :  
  ```sh
  docker start <nom_conteneur>
  ```
- Démarrer un conteneur en mode interactif :  
  ```sh
  docker run -it <image> /bin/bash
  ```

### 🛑 1.3. Arrêter et supprimer un conteneur  
- Arrêter un conteneur :  
  ```sh
  docker stop <nom_conteneur>
  ```
- Supprimer un conteneur :  
  ```sh
  docker rm <nom_conteneur>
  ```
- Supprimer tous les conteneurs arrêtés :  
  ```sh
  docker container prune
  ```

---

## 📦 2. Gestion des Images  

### 📜 2.1. Lister les images  
```sh
docker images
```

### ⬇️ 2.2. Télécharger une image  
```sh
docker pull <image>
```

### 🗑️ 2.3. Supprimer une image  
```sh
docker rmi <image_id>
```

---

## 💾 3. Gestion des Volumes  

### 📜 3.1. Lister les volumes  
```sh
docker volume ls
```

### ➕ 3.2. Créer un volume  
```sh
docker volume create <nom_volume>
```

### 🗑️ 3.3. Supprimer un volume  
```sh
docker volume rm <nom_volume>
```

### 🧹 3.4. Supprimer tous les volumes non utilisés  
```sh
docker volume prune
```

---

## 🌐 4. Gestion des Réseaux  

### 📜 4.1. Lister les réseaux  
```sh
docker network ls
```

### ➕ 4.2. Créer un réseau  
```sh
docker network create <nom_reseau>
```

### 🗑️ 4.3. Supprimer un réseau  
```sh
docker network rm <nom_reseau>
```

### 🔗 4.4. Connecter un conteneur à un réseau  
```sh
docker network connect <nom_reseau> <nom_conteneur>
```

### 🔌 4.5. Déconnecter un conteneur d’un réseau  
```sh
docker network disconnect <nom_reseau> <nom_conteneur>
```

### 🔍 4.6. Inspecter un réseau  
```sh
docker network inspect <nom_reseau>
```

### 🏗️ 4.7. Créer un réseau bridge personnalisé  
```sh
docker network create --driver bridge <nom_reseau>
```

### ☁️ 4.8. Créer un réseau overlay (nécessite Docker Swarm)  
```sh
docker network create --driver overlay <nom_reseau>
```

---

## 🛠️ 5. Docker Compose  

### 🚀 5.1. Démarrer un projet Docker Compose  
```sh
docker-compose up -d
```

### 🛑 5.2. Arrêter un projet Docker Compose  
```sh
docker-compose down
```

### 📜 5.3. Lister les services d'un projet  
```sh
docker-compose ps
```

---

## 🔍 6. Informations et Dépannage  

### 📜 6.1. Voir les logs d’un conteneur  
```sh
docker logs <nom_conteneur>
```

### 📊 6.2. Voir les ressources utilisées par les conteneurs  
```sh
docker stats
```

### 🔍 6.3. Inspecter un conteneur ou une image  
```sh
docker inspect <nom_conteneur>
```

### 🧹 6.4. Nettoyer Docker  
- Supprimer les conteneurs arrêtés, les images non utilisées et les volumes inutilisés :  
  ```sh
  docker system prune -a
  ```

---