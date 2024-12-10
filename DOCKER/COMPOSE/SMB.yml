## Compose avec variables :
```

version: '3.8'

services:
  samba:
    image: dperson/samba
    container_name: samba
    network_mode: "bridge"
    volumes:
      - /chemin/sur/hote:/montage
      - /chemin/sur/hote/smb.conf:/etc/samba/smb.conf:ro
    ports:
      - "139:139"
      - "445:445"
    command: ['-s', 'Partage;/montage;yes;no;no', '-u', 'utilisateur;motdepasse']
    restart: always

```