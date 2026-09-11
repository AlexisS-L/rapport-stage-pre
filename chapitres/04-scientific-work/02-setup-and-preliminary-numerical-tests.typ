#import "../../backmatter/glossaire.typ": *

== Setup and Preliminary Numerical Tests <sec:setup_prelim>

=== Simulation Box Configuration and Discretization <sec:box_config>

The flame propagates along the $x_2$ direction of the computational domain, with the transverse directions $x_1$ and $x_3$ left inactive in this 1D setup. The reference configuration uses $x_"2l" = 0$ and $x_"2u" = 4.0 times 10^(-3)$ cm, discretized with $"nx2" = 2048$ cells, giving a cell width $Delta x = x_"2u" \/ "nx2" approx 1.95 times 10^(-6)$ cm.

The spatial resolution was set following a criterion of at least ten grid cells per expected flame width, adopted on a colleague's recommendation. For the reference case ($rho = 3 times 10^9$ g/cm#super[3], $X(upright("C12")) = 0.5$), this resolution corresponds to approximately 13-14 cells per flame width.

*Automatic box sizing.* Because the flame width and propagation speed vary by orders of magnitude across the explored parameter space (@sec:convergence), a single fixed box configuration is unsuitable for the full phase-space sweep. The `generate_simulations.py` script instead sizes every simulation individually from the flame width and speed predicted by @timmes1992:
$ x_"2u" = N_"widths" times ell_"Timmes", quad "nx2" = N_"widths" times N_"cells/width" $ <eq:box_sizing>
with $N_"widths" = 300$ and $N_"cells/width" = 10$, the resulting cell count being rounded up to the next power of two for compatibility with the domain decomposition. Because every simulation is sized using the same $N_"cells/width"$, all simulations share the same spatial resolution relative to the local flame width, independent of where they sit in the parameter space. In practice, this rounding consistently lands on $"nx2" = 2048$ across the explored parameter space (see the computational-cost discussion below). The simulation end time is set so that the flame crosses the box exactly once,
$ t_max = x_"2u" \/ v_"cond,Timmes" . $ <eq:tmax>
The factor of 300 flame widths was chosen to leave additional margin for the transient to relax before the flame reaches the domain boundary (Section #ref(<sec:challenges>, supplement: none)).

An analytical argument explains why $"nx2"$ stays close to a single value across the whole parameter space, even though it is formally recomputed from @eq:box_sizing for every simulation. Because the flame speed and flame width predicted by @timmes1992 vary in inverse proportion to one another across $(rho, X_i)$, a faster-burning mixture having a correspondingly narrower flame, so the product $N_"widths" times N_"cells/width"$ that sets $"nx2"$ varies comparatively little over the explored range, and its nearest power of two consistently rounds to $"nx2" = 2048$. A fast, thin flame is thus resolved at the same effective grid resolution as a slow, thick flame integrated for a correspondingly longer physical time, keeping the computational cost per simulation roughly constant across the phase space.

*Ignition profile.* The flame is seeded at $t=0$ with a hyperbolic tangent transition between a pre-burned ("ash") region and the cold background,
$ T(x) = T_b + T times 0.5 (1 - tanh((x - "xt" x_"2u") \/ "deltax")) $ <eq:flame_initialization>
where $"xt"$ denotes the fraction of the box length initially set to the ignition temperature $T$, i.e. the extent of the pre-ignited "ash" region, and $"deltax"$ sets the sharpness of the transition to the cold background at $T_b = 0.01 T = 10^8$ K. A convergence study over $"xt"$ and $"deltax"$ (@sec:convergence) led to fixing $"deltax" = "xt" \/ 2$, so that the transition width scales with the ignited-region size rather than being an independent free parameter. The absolute length of ignited material, $L_"ign" = "xt" times x_"2u"$, is kept constant across all simulations by rescaling $"xt"$ whenever $x_"2u"$ changes with the target parameters, keeping the initial energy injected into the system comparable across the parameter space. The peak ignition temperature was initially set to $T = 10^10$ K (see @sec:convergence for a complication this raised).

@schwab2020 (Appendix A) show that the flame speed is insensitive to the precise values of $"xt"$, $"deltax"$, and $T_b$, provided the ignited region is neither so small that the flame extinguishes nor so large that it produces a prolonged, decelerating transient; after a few flame widths of propagation, the memory of the initial condition is effectively erased. This motivates fixing the ignition parameters once rather than tuning them per simulation, at the cost of the transient-length sensitivity discussed in @sec:convergence.

=== Nuclear Reaction Network Selection <sec:network_selection>

The nuclear network used by #gls("phlegethon") was progressively extended over the course of the internship:

- *7 species* (he4, c12, o16, ne20, mg24, si28, s32; $tilde.op$20 reactions): a minimal $alpha$-chain network, used as a stable functional baseline.
- *15 species*: adds n14, ne22, ar36, ca40, ti44, cr48, fe52, ni56, completing the $alpha$-chain up to ni56. Functional, and used for the majority of the preliminary tests reported in this section.
- *35 species* (current production network): extends the 15-species set with non-$alpha$ isotopes (n, p, na22, na23, mg25, mg26, al27, si29, si30, p31, and others). Flame speeds obtained with this network are slightly below those of @timmes1992, an expected consequence of the smaller network size (see below) rather than an indication of a numerical problem.
- *56 species*: currently non-functional in #gls("phlegethon"). The most likely cause is that the nuclear network solver relies on dense matrices for its linear algebra; even though these matrices are mostly filled with zeros for a network of this size, dense storage and factorization still scale as $O(n^3)$ in the number of species, making the 56-species case prohibitively expensive and triggering the errors observed. A sparse-matrix formulation is a candidate fix, discussed further as future work (Section #ref(<sec:challenges>, supplement: none)); this has not been resolved at the time of writing.

For reference, @timmes1992 use a 130-isotope network (their Table 1, network 5), while @schwab2020 use an adaptive #glsf("network") of $tilde.op$495 isotopes, noting that more than 200 isotopes are required for their results to converge. Table 5 of @timmes1992 shows the conductive flame speed increasing systematically with network size (9, 19, 33, 83, and 130 isotopes give 54.4, 71.9, 79.1, 87.2, and 87.5 km/s respectively, for an O+Ne+Mg mixture at $rho_9 = 10$), which would naively suggest that the present 35-species results should underestimate the true, large-network flame speed. In practice, this is not clear-cut: the 35-species network already includes most of the highest-energy-yield reactions, but omits others that would reduce the net energy release if included, so whether the resulting speed is biased high or low is not obvious in general and may depend on the local conditions, density in particular. This is an important caveat when interpreting the validation against @timmes1992 in Section #ref(<sec:results>, supplement: none), and part of the motivation for tracking the overall trend across the parameter space, via the polynomial fit of Section #ref(<sec:velocity_extraction>, supplement: none), rather than relying solely on the absolute agreement of any single simulation.

=== OpenMP Parallel Scalability <sec:openmp_scalability>

Simulations run on the Genoa cluster's nodes, each equipped with 256 logical cores (AMD EPYC 9174F, 16 physical cores per socket, 2 threads per core) and 384 GB of RAM. Table 4.2.1 summarizes a scalability test using the 15-species network, run for 10 000 timesteps at $"nx2" = 8192$, comparing pure #gls("hpc")-style MPI parallelism against hybrid MPI+OpenMP configurations.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    stroke: 0.5pt,
    align: center,
    [*MPI ranks*], [*`OMP_NUM_THREADS`*], [*wall-clock time (s, $times 10^2$)*], [*Total duration*],
    [64], [1], [0.575], [1min 22s],
    [64], [2], [0.323-0.564 (variable)], [N/A],
    [64], [4], [0.554], [1min 20s],
    [64], [8], [0.977], [2min 18s],
    [64], [16], [1.320], [3min 06s],
  ),
  caption: [OpenMP scalability test, 15-species network, 10 000 timesteps, $"nx2" = 8192$.],
) <table:openmp_scaling>

OpenMP provides no measurable benefit at this problem size and network: `OMP_NUM_THREADS=2` gives highly variable timings, consistent with memory contention rather than genuine parallel speed-up, and performance degrades monotonically beyond two threads (@table:openmp_scaling). A representative radial-profile overview from one of these runs is given in Appendix #ref(<sec:appendix_a>, supplement: none). It remains possible that larger networks (35 or 56 species), for which the nuclear network integration cost is expected to weigh more heavily in the total runtime, would better justify hybrid parallelization; this has not yet been confirmed. Despite the marginal and inconsistent benefit measured in this test, production runs use `OMP_NUM_THREADS=2` alongside MPI rather than pure MPI.

=== Convergence and Sensitivity Studies <sec:convergence>

Four numerical or initial-condition parameters were varied to test their effect on the extracted flame speed: grid resolution, box size, ignition temperature, and ignition spot size.

*Grid resolution and box size.* The ten-cells-per-flame-width criterion and the 300-flame-width box length (Section #ref(<sec:box_config>, supplement: none)) were adopted following a colleague's recommendation and a qualitative expectation that a longer box improves convergence margin, respectively, rather than from a dedicated convergence study; a systematic test on extreme phase-space cases is left for future work. Whether the chosen margin was ultimately sufficient is discussed in Section #ref(<sec:challenges>, supplement: none).

*Ignition temperature.* The initial choice of $T = 10^10$ K for the ignited zone was found to be problematic at lower densities: at $rho = 10^8$ g/cm#super[3], this temperature exceeds the upper validity range of the JINA REACLIB reaction rate library @cyburt2010, triggering spurious photodisintegration ($dot(epsilon)_"nuc" < 0$) within the ignition zone itself, as illustrated in @fig:ignition_temperature_convergence. We can also qualitatively notice that a higher ignition temperature will pour additional energy into the system, hence adding amplitude and duration to the transient.

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 8pt,
    image("../../assets/varying_T.png", width: 100%),
    image("../../assets/Negative_e_dot_nuc.png", width: 100%),
  ),
  caption: [Left: comparison graph of the flame front position for different ignition temperatures $T$. The gap between the curves is smaller than our grid resolution for these simulations. \ Right: negative $dot(epsilon)_"nuc"$ in the ignition zone at $rho = 10^8$ g/cm#super[3], $T = 10^10$ K: this run did not produce a self-sustained flame.],
) <fig:ignition_temperature_convergence>

A lower ignition temperature ($T = 10^9$ K) was tested to address this; a definitive value had not yet been settled at the time this investigation was carried out (see Section #ref(<sec:challenges>, supplement: none) for the eventual resolution of this issue).

*Ignition spot size.* With the 15-species network, $"xt" = 0.004$ successfully ignites a self-sustained flame, while $"xt" = 0.002$ fails to do so: in this case the perturbation simply lacks enough energy to trigger a self-sustained reaction and decays by pure diffusion, as illustrated in @fig:ignition_spot_size, rather than being affected by the photodisintegration issue discussed above. The 35-species network, with more nuclear energy available, is expected to ignite at a lower threshold, though this was not separately quantified. A separate unfavorable test case ($rho = 10^8$ g/cm#super[3], $X(upright("C12")) = 0.2$, $"xt" = 0.2$) did show a visible ignition attempt but an unclean, disrupted front, linked instead to the photodisintegration issue described above. As described in Section #ref(<sec:box_config>, supplement: none), the absolute ignited length $L_"ign"$ was ultimately fixed across all simulations (via the $"xt"$ rescaling described there) rather than tuned per parameter point.

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 8pt,
    image("../../assets/xt_04_success.png", width: 100%),
    image("../../assets/xt_02_fail.png", width: 100%),
  ),
  caption: [Ignition outcome with the 15-species network: $"xt" = 0.004$ (left) successfully ignites a self-sustained flame; $"xt" = 0.002$ (right) fails to ignite and decays by pure diffusion.],
) <fig:ignition_spot_size>

*Common outcome.* Across all four parameters, none was found to change the converged, late-time flame speed: only the duration and amplitude of the preceding transient were affected. This behavior, initial and numerical conditions altering the approach to a solution without altering the solution itself, is consistent with the flame speed being a stable physical attractor of the underlying reaction-diffusion dynamics, discussed further in Section #ref(<sec:challenges>, supplement: none).

=== Spurious Acoustic Wave Reflections <sec:acoustic_reflections>

Oscillations superposed on the instantaneous flame speed, visible in early diagnostic plots, were at first attributed to noise on the data. However, due to the consistent nature of the oscillations, the hypothesis was made that these came from acoustic waves reflecting back and forth across the simulation domain. The boundary conditions active in the current configuration (defined in the Makefile) are reflective at both ends of $x_2$ and periodic (inactive) in $x_1$ and $x_3$. To test this theory, a comparison study was made in @fig:bouncing_waves to check if the frequency (and period) of the oscillations grew with $"x2u"$, the length of the box, because that is what would be expected of constant-speed waves bouncing back and forth in a medium of changing length.

#figure(
    image("../../assets/waves_bouncing.png", width: 100%),
  caption: [Position of the flame front as a function of time, with varying box lengths $"x2u"$.],
) <fig:bouncing_waves>

#figure(
    image("../../figures/acoustic_oscillation_damping.png", width: 100%),
  caption: [Instantaneous flame speed (both indicators and their mean) over a full run, showing the reflected wave's oscillation progressively damping out as the transient relaxes.],
) <fig:acoustic_damping>

The physical origin of these waves is discussed further in Section #ref(<sec:challenges>, supplement: none), along with their consequences for flame-speed extraction: briefly, the artificial energy injected into the domain at ignition also seeds a compression wave. As this wave bounces back and forth across the box, it locally perturbs the density of the medium at the flame front; since the flame speed itself depends on the local density of the stellar matter, each pass of the wave modulates the instantaneous speed measurement, hence even more noise in the computed speed value.

Alternative boundary conditions were tested in an attempt to remove these reflections at the source: inflow and outflow conditions at $x_"2l"$ and $x_"2u"$ respectively, as well as far-field conditions. Each alternative introduced its own artifacts and reproduced the deflagration physics noticeably less faithfully than the simple reflective (bounce-back) conditions, which were therefore retained despite the reflections they permit.

The mitigation adopted at this stage of the project was to add a fit to the flame front position with a low-order (third-degree) polynomial in addition to differencing consecutive raw snapshot positions, as this new method yields an analytically smooth derivative for the instantaneous speed. As the parameter space exploration progressed, the noise on the signal became a major obstacle to reliable flame-speed extraction, discussed extensively in Section #ref(<sec:challenges>, supplement: none).