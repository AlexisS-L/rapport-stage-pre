#import "../../backmatter/glossaire.typ": *

== Spectator Species Methodology for Variable $Y_e$ <sec:ye_methodology>

=== Motivation <sec:ye_motivation>

The electron fraction $Y_e$ of the fuel is not universal across progenitor white dwarfs, nor necessarily uniform within a single one, and it directly affects the propagation of the deflagration flame @schwab2020. Two distinct physical drivers are relevant here. First, $Y_e$ varies from one progenitor to another as a consequence of the initial metallicity of the #gls("main_sequence") star: CNO-cycle products converted to neutron-rich $""^22$Ne during helium burning set a metallicity-dependent neutron excess in the resulting C-O core @timmes2003. Second, within a given white dwarf, $Y_e$ can be non-uniform as a result of the star's specific burning history, stratified across different layers @jones2013. Reproducing this dependence numerically requires a way to vary $Y_e$ independently of the C-O composition already explored in Section #ref(<sec:setup_prelim>, supplement: none), while staying physically sound, and without introducing a physically inconsistent nuclear species into the burning process itself.

=== The Ne40 Spectator Species <sec:ne40_species>

No naturally abundant isotope provides the exact $Y_e$ shift required without substantially perturbing the C-O fuel composition. The approach adopted instead introduces Ne40 (Z=10, A=40) as an inert spectator species: an unrealistic but numerically convenient isotope with $Z\/A = 0.25$, added to the fuel composition without taking part in the reaction network.

For a mixture of C12, O16 (each with $Z\/A = 0.5$) and a mass fraction $X_s ("Ne40")$ of the spectator species,
$ Y_e = 0.5 (1 - X_s ("Ne40")) + 0.25 X_s ("Ne40") $
which rearranges to
$ X_s ("Ne40") = (0.5 - Y_e) \/ 0.25 $ <eq:ye_ne40>
The remaining mass fraction is then distributed between C12 and O16 according to the target C/O ratio,
$ X_s (upright("C12")) = "ratio"_"C/O" times (1 - X_s ("Ne40")), \ quad X_s (upright("O16")) = (1 - "ratio"_"C/O") times (1 - X_s ("Ne40"))  $ <eq:composition_ye>
so that @eq:ye_ne40 and @eq:composition_ye together fully specify the initial composition for any target $(rho, "ratio"_"C/O", Y_e)$ point in the parameter space.

The choice to introduce the spectator species into the *fuel* is deliberate: what governs the flame physics is the electron fraction of the unburned material ahead of the front, not that of the ash left behind it, since the ash is downstream and already reacted. An inert species keeps the fuel $Y_e$ fixed at its target value by construction, independent of what happens to the composition once it crosses the flame front.

=== Comparison with Ne22 <sec:ne22_comparison>

Ne22 ($Z\/A approx 0.4545$) was considered as a more physically motivated alternative, being a real, stable isotope. However, reaching a given $Y_e$ shift with Ne22 requires a substantially larger mass fraction than with Ne40: for example, $Y_e = 0.49$ requires $X_s ("Ne22") approx 0.26$, compared to $X_s ("Ne40") approx 0.04$ from @eq:ye_ne40, a difference of roughly a factor of six. Since the goal is to shift $Y_e$ while perturbing the C-O fuel composition as little as possible, Ne40 was retained despite not corresponding to a physically real neon isotope in our stellar matter nuclear networks.

=== Box Sizing for $Y_e < 0.5$ <sec:ye_box_sizing>

The self-similar box-sizing strategy of Section #ref(<sec:box_config>, supplement: none) (@eq:box_sizing) is defined in terms of the flame speed and width predicted by @timmes1992, which does not itself depend on $Y_e$. To extend this scaling to $Y_e < 0.5$, the @schwab2020 (eq. 2) correction factor is applied multiplicatively,
$ "factor"(Y_e) = 1 + 96.8 (0.5 - Y_e) $ <eq:schwab_factor>
giving a corrected expected speed and flame width,
$ v_"cond" (rho, "ratio"_"C/O", Y_e) = v_"cond,Timmes" (rho, "ratio"_"C/O") times "factor"(Y_e), $
$ ell (rho, "ratio"_"C/O", Y_e) = ell_"Timmes" (rho, "ratio"_"C/O") \/ "factor"(Y_e), $
both of which are substituted into @eq:box_sizing in place of their Timmes-only counterparts when generating simulations away from $Y_e = 0.5$.

=== Limitations <sec:ye_limitations>

Two approximations underlie this methodology and are worth stating explicitly. First, Ne40 is a numerical device rather than a physical isotope: no neon nuclei has $Z\/A = 0.25$. Second, the correction factor of @eq:schwab_factor was calibrated by @schwab2020 on O-Ne mixtures, not C-O; its use here is a working assumption to be tested against simulation results (Section #ref(<sec:results>, supplement: none)), not an established result for this composition. Some support for the underlying approach comes from @schwab2020 themselves, who find the $Y_e$ dependence of the flame speed to be largely insensitive to which neutron-rich species carries the excess neutrons in their models (their Fig. 7 gives consistent results for Ne22, Ne23, and Ne24), suggesting that the identity of the spectator species matters less than its mass fraction. On top of this, the parameters calculated from these adjusted values have no effect on the physical behavior and asymptotic speed of the flame, as shown in section #ref(<sec:convergence>, supplement: none), the only impact is in the simulated duration and the scope of the study, not on the physical level.

=== Parameter Grid <sec:parameter_grid>

The full phase-space is:
$ rho in {0.01, 0.05, 0.1, 0.2, 0.5, 1, 2, 4, 6, 8, 10} times 10^9 upright("g/cm")^3, $
$ "ratio"_"C/O" in {0.2, 0.4, 0.5, 0.6, 0.8, 1.0}, $
$ Y_e in {0.5, 0.495, 0.490, 0.485, dots}, $
with $Y_e = 0.5$ run first in every case to validate against @timmes1992 before extending to $Y_e != 0.5$. At the time of writing, the $Y_e = 0.5$ sweep has been completed (Section #ref(<sec:results>, supplement: none)); the extension to variable $Y_e$ is unfinished work due to time constraints (Section #ref(<sec:planning>, supplement: none)).
