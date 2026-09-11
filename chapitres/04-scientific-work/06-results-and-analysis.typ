#import "../../backmatter/glossaire.typ": *

== Results and Analysis <sec:results>

=== Validation Against Timmes and Woosley (1992) at $Y_e = 0.5$ <sec:validation_timmes>

The full $Y_e = 0.5$ sweep of Section #ref(<sec:ye_methodology>, supplement: none), 66 simulations spanning eleven densities and six C/O ratios, has been completed and processed through the pipeline of Section #ref(<sec:post_processing>, supplement: none). @fig:compare_results_after shows the resulting flame speed, $v_"robust"$ where the collapse guard flagged the exponential fit as unreliable and $v_"sim"$ otherwise, against the prediction of #cite(<timmes1992>, form: "prose") for each composition.

// TODO: replace with the final, re-generated version of this comparison once
// the low-density issue below is investigated further.
#figure(
  image("../../figures/compare_results_after.png", width: 85%),
  caption: [Simulated flame speed vs. the prediction of #cite(<timmes1992>, form: "prose") at $Y_e = 0.5$, across the full density and C/O grid of Section #ref(<sec:ye_methodology>, supplement: none), with exponential fitting.],
) <fig:compare_results_after>

At $rho ≳ 5 times 10^8$ g/cm#super[3], @fig:compare_results_polyfit (polynomial fit) shows a clean, monotonic trend in log-log space for every composition, correctly ordered relative to one another, though offset from the #cite(<timmes1992>, form: "prose") prediction by a moderate but fairly consistent factor. This confirms that the underlying physics behaves consistently across the composition grid in this density range, even though the polynomial estimator itself is not expected to converge to the true asymptotic speed (Section #ref(<sec:post_processing>, supplement: none)).

// NOTE: figure and paragraph below compare against the polynomial-fit
// extraction directly.
#figure(
  image("../../figures/compare_results_polyfit_era.png", width: 85%),
  caption: [The same $Y_e = 0.5$ validation, extracted with the polynomial-fit method rather than the exponential relaxation fit of @fig:compare_results_after.],
) <fig:compare_results_polyfit>

@fig:compare_results_after (exponential fit) tells a more mixed story over the same density range. On the subset of simulations where the fit is well-conditioned (Section #ref(<sec:tau_speed_relation>, supplement: none)), the extracted speed sits closer to the #cite(<timmes1992>, form: "prose") prediction than the polynomial estimate on the same points, consistent with the exponential model's stronger physical motivation (Section #ref(<sec:post_processing>, supplement: none)). However, since a substantial fraction of simulations in this range still fail to produce a well-conditioned fit, points from different compositions become interleaved rather than staying cleanly separated: some higher-density points fall below lower-density ones of a different composition, an ordering violation not observed in the polynomial extraction at these densities specifically. At lower densities, both extraction methods show outliers, and the polynomial fit's advantage in this respect is confined to the higher-density regime. In aggregate, the exponential fit is therefore more accurate on the individual simulations where it succeeds, but less reliable as a global picture, since a failed fit is not visually distinguishable from a successful one without consulting the diagnostics of Section #ref(<sec:post_processing>, supplement: none). Below $rho ≈ 5 times 10^8$ g/cm#super[3], several points depart from the theoretical curve by multiple orders of magnitude, in some cases dropping to values that are clearly non-physical.

=== Diagnosis of the Low-Density Discrepancy <sec:low_density_diagnosis>

The low-density outliers in @fig:compare_results_after are not scattered randomly across the grid: they recur at the same handful of density values across several different C/O ratios simultaneously. This pattern, several compositions failing together at the same $rho$ rather than isolated simulations failing independently, points to a systematic cause tied to density itself rather than to per-simulation numerical noise.

Cross-referencing these outliers against the diagnostics of Section #ref(<sec:post_processing>, supplement: none) confirms this: the affected simulations are overwhelmingly the same ones flagged by a high $tau \/ T_"span"$ ratio and by disagreement (`agree = false`) between the independent extraction methods of Section #ref(<sec:post_processing>, supplement: none), consistent with the accelerating growth of $tau$ at low density identified in Section #ref(<sec:challenges>, supplement: none). In other words, the discrepancy visible in @fig:compare_results_after is best explained, at the current stage, as $t_max$ being insufficient to resolve the transient at low density, rather than as a genuine physical disagreement with #cite(<timmes1992>, form: "prose"). This does not rule out a real physical effect being present as well, but it cannot currently be distinguished from the extraction issue with the available run lengths.

=== Phase-Space Maps <sec:phase_space_maps>

// TODO: insert the v(rho, X_C) heatmap and 3D surface here once regenerated
// from the current dataset (via `analyze_results.py --heatmap-co` and
// `--surface-co`, Section #ref(<sec:post_processing>, supplement: none)).

A two-dimensional map and a three-dimensional surface of $v(rho, "ratio"_"C/O")$ at $Y_e = 0.5$ were produced using the tooling described in Section #ref(<sec:post_processing>, supplement: none), but are not yet conclusive: the low-density artifacts of the previous section propagate directly into these visualizations and currently dominate their appearance at the low-$rho$ end of the grid.

=== Current Status <sec:current_status>

At the time of writing, the $Y_e = 0.5$ validation is complete for $rho ≳ 5 times 10^8$ g/cm#super[3], with the low-density regime requiring the further investigation outlined in Section #ref(<sec:tau_speed_relation>, supplement: none) before it can be considered resolved. The extension of the parameter sweep to $Y_e != 0.5$ (Section #ref(<sec:ye_methodology>, supplement: none)) and the derivation of a combined fitting formula $v_l = f(rho, X_i, Y_e)$ remain future work, discussed in Section #ref(<sec:planning>, supplement: none).
