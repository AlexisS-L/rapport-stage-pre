#import "../backmatter/glossaire.typ": *

= Astrophysical Background and Problem Definition

== Cosmological and Astrophysical Significance of Type Ia Supernovae

#Glsf("snia") are among the most energetic transient phenomena in the Universe. Unraveling their physical explosion mechanisms is fundamental across multiple domains of modern physics:

1. *Cosmology and Dark Energy:* Due to their remarkable empirical uniformity, #gls("snia") serve as standardizable cosmological candles. Measurements of their luminosity distances led directly to the discovery of the accelerated expansion of the Universe @perlmutter1999. However, improving the precision of dark energy constraints now requires reducing systematic uncertainties rooted in the unconstrained microphysics of the progenitor explosion.
2. *Galactic Chemical Evolution:* Thermonuclear explosions of compact remnants are the primary cosmic drivers for the synthesis and distribution of iron-peak elements (e.g., Fe, Ni, Cr) into the interstellar medium @iwamoto2000.
3. *High Energy Density Physics (#gls("hedp")):* The extreme thermodynamic regimes reached inside exploding degenerate stellar matter, characterized by relativistic electron degeneracy, supersonic/subsonic burning fronts, and stiff nuclear reaction rates, share fundamental physical and mathematical aspects with some laboratory experiments, such as #glsf("icf").

Even if they play a crucial role for astrophysics, the exact physical initiation and propagation of the thermonuclear runaway remain subjects of active research. Simulating fully an exploding star is not computationally feasable, but we have ways of studying the phenomenon to feed models to the macro-scale simulations. This requires knowledge of the stellar objects we work upon, as well as the microphysical processes that govern the propagation of the thermonuclear flame front.

== Stellar Progenitors and Microphysical Firefront Dynamics

#heading(level: 3, outlined: false)[Progenitor Systems and Nuclear Networks]
#Glsf("snia") originate from carbon-oxygen (C-O) #gls("wd") in binary systems that approach the Chandrasekhar mass limit via accretion or mergers. While oxygen-neon (O-Ne) #gls("wd") systems also exist and undergo distinct evolutionary paths @schwab2020, modeling C-O flames is central to understanding standard #gls("snia") explosions. From a computational perspective, simulating O-Ne mixtures in a physically coherent and comprehensive manner requires substantially larger nuclear reaction networks that struggle to tractably reach #glsf("nse") within the current hydrodynamical and #gls("network") capabilities of *Phlegethon* @leidi2026.

#heading(level: 3, outlined: false)[The Multiscale Resolution Challenge and Deflagration Speed]
In subsonic burning regimes (#gls("deflagration")), the firefront propagates via thermal conduction mediated mainly by degenerate electrons. This microphysical structure introduces a severe multiscale challenge:

- The physical width of the laminar deflagration flame front ($l_f$) is dictated by microscopic transport coefficients and nuclear reaction timescales, spanning from a fraction of a micrometer to a few centimeters ($~ 10^(-7) "to" 10 "cm"$).
- The global radius of the parent #gls("wd") is on the order of thousands of kilometers ($10^8"cm"$).

Because global multi-dimensional hydrodynamic simulations operating at the stellar scale cannot resolve sub-centimeter flame structures, subgrid models or parameterized fits are required @timmes1992. The precise laminar flame speed $v_l$ plays a decisive role in governing the transition to detonation and determining whether the star undergoes a complete explosion or a gravitational collapse @holas2026.

Determining accurate, localized laminar flame speeds $v_l$ as a function of fuel density ($rho$), chemical composition ($X_i$), and electron fraction ($Y_e$) is therefore an essential prerequisite for macro-scale astrophysical modeling. The current litterature on the topic @timmes1992 @schwab2020 provides formulas that each take two parameters out of the three. The point of this work is to extend the parameter space exploration with all three parameters, and to provide a new fitting formula for the laminar flame speed $v_l = f(rho, X_i, Y_e)$.

== Numerical Framework and 1D Benchmarking in Phlegethon

To investigate these microphysical combustion processes, this study utilizes *Phlegethon* @leidi2026, a modern computational astrophysics code designed for astrophysical fluid dynamics and nuclear burning.

The simulation setup is intentionally restricted to a 1D Cartesian geometry. This choice stems mainly from the fact that this work has been done by someone with no prior experience in astrophysics nor in numerical simulations, for a duration of only three months. However, the 1D approach still presents both scientific and practical advantages:
- *Simplicity and Unidimensional Front Analysis:* Planar 1D setups isolate the planar flame structure from geometry-induced curvature effects, allowing direct evaluation of thermal conduction and nuclear energy release across the firefront.
- *Framework Verification:* Running 1D benchmarks evaluates Phlegethon against established literature, verifying its numerical schemes, equation-of-state integrations, and nuclear reaction network solvers.
- *Profiling Framework Limits:* Operating in 1D allows testing the operational boundaries of the code, particularly identifying memory and runtime bottlenecks when scaling nuclear network sizes or approaching parameters for which the #gls("deflagration") flame is hardly holding up.

== Project Objectives and Key Deliverables

The primary goal of this project is to quantitatively model subsonic deflagration flames in degenerate stellar matter using Phlegethon. The work is structured around three core objectives:

1. *Laminar Flame Speed Formula:* Deriving a robust analytical fitting formula for the laminar flame speed $v_l$ as a function of key physical input parameters:
$ v_l = f(rho, X_i, Y_e) $
where $rho$ represents the fuel density, $X_i$ the initial chemical composition, and $Y_e$ the electron fraction.
2. *Phlegethon Verification:* Validating Phlegethon's hydrodynamical and nuclear solvers by reproducing the results from the existing literature, and if the results differ, identifying the sources of discrepancy and address those by suggesting improvements.
3. *Code Profiling and Limitations:* Documenting the technical capabilities, numerical constraints, and potential avenues for future enhancements within the Phlegethon ecosystem. Produce documentation for the post-processing programs that have been developped for this project, and provide a clear roadmap for future work, should it come to use.