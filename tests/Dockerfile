# tests/Dockerfile

FROM python:3.11-slim

# Installer les dépendances nécessaires
COPY requirements.txt /tmp/
RUN apt-get update \
    && pip install --no-cache-dir -r /tmp/requirements.txt \
    && pip install --no-cache-dir pytest \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copier app.py et test_app.py dans le conteneur
COPY app.py /app/app.py
COPY tests/test_app.py /app/tests/test_app.py

# Définir le dossier de travail
WORKDIR /app/tests

# Définir le chemin d'import Python
ENV PYTHONPATH=/app

# Point d’entrée par défaut (peut être redéfini)
CMD ["sh", "-c", "pytest -s"]