## Compose avec variables :
```

version: '3.8'

services:
  wordpress_db:
    image: mysql:5.7
    container_name: wordpress-mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${WORDPRESS_DATABASE}
      MYSQL_USER: ${WORDPRESS_USER}
      MYSQL_PASSWORD: ${WORDPRESS_PASSWORD}
    volumes:
      - wordpress_db_data:/var/lib/mysql
    restart: always

  wordpress:
    depends_on:
      - wordpress_db
    image: wordpress:latest
    container_name: wordpress
    environment:
      WORDPRESS_DB_HOST: wordpress_db:3306
      WORDPRESS_DB_USER: ${WORDPRESS_USER}
      WORDPRESS_DB_PASSWORD: ${WORDPRESS_PASSWORD}
      WORDPRESS_DB_NAME: ${WORDPRESS_DATABASE}
    volumes:
      - wordpress_data:/var/www/html
    ports:
      - "8080:80"  # Changez le port ici pour éviter un conflit avec GLPI
    restart: always

volumes:
  wordpress_db_data:
  wordpress_data:

```

## Fichiers variables 

```
WORDPRESS_DATABASE=wordpress
WORDPRESS_USER=utilisateur_wordpress
WORDPRESS_PASSWORD=mot_de_passe_wordpress
```

## Sans Variables 

```
version: '3.1'

services:
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: Simplon@is24
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: Simplon@is24

  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    ports:
      - "80:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: Simplon@is24
      WORDPRESS_DB_NAME: wordpress
volumes:
    db_data: {}

```