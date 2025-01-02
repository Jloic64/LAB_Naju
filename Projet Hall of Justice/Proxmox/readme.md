<p align="center">
    <img src="img/proxmox.png" style="width: 1000px;" />
</p>

# Concepts de Base de Proxmox

## Qu'est-ce que Proxmox ?
Proxmox est une solution open-source de gestion de virtualisation qui combine deux technologies principales :

- KVM (Kernel-based Virtual Machine) : Pour la virtualisation complète de machines.
- LXC (Linux Containers) : Pour la gestion de conteneurs légers.

Proxmox est conçu pour simplifier la gestion d'une infrastructure virtualisée grâce à une interface web intuitive et de puissants outils d'administration.

## Principaux Concepts de Proxmox

### Virtualisation (VM) avec KVM
- Permet de créer des machines virtuelles isolées avec un système d'exploitation complet.
- Idéal pour des applications ou des charges de travail nécessitant un environnement totalement séparé.

### Conteneurs (LXC)
- LXC offre des environnements virtualisés plus légers.
- Partage le noyau Linux de l’hôte, ce qui réduit l'empreinte mémoire et augmente la rapidité.

### Cluster Proxmox
- Regroupe plusieurs nœuds Proxmox dans une seule interface de gestion.
- Permet la migration à chaud des machines virtuelles ou conteneurs entre les nœuds.

### Haute disponibilité (HA)
- Assure que les VM et conteneurs redémarrent automatiquement sur d'autres nœuds en cas de panne.

### Snapshots et Backups
- **Snapshots** : Sauvegarde rapide de l'état d'une VM ou d'un conteneur à un instant donné.
- **Backups** : Permettent de restaurer des machines virtuelles ou conteneurs en cas de besoin.

### Gestion du stockage
- Supporte plusieurs types de stockage : local, NAS (NFS, SMB), SAN (iSCSI), CEPH, etc.

### Réseautage
- Configuration des interfaces réseau (ponts, VLANs) pour la connectivité des VM et conteneurs.

---
### Liens vers la documentation officielle

- [Documentation officielle de Proxmox VE](https://pve.proxmox.com/wiki/Main_Page)
- [Guide de l'utilisateur Proxmox VE](https://pve.proxmox.com/pve-docs/)
- [Forum officiel Proxmox](https://forum.proxmox.com/)

Ces ressources offrent des détails sur les concepts, configurations avancées, et solutions aux problèmes fréquents.


