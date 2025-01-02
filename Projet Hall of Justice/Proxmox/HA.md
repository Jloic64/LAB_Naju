# Configuration de la Haute Disponibilité (HA) sur Proxmox

## Étape 1 : Création d'un groupe HA
Pour créer un groupe HA nommé `HA_1` avec les nœuds **BRUCE**, **CLARK**, et **DIANA**, utilisez la commande suivante :

```bash
ha-manager groupadd HA_1 --nodes BRUCE,CLARK,DIANA --nofailback 1
```

Explications :
groupadd : La commande pour ajouter un nouveau groupe.
HA_1 : Le nom du groupe.
--nodes BRUCE,CLARK,DIANA : Liste des nœuds du cluster participant au groupe HA.
--nofailback 1 : Empêche le retour automatique d'une ressource vers son nœud d’origine après un redémarrage.

**Explications :**  
- **groupadd** : La commande pour ajouter un nouveau groupe.  
- **HA_1** : Le nom du groupe.  
- **--nodes BRUCE,CLARK,DIANA** : Liste des nœuds du cluster participant au groupe HA.  
- **--nofailback 1** : Empêche le retour automatique d'une ressource vers son nœud d’origine après un redémarrage.

## Étape 2 : Ajout d'une VM au groupe HA

Ajoutez une VM au groupe HA avec la commande suivante :

```bash
ha-manager add vm:400 --group HA_1
```

**Explications :**  
- **vm:400** : Identifiant de la VM à ajouter au groupe HA.  
- **--group HA_1** : Le groupe HA auquel associer la VM.

## Étape 3 : Vérification de la configuration

Après avoir configuré le groupe et ajouté une VM, vérifiez la configuration HA avec la commande suivante :

```bash
ha-manager status
```
**Cette commande affichera l'état des ressources, les nœuds associés et leur statut** 
(par exemple *started*, *stopped*, etc.).

Vous pouvez également utiliser la commande suivante pour **surveiller en temps réel l'évolution du statut HA** :
```bash
watch ha-manager status
```