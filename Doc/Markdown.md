Le Markdown est un langage léger de balisage permettant de formater du texte. Voici un guide des commandes les plus courantes en Markdown :

## Titres
Utilisez des dièses (#) pour créer des titres de différentes tailles.

\```markdown
# Titre de niveau 1
## Titre de niveau 2
### Titre de niveau 3
#### Titre de niveau 4
##### Titre de niveau 5
###### Titre de niveau 6
\```

## Texte en italique et en gras

### Italique : entourez le texte d'un astérisque (*) ou d'un underscore (_).

\```markdown
*italique* ou _italique_
\```

### Gras : entourez le texte de deux astérisques (**) ou de deux underscores (__).

\```markdown
**gras** ou __gras__
\```

### Italique et gras combinés : utilisez trois astérisques (***) ou trois underscores (___).

\```markdown
***italique et gras*** ou ___italique et gras___
\```

## Listes

### Listes à puces : utilisez des tirets (-), des astérisques (*) ou des plus (+).

\```markdown
- Élément 1
- Élément 2
  - Sous-élément 2.1
  - Sous-élément 2.2
\```

### Listes numérotées : utilisez des chiffres suivis d'un point.

\```markdown
1. Premier élément
2. Deuxième élément
3. Troisième élément
\```

## Liens
Utilisez des crochets pour le texte du lien et des parenthèses pour l'URL.

\```markdown
[Texte du lien](http://example.com)
\```

## Images
Semblable aux liens, mais avec un point d'exclamation au début.

\```markdown
![Texte alternatif](http://url-de-l-image.com/image.jpg)
\```

## Citations
Utilisez le symbole `>` pour créer une citation.

\```markdown
> Ceci est une citation.
\```

## Code

### Code en ligne : utilisez des accents graves (backticks) autour du texte.

\```markdown
Voici un exemple de `code en ligne`.
\```

### Bloc de code : utilisez trois accents graves (```) sur des lignes séparées avant et après le code.

\```markdown
\```
Bloc de code
sur plusieurs lignes
\```
\```

## Tableaux
Utilisez des pipes (|) et des tirets (-) pour créer des tableaux.

\```markdown
| En-tête 1 | En-tête 2 |
|-----------|-----------|
| Cellule 1 | Cellule 2 |
| Cellule 3 | Cellule 4 |
\```

## Lignes horizontales
Utilisez trois tirets (---), trois astérisques (***), ou trois underscores (___) sur une ligne séparée.

\```markdown
---
\```

## Échappement des caractères spéciaux
Utilisez une barre oblique inverse (\) avant un caractère spécial pour l'afficher littéralement.

\```markdown
\*Ce texte n'est pas en italique\*
\```

Avec ces commandes de base, vous pouvez déjà réaliser un grand nombre de formats en Markdown.

---

## Comment faire un bloc de code avec un titre
Pour créer un bloc de code avec un titre en Markdown, il n'existe pas de syntaxe directe pour inclure un titre spécifique à un bloc de code. Cependant, vous pouvez utiliser une astuce en combinant un titre de niveau approprié et un bloc de code juste en dessous. Voici comment vous pouvez le faire :

### Exemple

\```markdown
#### Titre du Bloc de Code

\```langage
// Votre code ici
function example() {
    console.log("Hello, world!");
}
\```
\```

### Explication

1. **Titre du Bloc de Code :** Utilisez un titre de niveau 4 (ou tout autre niveau) pour indiquer le titre du bloc de code.

\```markdown
#### Titre du Bloc de Code
\```

2. **Bloc de Code :** Utilisez trois accents graves (```) avant et après le bloc de code. Vous pouvez spécifier le langage de programmation après les accents graves d'ouverture pour activer la coloration syntaxique.

\```markdown
\```langage
// Votre code ici
function example() {
    console.log("Hello, world!");
}
\```
\```

### Exemple Complet

\```markdown
#### Exemple de Fonction JavaScript

\```javascript
function example() {
    console.log("Hello, world!");
}
\```
\```

### Résultat Rendu

#### Exemple de Fonction JavaScript

\```javascript
function example() {
    console.log("Hello, world!");
}
\```

Avec cette approche, vous pouvez organiser vos blocs de code avec des titres explicatifs, ce qui rend le document plus lisible et structuré.
