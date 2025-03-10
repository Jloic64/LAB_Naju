<p align="center">
    <img src="../Images/logo.png" width="850" />
</p>



# Commandes essentielles Docker

## 1. Gestion des Conteneurs

### Lister les conteneurs
- Conteneurs en cours d'exécution :
  ```sh
  docker ps
  ```
- Tous les conteneurs (y compris arrêtés) :
  ```sh
  docker ps -a
  ```

### Démarrer un conteneur
- Démarrer un conteneur existant :
  ```sh
  docker start <nom_conteneur>
  ```
- Démarrer un conteneur en mode interactif :
  ```sh
  docker run -it <image> /bin/bash
  ```

### Arrêter et supprimer un conteneur
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

## 2. Gestion des Images

### Lister les images
```sh
docker images
```

### Télécharger une image
```sh
docker pull <image>
```

### Supprimer une image
```sh
docker rmi <image_id>
```

## 3. Gestion des Volumes

### Lister les volumes
```sh
docker volume ls
```

### Créer un volume
```sh
docker volume create <nom_volume>
```

### Supprimer un volume
```sh
docker volume rm <nom_volume>
```

### Supprimer tous les volumes non utilisés
```sh
docker volume prune
```

## 4. Gestion des Réseaux

### Lister les réseaux
```sh
docker network ls
```

### Créer un réseau
```sh
docker network create <nom_reseau>
```

### Supprimer un réseau
```sh
docker network rm <nom_reseau>
```

### Connecter un conteneur à un réseau
```sh
docker network connect <nom_reseau> <nom_conteneur>
```

### Déconnecter un conteneur d’un réseau
```sh
docker network disconnect <nom_reseau> <nom_conteneur>
```

### Inspecter un réseau
```sh
docker network inspect <nom_reseau>
```

### Créer un réseau bridge personnalisé
```sh
docker network create --driver bridge <nom_reseau>
```

### Créer un réseau overlay (nécessite Docker Swarm)
```sh
docker network create --driver overlay <nom_reseau>
```

## 5. Docker Compose

### Démarrer un projet Docker Compose
```sh
docker-compose up -d
```

### Arrêter un projet Docker Compose
```sh
docker-compose down
```

### Lister les services d'un projet
```sh
docker-compose ps
```

## 6. Informations et Dépannage

### Voir les logs d’un conteneur
```sh
docker logs <nom_conteneur>
```

### Voir les ressources utilisées par les conteneurs
```sh
docker stats
```

### Inspecter un conteneur ou une image
```sh
docker inspect <nom_conteneur>
```

### Nettoyer Docker
- Supprimer les conteneurs arrêtés, les images non utilisées et les volumes inutilisés :
  ```sh
  docker system prune -a
  ```
