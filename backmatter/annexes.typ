#import "glossaire.typ": *

#set heading(numbering: "A.1")
#counter(heading).update(0)

= Additional Figures and Data <sec:appendix_a>

#figure(
  image("../figures/openmp_test_overview.png", width: 85%),
  caption: [Radial profile overview from one of the OpenMP scalability test runs of Section #ref(<sec:openmp_scalability>, supplement: none) (15-species network, 10 000 timesteps).],
) <fig:openmp_overview>

// TODO: additional supplementary figures, raw result tables, or extended
// test cases not shown in the main text go here.

== Sensitivity Analyses to Initial Conditions and Limiting Regimes

=== Impact of Domain Size and Acoustic Oscillations

This series of figures illustrates the sensitivity of the flame-speed calculation to the dimensions of the numerical domain and to acoustic reflections.

#figure(
  grid(
    columns: (1fr),
    gutter: 1.5em,
    image("../figures/Screenshot from 2026-06-17 13-26-57.png", width: 85%),
  ),
  caption: [
    Evolution of the flame-front position for different box lengths ($"x2u"$). When the front reaches the right end of the domain, its interaction with the boundary condition causes a numerical divergence (`nan`). This justifies the analysis stopping criterion and data cutoff set at 90% of the domain length ($0.9 L_x$) in the data post-processing.
  ]
) <fig-edge-effect>

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    image("../figures/Screenshot from 2026-06-17 13-36-59.png", width: 100%),
    image("../figures/Screenshot from 2026-06-15 10-43-59.png", width: 100%),
    image("../figures/Screenshot from 2026-06-15 14-00-31.png", width: 100%),
    image("../figures/Screenshot from 2026-06-16 11-42-43.png", width: 100%),
    image("../figures/Screenshot from 2026-06-17 13-31-30.png", width: 100%),
  ),
  caption: [
    Examples of instantaneous velocity signals $v(t)$ (obtained from the inflection point of $T$ and the maximum of $dot(epsilon)_"nuc"$) strongly affected by noise from compression waves. The oscillation frequency depends directly on the box length $"x2u"$, confirming the presence of acoustic waves in the box. The asymptotic time average makes it possible to extract the theoretical velocity despite these oscillations, although the signal remains highly noisy, which led to difficulties in drawing a conclusion for the project.
  ]
) <fig-acoustic-oscillations>

=== Spatio-Temporal Convergence Test ($x_t$)

This convergence study concerns the variation of $x_t$, the fraction of the box that is set to T at t=0 to initiate the deflagration, for a 15-species network ($rho = 3 times 10^9 ("g/cm")^3$, $X("C12") = 0.5$). The aim was to find the limiting value of $x_t$ that injects the energy required for ignition without exceeding this value.

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    image("../figures/15_network_xt=02.png", width: 100%),
    image("../figures/15_network_xt=2.png", width: 100%),
    image("../figures/15_network_xt=3.png", width: 100%),
    image("../figures/15_network_xt=04.png", width: 100%),
    image("../figures/15_network_xt=4.png", width: 100%),
  ),
  caption: [
    Spatio-temporal profiles ($T$, $P$, $dot epsilon_"nuc"$, $rho$) for different values of the parameter $x_t$. For ignition regions that are too small ($x_t <= 0.2$), the flame does not reach its steady state. Above this threshold, the deflagration is self-sustained. There is therefore a limiting value.
  ]
) <fig-xt-convergence-profiles>

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    image("../figures/15_network_speed_xt=2.png", width: 100%),
    image("../figures/15_network_speed_xt=3.png", width: 100%),
    image("../figures/15_network_speed_xt=4.png", width: 100%),
  ),
  caption: [
    The same results are obtained for the `speed_overview` velocity curves.
  ]
) <fig-xt-convergence-speed>

=== Extinction Regime by Diffusion and Out-of-Domain Photodisintegration

#figure(
  image("../figures/Screenshot from 2026-07-17 09-35-19.png", width: 85%),
  caption: [
    Spatio-temporal profiles of a simulation in a quasi-ignition regime followed by extinction through thermal diffusion ($X_("O16") = 0.8$, $rho = 10^8 "g/cm"^3$, 35-species network). An extremely large negative value of nuclear energy generation ($dot(epsilon)_"nuc" < -2 times 10^36 "erg/g/s"$) is observed at the very beginning of the simulation. This massive energy absorption corresponds to intense photodisintegration, amplified by exploring a temperature/density range outside the validity limits of the JINA REACLIB reaction-rate library.
  ]
) <fig-photodisintegration-extinction>

= Detailed Numerical Methods <sec:appendix_b>

This appendix expands on three methods summarized in the main text: the Aitken $Delta^2$ extrapolation of Section #ref(<sec:robust_cross_check>, supplement: none), the HLLC Riemann solver of Section #ref(<sec:discretization_solvers>, supplement: none), and the explicit scalar form of the conservation system introduced in vector notation in Section #ref(<sec:phys_continu>, supplement: none).

== Aitken $Delta^2$ Extrapolation <sec:aitken_derivation>

=== Derivation

Consider a sequence of local velocity estimates $v_1, v_2, v_3, dots$, obtained from the sliding-window regression of Section #ref(<sec:robust_cross_check>, supplement: none), and assume it relaxes geometrically toward an asymptote,
$ v_i = v_oo + A r^i $
for some ratio $r$ with $|r| < 1$ and amplitude $A$. This is the discrete analogue of the continuous exponential relaxation model of @eq:relaxation_model, sampled at the window centers. Three consecutive terms $v_1$, $v_2$, $v_3$ give three equations in the three unknowns $v_oo$, $A$, and $r$, which can be solved for $v_oo$ alone. Writing the first and second differences $Delta v_1 = v_2 - v_1$ and $Delta^2 v_1 = v_3 - 2 v_2 + v_1$, the geometric ansatz gives $Delta v_1 = A r (r-1)$ and $Delta^2 v_1 = A r (r-1)^2$, so that
$ v_oo = v_1 - (Delta v_1)^2 / Delta^2 v_1 = (v_3 v_1 - v_2^2) / (v_3 + v_1 - 2 v_2) $ <eq:aitken>
which is Aitken's $Delta^2$ formula. Unlike a direct nonlinear least-squares fit of the full sequence to the exponential model, @eq:aitken requires only algebraic operations on three numbers, and cannot itself diverge to a local minimum the way a multi-parameter nonlinear solver can.

=== Uncertainty Propagation and Ill-Conditioning

Each $v_i$ carries a formal uncertainty $sigma_i$ from the underlying window regression. Treating @eq:aitken as a function of $(v_1, v_2, v_3)$, linear error propagation gives
$ sigma_(v_oo)^2 = sum_(i=1)^3 ((partial v_oo) / (partial v_i))^2 sigma_i^2, $
with partial derivatives, writing $D = v_3 + v_1 - 2 v_2$ for the denominator of @eq:aitken,
$ (partial v_oo) / (partial v_1) = (v_3 - v_oo) / D, quad (partial v_oo) / (partial v_2) = (2 v_oo - 2 v_2) / D, quad (partial v_oo) / (partial v_3) = (v_1 - v_oo) / D. $
Because $D$ appears in the denominator of every partial derivative, @eq:aitken is intrinsically ill-conditioned whenever $D$ is small: this is precisely the regime in which the sequence has barely started to curve, i.e. is close to linear over the three sampled points, and Aitken extrapolation amounts to dividing two small, noisy quantities. A triplet is treated as well-conditioned only when $D$ is resolved above its own propagated uncertainty $sigma_D = sqrt(sigma_1^2 + sigma_3^2 + 4 sigma_2^2)$, specifically $|D| > 2 sigma_D$; triplets failing this criterion are excluded from the combined estimate (Section #ref(<sec:robust_cross_check>, supplement: none)) rather than included with an artificially small formal uncertainty.

== HLLC Riemann Solver <sec:hllc_derivation>

The HLLC flux of @eq:hllc_flux (Section #ref(<sec:discretization_solvers>, supplement: none)) requires estimates of the left, right, and contact wave speeds $S_L$, $S_R$, $S_*$, following #cite(<toro1994>, form: "prose"). Given left and right states $U_L$, $U_R$ with density $rho_K$, normal velocity $u_K$, pressure $P_K$, and sound speed $c_K$ ($K in {L, R}$), the wave-speed estimates are
$ S_L = min(u_L - c_L, u_R - c_R), quad S_R = max(u_L + c_L, u_R + c_R), $
$ S_* = (P_R - P_L + rho_L u_L (S_L - u_L) - rho_R u_R (S_R - u_R)) / (rho_L (S_L - u_L) - rho_R (S_R - u_R)). $
The star-region states $U_(*K)$ used in @eq:hllc_flux are then
$ U_(*K) = rho_K ((S_K - u_K)/(S_K - S_*)) vec(1, S_*, E_K/rho_K + (S_* - u_K)[S_* + P_K/(rho_K (S_K - u_K))]) $
for the density, normal momentum, and total energy components respectively, with the transverse momentum and species mass fraction components of $U_(*K)$ carried over unchanged from $U_K$, since they are advected passively across the contact wave.

== Explicit 1D Form of the Conservation System <sec:explicit_1d_system>

Section #ref(<sec:phys_continu>, supplement: none) presents the governing equations in vector form (@eq:conservation_law). Restricted to the 1D planar geometry used throughout this study ($partial / (partial y) = partial / (partial z) = 0$, single velocity component $u$), the system reduces to five coupled scalar equations, one continuity equation, one momentum equation, one energy equation, and $N_"species" - 1$ independent species equations (the last being fixed by the constraint $sum_k X_k = 1$):
$ (partial rho) / (partial t) + (partial (rho u)) / (partial x) = 0, $
$ (partial (rho u)) / (partial t) + (partial (rho u^2 + P)) / (partial x) = rho g, $
$ (partial E) / (partial t) + (partial ((E + P) u)) / (partial x) = rho u g + partial / (partial x) (K (partial T) / (partial x)) + rho dot(epsilon)_"nuc", $
$ (partial (rho X_k)) / (partial t) + (partial (rho X_k u)) / (partial x) = rho dot(omega)_k, quad k = 1, dots, N_"species" - 1. $
These are the equations actually discretized cell-by-cell by the finite-volume scheme of Section #ref(<sec:discretization_solvers>, supplement: none); the vector notation of Section #ref(<sec:phys_continu>, supplement: none) is retained in the main text for compactness and to keep the formulation independent of the number of species and spatial dimensions used in a given run.