# 🧰 Création d’un Template Debian 12 Cloud-Init dans Proxmox avec Ceph (RBD)

## 📥 1. Télécharger l’image Debian 12 Cloud

```bash
wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2 -P /tmp
```

## 🧪 2. Personnaliser l’image avec `virt-customize`

```bash
virt-customize \
  -a /tmp/debian-12-genericcloud-amd64.qcow2 \
  --root-password password:'Nahi@Julen08' \
  --ssh-inject root:file:/root/.ssh/id_rsa.pub \
  --install qemu-guest-agent \
  --install resolvconf \
  --install systemd-resolved \
  --update \
  --run-command 'mkdir -p /etc/network/interfaces.d' \
  --run-command 'echo "auto ens18" >> /etc/network/interfaces.d/ens18' \
  --run-command 'echo "iface ens18 inet manual" >> /etc/network/interfaces.d/ens18'
```

## 💻 3. Création de la VM dans Proxmox

```bash
qm create 3001 --name "3001-TPL-DEBIAN12-CLOUDINIT" --memory 2048 --net0 virtio,bridge=vmbr0
```

## 💾 4. Importer le disque dans Ceph

```bash
qm importdisk 3001 /tmp/debian-12-genericcloud-amd64.qcow2 vm-ceph --format qcow2
```

## 🔌 5. Attacher le disque avec contrôleur SCSI

```bash
qm set 3001 --scsihw virtio-scsi-pci --scsi0 vm-ceph:vm-3001-disk-0
```

## 📏 6. (Optionnel) Redimensionner le disque

```bash
qm resize 3001 scsi0 10G
```

## ☁️ 7. Ajouter un disque Cloud-Init

```bash
qm set 3001 --ide2 vm-ceph:cloudinit
```

## ⚙️ 8. Définir le disque de démarrage

```bash
qm set 3001 --boot c --bootdisk scsi0
```

## 🖥️ 9. Configurer la console série

```bash
qm set 3001 --serial0 socket --vga serial0
```

## 🧱 10. Convertir la VM en template

```bash
qm template 3001
```

## ✅ Résultat

- Le template `3001-TPL-DEBIAN12-CLOUDINIT` est prêt.
- Il peut être cloné via l’interface Proxmox ou utilisé avec Terraform.