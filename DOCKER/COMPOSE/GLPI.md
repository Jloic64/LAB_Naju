## Compose avec variables :
```

version: '3.8'

services:
  mysql:
    image: mysql:5.7
    container_name: glpi-mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - mysql_data:/var/lib/mysql
    restart: always

  glpi:
    image: diouxx/glpi
    container_name: glpi
    depends_on:
      - mysql
    environment:
      GLPI_DB_HOST: mysql
      GLPI_DB_USER: ${MYSQL_USER}
      GLPI_DB_PASSWORD: ${MYSQL_PASSWORD}
      GLPI_DB_NAME: ${MYSQL_DATABASE}
    ports:
      - "8080:80"
    volumes:
      - glpi_data:/var/www/html/glpi
    restart: always

volumes:
  mysql_data:
  glpi_data:

```

## Fichiers variables 

```
MYSQL_ROOT_PASSWORD=un_mot_de_passe_très_sécurisé
MYSQL_DATABASE=glpi
MYSQL_USER=glpi
MYSQL_PASSWORD=un_autre_mot_de_passe_sécurisé
```

## Sans Variables 

```
version: '3.8'

services:
  glpi:
    image: diouxx/glpi
    container_name: glpi
    ports:
      - "8080:80"
    volumes:
      - glpi_data:/var/www/html/glpi
    depends_on:
      - mysql

  mysql:
    image: mysql:5.7
    container_name: glpi-mysql
    environment:
      MYSQL_ROOT_PASSWORD: Simplon@is24
      MYSQL_DATABASE: glpi
      MYSQL_USER: glpi
      MYSQL_PASSWORD: Simplon@is24
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  glpi_data:
  mysql_data:
```