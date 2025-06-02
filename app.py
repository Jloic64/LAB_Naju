from flask import Flask
from redis import Redis, RedisError
import os
import socket

app = Flask(__name__)

# Connexion à Redis
redis = Redis(host="redis", db=0, socket_connect_timeout=2, socket_timeout=2)

@app.route("/")
def index():
    env = os.getenv("APP_ENV", "inconnu")   #
    try:
        visites = redis.incr("compteur")
        redis_status = "✅ Connexion réussie à Redis"
    except RedisError:
        visites = "<i>Erreur</i>"
        redis_status = "❌ Connexion à Redis échouée"

    html = f"""
    <html>
    <head>
        <title>Mini App Docker</title>
        <style>
            body {{
                font-family: Arial, sans-serif;
                text-align: center;
                background-color: #f0f2f5;
                color: #333;
                margin-top: 50px;
            }}
            h1 {{
                color: #007bff;
            }}
            .container {{
                background: white;
                padding: 20px;
                border-radius: 10px;
                box-shadow: 0 0 10px rgba(0,0,0,0.1);
                display: inline-block;
            }}
            .info {{
                margin-top: 15px;
                font-size: 1.1em;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>👋 Bonjour les AIS P3 !</h1>
            <div class="info">
                <p><strong>Hostname :</strong> {socket.gethostname()}</p>
                <p><strong>Environnement :</strong> {env}</p> 
                <p><strong>Visites :</strong> {visites}</p>
                <p><strong>Status Redis :</strong> {redis_status}</p>
            </div>
            <hr/>
            <p>🚀 Cette mini app est utilisée dans un atelier gitlab Docker & CI/CD 🐳</p>
            <p>✨ Modifie le code, relance le pipeline, et vois les changements !</p>
            <p> MODIFICATION DE DEMONSTRATION </p>
        </div>
    </body>
    </html>
    """
    return html

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)