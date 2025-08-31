#  Veille Technologique – Infrastructure as Code (IaC)

##  Qu’est-ce que l’IaC ?

L’Infrastructure as Code (IaC) est une approche permettant de **provisionner, configurer et gérer une infrastructure informatique via du code**.

###  Objectifs :
- Automatiser les déploiements et la configuration
- Versionner l’infrastructure comme du code source
- Répliquer facilement les environnements
- Réduire les erreurs humaines
- Améliorer la traçabilité et la sécurité

---

##Comparaison des principaux outils IaC

|  Outil     | Catégorie                     | Langage           | Agent requis | Mode         |
|--------------|-------------------------------|-------------------|--------------|--------------|
| **Terraform**| Provisioning (infrastructure) | HCL               | Non          | Déclaratif   |
| **Ansible**  | Configuration & Orchestration | YAML + Jinja2     | Non (SSH)    | Déclaratif   |
| **Puppet**   | Configuration Management      | DSL (Ruby-like)   | Oui (agent)  | Déclaratif   |
| **Chef**     | Configuration Management      | Ruby              | Oui (agent)  | Déclaratif   |

---

## Avantages et inconvénients

###  Terraform
**Avantages :**
- Idéal pour le provisioning (VM, réseau, stockage)
- Multi-cloud via des providers (AWS, Azure, Proxmox…)
- Gestion d’état avec plan/apply

**Inconvénients :**
- Moins adapté à la configuration logicielle
- Fichier `.tfstate` à sécuriser

---

### Ansible
** Avantages :**
- Simple à prendre en main (YAML, pas d’agent)
- Idempotent, parfait pour la configuration logicielle
- Installation via SSH ou WinRM

**Inconvénients :**
- Moins efficace à très grande échelle sans AWX/Tower
- Pas de gestion d’état centralisée

---

###Puppet
**Avantages :**
- Très robuste pour grands parcs serveurs
- Détection/remédiation automatique des écarts
- Rapport de conformité intégré

**Inconvénients :**
- DSL spécifique à apprendre
- Architecture maître/agent lourde

---

### Chef
**Avantages :**
- Très flexible avec Ruby
- Idéal pour des déploiements complexes et logiques applicatives

** Inconvénients :**
- Courbe d’apprentissage plus élevée
- Infrastructure agent/serveur lourde

---

##  Choix selon les cas d’usage

|  Besoin principal                                                                 | 🛠️ Outil recommandé      |
|------------------------------------------------------------------------------------|---------------------------|
| Créer une infrastructure Cloud ou on-premise (VM, réseau, stockage)               | Terraform                 |
| Configurer le système, installer des services (Docker, Nginx, PostgreSQL…)        | Ansible                   |
| Maintenir la conformité d’un grand parc, remédier aux écarts                      | Puppet                    |
| Déploiement d’applications complexes avec logique métier                          | Chef                      |
| Provisioning + Configuration dans un même workflow                                | Terraform + Ansible       |
| Gestion multi-cloud avec dépendances réseau (IAM, DNS, VPC, peering…)             | Terraform                 |
| Déploiement applicatif progressif (Canary, Blue/Green)                            | Ansible (avec AWX/Tower)  |
| Environnements critiques avec politique de conformité forte                       | Puppet                    |

---

##  Tendances actuelles du marché

-  **Terraform + Ansible** : la combinaison la plus utilisée
    - Terraform pour le provisioning
    - Ansible pour la configuration logicielle
-  **Puppet et Chef** : moins utilisés dans les nouveaux projets
-  Émergence d’alternatives comme **OpenTofu** (fork libre de Terraform suite au changement de licence)
-  Intégration avec les CI/CD (GitLab, GitHub Actions, Jenkins…)

---

##  Conclusion

Le choix de l’outil dépend :
- Du **type de tâche** (provisioning vs configuration)
- De la **taille de l’infrastructure**
- Des **compétences de l’équipe**
- Des **objectifs DevOps ou SRE**

**Terraform + Ansible** couvrent la majorité des besoins modernes.

