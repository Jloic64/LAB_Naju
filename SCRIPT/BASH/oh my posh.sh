#!/bin/bash

set -e  # Arrête le script en cas d'erreur

echo "🚀 Installation d'Oh My Posh pour Debian 12..."

# 1️⃣ Mise à jour du système et installation des dépendances
echo "📦 Mise à jour et installation des dépendances..."
sudo apt update && sudo apt install -y curl unzip

# 2️⃣ Installation d'Oh My Posh
echo "🔽 Installation d'Oh My Posh..."
curl -s https://ohmyposh.dev/install.sh | bash

# 3️⃣ Vérification du binaire
if [ ! -f "/root/.local/bin/oh-my-posh" ]; then
    echo "❌ Échec de l'installation d'Oh My Posh !"
    exit 1
fi

# 4️⃣ Définition du chemin pour tous les utilisateurs
echo "🔧 Ajout d'Oh My Posh au PATH..."
echo 'export PATH=$PATH:$HOME/.local/bin' | sudo tee -a /etc/profile.d/ohmyposh.sh > /dev/null
sudo chmod +x /etc/profile.d/ohmyposh.sh

# 5️⃣ Télécharger le thème quick-term pour root et chaque utilisateur
THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/quick-term.omp.json"

apply_ohmyposh_for_user() {
    local USERNAME=$1
    local USER_HOME=$(eval echo ~$USERNAME)

    echo "🎨 Configuration d'Oh My Posh pour $USERNAME ($USER_HOME)..."

    # Créer le dossier des thèmes
    mkdir -p "$USER_HOME/.poshthemes"

    # Télécharger le thème quick-term
    curl -sL "$THEME_URL" -o "$USER_HOME/.poshthemes/quick-term.omp.json"

    # Appliquer la configuration dans ~/.bashrc
    echo 'eval "$(oh-my-posh init bash --config ~/.poshthemes/quick-term.omp.json)"' >> "$USER_HOME/.bashrc"

    # Donner la bonne propriété au fichier si ce n'est pas root
    if [ "$USERNAME" != "root" ]; then
        chown -R "$USERNAME:$USERNAME" "$USER_HOME/.poshthemes"
    fi
}

# Appliquer la configuration pour root
apply_ohmyposh_for_user "root"

# Appliquer la configuration pour tous les utilisateurs
for USER in $(ls /home); do
    apply_ohmyposh_for_user "$USER"
done

# Appliquer immédiatement la configuration pour root
source /root/.bashrc

echo "✅ Installation et configuration terminées ! Redémarre le terminal pour voir les changements. 🚀"
