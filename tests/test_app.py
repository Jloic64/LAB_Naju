# test_app.py

import pytest
from app import app  # Import de l’application Flask à tester

# Fixture Pytest : configuration d’un client de test Flask
@pytest.fixture
def client():
    # Activation du mode test de Flask (désactive le gestionnaire d’erreurs, etc.)
    app.config['TESTING'] = True

    # Création d’un client de test simulant un navigateur
    with app.test_client() as client:
        yield client  # Le client est accessible dans les tests

# Test de la page d’accueil
def test_index_page(client):
    print("▶️  Test de la page d'accueil `/`...")

    # Envoi d’une requête GET vers la racine de l'application
    response = client.get('/')

    # Vérifie que la réponse HTTP est bien 200 (succès)
    assert response.status_code == 200, "❌ Le code HTTP de la page d'accueil n'est pas 200"

    # Vérifie que le mot-clé 'Visites' est bien présent dans le contenu de la réponse
    assert b'Visites' in response.data, "❌ Le mot 'Visites' n'est pas présent dans la réponse"

    print("✅ La page d'accueil retourne bien un statut 200 et affiche le compteur de visites.")
