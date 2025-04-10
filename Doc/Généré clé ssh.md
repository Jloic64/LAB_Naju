# Génération des clés communs window linux
ssh-keygen -t rsa -b 4096

# SSH (pour linux)
ssh-copy-id loic@10.108.0.50

# SSH copy id
Get-Content C:\Users\Loic\.ssh\id_rsa.pub | ssh loic@10.108.0.50 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
