<p align="center">
    <img src="img/Terraform.png" style="width: 400px;" />
</p>

# 🏗️ Présentation de Terraform  

---

## 📌 1. Qu'est-ce que Terraform ?  
Terraform est un outil open-source d'**Infrastructure as Code (IaC)** développé par **HashiCorp**.  
Il permet de **définir, provisionner et gérer des infrastructures** (serveurs, bases de données, réseaux, services cloud, etc.) sous forme de **code déclaratif**.  

Terraform est compatible avec plusieurs fournisseurs cloud (**AWS, Azure, GCP, etc.**) ainsi qu'avec des solutions **on-premise** comme **Proxmox, VMware ou OpenStack**.

---

## 🔑 2. Les concepts clés de Terraform  

### 📜 2.1. Configuration en HCL  
Terraform utilise un langage appelé **HCL (HashiCorp Configuration Language)** pour définir l'infrastructure.  
Les fichiers Terraform ont généralement l'extension `.tf`.

### 📦 2.2. Providers  
Les **providers** sont des plugins permettant d'interagir avec différents services cloud ou infrastructures, comme AWS, Azure, GCP, ou Proxmox.

### ⚙️ 2.3. Ressources  
Les **ressources** sont les éléments qui composent l’infrastructure, comme les machines virtuelles, bases de données et réseaux.

### 🔄 2.4. State (Fichier d'état)  
Terraform maintient un **fichier d'état (`terraform.tfstate`)** qui suit l’infrastructure existante et permet d’effectuer des modifications de manière incrémentale.

### 🔍 2.5. Plan & Apply  
- `terraform plan` : Montre les changements qui seront appliqués.  
- `terraform apply` : Applique les modifications à l’infrastructure.  

### 🏗️ 2.6. Modules  
Un **module** est un ensemble de fichiers Terraform permettant de **réutiliser et organiser le code** pour des infrastructures complexes.

---

## ✅ 3. Avantages et inconvénients de Terraform  

### ✔️ Avantages  
✅ **Infrastructure as Code (IaC)** : Automatisation et versioning de l’infrastructure.  
✅ **Multi-cloud et On-Premise** : Compatible avec de nombreux fournisseurs.  
✅ **Idempotence** : Exécuter plusieurs fois le même code produit le même résultat.  
✅ **Facilité de gestion et évolutivité** : Permet de créer, modifier et supprimer des infrastructures facilement.  
✅ **Communauté et écosystème riche** : Terraform Registry propose de nombreux modules.

### ❌ Inconvénients  
⚠️ **Courbe d'apprentissage** : HCL et la gestion des états peuvent être complexes au début.  
⚠️ **Gestion de l’état (`terraform.tfstate`)** : Doit être bien sécurisée, surtout en équipe.  
⚠️ **Modification manuelle déconseillée** : Modifier une infrastructure sans passer par Terraform peut créer des incohérences.  
⚠️ **Moins adapté aux workflows impératifs** : Terraform est basé sur un modèle déclaratif, ce qui peut être un frein pour certains cas nécessitant du scripting.

---

## 🔗 4. Ressources utiles

📖 **Documentation Terraform (traduite par la communauté)** : [https://learn-terraform.fr/](https://learn-terraform.fr/)  
📂 **Guide Terraform en français (par OVH)** : [https://docs.ovh.com/fr/terraform/](https://docs.ovh.com/fr/terraform/)  
🎓 **Formation Terraform gratuite en français** : [https://grafikart.fr/tutoriels/terraform-1887](https://grafikart.fr/tutoriels/terraform-1887)  
📘 **Article détaillé sur Terraform en français** : [https://blog.eleven-labs.com/fr/decouverte-terraform/](https://blog.eleven-labs.com/fr/decouverte-terraform/)  
📝 **Blog de Stéphane Robert sur Terraform et l'IaC** : [https://blog.stephane-robert.info/categories/terraform/](https://blog.stephane-robert.info/categories/terraform/)  

---