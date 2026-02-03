# Bag Battler - Journal de Développement

## 3 Février 2026

**1. Création du système de jetons**
- Créé `TokenResource` (script de base pour les jetons)
- Ajouté 3 types : ATTACK, DEFENSE, HAZARD
- Créé 3 jetons concrets :
  - `basic-sword.tres` (ATTACK, valeur 3)
  - `shield.tres` (DEFENSE, valeur 5)
  - `hazard.tres` (HAZARD, valeur 0)

**2. Création du BagManager**
- Script `bag_manager.gd` avec les fonctions :
  - `add_tokens()` - Ajouter plusieurs jetons identiques
  - `draw_token()` - Tirer un jeton au hasard (et le retirer du sac)
  - `print_bag()` - Afficher le contenu du sac
  - `shuffle()` - Mélanger le sac
  - `reset_bag()` - Remettre tous les jetons dans le sac
- Testé en console, tout fonctionne ✅

**3. Création de l'interface UI**
- Scène `bag_ui.tscn` avec :
  - Titre du jeu
  - Affichage du nombre de jetons (par type)
  - Bouton "Tirer un jeton"
  - Bouton "Reset"
  - Affichage du dernier jeton tiré
- Script `bag_ui.gd` pour connecter tout ça

**4. Création de la ligne de combat visuelle**
- Scène `token_card.tscn` - Carte visuelle pour un jeton
- Script `token_card.gd` - Affiche icône, nom, valeur
- Couleurs différentes selon le type (rouge/bleu/gris)
- Les cartes s'alignent de gauche à droite
- Disparaissent au reset ✅
