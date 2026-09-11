#import "../../backmatter/glossaire.typ": *

== Development of the Data Post-Processing Method <sec:post_processing>

=== Pipeline Architecture <sec:pipeline_architecture>

The full analysis chain runs in four stages: `generate_simulations.py` sizes and submits a simulation following the self-similar scheme of Section #ref(<sec:box_config>, supplement: none), #gls("phlegethon") runs on the Genoa cluster and writes RPROFS snapshots, a flame-speed extraction stage processes these snapshots into a single speed estimate per simulation, and `analyze_results.py` aggregates the results across the parameter space into cached csv tables and comparison plots.

=== Flame Front Detection <sec:front_detection>

The position of the flame front within a snapshot is estimated from two independent indicators and averaged: the radius at which the temperature profile crosses the midpoint between the fuel and ash temperatures, $(T_"fuel" + T_"ashes")\/2$, and the radius of the peak nuclear energy generation rate $dot(epsilon)_"nuc"$. The mean temperature value crossing criterion replaced an earlier implementation based on the inflection point of $T(r)$, which proved erratic on profiles with local noise, since it relies on a well-behaved second derivative; the midpoint crossing only requires the fuel and ash plateaus themselves to be identifiable, which is a substantially weaker requirement, and as such, more consistent.

#figure(
    image("../../figures/inflection_point_early_example.png", width: 70%),
  caption: [A case where the temperature briefly exceeds the stable ash temperature ahead of the true front, causing the inflection-point criterion to misidentify the front position.],
) <fig:inflection_point_issue>

In both cases, sub-cell resolution is recovered via a parabolic interpolation across the three cells adjacent to the remarkable point (mean temperature crossing or peak $dot(epsilon)_"nuc"$), rather than reporting the position at native grid resolution. Snapshots past the point where the flame reaches 90% of the box length are discarded, to exclude the influence of the domain boundary described in Section #ref(<sec:acoustic_reflections>, supplement: none).

#figure(
    image("../../figures/boundary_effect_and_low_Tign_example.png", width: 85%),
  caption: [Radial profiles as the flame approaches the right-hand domain boundary: the pressure and density profiles show a visible upturn near the edge, motivating the 90% cutoff. This run also used a reduced ignition temperature without ignition issues.],
) <fig:cutoff_90>

=== Velocity Extraction <sec:velocity_extraction>

Three successive methods were used over the course of the project to convert a front-position time series $r(t)$ into a single flame speed estimate, each addressing a shortcoming of the previous one; the difficulties that motivated each transition are discussed in detail in Section #ref(<sec:challenges>, supplement: none).

*Time-averaged velocity.* The initial approach averaged the instantaneous velocity $dif r\/dif t$ over the full run. This estimator is biased whenever the transient discussed in Section #ref(<sec:convergence>, supplement: none) has not fully decayed by $t_max$, which is the common case.

*Polynomial fit.* A low-order polynomial fit to $r(t)$, differentiated analytically, was adopted next to obtain a smooth velocity estimate without differencing noisy raw snapshots. It remains a numerically robust fallback but has no physical basis for extrapolating to the true asymptotic speed.

*Integrated exponential relaxation fit.* The current default method fits $r(t)$ directly with the physically motivated model
$ r(t) = r_0 + v_infinity t + A tau (1 - e^(-t\/tau)) $ <eq:relaxation_model>
so that $v_infinity$ is a direct estimate of the asymptotic flame speed and $tau$ of the transient's relaxation time. This functional form is motivated by the classical theory of traveling-wave solutions to reaction-diffusion systems: near a stable traveling wave, #cite(<fife1977>, form: "prose") show that small perturbations decay exponentially in time, consistent with the flame speed acting as a stable physical attractor, in the sense of the eigenvalue flame-speed formalism introduced by #cite(<zeldovich1938>, form: "prose"), also underlying the formulation of #cite(<timmes1992>, form: "prose"). It should be stressed that both of these classical results were derived for comparatively simple reaction-diffusion systems, typically a single chemical reaction-progress variable without degenerate thermodynamics, fully compressible hydrodynamics, or a stiff multi-species #glsl("network"). Here they are used as physical motivation for the functional form rather than as a rigorous derivation for this specific, considerably more complex multiphysics system like the ones we consider in this study. The superposition of several coupled effects, thermal conduction, compressible hydrodynamics, a 35-species reaction network, and, as discussed in Section #ref(<sec:acoustic_reflections>, supplement: none), spurious acoustic reflections, gives additional mechanisms and timescales that a single exponential mode is not guaranteed to capture. This justification is therefore asymptotic and qualitative, and does not guarantee a single exponential mode dominates the transient from $t=0$ onwards, a limitation revisited in Section #ref(<sec:challenges>, supplement: none) together with the fit-stability issues it produces in practice.

=== Robust Cross-Check <sec:robust_cross_check>

To guard against the fit-stability issues discussed in Section #ref(<sec:challenges>, supplement: none), every simulation is additionally processed by an independent, non-parametric estimator that never differentiates the raw position data directly:

- *Sliding-window local slopes.* $r(t)$ is split into consecutive windows, each fit by ordinary least squares to obtain a local velocity and its formal uncertainty.
- *Aitken $Delta^2$ extrapolation.* Aitken's delta-squared method is applied to consecutive triplets of these local velocities to extrapolate the asymptotic value, with linear uncertainty propagation and rejection of triplets whose denominator is not resolved above its own noise floor. The method itself is detailed in Appendix #ref(<sec:aitken_derivation>, supplement: none).
- *Late-window plateau.* An inverse-variance-weighted mean of the local velocities over the last fraction of the run serves as a numerically bullet-proof fallback with no extrapolation.

The three estimates, together with the exponential fit of @eq:relaxation_model, are combined into a single inverse-variance-weighted robust estimate $v_"robust"$, flagged as `agree` when the individual estimates lie within 5% of one another and as disagreeing otherwise. A collapse guard compares the exponential fit's $v_infinity$ against the run's overall secant slope $(r(t_max) - r(t_0))\/(t_max - t_0)$; if the two differ by more than a factor of 20 (or the fit gives a non-positive speed), the exponential fit is discarded in favor of $v_"robust"$.

=== Diagnostic and Caching Infrastructure <sec:diagnostic_caching>

Because processing every simulation's RPROFS snapshots from scratch is costly, `analyze_results.py` caches results in a CSV file, re-used on subsequent runs unless explicitly forced to recompute. Alongside the velocity estimates, each entry records the number of valid snapshots retained after the boundary cutoff, the total simulated time span $T_"span"$, and the ratio $tau \/ T_"span"$: a value exceeding unity flags a simulation whose transient likely has not been fully resolved within $t_max$, independent of whether the fit itself converged cleanly. These diagnostics are used throughout Section #ref(<sec:results>, supplement: none) to distinguish genuine physical discrepancies from simulations that would require a longer run.

Empirically, this ratio does not follow a simple fixed power-law dependence on speed: $t_max$ reaches around 1.5 $tau$ at high density and high speed, but drops to only around 0.1 $tau$ at low density and low speed, with the divergence between the two accelerating rather than following a constant scaling exponent. This behavior, and its consequences for low-density simulations specifically, are examined in detail in Section #ref(<sec:challenges>, supplement: none).
