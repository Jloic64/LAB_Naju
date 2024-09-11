# Rapport d'Audit de Sécurité - Référentiel PASSI

## 1. Introduction 
Contexte de l'audit : 

ABC est une entreprise spécialisée dans le développement de logiciels, employant 30 salariés. Dans le cadre de son programme d'audit, ABC a sollicité nos services pour réaliser un audit de sécurité de certains composants de son système d'information (SI). 

Périmètre de l'audit : 

L’audit couvre le serveur Linux non intégré au domaine hébergeant un serveur FTP et un serveur Web. (Vérification de la sécurité et de la configuration du serveur).

## 2. Objectif de l'Audit

L'objectif de cet audit est d'évaluer la sécurité de l'infrastructure et des applications en place, afin d'identifier les vulnérabilités potentielles et de proposer des recommandations pour améliorer la sécurité globale du SI.


## 4. Méthodologie

Cet audit sera réalisé en suivant la méthodologie PASSI (Prestataire d'Audit de la Sécurité des Systèmes d'Information). Cette approche structurée nous permettra d'effectuer une évaluation complète et rigoureuse des composants du SI d'ABC. Les étapes principales de la méthodologie PASSI incluent l'analyse des risques, les tests techniques, les entretiens avec le personnel et l'observation sur le terrain.

## 5. Résumé Exécutif

Ce résumé présente les principaux constats de l'audit, les vulnérabilités critiques identifiées, et les recommandations clés.

### 5.1 Constat Global


| Critère                                      | Détails                                                             |
|----------------------------------------------|---------------------------------------------------------------------|
| **État général**                            | Critique                                                            |
| **Nombre de vulnérabilités identifiées**     | 12                                                                  |
| **Vulnérabilités critiques**                | 6                                                                   |
| **Risques majeurs identifiés**              | - Compromission par force brute (Fail2Ban non installé)              |
|                                              | - Saturation des journaux systèmes (Absence de partitionnement /var) |
|                                              | - Exposition à des attaques physiques ou des fuites de données par USB (USBGuard non installé) |
|                                              | - Compromission de la robustesse des mots de passe (Durée maximale de validité du mot de passe désactivée) |


---

## 6. Constatations Détaillées
Le serveur à était installé avec les configurations par défaut. 

### 6.1 Vulnérabilités Identifiées

| ID  | Type de vulnérabilité                                    | Niveau de risque | Impact potentiel                                                       | Priorité |
|-----|----------------------------------------------------------|------------------|------------------------------------------------------------------------|----------|
| 01  | Absence de Fail2Ban                                     | Élevé            | Compromission par force brute                                          | Haute    |
| 02  | Absence de partitionnement /var                         | Moyen            | Saturation des journaux systèmes et des logs                           | Moyenne  |
| 03  | Aucun mot de passe GRUB                                 | Élevé            | Modification des paramètres de démarrage par une personne non autorisée | Haute    |
| 04  | Permissions pour le répertoire /etc/sudoers.d            | Élevé            | Risque d'escalade de privilèges non autorisée                          | Haute    |
| 05  | Permissions pour le fichier de configuration CUPS        | Moyen            | Risque de sécurité lié aux permissions des fichiers                    | Moyenne  |
| 06  | wpa_supplicant.service                                  | Risqué           | Vulnérabilités potentielles dans la gestion des connexions Wi-Fi       | Haute    |
| 07  | user@1000.service                                       | Risqué           | Risque potentiel lié à des services utilisateurs mal configurés         | Haute    |
| 08  | systemd-rfkill.service                                  | Risqué           | Risque lié à la gestion des périphériques RF (Wi-Fi/Bluetooth)         | Haute    |
| 09  | USBGuard non installé                                   | Élevé            | Exposition du système à des attaques physiques ou à des fuites de données par USB | Haute    |
| 10  | Paramètres de timeout de session                        | Moyen            | Risque d'accès non autorisé en cas de session inactive                 | Moyenne  |
| 11  | Pas de scanner de malware                               | Élevé            | Système vulnérable aux menaces                                         | Haute    |
| 12  | Durée maximale de validité du mot de passe désactivée   | Très élevé       | Compromission de la robustesse des mots de passe sur le long terme     | Très haute |

 
## 7. Recommandations

### 7.1 Recommandations Générales

Quelques ajustements sont nécessaires pour optimiser la sécurité du serveur.

### 7.2 Recommandations Spécifiques

| Vulnérabilité | Action recommandée | Priorité |
|---------------|--------------------|----------|
| 01| Installez Fail2Ban pour bannir automatiquement les hôtes ayant plusieurs erreurs d'authentification. | Haute |
| 02 | Partitionner le disque en séparant /home /tmp  /var | Moyenne |
| 03 | Affecter un mot de passe robuste au GRUB | Haute |
| 04 | Vérifiez et ajustez les permissions du répertoire /etc/sudoers.d pour éviter les escalades de privilèges non autorisées. | Haute |
| 05 | Vérifiez et ajustez les permissions des fichiers de configuration de CUPS pour améliorer la sécurité. | Moyenne |
| 06 | Examinez la configuration du service wpa_supplicant pour identifier et corriger les vulnérabilités potentielles. | Haute |
| 07 | Vérifiez la configuration du service user@1000 pour garantir qu'il ne présente pas de risques de sécurité. | Haute |
| 08 | Examinez la configuration du service systemd-rfkill pour réduire les risques liés à la gestion des périphériques RF. | Haute |
| 09 | Installer et configurer USBGuard | Haute |  
| 10 | Configurer le timeout des sessions utilisateur local et SSH| Moyenne |
| 11 | Installer ClamAV et planifier des scans automatiques| Haute |
| 12 | Configurer la durée maximale de validité des mots de passe de minimum 90 jours | Très haute |



| ... | ... | ... | ... |

---

## 8. Conclusion

L'audit a révélé 12 vulnérabilités dans le système, dont 6 sont considérées comme critiques. Ces vulnérabilités exposent le système à divers risques de sécurité, allant des attaques par force brute à l'exposition aux menaces physiques. Les principales préoccupations identifiées incluent l'absence de mesures de sécurité essentielles comme Fail2Ban et USBGuard, ainsi que des configurations inappropriées pour les services et les permissions des fichiers.
Les recommandations proposées visent à remédier aux problèmes identifiés et à renforcer la sécurité globale du système. 
Les actions recommandées comprennent l'installation et la configuration appropriée de Fail2Ban, l'activation de USBGuard, et l'ajustement des paramètres de sécurité pour divers services et fichiers système.
Il est crucial que ces recommandations soient mises en œuvre rapidement pour réduire les risques et protéger le système contre les menaces potentielles. 
Un suivi régulier et une réévaluation périodique des mesures de sécurité sont également recommandés pour garantir que le système reste sécurisé contre les vulnérabilités émergentes.
L'amélioration des mesures de sécurité est essentielle pour assurer l'intégrité, la confidentialité et la disponibilité des données et des services.

---

## 9. Annexes

### 9.1 Glossaire

- **PASSI** : Prestataire d'Audit de la Sécurité des Systèmes d'Information
- **Vulnérabilité** : Faiblesse d'un système ou d'une infrastructure qui peut être exploitée pour compromettre sa sécurité.

- **Fail2Ban** : Outil de sécurité qui bannit automatiquement les adresses IP après plusieurs tentatives d'authentification échouées, réduisant ainsi le risque d'attaques par force brute.

- **Partitionnement** :
  - **/home** : Répertoire contenant les fichiers personnels des utilisateurs. La création d'une partition distincte pour /home isole ces données pour une meilleure gestion et sécurité.
  - **/tmp** : Répertoire utilisé pour les fichiers temporaires. Une partition séparée aide à prévenir la saturation des ressources.
  - **/var** : Répertoire où sont stockés les journaux systèmes et autres fichiers variables. Une partition dédiée permet d'éviter la saturation des logs et améliore la gestion des espaces.

- **GRUB (Grand Unified Bootloader)** : Programme de démarrage utilisé pour gérer les systèmes d'exploitation installés. L'absence d'un mot de passe GRUB expose le système à des modifications non autorisées des paramètres de démarrage.

- **/etc/sudoers.d** : Répertoire contenant des fichiers de configuration pour les privilèges sudo. Des permissions incorrectes peuvent permettre des escalades de privilèges non autorisées.

- **CUPS (Common UNIX Printing System)** : Système d'impression utilisé sur les systèmes UNIX. Les permissions des fichiers de configuration CUPS doivent être correctement définies pour éviter les risques de sécurité.

- **wpa_supplicant.service** : Service utilisé pour gérer les connexions Wi-Fi. Des vulnérabilités dans ce service peuvent compromettre la sécurité des connexions sans fil.

- **user@1000.service** : Service lié aux sessions utilisateurs. Une configuration incorrecte peut présenter des risques de sécurité liés aux services mal configurés.

- **systemd-rfkill.service** : Service utilisé pour gérer les périphériques RF (Wi-Fi/Bluetooth). Des configurations incorrectes peuvent exposer à des risques de sécurité.

- **USBGuard** : Outil de sécurité pour contrôler les périphériques USB connectés au système. Son absence expose le système à des attaques physiques ou des fuites de données via USB.

- **Timeout de session** : Paramètre de sécurité qui déconnecte automatiquement une session inactive. Des paramètres de timeout insuffisants augmentent le risque d'accès non autorisé.

- **Scanner de malware** : Logiciel destiné à détecter et éliminer les logiciels malveillants. L'absence de scanner de malware laisse le système vulnérable aux menaces.

- **Durée maximale de validité du mot de passe** : Paramètre de sécurité qui définit la période pendant laquelle un mot de passe reste valide avant d'exiger un changement. Une durée maximale désactivée compromet la robustesse des mots de passe sur le long terme.

### 9.2 Liste des documents analysés

- [Nom du document 1]
- [Nom du document 2]

### 9.3 Logs et Résultats des Tests Techniques

- [Insérer des logs, détails techniques si nécessaire]

---

**Fait à [Ville], le [Date]**

**[Nom de l'auditeur principal]**


