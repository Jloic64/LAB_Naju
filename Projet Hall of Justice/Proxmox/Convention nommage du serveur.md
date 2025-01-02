# Plan de Nomenclature pour VM et Conteneurs LXC sous Proxmox

## 1. Structure générale
- **ID** : Un numéro unique à 3 chiffres, défini par le type, le rôle, et le système.
- **Type de machine** : Spécifie le type de machine (VM, LXC, outil spécifique) et son rôle.
- **Détails** : Donne des informations supplémentaires sur l'utilisation et les cas d'usage.

---

## 2. Répartition des ID
| **Plage d'ID** | **Type de machine**            | **Détails**                                  |
|----------------|--------------------------------|----------------------------------------------|
| 100-199        | Libre / Non assigné           | Réserve pour des usages futurs.              |
| 200-299        | VM - Windows                  | Machines virtuelles Windows                 |
| 300-399        | VM - Linux                    | Machines virtuelles Linux (Debian, CentOS…) |
| 400-499        | LXC - Linux                   | Conteneurs Linux (Debian, Ubuntu, etc.)      |
| 500-599        | Modèles (Templates)           | Modèles de VM ou LXC pour duplication.       |
| 600-699        | Outils spécifiques            | NAS, routeurs (pfsense), outils réseau, etc. |
| 1000-1100      | Lab - VM ou LXC               | Machines utilisées pour des environnements de formation (serveurs ou clients). |
---

## 3. Exemples de nomenclature

### VM Windows
- **201-VM-WIN10-CLIENT01**  
ID : 201, Type : VM, OS : Windows 10, Fonction : Poste client.  
- **202-VM-WIN2019-SRVAD**  
ID : 202, Type : VM, OS : Windows Server 2019, Fonction : Contrôleur de domaine.

### VM Linux
- **301-VM-DEBIAN-SRVWEB**  
ID : 301, Type : VM, OS : Debian, Fonction : Serveur web.  
- **302-VM-CENTOS-DOCKER**  
ID : 302, Type : VM, OS : CentOS, Fonction : Serveur Docker.

### Conteneurs LXC Linux
- **401-LXC-UBUNTU-DB01**  
ID : 401, Type : LXC, OS : Ubuntu, Fonction : Base de données n°1.  
- **402-LXC-DEBIAN-PROXY**  
ID : 402, Type : LXC, OS : Debian, Fonction : Proxy.

### Modèles (Templates)
- **501-TPL-DEBIAN-BASE**  
ID : 501, Type : Modèle, OS : Debian, Fonction : Base générique.  
- **502-TPL-WIN10-CLIENT**  
ID : 502, Type : Modèle, OS : Windows 10, Fonction : Client générique.

### Outils spécifiques
- **601-TOOLS-NAS-SYN01**  
ID : 601, Type : Outils, Fonction : NAS Synology n°1.  
- **602-TOOLS-PFSENSE-FW01**  
ID : 602, Type : Outils, Fonction : Routeur pfsense n°1.  

- **1000-1100**  
  - **Type de machine** : Lab formation - VM ou LXC  
  - **Détails** : Machines utilisées pour un environnement de formation (serveurs ou clients).  
  - **Convention de nomenclature** :  
    ```
    Type-OS-TYPE(NUM)
    ```
    - **Exemples** :  
      - `LXC-DEBIAN-SERVEUR-01` : Conteneur LXC Debian utilisé comme serveur.  
      - `VM-WIN10-CLIENT-01` : Machine virtuelle Windows 10 utilisée comme client.  
      - `LXC-UBUNTU-CLIENT-02` : Conteneur LXC Ubuntu utilisé comme client n°2.
---

## 4. Convention de nommage des OS
| **OS**            | **Abréviation** |
|-------------------|-----------------|
| Debian            | DEBIAN          |
| Ubuntu            | UBUNTU          |
| CentOS            | CENTOS          |
| Windows 10        | WIN10           |
| Windows 11        | WIN11           |
| Windows Server 2019 | WIN2019       |
| pfsense           | PFSENSE         |
| Autre outil       | TOOL            |

---

## 5. Convention de nommage des rôles
| **Rôle**          | **Abréviation** |
|-------------------|-----------------|
| Serveur web       | WEB             |
| Base de données   | DB              |
| Proxy             | PROXY           |
| Contrôleur de domaine | SRVAD       |
| Client            | CLIENT          |
| Docker            | DOCKER          |
| NAS               | NAS             |
| Pare-feu          | FW              |

---

## 6. Recommandations
- **Plage 100-199 libre** : Projets futurs ou des besoins non prévus.
- **Utilisation des préfixes d'environnement** :  
- `DEV` pour développement.  
- `PROD` pour production.  
- Exemple : `301-VM-DEBIAN-DEV-WEB` pour un serveur web de développement.
- **Suivi dans un tableau** : Documentez les ID dans un fichier pour éviter tout conflit.
- **Documentation importante** : Conservez une liste des utilisateurs et permissions associées dans un fichier sécurisé pour éviter les oublis ou les conflits.
---
