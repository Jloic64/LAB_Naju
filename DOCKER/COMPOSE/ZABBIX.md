## Compose sans variables :
```
version: '3.5'

services:
  zabbix-server-pgsql:
    image: zabbix/zabbix-server-pgsql:latest
    environment:
      DB_SERVER_HOST: "postgres-server"
      POSTGRES_USER: "zabbix"
      POSTGRES_DB: "zabbix"
      POSTGRES_PASSWORD: "zabbix_password"
    ports:
      - "10051:10051"
    depends_on:
      - postgres-server

  zabbix-web-nginx-pgsql:
    image: zabbix/zabbix-web-nginx-pgsql:latest
    environment:
      ZBX_SERVER_HOST: "zabbix-server-pgsql"
      DB_SERVER_HOST: "postgres-server"
      POSTGRES_USER: "zabbix"
      POSTGRES_DB: "zabbix"
      POSTGRES_PASSWORD: "zabbix_password"
      ZBX_SERVER_NAME: "Zabbix Server"
      PHP_TZ: "Europe/Paris"
    ports:
      - "8080:8080"
    depends_on:
      - zabbix-server-pgsql
      - postgres-server

  postgres-server:
    image: postgres:latest
    environment:
      POSTGRES_USER: "zabbix"
      POSTGRES_DB: "zabbix"
      POSTGRES_PASSWORD: "zabbix_password"
    volumes:
      - zabbix-postgres-data:/var/lib/postgresql/data

volumes:
  zabbix-postgres-data:

```