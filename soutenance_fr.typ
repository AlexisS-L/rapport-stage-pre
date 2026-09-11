#import "@preview/touying:0.5.3": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  primary: rgb("#2b3a67"),
)

#set page(fill: rgb("#e9eef8"))

#let punchline(body) = rect(
  fill: rgb("#d3ddf0"),
  stroke: none,
  inset: 12pt,
  radius: 6pt,
  width: 100%,
)[#align(center)[#text(size: 1.15em)[*#body*]]]

#title-slide[
  = Flammes de déflagration thermonucléaire dans les supernovae de type Ia

  == Une étude multiparamétrique en 1D avec le programme Phlegethon

  #v(1em)
  Soutenance de stage, Projet de Recherche \
  Alexis Spaeth-Lemarchand \
  HITS, Physics of Stellar Objects group

  #v(0.5em)
  #text(size: 0.8em)[Tuteurs : Prof. Dr. Friedrich K. Röpke, Dr. Giovanni Leidi, Dr. Alexander Holas]
]

== Contexte : pourquoi les supernovae de type Ia comptent

- Explosion thermonucléaire d'une naine blanche carbone-oxygène proche de la masse de Chandrasekhar
- Chandelles cosmologiques standardisables : ont permis de mesurer l'expansion accélérée de l'Univers
- La cosmologie de précision est aujourd'hui limitée par l'incertitude *systématique* sur le mécanisme d'explosion lui-même, pas par la statistique

#v(1em)
#punchline[Améliorer la physique de l'explosion, c'est améliorer notre mesure de l'Univers]

== Où se situe la vitesse de flamme laminaire

- L'explosion est en réalité pilotée par l'accélération *turbulente* de la flamme en 3D : ce n'est pas ce qu'une étude 1D modélise directement
- Mais la turbulence elle-même est façonnée par la vitesse de flamme laminaire *locale* : #cite(<holas2026>, form: "prose") montrent que la suppression de la turbulence est fortement localisée via la dépendance en $Y_e$ de $v_l$
- $v_l$ est un ingrédient microphysique nécessaire aux modèles turbulents à grande échelle : pas toute l'histoire, mais la pièce que ce projet adresse

#v(0.5em)
$ v_l = f(rho, X_i, Y_e) $

== Le trou dans la littérature

#align(center)[
  #table(
    columns: (1fr, 1fr),
    stroke: 0.5pt,
    align: left,
    [*Timmes & Woosley (1992)*], [*Schwab et al. (2020)*],
    [$v_l (rho, X_i)$], [$v_l (rho, Y_e)$],
    [Pas de dépendance en $Y_e$], [Pas de dépendance en composition],
  )
]

#v(1em)
#punchline[Personne n'a combiné les trois paramètres dans une seule formule]

#v(0.5em)
Objectif du stage : explorer tout l'espace $(rho, X_i, Y_e)$ avec Phlegethon, et travailler vers cette formule combinée.

== L'outil : Phlegethon

Un code d'hydrodynamique stellaire compressible et multiphysique #cite(<leidi2026>, form: "prose"), en volumes finis :

$ (partial U) / (partial t) + nabla dot bold(F)(U) = S(U), quad U = mat(rho; rho bold(u); E; rho X_k) $

#v(0.3em)
#text(size: 0.85em)[
$ bold(F)(U) = mat(rho bold(u); rho bold(u) ⊗ bold(u) + P bold(I); (E+P) bold(u); rho X_k bold(u)) quad quad
  S(U) = mat(0; rho bold(g); rho bold(u) dot bold(g) + nabla dot (K nabla T) + rho dot(epsilon)_"nuc"; rho dot(omega)_k) $
]

#v(0.3em)
#text(size: 0.8em)[
*$bold(F)$, flux advectifs :* masse ; quantité de mouvement + pression ; énergie totale + travail des forces de pression ; advection des espèces \
*$S$, termes sources :* gravité $rho bold(g)$ ; puissance gravitationnelle ; conduction thermique $nabla dot (K nabla T)$ ; dégagement d'énergie nucléaire $rho dot(epsilon)_"nuc"$ ; production d'espèces $rho dot(omega)_k$
]

== À quoi ressemble une flamme de déflagration

#figure(
  image("figures/T_front_closeup.png", width: 78%),
)

#text(size: 0.85em)[Profil d'ignition à $t = 0$, puis un front auto-entretenu se propageant à vitesse constante. Cendres à gauche, carburant à droite.]

== Les diagnostics

#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  image("figures/overview_clean_15species.png", width: 100%),
  image("figures/speed_overview_clean_15species.png", width: 100%),
)

#text(size: 0.85em)[Position du front à partir de deux indicateurs indépendants : passage à mi-hauteur de température et pic du dégagement d'énergie nucléaire, avec interpolation parabolique sous-maille.]

== Un attracteur physique

Tests de convergence : résolution de grille, taille de boîte, température d'ignition, taille de la zone ignitée.

#figure(
  image("figures/acoustic_oscillation_damping.png", width: 52%),
)

#punchline[Le transitoire change. La vitesse de flamme asymptotique, jamais.]

== Réseaux nucléaires : plus de physique, plus de coût

Progression pendant le stage : 7 $arrow.r$ 15 $arrow.r$ 35 espèces.

#v(0.5em)
#align(center)[
  #table(
    columns: (auto, auto, auto, auto),
    stroke: 0.5pt,
    align: center,
    [*rangs MPI*], [*threads OMP*], [*wct ($times 10^2$ $mu$s)*], [*Durée*],
    [64], [1], [0.575], [1min 22s],
    [64], [2], [0.323-0.564 (var.)], [N/A],
    [64], [4], [0.554], [1min 20s],
    [64], [8], [0.977], [2min 18s],
    [64], [16], [1.320], [3min 06s],
  )
]

== L'espace des phases : des ordres de grandeur

- Composition $X_i$ fixée par le réseau ; densité $rho$ balayée de $10^7$ à $10^10$ g/cm#super[3]
- Sur cette plage, la largeur et la vitesse de flamme varient chacune de plusieurs *ordres de grandeur*
- Une boîte, une résolution et un $t_max$ fixes ne peuvent pas convenir partout

#v(0.5em)
#punchline[Solution : dimensionner chaque simulation selon sa propre physique attendue]

#text(size: 0.85em)[
Longueur de boîte en largeurs de flamme, nombre fixe de cellules par largeur de flamme, $t_max = x_"2u" \/ v_"attendue"$ d'après Timmes & Woosley $arrow.r$ coût par simulation à peu près constant sur tout l'espace des phases.
]

== Le troisième paramètre : $Y_e$ variable

- Aucun isotope naturellement abondant ne donne le décalage de $Y_e$ voulu sans perturber la composition C-O
- Ne40 (Z=10, A=40, $Z\/A = 0.25$) introduit comme *espèce spectatrice inerte*

$ X_s (upright("Ne40")) = (0.5 - Y_e) / 0.25 $

- Choisi plutôt que Ne22 : $~6 times$ moins de fraction massique pour le même décalage, perturbant bien moins le carburant
- Ce qui compte physiquement est le $Y_e$ du *carburant* : une espèce inerte le maintient fixé par construction

== Extraire une vitesse (1/4) : la moyenne naïve

#figure(
  image("figures/naive_mean_example.png", width: 66%),
)

#text(size: 0.85em)[Ligne pointillée : la vitesse moyennée dans le temps. Biaisée dès que le transitoire n'a pas décru avant $t_max$.]

== Extraire une vitesse (2/4) : le fit polynomial

#figure(
  image("figures/speed_overview_clean_15species.png", width: 66%),
)

#text(size: 0.85em)[Lisse et numériquement robuste, mais sans fondement physique pour extrapoler vers la vitesse asymptotique.]

== Extraire une vitesse (3/4) : le fit exponentiel

$ r(t) = r_0 + v_infinity t + A tau (1 - e^(-t\/tau)) $

#figure(
  image("figures/exp_fit_good_example.png", width: 50%),
)

#text(size: 0.85em)[
Motivé physiquement : près d'une onde progressive stable, les perturbations décroissent exponentiellement #cite(<fife1977>, form: "prose"), en cohérence avec le formalisme de vitesse propre de #cite(<zeldovich1938>, form: "prose") qui sous-tend #cite(<timmes1992>, form: "prose").
]

== Extraire une vitesse (4/4) : quand il s'effondre

#figure(
  image("figures/exp_fit_absurd_example.png", width: 52%),
)

#text(size: 0.85em)[
Le fit non-linéaire à 3 paramètres est mal conditionné quand le run ne couvre pas plusieurs $tau$. Correction : un cross-check indépendant et non-paramétrique (régression par fenêtre glissante + Aitken $Delta^2$) qui *signale le désaccord* au lieu de faire confiance aveuglément à un seul fit.
]

== D'où vient le bruit

#punchline["Changer un chiffre et relancer" n'a jamais été la méthode : hypothèse, test, cause]

#v(0.3em)
#text(size: 0.9em)[
*Hypothèse :* l'énergie d'ignition amorce aussi une onde de compression, qui rebondit sur les bords réfléchissants et module la densité, donc la vitesse, à chaque passage. \
*Test :* la période d'oscillation doit alors croître avec la longueur de boîte.
]

#figure(
  image("figures/acoustic_bounce_x2u.png", width: 48%),
)

== Résultats actuels

#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  figure(
    image("figures/compare_results_polyfit_era.png", width: 100%),
    caption: [Fit polynomial : tendance propre, écart modéré],
  ),
  figure(
    image("figures/compare_results_after.png", width: 100%),
    caption: [Fit exponentiel : précis quand il est conditionné],
  ),
)

#text(size: 0.85em)[Bon accord avec #cite(<timmes1992>, form: "prose") pour $rho ≳ 5 times 10^8$ g/cm#super[3]. Robustesse et précision sont en tension entre les deux méthodes.]

== Pourquoi les basses densités sont difficiles

- Ratio diagnostic $tau \/ T_"span"$ sur l'espace des paramètres :
  - haute densité : $t_max approx 1.5 tau$
  - basse densité : $t_max approx 0.1 tau$
- La divergence *s'accélère* quand la densité baisse : ce n'est pas une loi de puissance fixe
- Un argument naïf ($t_max$ et $tau$ variant tous deux comme $ell \/ v$, avec $ell prop 1\/v$) prédirait un ratio *constant*, ce que les données contredisent

#v(0.5em)
#punchline[Les runs à basse densité sont précisément ceux privés de temps de relaxation résolu]

== Cartes de l'espace des phases

#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  image("figures/results_Ye_0_5_0_497_expo_04_heatmap.png", width: 100%),
  image("figures/results_Ye_0_5_0_497_expo_04_3d.png", width: 100%),
)

#text(size: 0.85em)[Produites, mais pas encore concluantes : les artefacts à basse densité dominent leur apparence à faible $rho$, et la dimension $Y_e$ est à peine échantillonnée.]

== Conclusion

*Livré :* une conception de simulation auto-similaire validée contre un attracteur physique ; un pipeline de post-traitement complet avec extraction de vitesse robuste et auto-diagnostiquée ; une méthodologie fonctionnelle de variation de $Y_e$ ; une contribution à la branche 1D de Phlegethon.

*Non livré :* la formule combinée $v_l = f(rho, X_i, Y_e)$, bloquée par le transitoire à basse densité et une dimension $Y_e$ non balayée.

#v(0.5em)
#punchline[L'écart entre une simulation qui produit un chiffre et ce chiffre étant fiable, c'était le vrai sujet de ce stage]

== Perspectives

*Court terme :* caractériser l'échelle de $tau$ et allonger les runs à basse densité ; compléter le balayage en $Y_e$ ; ajuster la formule combinée.

*Ensuite, à quoi sert vraiment cette formule :*
- Modèle de sous-maille pour les simulations 3D turbulentes, qui ne peuvent pas résoudre des flammes de l'ordre du centimètre
- Trancher entre explosion et effondrement gravitationnel dans les supernovae à capture électronique #cite(<holas2026>, form: "prose")
- Réduire l'incertitude systématique qui limite aujourd'hui les supernovae de type Ia comme chandelles cosmologiques

#v(1em)
#align(center)[#text(size: 1.6em)[Merci.]]

= Annexes

== Dispositif de simulation

- Boîte plane 1D, propagation selon $x_2$, bords réfléchissants
- Profil d'ignition à $t=0$ :
$ T(x) = T_b + T times 0.5 (1 - tanh((x - "xt" dot x_"2u") \/ "deltax")) $
- $"deltax" = "xt" \/ 2$ fixé par une étude de convergence ; longueur absolue ignitée maintenue constante sur tout le balayage en rescalant $"xt"$ quand $x_"2u"$ change
- Résolution : au moins 10 cellules par largeur de flamme ; $"nx2" = 2048$ en pratique sur tout l'espace des phases
- Longueur de boîte : 300 largeurs de flamme

== Dimensionnement et coût

$ x_"2u" = N_"largeurs" times ell_"Timmes", quad "nx2" = N_"largeurs" times N_"cellules/largeur", quad t_max = x_"2u" \/ v_"cond,Timmes" $

Vitesse et largeur de flamme varient en proportion inverse sur $(rho, X_i)$, donc le produit qui fixe $"nx2"$ varie peu et s'arrondit systématiquement à 2048 : une flamme rapide et fine est résolue à la même résolution effective qu'une flamme lente et épaisse intégrée plus longtemps.

#v(0.5em)
Pour $Y_e != 0.5$, les deux sont corrigés par le facteur de Schwab
$ "facteur"(Y_e) = 1 + 96.8 (0.5 - Y_e) $

== Formules de référence

*Timmes & Woosley (1992), eq. 43 :*
$ v_"cond" = 92.0 (rho \/ 2 times 10^9)^0.805 [X(upright("C12"))\/0.5]^0.889 quad upright("km/s") $

*Schwab et al. (2020), eq. 2 :*
$ v_"flamme" = 16.0 rho_9^0.813 [1 + 96.8 (0.5 - Y_e)] quad upright("km/s") $

*Composition avec l'espèce spectatrice Ne40 :*
$ X_s (upright("C12")) = "ratio"_"C/O" (1 - X_s (upright("Ne40"))), quad X_s (upright("O16")) = (1 - "ratio"_"C/O")(1 - X_s (upright("Ne40"))) $

== Extrapolation d'Aitken $Delta^2$

En supposant que la suite d'estimations locales de vitesse relaxe géométriquement, $v_i = v_infinity + A r^i$ :

$ v_infinity = (v_3 v_1 - v_2^2) / (v_3 + v_1 - 2 v_2) $

- Algébrique sur trois nombres : ne peut pas diverger vers un minimum local comme un solveur non-linéaire
- Appliquée aux pentes *lissées* par fenêtre glissante, jamais au signal brut : la formule est un opérateur de différence seconde et amplifie le bruit haute fréquence
- Un triplet n'est retenu que si le dénominateur $D$ est résolu au-dessus de son propre bruit propagé, $|D| > 2 sigma_D$

== Les réseaux nucléaires en détail

- *7 espèces :* chaîne alpha minimale, base stable
- *15 espèces :* chaîne alpha complète jusqu'à ni56, utilisée pour la plupart des tests préliminaires
- *35 espèces :* réseau de production actuel, ajoute des isotopes non-alpha
- *56 espèces :* échoue. L'algèbre linéaire à matrices denses du solveur de réseau scale en $O(n^3)$ ; une reformulation creuse est la correction naturelle

#v(0.5em)
#text(size: 0.9em)[
#cite(<timmes1992>, form: "prose") utilisent 130 isotopes, #cite(<schwab2020>, form: "prose") un réseau adaptatif de $tilde.op$495. Le réseau à 35 espèces inclut déjà la plupart des réactions les plus énergétiques mais en omet d'autres qui réduiraient le dégagement net, donc le signe du biais n'est pas évident a priori.
]

== Détection du front : un mode d'échec antérieur

#figure(
  image("figures/inflection_point_early_example.png", width: 62%),
)

#text(size: 0.85em)[
La température dépasse brièvement la température de cendres stable en avant du vrai front, si bien que le critère du point d'inflexion identifie mal la position du front. Remplacé par le passage à mi-hauteur, qui ne demande que d'identifier les deux paliers.
]

== Échec d'amorçage

#figure(
  image("figures/T_diffusion_no_ignition.png", width: 68%),
)

#text(size: 0.85em)[
Zone d'ignition trop petite : la perturbation manque simplement d'énergie pour déclencher une réaction auto-entretenue, et décroît par pure diffusion. La température d'ignition doit être assez basse pour ne pas gonfler le transitoire, assez haute pour amorcer.
]

== Profils des espèces

#figure(
  image("figures/overview_species_profile.png", width: 66%),
)

#text(size: 0.85em)[Profils radiaux incluant les fractions massiques des 36 espèces à travers le front.]

== Un bug d'intégrité des données

- Les graphes de comparaison montraient des sauts entre simulations sans aucun sens physique
- Cause racine : `read_sim_params()` ne relisait jamais réellement $Y_e$ depuis les fichiers de simulation, retombant silencieusement à $0.5$ pour *tous* les runs
- Conséquence : les filtres `--ye` matchaient tout, et des graphes nominalement à $Y_e = 0.5$ mélangeaient silencieusement $0.495$, $0.490$, ...
- Corrigé en recalculant $Y_e$ depuis la fraction massique de Ne40 réellement sur le disque

#v(0.5em)
#text(size: 0.9em)[Ce qui a ressemblé un temps à une forte dispersion physique était, en partie, un bug de post-traitement. Valider les outils de diagnostic est aussi nécessaire que valider la physique.]

== Références

#text(size: 0.7em)[
  #bibliography("references.bib", title: none, style: "apa")
]
