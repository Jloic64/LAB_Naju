#!/bin/bash

# Mettre à jour la liste des paquets
echo "Mise à jour de la liste des paquets..."
sudo apt update

# Installer vsftpd
echo "Installation de vsftpd..."
sudo apt install -y vsftpd

# Sauvegarder le fichier de configuration original
echo "Sauvegarde du fichier de configuration original..."
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.orig

# Configurer vsftpd
echo "Configuration de vsftpd..."

# Créer un nouveau fichier de configuration vsftpd.conf
sudo tee /etc/vsftpd.conf > /dev/null <<EOL
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=YES
pasv_enable=YES
pasv_min_port=10000
pasv_max_port=10100
EOL

# Créer un utilisateur FTP pour les tests
echo "Création d'un utilisateur FTP pour les tests..."
sudo useradd -m ftpuser
echo "ftpuser:password" | sudo chpasswd

# Créer un répertoire FTP et définir les permissions
echo "Création du répertoire FTP et définition des permissions..."
sudo mkdir -p /home/ftpuser/ftp
sudo chown nobody:nogroup /home/ftpuser/ftp
sudo chmod a-w /home/ftpuser/ftp
sudo mkdir -p /home/ftpuser/ftp/upload
sudo chown ftpuser:ftpuser /home/ftpuser/ftp/upload

# Redémarrer le service vsftpd
echo "Redémarrage du service vsftpd..."
sudo systemctl restart vsftpd

# Vérifier le statut du service vsftpd
echo "Vérification du statut du service vsftpd..."
sudo systemctl status vsftpd

echo "Installation et configuration de vsftpd terminées !"
echo "Vous pouvez vous connecter avec l'utilisateur 'ftpuser' et le mot de passe 'password'."

#Pour exécuter ce script, enregistrez-le dans un fichier, par exemple install_vsftpd.sh, puis rendez-le exécutable et exécutez-le :
#chmod +x install_vsftpd.sh
#sudo ./install_vsftpd.sh