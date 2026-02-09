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

**5. Ajout de l'affichage des totaux de combat (Session du soir - 3 février)**
- Ajouté trois labels distincts dans `bag_ui.tscn` : `LabelAttackTotal` (rouge, gauche), `LabelDefenseTotal` (bleu, droite), `LabelHazardWarning` (orange, centre)
- Créé la fonction `update_combat_line_totals()` qui calcule et affiche les totaux d'attaque et défense de la ligne de combat
- Système d'avertissement pour les hazards : vide si aucun, "⚠️ 1 Hazard - Attention!" si un seul, "💀 CRASH!" si deux ou plus
- Correction bug reset : utilisation de `free()` au lieu de `queue_free()` pour remettre immédiatement les totaux à zéro
- Les totaux se mettent à jour automatiquement après chaque tirage ✅

## 9 Février 2026

**Système de combat complet ✅**
- Créé `EnemyResource.gd` et `Enemy.gd` pour gérer les ennemis
- Ajouté le bouton "EXÉCUTER" pour résoudre le combat
- Logique de combat fonctionnelle :
  - Calcul ATTACK et DEFENSE
  - Système de Crash (2 Hazards = 0 dégâts)
  - Dégâts infligés à l'ennemi
  - Réduction des dégâts par la défense
  - Les jetons retournent dans le sac après chaque tour
- Premier ennemi créé : Gobelin (20 HP, 5 ATK)
- Combat testé et fonctionnel !

## 9 Février 2026 (suite)

**Ajout du système de vie du joueur ✅**
- HP du joueur : 30 HP de base
- Affichage des HP avec changement de couleur selon l'état
- Dégâts ennemis appliqués au joueur
- Système de défaite (Game Over quand HP = 0)

**Amélioration du système de Crash ✅**
- Le Crash se déclenche IMMÉDIATEMENT au tirage du 2ème Hazard
- Plus besoin de cliquer sur EXÉCUTER
- Le joueur prend tous les dégâts sans défense
- La ligne se vide automatiquement
- Le tour passe directement à l'ennemi

**Le cœur du gameplay est fonctionnel ! 🎮**
