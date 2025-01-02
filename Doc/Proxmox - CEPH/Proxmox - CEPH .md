# Mise en place Proxmox + Ceph : virtualisation Open Source

![alt text](image.png)

## Qu'est-ce que Proxmox VE ?
Proxmox Virtual Environment (Proxmox VE) est une plateforme open source de virtualisation. Elle permet de gérer des machines virtuelles (VM) et des conteneurs, offrant une interface web intuitive pour une administration simplifiée. Proxmox VE supporte les hyperviseurs KVM (Kernel-based Virtual Machine) et LXC (Linux Containers), permettant ainsi de déployer facilement des environnements virtualisés.

## Qu'est-ce que Ceph ?
Ceph est un système de stockage distribué conçu pour offrir une haute performance, une grande évolutivité et une tolérance aux pannes. Il permet de stocker des données de manière redondante et distribuée sur plusieurs nœuds, assurant ainsi une haute disponibilité et une récupération rapide en cas de panne. Ceph offre plusieurs interfaces de stockage, y compris le stockage d'objets, le stockage de blocs et le système de fichiers.

## Quelles sont les avantages de l'intégration de Proxmox et de Ceph ?

Haute Disponibilité : Avec Ceph, les données sont répliquées sur plusieurs nœuds, ce qui garantit que vos VM et conteneurs restent disponibles même en cas de panne d'un serveur.

Scalabilité : Ajouter des ressources de stockage et de calcul est simple et peut être fait sans interruption de service.

Gestion Centralisée : L'interface web de Proxmox VE permet de gérer facilement l'infrastructure de virtualisation et le stockage Ceph, réduisant ainsi la complexité administrative.

Performance Optimale : Ceph offre un stockage haute performance, idéal pour les applications critiques et les charges de travail intensives.

## Mise en place d'un Cluster Proxmox VE avec Ceph

Dans la suite de cet article, nous allons installer et configurer un cluster Proxmox en haute disponibilité, intégrant Ceph pour le stockage distribué.

### Doc officielle:

https://pve.proxmox.com/wiki/Deploy_Hyper-Converged_Ceph_Cluster

#### Étape 1: Installation de Proxmox VE

Installez Proxmox VE sur vos serveurs physiques ou virtuels.

Nous allons installer trois serveurs Proxmox avec des configurations identiques, et avec trois interfaces réseau minimum chacun.
![alt text](image-2.png)

Les trois PVE qui vont constituer notre cluster

![alt text](image-3.png)

#### Étape 2: Configuration du réseau

Configurez les adresses IP et les noms d'hôtes pour assurer une communication fluide entre les serveurs.

PVE-1 : 192.168.0.111

PVE-2: 192.168.0.112

PVE-3: 192.168.0.113

Sur chaque serveur Proxmox il faudra modifier le fichier /etc/hosts comme suit:

![alt text](image-4.png)

#### Puis nous devrons créer au moins trois réseaux bien distincts:

En cas de doute, nous recommandons d'utiliser trois réseaux (physiques) distincts pour les configurations à hautes performances : un réseau à très haut débit (25 Gbit/s et plus) pour le trafic du cluster Ceph (interne). Un second réseau à haut débit (10 Gbit/s et plus) pour le trafic Ceph (public) entre le serveur Ceph et le trafic de stockage du client Ceph.

## Étape 3: Initialisation du Cluster

Créez et joignez les serveurs au cluster Proxmox.

Nous pouvons créer notre cluster en ligne de commande avec:
```bash
pvecm create mon cluster 
```
Ou directement sur le portail web d'un des trois nœuds comme suit:

![alt text](image-5.png)

Le Cluster est créé sur le PVE-1. Nous devons maintenant joindre le PVE-2 et le PVE-3 au Cluster que nous venons de créer.

Pour ce faire, nous nous connectons sur l’interface web de notre PVE-2 qui est sur 192.168.0.112, et nous allons sur « Datacenter » > « Cluster » > « Join Cluster ». En français cela donne:

![alt text](image-6.png)

Pour joindre un Cluster Proxmox à partir du second ou troisième nœud, nous devons au préalable récupérer les informations de jonction sur le premier nœud, sur lequel nous avons créé le Cluster, comme suit : « Datacenter » > « Cluster » > « Join Information ».

![alt text](image-7.png)

On copie le contenu de « Join information » pour le coller dans « Information » de la fenêtre de jonction du Cluster sur le PVE-2 et du PVE-3.
![alt text](image-8.png)
![alt text](image-9.png)
![alt text](image-10.png)
Et voila le résultat, notre cluster de trois nœuds tout neuf !
![alt text](image-11.png)

## Étape 4: Installation de Ceph
Installez Ceph sur chaque serveur du cluster.
![alt text](image-12.png)
![alt text](image-13.png)
![alt text](image-14.png)

## Étape 5: Configuration de Ceph

A cette étape nous allons configurer les Monitors et Managers pour gérer l'état et les opérations du cluster Ceph.
![alt text](image-16.png)
![alt text](image-17.png)

Etat final recherché :)

![alt text](image-18.png)

## Étape 6: Ajouter des OSDs (Object Storage Daemons)

Les OSDs stockent les données réelles dans le cluster Ceph et participent à la réplication et la récupération des données.

Sur chaque serveur, ajoutez des OSDs. Vous pouvez utiliser des disques spécifiques ou les partitions existantes.

![alt text](image-19.png)

Etat final recherché dans Ceph > OSD:

![alt text](image-20.png)

## Étape 7: Configuration du pool de stockage Ceph

Créez un pool de stockage dans Ceph pour organiser et gérer les données, notamment pour le stockage de nos machines virtuelles.

![alt text](image-21.png)
![alt text](image-22.png)

Si on clique sur Avancé, nous pouvons voir le calcul du PG:
![alt text](image-23.png)

Le nombre de Placement Groups (PG) dans un cluster Ceph est une variable critique qui affecte la performance et la résilience du stockage distribué. Le calcul optimal des PG peut aider à équilibrer la charge et à garantir une gestion efficace des données. Voici comment calculer le nombre de PG approprié pour un pool Ceph.

#### Formule de Calcul des PGs

Avant d'aller plus loin je vous conseille de lire ceci:

https://docs.ceph.com/en/nautilus/rados/operations/placement-groups

La formule recommandée pour déterminer le nombre de PG est :

Nombre de PG = Nombre d'OSD x 100 / facteur de réplication

![alt text](image-24.png)

Cependant, il est important d'ajuster ce nombre pour qu'il soit une puissance de 2 (par exemple, 128, 256, 512, etc.), car Ceph fonctionne plus efficacement avec des valeurs de PG qui sont des puissances de 2.

Imaginons que nous avons 6 OSDs, la formule à appliquer nous donne:

![alt text](image-25.png)

Pour vous simplifier la tache, il est conseillé d'activer le PG-Autoscaler.

![alt text](image-26.png)

Notre pool Ceph est automatiquement ajouté comme stockage dans Proxmox VE. Il sera utilisé par les VM et conteneurs, offrant ainsi une haute disponibilité et une redondance des données.

![alt text](image-27.png)

### Étape 8: Configuration de la Haute Disponibilité (HA)

Nous allons voir comment configurer la haute disponibilité (HA) dans Proxmox. Pour cela, il est nécessaire que le stockage des machines virtuelles soit partagé entre les serveurs du groupe HA.

La haute disponibilité dans Proxmox est gérée via des groupes de haute disponibilité auxquels les serveurs appartiennent. Cela permet, par exemple, de regrouper différents types de serveurs membres d’un cluster et d'organiser les serveurs de type identique dans un même groupe.

#### Pour créer le groupe HA:
![alt text](image-28.png)

Ensuite nous pouvons intégrer dans le groupe HA les VM de notre choix:

![alt text](image-29.png)

D'après le screen de dessus, la VM 100 (srv-web-01) est configurée pour être en haute disponibilité.

### Étape 9: Test - Simulation de la panne d'un nœud

![alt text](image-30.png)
VM 101 qui tourne sur le PVE-1

![alt text](image-31.png)
Arrêt du nœud PVE-1

![alt text](image-32.png)
Début du la bascule de la VM 101

![alt text](image-33.png)

Comme vous pouvez le constater, avec la "panne" du nœud PVE-1 notre la machine VM 101 a basculée en quelques secondes sur le nœud PVE-2! 🏆





Vous voilà désormais aux commandes d'une infrastructure hyperconvergée à la fois puissante, flexible et – cerise sur le gâteau – quasi gratuite (mis à part, bien sûr, le coût du matériel et le support Pro). ;)

![alt text](image-34.png)

Proxmox couplé à Ceph se démarque par son coût quasi-nul et sa flexibilité remarquable. Attention cependant, il requiert une certaine expertise technique pour être parfaitement maîtrisé.

De l'autre côté de la balance, nous avons des mastodontes comme VMware et Nutanix. Ces solutions sont bardées de fonctionnalités avancées et d'un support client à toute épreuve, mais à des coûts parfois stratosphériques.

En fonction de vos besoins spécifiques; budget, complexité de gestion et fonctionnalités requises, vous pouvez choisir la solution HCI qui vous convient le mieux. 

Et laissez-moi vous dire, Proxmox avec Ceph n’ont absolument pas à rougir devant ces géants du marché !



Pour plus d'informations sur Proxmox (et pas que) je vous invite à visiter les blog de Stephane ROBERT 🐳 : https://blog.stephane-robert.info/, un des meilleurs blogs francophone dans le domaine de DevSecOps.