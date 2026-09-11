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
  = Thermonuclear Deflagration Flames in Type Ia Supernovae

  == A 1D Multiparametric Study on the Phlegethon Program

  #v(1em)
  Soutenance de stage, Projet de Recherche \
  Alexis Spaeth-Lemarchand \
  HITS, Physics of Stellar Objects group

  #v(0.5em)
  #text(size: 0.8em)[Tuteurs : Prof. Dr. Friedrich K. Röpke, Dr. Giovanni Leidi, Dr. Alexander Holas]
]

== Context: Why Type Ia Supernovae Matter

- Standardizable cosmological candles: measured the accelerated expansion of the Universe
- Thermonuclear explosion of a carbon-oxygen white dwarf near the Chandrasekhar mass
- Precision cosmology now limited by *systematic* uncertainty in the explosion mechanism itself, not by statistics

#v(1em)
#punchline[Improving the physics of the explosion improves our measurement of the Universe]

== Where the Laminar Flame Speed Fits In

- The explosion is ultimately driven by *turbulent* flame acceleration in 3D: not something a 1D study models directly
- But turbulence itself is shaped by the *local* laminar flame speed: #cite(<holas2026>, form: "prose") show turbulence suppression is highly localized through the $Y_e$ dependence of $v_l$
- $v_l$ is a necessary microphysical input to the larger-scale turbulent models: not the whole story, but the piece this project addresses

#v(0.5em)
$ v_l = f(rho, X_i, Y_e) $

== The Gap in the Literature

#align(center)[
  #table(
    columns: (1fr, 1fr),
    stroke: 0.5pt,
    align: left,
    [*Timmes & Woosley (1992)*], [*Schwab et al. (2020)*],
    [$v_l (rho, X_i)$], [$v_l (rho, Y_e)$],
    [No $Y_e$ dependence], [No composition dependence],
  )
]

#v(1em)
#punchline[Nobody has combined all three parameters into one formula]

#v(0.5em)
Goal of this internship: explore the full $(rho, X_i, Y_e)$ space with Phlegethon, and work towards that combined formula.

== The Tool: Phlegethon

A compressible, multiphysics stellar hydrodynamics code #cite(<leidi2026>, form: "prose"), finite-volume:

$ (partial U) / (partial t) + nabla dot bold(F)(U) = S(U), quad U = mat(rho; rho bold(u); E; rho X_k) $

#v(0.3em)
#text(size: 0.85em)[
$ bold(F)(U) = mat(rho bold(u); rho bold(u) ⊗ bold(u) + P bold(I); (E+P) bold(u); rho X_k bold(u)) quad quad
  S(U) = mat(0; rho bold(g); rho bold(u) dot bold(g) + nabla dot (K nabla T) + rho dot(epsilon)_"nuc"; rho dot(omega)_k) $
]

#v(0.3em)
#text(size: 0.8em)[
*$bold(F)$, advective fluxes:* mass; momentum + pressure; total energy + pressure work; species advection \
*$S$, sources:* gravity $rho bold(g)$; gravitational power; thermal conduction $nabla dot (K nabla T)$; nuclear energy release $rho dot(epsilon)_"nuc"$; species production $rho dot(omega)_k$
]

== What a Deflagration Flame Looks Like

#figure(
  image("figures/T_front_closeup.png", width: 78%),
)

#text(size: 0.85em)[Ignition profile at $t = 0$, then a self-sustained front propagating at constant speed. Ashes on the left, fuel on the right.]

== The Diagnostics

#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  image("figures/overview_clean_15species.png", width: 100%),
  image("figures/speed_overview_clean_15species.png", width: 100%),
)

#text(size: 0.85em)[Front position from two independent indicators: temperature midpoint crossing and peak nuclear energy release, with sub-cell parabolic interpolation.]

== A Physical Attractor

Convergence tests: grid resolution, box size, ignition temperature, ignition spot size.

#figure(
  image("figures/acoustic_oscillation_damping.png", width: 52%),
)

#punchline[The transient changes. The asymptotic flame speed never does.]

== Nuclear Networks: More Physics, More Cost

Progression over the internship: 7 $arrow.r$ 15 $arrow.r$ 35 species.

#v(0.5em)
#align(center)[
  #table(
    columns: (auto, auto, auto, auto),
    stroke: 0.5pt,
    align: center,
    [*MPI ranks*], [*OMP threads*], [*wct ($times 10^2$ s)*], [*Duration*],
    [64], [1], [0.575], [1min 22s],
    [64], [2], [0.323-0.564 (var.)], [N/A],
    [64], [4], [0.554], [1min 20s],
    [64], [8], [0.977], [2min 18s],
    [64], [16], [1.320], [3min 06s],
  )
]

== The Phase Space: Orders of Magnitude

- Composition $X_i$ set by the network; density $rho$ swept from $10^7$ to $10^10$ g/cm#super[3]
- Across that range, flame width and flame speed each vary by *orders of magnitude*
- One fixed box, resolution and $t_max$ cannot work everywhere

#v(0.5em)
#punchline[Solution: scale every simulation to its own expected physics]

#text(size: 0.85em)[
Box length in flame widths, fixed cells per flame width, $t_max = x_"2u" \/ v_"expected"$ from Timmes & Woosley $arrow.r$ roughly constant cost per simulation across the whole phase space.
]

== The Third Parameter: Variable $Y_e$

- No naturally abundant isotope gives the required $Y_e$ shift without disturbing the C-O composition
- Ne40 (Z=10, A=40, $Z\/A = 0.25$) introduced as an *inert spectator species*

$ X_s (upright("Ne40")) = (0.5 - Y_e) / 0.25 $

- Chosen over Ne22: $~6 times$ less mass fraction for the same $Y_e$ shift, perturbing the fuel far less
- What matters physically is the *fuel* $Y_e$: an inert species keeps it fixed by construction

== Extracting a Speed (1/4): the Naive Average

#figure(
  image("figures/naive_mean_example.png", width: 66%),
)

#text(size: 0.85em)[Dashed line: the time-averaged velocity. Biased whenever the transient has not decayed by $t_max$.]

== Extracting a Speed (2/4): the Polynomial Fit

#figure(
  image("figures/speed_overview_clean_15species.png", width: 66%),
)

#text(size: 0.85em)[Smooth and numerically robust, but no physical basis for extrapolating to the asymptotic speed.]

== Extracting a Speed (3/4): the Exponential Fit

$ r(t) = r_0 + v_infinity t + A tau (1 - e^(-t\/tau)) $

#figure(
  image("figures/exp_fit_good_example.png", width: 50%),
)

#text(size: 0.85em)[
Physically motivated: near a stable travelling wave, perturbations decay exponentially #cite(<fife1977>, form: "prose"), consistent with the eigenvalue flame-speed formalism of #cite(<zeldovich1938>, form: "prose") underlying #cite(<timmes1992>, form: "prose").
]

== Extracting a Speed (4/4): When It Collapses

#figure(
  image("figures/exp_fit_absurd_example.png", width: 52%),
)

#text(size: 0.85em)[
The 3-parameter nonlinear fit is ill-conditioned when the run does not cover several $tau$. Fix: an independent, non-parametric cross-check (sliding-window regression + Aitken $Delta^2$) that *flags disagreement* instead of trusting one fit blindly.
]

== Where the Noise Comes From

#punchline["Change a number and rerun" was never the method: hypothesis, test, cause]

#v(0.3em)
#text(size: 0.9em)[
*Hypothesis:* the ignition energy also seeds a compression wave, bouncing off the reflective boundaries and modulating the density, hence the speed, at each pass. \
*Test:* the oscillation period should then scale with box length.
]

#figure(
  image("figures/acoustic_bounce_x2u.png", width: 48%),
)

== Current Results

#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  figure(
    image("figures/compare_results_polyfit_era.png", width: 100%),
    caption: [Polynomial fit: clean trend, moderate offset],
  ),
  figure(
    image("figures/compare_results_after.png", width: 100%),
    caption: [Exponential fit: accurate when conditioned],
  ),
)

#text(size: 0.85em)[Good agreement with #cite(<timmes1992>, form: "prose") for $rho ≳ 5 times 10^8$ g/cm#super[3]. Robustness and accuracy are in tension between the two methods.]

== Why Low Density Is Hard

- Diagnostic ratio $tau \/ T_"span"$ across the parameter space:
  - high density: $t_max approx 1.5 tau$
  - low density: $t_max approx 0.1 tau$
- The divergence *accelerates* as density drops: not a fixed power law
- A naive argument ($t_max$ and $tau$ both scaling as $ell \/ v$, with $ell prop 1\/v$) would predict a *constant* ratio, which the data contradict

#v(0.5em)
#punchline[Low-density runs are precisely those starved of resolved relaxation time]

== Phase-Space Maps

#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  image("figures/results_Ye_0_5_0_497_expo_04_heatmap.png", width: 100%),
  image("figures/results_Ye_0_5_0_497_expo_04_3d.png", width: 100%),
)

#text(size: 0.85em)[Produced, but not yet conclusive: the low-density artifacts dominate their appearance at low $rho$, and the $Y_e$ dimension is barely sampled.]

== Conclusion

*Delivered:* a self-similar simulation design validated against a physical attractor; a full post-processing pipeline with robust, self-diagnosing speed extraction; a working $Y_e$-variation methodology; a contribution to Phlegethon's own 1D branch.

*Not delivered:* the combined formula $v_l = f(rho, X_i, Y_e)$, blocked by the low-density transient and an unswept $Y_e$ dimension.

#v(0.5em)
#punchline[The gap between a simulation producing a number and that number being trustworthy was the real subject of this internship]

== Perspectives

*Short term:* characterize the $tau$ scaling and lengthen low-density runs; complete the $Y_e$ sweep; fit the combined formula.

*Then, what the formula is actually for:*
- Subgrid input for multi-dimensional turbulent deflagration simulations, which cannot resolve centimetre-scale flames
- Deciding explosion versus gravitational collapse in electron-capture supernovae #cite(<holas2026>, form: "prose")
- Reducing the systematic uncertainty that currently limits Type Ia supernovae as cosmological candles

#v(1em)
#align(center)[#text(size: 1.6em)[Merci.]]

= Annexes

== Simulation Setup

- Planar 1D box, propagation along $x_2$, reflective boundaries
- Ignition profile at $t=0$:
$ T(x) = T_b + T times 0.5 (1 - tanh((x - "xt" dot x_"2u") \/ "deltax")) $
- $"deltax" = "xt" \/ 2$ fixed by a convergence study; absolute ignited length held constant across the sweep by rescaling $"xt"$ when $x_"2u"$ changes
- Resolution: at least 10 cells per flame width; $"nx2" = 2048$ in practice across the phase space
- Box length: 300 flame widths

== Box Sizing and Cost

$ x_"2u" = N_"widths" times ell_"Timmes", quad "nx2" = N_"widths" times N_"cells/width", quad t_max = x_"2u" \/ v_"cond,Timmes" $

Flame speed and flame width vary in inverse proportion across $(rho, X_i)$, so the product setting $"nx2"$ varies little and rounds consistently to 2048: a fast, thin flame is resolved at the same effective resolution as a slow, thick one integrated for longer.

#v(0.5em)
For $Y_e != 0.5$, both are corrected by the Schwab factor
$ "factor"(Y_e) = 1 + 96.8 (0.5 - Y_e) $

== Reference Formulas

*Timmes & Woosley (1992), eq. 43:*
$ v_"cond" = 92.0 (rho \/ 2 times 10^9)^0.805 [X(upright("C12"))\/0.5]^0.889 quad upright("km/s") $

*Schwab et al. (2020), eq. 2:*
$ v_"flame" = 16.0 rho_9^0.813 [1 + 96.8 (0.5 - Y_e)] quad upright("km/s") $

*Composition with the Ne40 spectator:*
$ X_s (upright("C12")) = "ratio"_"C/O" (1 - X_s (upright("Ne40"))), quad X_s (upright("O16")) = (1 - "ratio"_"C/O")(1 - X_s (upright("Ne40"))) $

== Aitken $Delta^2$ Extrapolation

Assuming the sequence of local velocity estimates relaxes geometrically, $v_i = v_infinity + A r^i$:

$ v_infinity = (v_3 v_1 - v_2^2) / (v_3 + v_1 - 2 v_2) $

- Algebraic on three numbers: cannot diverge to a local minimum the way a nonlinear solver can
- Applied to *smoothed* sliding-window slopes, never to the raw signal: the formula is a second-difference operator and amplifies high-frequency noise
- A triplet is used only if the denominator $D$ is resolved above its own propagated noise, $|D| > 2 sigma_D$

== Nuclear Networks in Detail

- *7 species:* minimal alpha chain, stable baseline
- *15 species:* alpha chain complete to ni56, used for most preliminary tests
- *35 species:* current production network, adds non-alpha isotopes
- *56 species:* fails. Dense-matrix linear algebra in the network solver scales as $O(n^3)$; a sparse reformulation is the natural fix

#v(0.5em)
#text(size: 0.9em)[
#cite(<timmes1992>, form: "prose") use 130 isotopes, #cite(<schwab2020>, form: "prose") an adaptive network of $tilde.op$495. The 35-species network already includes most of the highest-yield reactions but omits some that would reduce net energy release, so the sign of the bias is not obvious a priori.
]

== Front Detection: an Earlier Failure Mode

#figure(
  image("figures/inflection_point_early_example.png", width: 62%),
)

#text(size: 0.85em)[
Temperature briefly exceeds the stable ash temperature ahead of the true front, so the inflection-point criterion misidentifies the front position. Replaced by the midpoint crossing, which only requires the two plateaus to be identifiable.
]

== Ignition Failure

#figure(
  image("figures/T_diffusion_no_ignition.png", width: 68%),
)

#text(size: 0.85em)[
Too small an ignition spot: the perturbation simply lacks the energy to trigger a self-sustained reaction, and decays by pure diffusion. Ignition temperature must be low enough not to inflate the transient, high enough to ignite at all.
]

== Species Profiles

#figure(
  image("figures/overview_species_profile.png", width: 66%),
)

#text(size: 0.85em)[Radial profiles including the mass fractions of all 36 species across the front.]

== A Data-Integrity Bug

- Comparison plots showed jumps between simulations with no physical sense
- Root cause: `read_sim_params()` never actually re-read $Y_e$ from the simulation files, silently defaulting to $0.5$ for *every* run
- Consequence: `--ye` filters matched everything, and plots nominally at $Y_e = 0.5$ silently mixed in $0.495$, $0.490$, ...
- Fixed by recomputing $Y_e$ from the Ne40 mass fraction actually on disk

#v(0.5em)
#text(size: 0.9em)[What looked for a while like severe physical scatter was, in part, a post-processing bug. Validating the diagnostic tools is as necessary as validating the physics.]

== References

#text(size: 0.7em)[
  #bibliography("references.bib", title: none, style: "apa")
]
