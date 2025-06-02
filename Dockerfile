FROM python:3.11-slim

# Définir le dossier de travail
WORKDIR /app

# Copier le code source
COPY . /app

# Copier requirements.txt en amont du RUN pour installation
COPY requirements.txt /tmp/requirements.txt

# Installation de curl + dépendances Python
RUN apt-get update \
    && apt-get install -y curl \
    && pip install --no-cache-dir -r /tmp/requirements.txt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Définir les variables d'environnement
ENV PORT=8080
ENV FLASK_APP=app.py

# Exposer le port (utile pour documentation, pas obligatoire pour fonctionnement)
EXPOSE 8080

# Lancer l'application Flask
CMD ["python", "app.py"]