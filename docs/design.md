# Seuil — document de conception (v0.1)

Un hybride idle / tower defense construit sur une escalade civilisationnelle : chaque palier de puissance atteint devient le socle automatisé du suivant.

- **Genre** : idle incrémental + tower defense
- **Plateforme** : mobile, portrait
- **Portée** : solo / petite équipe
- **Statut** : exploration conceptuelle

## Sommaire

1. [Concept et pitch](#01--concept-et-pitch)
2. [Thème : l'escalade civilisationnelle](#02--thème--lescalade-civilisationnelle)
3. [Tourelles et ennemis par couche](#03--tourelles-et-ennemis-par-couche)
4. [Économie de la ressource](#04--économie-de-la-ressource)
5. [Scaling des statistiques](#05--scaling-des-statistiques)
6. [Arbres de progression](#06--arbres-de-progression)
7. [UI des couches automatisées](#07--ui-des-couches-automatisées)
8. [Durée de vie](#08--durée-de-vie)
9. [La boucle infinie](#09--la-boucle-infinie-décision-actée)
10. [Monétisation](#10--monétisation)
11. [Points ouverts](#11--points-ouverts)

## 01 — Concept et pitch

Chaque run est une défense de base classique : tourelles sur grille, vagues d'ennemis, ressource récoltée sur destruction. Cette ressource n'achète pas seulement la tourelle suivante — elle alimente un arbre de couches façon *Revolution Idle* : chaque couche débloque une mécanique de jeu nouvelle, pas seulement un multiplicateur.

Le levier idle vient de l'automatisation progressive : à mesure qu'une couche est maîtrisée, sa défense devient autonome et continue de produire en arrière-plan pendant que le joueur se concentre sur la couche suivante, active et manuelle.

> **Tension à arbitrer en continu** — L'idle repose sur du temps qui passe passivement, y compris hors-ligne. Le tower defense repose sur des décisions spatiales actives. Chaque système ajouté au jeu doit être vérifié contre cette tension : s'il permet de résoudre une vague sans y penser, il grignote l'intérêt tactique qui justifie le genre TD.

## 02 — Thème : l'escalade civilisationnelle

Chaque couche défend une chose plus grande que la précédente, avec une raison narrative explicite de déléguer la couche d'avant :

| Couche | Ce qu'on défend | Pourquoi l'ancienne couche s'automatise |
|---|---|---|
| Tribu | Le feu | — |
| Village | Le mur / silo | Les guerriers formés patrouillent seuls |
| Royaume | Le château | Un intendant gère la défense locale |
| Nation | La capitale industrielle | Un gouvernement automatisé administre le royaume |
| Planète | Le globe, contre une invasion orbitale | La nation tourne en pilote automatique via IA |
| Galactique | Le système stellaire | La planète est intégrée à un empire post-singularité |

L'automatisation n'est donc jamais un simple bouton « auto » : c'est une délégation de commandement cohérente avec le changement d'échelle. Le prestige (section 09) hérite du même vocabulaire : un reset, c'est l'humanité qui franchit un nouveau seuil technologique pendant que l'ancien monde continue de tourner sans le joueur.

> **Alternative écartée** — Une escalade biologique (cellule → organisme → écosystème → planète) a été envisagée pour son originalité. Écartée pour cette version : elle demande davantage de pédagogie visuelle pour que chaque couche soit lisible au premier regard, alors que « château », « robot » ou « vaisseau » se lisent instantanément.

## 03 — Tourelles et ennemis par couche

Pour que l'automatisation reste crédible — une IA qui gère une ancienne couche doit suivre des règles stables — les tourelles et les ennemis gardent le même rôle mécanique à travers toutes les couches. Seul l'habillage change.

### Tourelles

| Rôle | Tribu | Village | Royaume | Nation | Planète | Galactique |
|---|---|---|---|---|---|---|
| DPS mono-cible | Chasseur à sagaie | Archer | Arbalétrier | Mitrailleuse | Tourelle laser | Chasseur orbital |
| AoE | Feu lancé | Huile bouillante | Bombarde | Artillerie à gaz | Frappe orbitale | Bombe à antimatière |
| Contrôle | Piège à fosse | Filet | Herse | Mines EMP | Champ de gravité | Distorsion temporelle |
| Support | Chaman | Forgeron | Héraut | Ingénieur | IA médicale | Nanoessaim |

### Ennemis

| Rôle | Tribu | Village | Royaume | Nation | Planète | Galactique |
|---|---|---|---|---|---|---|
| Grouille | Loups | Pillards | Fantassins | Drones | Essaim d'insectoïdes | Nanoréplicants |
| Tank | Ours | Brute au bélier | Chevalier lourd | Char blindé | Mécha | Titan blindé |
| Rapide | Chacal | Éclaireur monté | Cavalier léger | Moto-jet | Intercepteur | Frégate furtive |
| Artillerie | — | Archer ennemi | Trébuchet | Obusier | Croiseur orbital | Cuirassé stellaire |

### Le twist par transition

Un seul mécanisme nouveau accompagne chaque changement de couche, pour éviter le pur reskin :

- **Tribu → Village** — le terrain (murs, portes) comme premier levier spatial.
- **Village → Royaume** — les vagues nommées et les boss.
- **Royaume → Nation** — le tir indirect, qui ignore la ligne de vue.
- **Nation → Planète** — la verticalité, menace orbitale contre défense au sol.
- **Planète → Galactique** — le ralentissement temporel de zone.

> **Règle de conception** — Les twists de transition sont débloqués automatiquement à l'entrée d'une couche, jamais noyés dans l'arbre de tech à farmer.

## 04 — Économie de la ressource

**Monnaie de couche** — une par couche active, gagnée en jouant le TD, dépensée sur les upgrades de tourelles. Devient inactive mais jamais inutile quand la couche suivante s'ouvre.

**Monnaie de prestige** — permanente, gagnée uniquement au reset, dépensée sur des bonus globaux. Seule monnaie qui traverse tout le jeu sans être remise à zéro.

**Sources** : kill de vague (flux principal), production passive des couches automatisées, bonus de vague nommée/boss, reset → monnaie de prestige.

**Sinks** : upgrades de tourelles (continu), déblocage de la couche suivante (palier), upgrades de prestige (rare, impactant).

**Le pont inter-couches** — la monnaie d'une couche fermée continue d'être produite par l'automatisation et se convertit en ressource de départ de la couche suivante, à un taux sous-linéaire :

```
Départ(N+1) = k × √Produit(N)
```

Sous-linéaire pour éviter qu'une vieille couche rende la nouvelle triviale dès le départ.

Garde-fous contre l'inflation illisible : notation compacte obligatoire au-delà de quatre chiffres (1,2K / 3,4M), et monnaie de prestige délibérément petite.

## 05 — Scaling des statistiques

| Axe | Formule | Note |
|---|---|---|
| Vagues, PV ennemi | `HP(n) = HP₀ × 1.15ⁿ` | Croissance par vague au sein d'une couche |
| Vagues, récompense | `Reward(n) = R₀ × 1.15ⁿ` | Calée sur les PV, pas sur les dégâts |
| Upgrade de tourelle | `Coût(k) = C₀ × 1.5ᵏ` ; dégâts en `1.25ᵏ` | Dégâts plus plats que le coût |
| Prestige | `Mult = 1 + √Points` | Sous-linéaire à dessein |
| Production hors-ligne | `Taux = ActifRate × 0,3–0,5`, plafonné 8–12h | Jouer activement reste toujours meilleur |

> **Risque principal** — Empiler des multiplicateurs indépendants (prestige × couche × upgrade × événement) rend les nombres illisibles en quelques heures. N'exposer que **deux** axes visibles au joueur : puissance des tourelles, ressources par seconde.

## 06 — Arbres de progression

**Arbre de couche** — remplacé à chaque changement de couche, payé en monnaie de couche. Cinq branches : DPS, AoE, Contrôle, Support, et une branche *Délégation* dédiée à l'automatisation, volontairement indépendante des quatre autres. Deux à trois paliers à choix binaire par branche (ex. dégâts bruts contre cadence de tir). Respec gratuit ou quasi-gratuit.

**Arbre de prestige** — cinq à huit nœuds sur tout le jeu, chacun un choix fort et permanent. Pas de respec, ou un coût très élevé.

> **Compromis assumé** — Des choix binaires maximisent la lisibilité et la rejouabilité, mais sacrifient la sensation d'un grand arbre touffu que certains joueurs d'incrémentaux recherchent explicitement.

## 07 — UI des couches automatisées

La couche jouée occupe tout l'espace principal. Les couches automatisées vivent dans un bandeau compact en pied d'écran, réduites à un point de statut et un débit.

Seules les deux couches automatisées les plus récentes gardent une ligne individuelle. Tout ce qui est plus ancien tombe dans une ligne unique « Ères précédentes » au débit cumulé, dépliable au besoin — le bandeau garde ainsi une taille fixe quel que soit le nombre de couches débloquées.

## 08 — Durée de vie

| Repère | Valeur |
|---|---|
| Premier prestige | 15–25 min |
| Session active (TD) | 3–8 min |
| Check-in idle | < 60 s |
| Arc complet (6 couches) | 15–25 h, sur 2–3 semaines calendaires |

## 09 — La boucle infinie (décision actée)

Une fois la couche Galactique atteinte, le reset relance les six couches depuis le début avec un multiplicateur permanent et des **modificateurs procéduraux tirés aléatoirement** (façon affixes roguelite). Pas de septième couche à concevoir à la main — l'effort se porte sur une table de modificateurs conçue une fois et combinée différemment à chaque run.

> **Vigilance** — Une boucle infinie appelle des attentes de type live-service. Si le jeu doit vivre sans support continu, la variance procédurale doit suffire seule à porter la rejouabilité.

## 10 — Monétisation

Vendre du temps, jamais de la puissance.

**À faire** : pub récompensée pour doubler le gain hors-ligne, achat unique « retirer les pubs », IAP de confort (skip de palier, boost temporaire, slot de modificateur supplémentaire).

**À éviter** : gacha/loot box sur des stats de puissance, PvP/classement greffé après coup, live-ops complet sans capacité réelle à l'opérer dans la durée.

> **Garde-fou général** — Tout ce qui s'achète doit rester atteignable gratuitement en jouant plus longtemps.

## 11 — Points ouverts

- [ ] Table détaillée des modificateurs procéduraux du prestige galactique — quels axes, combien de slots par run.
- [ ] Écran de transition et de déblocage entre deux couches.
- [ ] Nommage final du jeu — « Seuil » est un titre de travail.
- [ ] Identité visuelle et direction artistique par couche.
- [ ] Choix du moteur de développement.

---

*Version détaillée avec mise en page consultable : [artefact publié](https://claude.ai/code/artifact/bcd31153-1f2f-4ac2-b8d9-5a1e41f7b62c).*
