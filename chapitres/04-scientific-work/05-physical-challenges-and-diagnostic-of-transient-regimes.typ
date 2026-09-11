#import "../../backmatter/glossaire.typ": *

== Physical Challenges and Diagnostic of Transient Regimes <sec:challenges>

=== Long Transients and the Failure of Time-Averaging <sec:long_transients>

The first systematic validation attempt ran 66 simulations at $Y_e = 0.5$ across the density and C/O grid of Section #ref(<sec:ye_methodology>, supplement: none), to be compared against #cite(<timmes1992>, form: "prose"). The results were not conclusive: the instantaneous flame speed decreased monotonically over the full duration of most runs, with no clear plateau reached by $t_max$. Averaging the speed over the run, the initial approach described in Section #ref(<sec:post_processing>, supplement: none), is therefore biased, and biased by an amount that depends on how much of the underlying transient happens to be covered by $t_max$, itself a function of $(rho, "ratio"_"C/O", Y_e)$ through the self-similar sizing of Section #ref(<sec:box_config>, supplement: none).

// TODO: illustrative figure of the naive time-averaged velocity here, showing
// the lack of a clear plateau within t_max. <fig:naive_average>

This inconsistency across the parameter space, rather than any single simulation looking obviously wrong, was the first indication that the extraction method itself, not only the underlying physics, needed to be reconsidered, motivating the move to the exponential relaxation fit of @eq:relaxation_model.

#figure(
  image("../../figures/polyfit_speed_example.png", width: 80%),
  caption: [Polynomial-fit extraction on a well-behaved run: smooth and numerically stable, but with no physical basis for the extrapolated asymptotic value.],
) <fig:polyfit_example>

=== Exponential Fit Instability and the Collapse Guard <sec:fit_instability>

The nonlinear fit of @eq:relaxation_model can converge to a degenerate solution in which $v_infinity$ collapses toward zero while $A$ and $tau$ absorb the front's actual motion into the transient term. Diagnostic plots produced during the project showed this manifesting as fitted speeds many orders of magnitude below the expected value, in one case around $10^(-15)$ cm/s, without the fit raising any error.

#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  figure(
    image("../../figures/exp_fit_good_example.png", width: 100%),
    caption: [A well-conditioned fit: $tau$ is well resolved within $t_max$.],
  ),
  figure(
    image("../../figures/exp_fit_absurd_example.png", width: 100%),
    caption: [A degenerate fit: the extrapolated asymptote lies far outside the range the data actually cover.],
  ),
) <fig:exp_fit_comparison>

The underlying cause, confirmed once the diagnostics of Section #ref(<sec:post_processing>, supplement: none) were in place, is a strongly ill-conditioned fit: when $t_max$ does not cover several $tau$, the three parameters $v_infinity$, $A$, and $tau$ become highly correlated, and the least-squares solver can settle on a degenerate combination that reproduces the observed $r(t)$ equally well numerically while being physically meaningless. As discussed in Section #ref(<sec:tau_speed_relation>, supplement: none), this is precisely the regime that low-density simulations tend to fall into. The collapse guard and robust cross-check of Section #ref(<sec:post_processing>, supplement: none) were introduced specifically to catch and correct for this failure mode rather than to prevent it outright, since the underlying data limitation, insufficient $t_max$ relative to $tau$, cannot be fixed after the fact.

=== Sensitivity to the Extraction Method <sec:method_sensitivity>

A further complication surfaced when comparing extraction methods directly against one another: applying Aitken $Delta^2$ extrapolation to the raw, undifferenced velocity signal produced more coherent results on some simulations but substantially more aberrant ones on others, such that the overall trend across the parameter space was noisier than with the simpler polynomial fit it was meant to replace. The reason is that Aitken extrapolation is effectively a second-difference operator, and second differences strongly amplify high-frequency noise, of the kind discussed in Section #ref(<sec:acoustic_consequences>, supplement: none), when applied directly to already-noisy raw data. This was resolved not by abandoning Aitken extrapolation but by applying it to smoothed, sliding-window local slopes rather than to the raw signal, and by cross-checking the result against independent estimators, exactly the robust cross-check pipeline described in Section #ref(<sec:post_processing>, supplement: none).

=== The $Y_e$ Labeling Bug <sec:ye_bug>

The most consequential issue encountered was not a numerical or physical effect at all. For an extended period, comparison plots at fixed $rho$ and composition showed large, apparently random jumps in flame speed between adjacent density points of the same C/O ratio, jumps too large and too irregular to be explained by the transient and fit issues above. The eventual diagnosis was that `read_sim_params()`, the routine responsible for reading each simulation's parameters back from its configuration files, never actually recomputed $Y_e$ from the composition on disk: it silently returned a hardcoded default of $0.5$ for every simulation, regardless of the true value set through the Ne40 spectator fraction of Section #ref(<sec:ye_methodology>, supplement: none). As a direct consequence, any `--ye` filter matched every simulation unconditionally, and comparison plots ostensibly restricted to $Y_e = 0.5$ silently mixed in simulations run at $Y_e = 0.495$, $0.490$, and other values, since nothing in the pipeline could actually tell them apart. Once identified, the fix was to recompute $Y_e$ directly from the Ne40 mass fraction present in each simulation's own composition, following @eq:ye_ne40 in reverse. This episode is worth recording explicitly: what appeared for some time to be a severe physical or numerical inconsistency in the flame-speed data was, in large part, a data-integrity bug in the post-processing pipeline itself, underscoring the need to validate the diagnostic tools thoroughly before drawing physical conclusions from their output.

=== The $tau$-Speed Relation and Low-Density Simulations <sec:tau_speed_relation>

The diagnostic ratio $tau \/ T_"span"$ introduced in Section #ref(<sec:post_processing>, supplement: none) revealed a systematic pattern across the parameter space: at high density and high speed, $t_max$ (sized from the expected Timmes speed, Section #ref(<sec:box_config>, supplement: none)) reaches around 1.5 $tau$, while at low density and low speed it drops to only around 0.1 $tau$, a difference of more than an order of magnitude in the ratio itself. Notably, this progression does not appear linear: the growth of $tau$ relative to $t_max$ accelerates as density decreases, rather than following a fixed power-law dependence on speed. A naive argument, that both $t_max$ and $tau$ should scale as $ell \/ v$, with the flame width $ell$ itself inversely proportional to $v$ (Section #ref(<sec:box_config>, supplement: none)), would predict $t_max prop 1\/v^2$ for both quantities and hence a roughly *constant* ratio between them, which is directly contradicted by the accelerating divergence actually observed. This suggests that $tau$ picks up an additional density dependence beyond the simple flame-width-crossing argument, possibly related to the same low-density regime change flagged by the ignition-temperature issue of Section #ref(<sec:convergence>, supplement: none), though this connection has not been established. A precise characterization of this behavior has not been carried out and is left as an avenue for future work (Section #ref(<sec:planning>, supplement: none)). In practice, the consequence is direct: low-density simulations are the ones most starved of resolved relaxation time relative to $tau$, making them the most likely to trigger the collapse guard of Section #ref(<sec:post_processing>, supplement: none) and to show the largest residual disagreement between extraction methods in the results of Section #ref(<sec:results>, supplement: none).

=== Acoustic Reflections: Consequences for the Extracted Signal <sec:acoustic_consequences>

The physical origin of this oscillatory noise, a compression wave seeded by the artificial ignition energy and modulating the local density ahead of the flame front on each pass, was established in Section #ref(<sec:acoustic_reflections>, supplement: none). Its consequence for the extraction methods of Section #ref(<sec:post_processing>, supplement: none) is that this noise is superposed on the smoother relaxation transient discussed above, rather than replacing it: any fitting method has to contend with both simultaneously. This is part of why the sliding-window averaging step of the robust cross-check, rather than any single global fit, proved necessary: averaging over a window comparable to or larger than the reflection period suppresses this oscillatory component before the extrapolation step is applied, whereas a fit applied directly to the raw signal has no such protection.

=== Summary <sec:challenges_summary>

Taken together, these five issues, biased time-averaging, fit degeneracy, extraction-method noise sensitivity, the $Y_e$ labeling bug, and the density-dependent transient length, compounded rather than occurring in isolation, and disentangling them required building the diagnostic infrastructure of Section #ref(<sec:post_processing>, supplement: none) alongside the physical investigation itself. The main lesson carried forward is that the reliability of a derived physical quantity, here the flame speed, cannot be assessed from the quantity alone; it required cross-checking independent extraction methods against each other and validating the labeling of the data feeding into them, which is what ultimately exposed the $Y_e$ bug that a purely physics-focused investigation would not have caught.
