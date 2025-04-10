
# 🚀 Création et Configuration d'une VM Ubuntu 24.04 avec Cloud-Init sur Proxmox

## 🧱 Pré-requis

- **Proxmox** avec un nœud nommé **BRUCE**.
- **VM ID 10001** pour la VM Ubuntu.
- **Stockage** : `vm-ceph` pour les disques et `local` pour Cloud-Init.
- **Bridge réseau** : `vmbr0`.

---

# 🚀 Téléchargement et Personnalisation d'Ubuntu pour Cloud-Init

## 📥 Se connecter au shell Proxmox et télécharger l'image Ubuntu

```bash
cd /tmp
wget http://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
```

## 🔧 Installer virt-customize

```bash
sudo apt update && sudo apt install libguestfs-tools -y
```

## 🛠️ Personnalisation de l'image

```bash
# Personnalisation de l'image Ubuntu Cloud-Init avec virt-customize

# Spécifie l'image disque à modifier
virt-customize -a /tmp/noble-server-cloudimg-amd64.img 
  # Définit le mot de passe root (à éviter en clair en production)
  --root-password password:coucou 
  # Injecte une clé SSH pour l'utilisateur root
  --ssh-inject root:file:.ssh/authorized_keys 
  # Installe le QEMU Guest Agent (utile pour l'intégration avec Proxmox)
  --install qemu-guest-agent 
  # Installe resolvconf (gestion DNS)
  --install resolvconf 
  # Installe systemd-resolved (service DNS de systemd)
  --install systemd-resolved 
  # Met à jour tous les paquets de l'image
  --update 
  # Crée le dossier de configuration des interfaces réseau
  --run-command 'mkdir -p /etc/network/interfaces.d' 
  # Active l'interface réseau ens18 au démarrage
  --run-command 'echo "auto ens18" >> /etc/network/interfaces.d/ens18' 
  # Configure ens18 en mode 'manual' (souvent utilisé avec Cloud-Init)
  --run-command 'echo "iface ens18 inet manual" >> /etc/network/interfaces.d/ens18'
```

---

# 🚀 Création et Configuration de la VM Ubuntu 24.04 avec Cloud-Init sur Proxmox

## 📝 Étapes de configuration :

### 1. **Création de la VM**

Crée la VM avec 2 Go de RAM et une interface réseau `virtio` :

```bash
sudo qm create 10001 --name "ubuntu24.04-cloudinit" --memory 2048 --net0 virtio,bridge=vmbr0
```

---

### 2. **Création du template depuis l'image Ubuntu**

Une fois l'image Ubuntu personnalisée avec `virt-customize`, transforme cette VM en template :

```bash
sudo qm template 10001
```

Ce template pourra ensuite être utilisé dans Terraform pour créer de nouvelles machines virtuelles à partir de ce template Cloud-Init.

---

### 3. **Configuration du disque et du contrôleur SCSI sur `vm-ceph`**

Configure le contrôleur **SCSI** avec l'interface `virtio-scsi-pci` et utilise le **stockage `vm-ceph`** pour le disque :

```bash
sudo qm set 10001 --scsihw virtio-scsi-pci --scsi0 vm-ceph:10001/vm-10001-disk-0.qcow2
```

---

### 4. **Redimensionnement du disque à 10 Go**

Redimensionne le disque de la VM `10001` pour lui attribuer **10 Go** :

```bash
sudo qm resize 10001 scsi0 10G
```

---

### 5. **Ajout du disque Cloud-Init**

Ajoute un disque **Cloud-Init** via `ide2` dans le stockage **`vm-ceph`** :

```bash
sudo qm set 10001 --ide2 vm-ceph:cloudinit
```

---

### 6. **Configuration du démarrage sur le disque SCSI (`scsi0`)**

Configure le disque **SCSI** comme disque de démarrage de la VM :

```bash
sudo qm set 10001 --boot c --bootdisk scsi0
```

---

### 7. **Configuration de la console série**

Configure la **console série** pour accéder à la VM sans interface graphique :

```bash
sudo qm set 10001 --serial0 socket --vga serial0
```

---

### 8. **Transformation de la VM en template**

Une fois la VM configurée, transforme-la en **template** pour un clonage facile à l'avenir :

```bash
sudo qm template 10001
```

---

## 📌 Résumé des étapes :

1. **Création de la VM** avec `qm create`.
2. **Création du template** depuis l'image Ubuntu Cloud-Init personnalisée.
3. **Configuration du disque principal** avec un contrôleur SCSI sur **`vm-ceph`**.
4. **Redimensionnement du disque** à 10 Go.
5. **Ajout du disque Cloud-Init** pour l'initialisation automatique.
6. **Configuration du démarrage** sur le disque `scsi0`.
7. **Configuration de la console série** pour l'accès sans interface graphique.
8. **Transformation en template** pour un clonage rapide.

---

## 📝 Vérification et Suivi

1. Vérifie dans l'interface Proxmox que la **VM `10001`** est bien créée et configurée.
2. Teste l'**accès SSH** si Cloud-Init est configuré avec un mot de passe ou une clé SSH pour vérifier que tout fonctionne correctement.
3. Utilise la **VM template** pour cloner d'autres instances si nécessaire.
