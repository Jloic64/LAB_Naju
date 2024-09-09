# Parmi ces algorithmes, lesquels sont de type symétrique, asymétrique, de Hashage ? Lesquels ne devraient plus être utilisés ?

### Recommandés :

Symétrique : AES-256 avec XTS, AES-128 (avec un mode sûr comme CBC ou GCM)
Asymétrique : RSA avec OAEP
Hashage : SHA-2

### Déconseillés / obsolètes :

Symétrique : 3DES, AES avec ECB
Asymétrique : RSA avec PKCS1 (pour chiffrement)
Hashage : SHA1, MD5

# Grâce à un script, générer une clé de chiffrement AES256 ainsi que les IV avec le destinataire. Partagez là avec votre destinataire en essayant de préserver sa confidentialité.

Pour générer une clé AES-256 et un IV (vecteur d'initialisation) de manière sécurisée avec un destinataire, voici une méthode complète en Bash utilisant OpenSSL et RSA pour protéger la clé AES avant de la transmettre.

Étapes :
1. Générer une clé AES-256 et un IV avec OpenSSL.
2. Chiffrer la clé AES avec la clé publique RSA du destinataire pour garantir sa confidentialité.
3. Transmettre la clé chiffrée en toute sécurité.

```bash
 #!/bin/bash

# Générer une clé AES-256 (32 octets = 256 bits)
KEY=$(openssl rand -base64 32)

# Générer un vecteur d'initialisation (IV) de 16 octets (128 bits)
IV=$(openssl rand -base64 16)

# Afficher la clé AES et l'IV (base64)
echo "Clé AES-256 (Base64): $KEY"
echo "IV (Base64): $IV"

# Chemin vers la clé publique RSA du destinataire (au format PEM)
PUBLIC_KEY_PATH="chemin/vers/cle_publique_destinataire.pem"

# Chiffrer la clé AES avec la clé publique RSA du destinataire
echo -n "$KEY" | openssl rsautl -encrypt -pubin -inkey "$PUBLIC_KEY_PATH" -out encrypted_key.bin

# Convertir la clé chiffrée en Base64 pour un partage plus simple
ENCRYPTED_KEY_BASE64=$(base64 encrypted_key.bin)

# Afficher la clé AES chiffrée
echo "Clé AES chiffrée avec RSA (Base64): $ENCRYPTED_KEY_BASE64"

# Transmettre la clé chiffrée et l'IV au destinataire
# Vous pouvez l'envoyer par email sécurisé, message chiffré, ou tout autre canal sécurisé.
echo "Clé AES chiffrée et IV prêt à être partagés."
```

Explication du script :

1. Génération de la clé et de l'IV :
Utilisation d'OpenSSL pour générer une clé AES de 256 bits (32 octets) et un IV de 128 bits (16 octets), puis les convertir en Base64 pour un format plus lisible.
2. Chiffrement de la clé AES avec RSA :
La clé AES est chiffrée avec la clé publique RSA du destinataire (stockée dans un fichier PEM) en utilisant openssl rsautl. La clé chiffrée est ensuite convertie en Base64 pour être transmise facilement.
3. Partage sécurisé :
La clé chiffrée et l'IV sont prêts à être transmis via un canal sécurisé comme une messagerie chiffrée ou un email sécurisé.

### Le message suivant a été intercepté: "prggr grpuavdhr f'nccryyr yr puvsserzrag qr prnfre, vy a'rfg cyhf hgvyvft nhwbheq'uhv, pne crh ftphevft", il semble vulnérable à une attaque en fréquences ou une attaque par force brute. Déchiffrez-le !

Il s'agit d'un chiffrement de César avec un décalage simple.
Le message chiffré avec un décalage de 13 donne un résultat lisible. Le message déchiffré est :
"Cette technique s'appelle le chiffrement de César, il n'est plus utilisé aujourd'hui, car peu sécurisé"
https://www.dcode.fr/chiffre-cesar.

### Nous suspectons qu'un adversaire a implémenté une backdoor dans notre logiciel de messagerie sécurisé, pourtant nous utilisons AES-CBC, voici les logs :
``` 
Bob: '>s\x06\x14\x0c\xa7\xa6\x88\xd5[+i\xcc/J\xf7'
Alice: "3\x01\xeb\xcah\xf6\x1f\xc2[\xf9}P'A\xe0\xd5"
Bob: '\xf7\xb0\xc5\xccO\xab&\xee\xa4&6N?V\xbd\x85\x94b\xee\xc5\x18\x1f9\xe7\xe5\xe0\xffyf\xab\xfb\xb9
Alice: '\xde@=\x1ed\xc0Qe\x0fK=\x1c\xb3$\xd9\xcb'
Bob: '\xce\xbf\x0e\\\x8aX\x1c \xb2v\x97\xf5<\x86M\x86\x0c\xa1j\xa0\xe6\xa9\x11\xf9AyZ\xda9\x94ec'
Alice: "\xde@=\x1ed\xc0Qe\x0fK=\x1c\xb3$\xd9\xcb"
Bob: '\xfb\x0cc\xb0/\xd4:\xde\xe7a\x95_L\x8d\x108\xac\xff\xcep\x8e&\xcfq6ym\x0c\xf6\xccI\xed'
Alice: '\xee\xcb\xd0\x9aRt;\x12\xca\xfe\r\x01MN>\xde'
Bob: '\xab\x8aX\xef\xd4\xf3\x88a\x1a\x96\r\xec\x17\xe6s"\x94\xec6\xe0\xff \x82\xa1\xb4\xe2\xc1\x08\r!T\x89\xe2B\x1d^\xf7l\xd8\xc9\xa4\xcd\xa5\x8e\xb3\x1d\x1f\xe7'
Alice: '\xee\xcb\xd0\x9aRt;\x12\xca\xfe\r\x01MN>\xde'
Alice: '\x1f\xafV4\xcb\x116N\xc5.\xa8\xdfM\xcf\xda\x02\x98\xbb\x04\x04C}N{\xf95\x05e\xc6\xf9\xbe,'
Bob: '\xde@=\x1ed\xc0Qe\x0fK=\x1c\xb3$\xd9\xcb'
```
## Trouver le problème et proposer une solution. 

Plusieurs messages d'Alice sont identiques, par exemple :
Alice: '\xde@=\x1ed\xc0Qe\x0fK=\x1c\xb3$\xd9\xcb' est répété deux fois, ce qui suggère qu'un IV est réutilisé, ou que les données chiffrées sont identiques, ce qui est un signe d'une mauvaise gestion des IV.
De plus, certains messages de Bob et Alice sont très similaires, ce qui pourrait indiquer que les mêmes blocs de texte sont chiffrés de manière identique, ou que les mêmes données sont transmises plusieurs fois avec des IV potentiellement réutilisés.
La réutilisation de l'IV dans l'AES-CBC permet à un attaquant d'identifier quand deux messages sont les mêmes, ou de tenter une attaque par rejeu ou par analyse de texte chiffré.

## Solution :
Pour résoudre ce problème, voici les étapes à suivre :

IV unique pour chaque message : Assurez-vous que chaque message utilise un IV totalement aléatoire et unique. L'IV ne doit jamais être réutilisé, même pour des messages similaires ou répétés. Vous pouvez envoyer l'IV en clair avec le message, car il ne doit pas être secret.

Authentification des messages :

Implémentez un mécanisme de vérification d'intégrité comme un HMAC (Hash-based Message Authentication Code) ou utilisez un mode de chiffrement authentifié comme AES-GCM (Galois/Counter Mode). Cela permet de garantir que les messages ne sont pas modifiés ou falsifiés par un adversaire.
Si vous continuez à utiliser AES-CBC, il est crucial d'ajouter un MAC pour s'assurer que le message n'a pas été modifié.
Vérification des doublons :

Implémentez une méthode pour détecter et rejeter les messages répétés, ou utilisez un mécanisme de non-repudiation pour empêcher les attaques par rejeu.

### Nous avons intercepté le message suivant: b'\xd72U\xc03.\xda\x99Q\xb5\x020\xc4\xb8\x16\xc6\xfa-\xb9U+\xda\\\x126L\xf3~\xbd8\x12q\x02?\x80\xeaVI\xa9\xe1'.

La première partie de la Clé de 16 octets est: b'12345678bien' et l'algorithme utilisé est celui-ci:
``` 
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
from cryptography.hazmat.backends import default_backend

def des_encrypt(key, plaintext):
    cipher = Cipher(algorithms.TripleDES(key), modes.ECB(), backend=default_backend())
    encryptor = cipher.encryptor()
    padder = padding.PKCS7(64).padder()
    padded_data = padder.update(plaintext) + padder.finalize()
    ct = encryptor.update(padded_data) + encryptor.finalize()
    return ct

def des_decrypt(key, ciphertext):
    cipher = Cipher(algorithms.TripleDES(key), modes.ECB(), backend=default_backend())
    decryptor = cipher.decryptor()
    pt = decryptor.update(ciphertext) + decryptor.finalize()
    unpadder = padding.PKCS7(64).unpadder()
    unpadded_data = unpadder.update(pt) + unpadder.finalize()
    return unpadded_data
```
### Quel était le message transmis ?

Pour décrypter le message intercepté, nous devons d'abord compléter la clé avec la deuxième partie, puis utiliser la fonction des_decrypt avec l'algorithme TripleDES en mode ECB.

Étapes :
1. Vous avez la première partie de la clé : b'12345678bien'. La clé de TripleDES doit avoir une longueur de 16 ou 24 octets. Si la clé est incomplète, nous devons déterminer comment la compléter (p. ex., ajouter des octets pour atteindre 16 ou 24 octets).
2. Le message intercepté est : b'\xd72U\xc03.\xda\x99Q\xb5\x020\xc4\xb8\x16\xc6\xfa-\xb9U+\xda\\\x126L\xf3~\xbd8\x12q\x02?\x80\xeaVI\xa9\xe1'.
Hypothèses :
Si la clé est de 16 octets, nous devons ajouter des octets pour compléter la clé.
L'algorithme utilisé est TripleDES en mode ECB, avec un padding PKCS7 sur 64 bits.

Code de décryptage :


``` Python
# Importation des modules nécessaires
# cryptography.hazmat : Pour le chiffrement et le déchiffrement
# itertools : Pour générer toutes les combinaisons de caractères possibles
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
from cryptography.hazmat.backends import default_backend
import itertools

# Fonction de déchiffrement utilisant l'algorithme Triple DES
def des_decrypt(key, ciphertext):
    # Initialisation de l'objet Cipher avec l'algorithme 3DES et le mode ECB
    # Mode ECB est utilisé mais il n'est pas recommandé pour la sécurité moderne
    cipher = Cipher(algorithms.TripleDES(key), modes.ECB(), backend=default_backend())
    
    # Création de l'objet de déchiffrement
    decryptor = cipher.decryptor()
    
    # Déchiffrement du texte chiffré
    pt = decryptor.update(ciphertext) + decryptor.finalize()
    
    # Retrait du padding (remplissage) pour retrouver le texte original
    unpadder = padding.PKCS7(64).unpadder()
    unpadded_data = unpadder.update(pt) + unpadder.finalize()
    
    # Retourne les données déchiffrées sans padding
    return unpadded_data

# Texte chiffré à déchiffrer (donné en hexadécimal)
ciphertext = b'\xd72U\xc03.\xda\x99Q\xb5\x020\xc4\xb8\x16\xc6\xfa-\xb9U+\xda\x12F\\xf3~\xbd8\x12q\x02?\x80\xeaVI\xa9\xe1'

# Partie connue de la clé (12 octets), il manque 4 octets à découvrir
key_part = b'12345678bien'

# Liste des caractères possibles (lettres minuscules ASCII : 'a' à 'z')
possible_chars = map(chr, range(97, 123))

# Boucle pour tester toutes les combinaisons possibles de 4 lettres
for chars in itertools.product(possible_chars, repeat=4):
    # Construction de la clé complète en ajoutant la combinaison de 4 lettres à la clé partielle
    key = key_part + ''.join(chars).encode()
    
    try:
        # Tente de déchiffrer le message avec la clé complète
        plaintext = des_decrypt(key, ciphertext)
        
        # Si le déchiffrement réussit, on affiche la clé et le message déchiffré
        print("Clé trouvée :", key)
        print("Message déchiffré :", plaintext.decode('utf-8'))
        break  # On interrompt la boucle car la bonne clé a été trouvée
    except Exception as e:
        # Si le déchiffrement échoue (erreur d'encodage, clé incorrecte), on passe à la combinaison suivante
        continue

```

La clé partielle est donnée (b'12345678bien'), et il reste 4 octets à découvrir.
Le message chiffré est b'\xd72U\xc03.\xda\x99Q\xb5\x020\xc4\xb8\x16\xc6\xfa-\xb9U+\xda\x12F\\xf3~\xbd8\x12q\x02?\x80\xeaVI\xa9\xe1'.
Le programme teste toutes les combinaisons possibles de 4 lettres minuscules (ce qui représente 456,976 combinaisons).

### Message déchiffré : DES n'est plus sur de nors jours!