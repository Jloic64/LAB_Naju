
# Documentation du Cluster Proxmox

## 1. Informations Générales du Cluster

### Nom du Cluster
- **Nom** : Hall_of_Justice
- **Version de configuration** : 3
- **Transport** : knet
- **Authentification sécurisée** : Activée

### Quorum Information
- **Date** : Thu Apr 10 16:21:50 2025
- **Fournisseur de quorum** : corosync_votequorum
- **Nombre de nœuds** : 3
- **Quorate** : Oui


---

## 2. Membres du Cluster

| Nodeid    | Votes | Nom      |
|-----------|-------|----------|
| 0x00000001| 1     | BRUCE    |
| 0x00000002| 1     | CLARK    |
| 0x00000003| 1     | DIANA      |

---


## 4. Informations sur les Nœuds du Cluster

| Node ID     | Votes | Nom       | Adresse IP   | Statut          |
|-------------|-------|-----------|--------------|------------------|
| 0x00000001  | 1     | BRUCE     | 192.168.1.245| En ligne         |
| 0x00000002  | 1     | CLARK     | 192.168.1.246| En ligne         |
| 0x00000003  | 1     | DIANA     | 192.168.1.247| En ligne  |

---

## 5. Matériel des Nœuds

### Nœud BRUCE
- **Modèle** : PowerEdge T420
- **Processeur** : 2 x Intel Xeon E5-2403
- **Mémoire** : 104 GiB

#### Disques
- /dev/sda : 1.8T (ISO Storage)
- /dev/sdb/c/d : 931G (Ceph OSDs)
- /dev/sde : 1.8T (Backup)
- /dev/sdf : 128G (Système Proxmox)

#### Réseau
- eno1, eno2 : NetXtreme BCM5720

---

### Nœud CLARK
- **Modèle** : PowerEdge T320
- **Processeur** : Intel Xeon E5-1410
- **Mémoire** : 32 GiB

#### Disques
- /dev/sda/b/c : 931G (Ceph OSDs)
- /dev/sdd : 256G (Système Proxmox)

#### Réseau
- eno1, eno2 : NetXtreme BCM5720

---

### Nœud DIANA
- **Modèle** : HP Pro Mini 400 G9
- **Processeur** : Intel Core i5-13500T
- **Mémoire** : 8 GiB

#### Disques
- /dev/sda : 114G (SanDisk USB)
- /dev/nvme0n1 : 238G (Système Proxmox)

#### Réseau
- eno1 : I219-LM
- wlp2s0 : Wi-Fi

---

## 6. Machines Virtuelles (Nœud BRUCE)

| VMID  | Nom                        | Statut   | RAM (MB) | Disque (GB) |
|-------|----------------------------|----------|----------|-------------|
| 101   | VM-WIN10-CLI01             | running  | 8768     | 80.00       |
| 1000  | VM-FW-PFSENSE-LAB          | stopped  | 2048     | 32.00       |
| 3000  | MODEL-DEBIAN12             | stopped  | 8576     | 32.00       |
| 3001  | 3001-TPL-DEBIAN12-CLOUDINIT| stopped  | 2048     | 10.00       |
| 10001 | ubuntu24.04-cloudinit      | stopped  | 2048     | 10.00       |
