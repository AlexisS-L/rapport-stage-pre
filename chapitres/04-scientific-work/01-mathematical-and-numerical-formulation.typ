#import "../../backmatter/glossaire.typ": *

= Scientific Work

== Mathematical and Numerical Formulation <sec:math_num_formulation>

#counter(math.equation).update(0)

=== The Continuous Physical Model <sec:phys_continu>

#heading(level: 4, outlined: false, numbering: none)[Fluid Dynamics Equations for Stellar Plasmas]

The governing equations describing the evolution of stellar plasma in #glsf("phlegethon") are formulated as a hyperbolic-parabolic system of non-linear conservation laws with source terms @leidi2026. In Cartesian geometry (or within generalized coordinate systems), the spatio-temporal evolution of the vector of conservative variables $U(x,t)$ under the action of the advective flux tensor $bold(F)(U)$ and a vector of source terms $S(U)$ is written as @euler1757 @leidi2026:

$ (partial U) / (partial t) + nabla dot bold(F)(U) = S(U) $ <eq:conservation_law>

The vector of conservative variables $U$ collects the mass density $rho$, the momentum density $rho bold(u)$ (where $bold(u) = (u_x, u_y, u_z)^T$ is the fluid velocity vector), the total energy per unit volume $E$, and the partial mass densities of the various nuclear species $rho X_k$ @leidi2026:

$ U = vec(rho, rho bold(u), E, rho X_k) $ <eq:conservative_vector>

The total energy per unit volume $E$ combines the specific internal energy $e_("int")$ and the macroscopic kinetic energy @leidi2026:

$ E = rho e_("int") + 1/2 rho norm(bold(u))^2 $ <eq:total_energy>

The mass fractions $X_k$ associated with each isotope $k$ strictly satisfy the mass conservation closure constraint $sum_k X_k = 1$ @leidi2026. The advective flux tensor $bold(F)(U)$ represents the conservative transport of mass, momentum, and total energy through the fluid @leidi2026:

$ bold(F)(U) = vec(rho bold(u), rho bold(u) ⊗ bold(u) + P bold(I), (E + P) bold(u), rho X_k bold(u)) $ <eq:advective_fluxes>

where $P$ denotes the total plasma pressure and $bold(I)$ is the $3 times 3$ identity matrix.

#block(breakable: false)[
The source term $S(U)$ integrates the coupled contributions of gravity $S_("grav")$, diffusive thermal transport $S_("diff")$, and nuclear microphysics $S_("nuc")$ @leidi2026:

$ S(U) = S_("grav") + S_("diff") + S_("nuc") = vec(0, rho bold(g), rho bold(u) dot bold(g) + nabla dot (K nabla T) + rho dot(epsilon)_("nuc"), rho dot(omega)_k) $ <eq:source_terms>]

where $bold(g) = -nabla Phi$ is the gravitational acceleration field, $K$ represents the total thermal conductivity, $dot(epsilon)_("nuc")$ is the specific nuclear energy release rate per unit time, and $dot(omega)_k$ is the net production or destruction rate of nuclear species $k$ @leidi2026.

#heading(level: 4, outlined: false, numbering: none)[Thermodynamic Closure (Equation of State)]

The hydrodynamical system requires an #glsf("eos") to close the system of equations by relating the pressure $P$ and temperature $T$ to the conservative variables $(rho, e_("int"), X_k)$ @timmes1999eos @leidi2026.

In #glsf("phlegethon"), the Helmholtz #gls("eos") (`HELMHOLTZ_EOS`. In #glsf("phlegethon"), physical modules and numerical solver variants are selected at compile time via define preprocessor flags specified in the code Makefile, denoted in `MONOSPACE_FONT` throughout this chapter) models the stellar medium as a superposition of three independent thermodynamic components @timmes1999eos @leidi2026:

$ P(rho, T, X_k) = P_("ion") + P_("rad") + P_("elec/pos") $ <eq:helmholtz_p>

1. *The ionic contribution ($P_("ion")$):* Ions are treated as a classical, fully ionized ideal gas obeying Maxwell-Boltzmann statistics @timmes1999eos @leidi2026:
   $ P_("ion") = n_("ion") k_B T = rho / (bar(A) m_u) k_B T $ <eq:p_ion>
   where $k_B$ is the Boltzmann constant, $m_u$ is the atomic mass unit, and $bar(A) = (sum_k X_k / A_k)^(-1)$ is the mean atomic mass of the mixture @leidi2026.

2. *The radiation contribution ($P_("rad")$):* The radiation field is assumed to be in #glsf("lte"), following the Stefan-Boltzmann black body law @timmes1999eos @leidi2026:
   $ P_("rad") = 1/3 a T^4 $ <eq:p_rad>
   where $a = (8 pi^5 k_B^4) / (15 c^3 h^3)$ is the radiation constant @timmes1999eos.

3. *The electron and positron contribution ($P_("elec/pos")$):* Electrons and positrons are modeled as an arbitrarily degenerate, relativistic Fermi-Dirac gas, including $e^- e^+$ pair production processes at very high temperatures @leidi2026. Their thermodynamic quantities are computed via Fermi-Dirac integrals depending on the relative chemical potential $eta = mu / (k_B T)$ and the relativity parameter $beta = (k_B T) / (m_e c^2)$ @timmes1999eos @fermi1926 @dirac1926.

When the `USE_COULOMB_CORRECTIONS` option is enabled, electrostatic Coulomb correction terms are added to describe strongly coupled plasma regimes where the ion plasma coupling parameter $Gamma = (Z^2 e^2) / (a_i k_B T) > 1$ (the ratio of electrostatic Coulomb potential energy between neighboring ions to their thermal kinetic energy) @salpeter1954 @leidi2026.

#heading(level: 4, outlined: false, numbering: none)[Transport Terms and Nuclear Reactivity]

Energy transport by thermal conduction and material transformations via nuclear reactions constitute two key microphysical source terms in stellar environments @leidi2026.

- *Thermal conduction and opacities (`USE_TIMMES_KAPPA`):*
  The diffusive heat flux obeys Fourier's law $bold(q)_("cond") = -K nabla T$ @fourier1822 @leidi2026. The total thermal conductivity $K$ is related to the overall opacity of the medium $kappa$ through the radiative and conductive diffusion approximation @timmes1999eos @leidi2026:
  $ K = (4 a c T^3) / (3 kappa rho) $ <eq:thermal_conductivity>
  The total opacity $kappa = (kappa_("rad")^(-1) + kappa_("cond")^(-1))^(-1)$ combines the radiative opacity $kappa_("rad")$ (Thomson scattering, free-free transitions) and the electronic conductive opacity $kappa_("cond")$, evaluated on the fly following the analytical prescriptions from Timmes and Leidi et al. @timmes1999eos @leidi2026.

- *Nuclear kinetics and weak interaction rates (`USE_NUCLEAR_NETWORK`, `USE_LMP_WEAK_RATES`):*
  The temporal evolution of the mass fractions $X_k$ driven by thermonuclear reactions and weak interactions is described by a coupled system of #glsf("ode") @arnett1996 @leidi2026:
  $ (d X_k) / (d t) = dot(omega)_k (rho, T, X_j) = sum_j lambda_(j -> k) X_j + rho sum_(j,l) gamma_(j l -> k) X_j X_l + dots $ <eq:nuclear_network>
  The network accounts for Coulomb barrier penetration with electron screening effects via `USE_ELECTRON_SCREENING` @graboske1973 as well as weak interaction rates (electron captures and $beta$ decays) taken from the tabulated compilations of Langanke & Martínez-Pinedo (2000) via the `USE_LMP_WEAK_RATES` flag @langanke2000 @leidi2026.

=== Discretization and Numerical Solvers <sec:discretization_solvers>

#heading(level: 4, outlined: false, numbering: none)[The Finite Volume Framework]

The continuous hyperbolic-parabolic system of conservation laws is discretized within the #glsf("fv") framework @leidi2026. The spatial domain $Omega$ is partitioned into non-overlapping control volumes or grid cells $K_i = [x_(i-1/2), x_(i+1/2)]$ of volume $V_i = Delta x_i$. 

#block(breakable: false)[
Unlike Finite Element methods that approximate solutions within continuous functional Sobolev spaces, the fundamental discrete variable in a #gls("fv") scheme is not the pointwise value $U(x,t)$, but the cell-averaged conservative vector $bar(U)_i(t)$ defined over the Hilbert space $L^1(Omega) inter L^2(Omega)$ @leidi2026:

$ bar(U)_i(t) = 1 / V_i integral_(K_i) U(x,t) upright(d) x $ <eq:cell_average>]

Integrating the conservation law over the cell volume $K_i$ and applying the *Green-Ostrogradsky divergence theorem* yields the exact semi-discrete integral formulation @leidi2026:

$ (upright(d) bar(U)_i) / (upright(d) t) + 1 / (Delta x_i) (bold(F)_(i+1/2) - bold(F)_(i-1/2)) = bar(S)_i $ <eq:fv_integral_form>

where $bold(F)_(i+1/2) approx bold(F)(U(x_(i+1/2), t))$ represents the numerical flux through the cell interface at $x_(i+1/2)$. 

This formulation guarantees exact numerical conservation at machine precision: the flux leaving cell $K_i$ through face $i+1/2$ is identically equal to the flux entering cell $K_(i+1)$ ($bold(F)_(i+1/2) equiv bold(F)_((i+1)-1/2)$). Furthermore, according to the Lax-Wendroff theorem, if a conservative numerical scheme converges under grid refinement ($(Delta x, Delta t) -> (0, 0)$), its limit is guaranteed to be a weak solution of the continuous Euler equations, ensuring the exact capture of shock jump conditions (Rankine-Hugoniot relations) @lax1960 @rankine1870 @hugoniot1887 .

#heading(level: 4, outlined: false, numbering: none)[Spatial Discretization: Reconstruction and Riemann Solver]

To compute high-order interface fluxes without generating parasitical numerical oscillations near steep gradients or shocks, #glsf("phlegethon") combines a high-order spatial reconstruction scheme with an approximate Riemann solver @leidi2026.

- *Fifth-Order Spatial Reconstruction (`LIM5TH_REC`):*
  Interface states $U_(i+1/2)^L$ and $U_(i+1/2)^R$ are reconstructed from the cell averages $bar(U)_i$ using the 5th-order Monotonicity-Preserving (#glsf("mp5")) scheme @suresh1997 @leidi2026. The #glsf("mp5") algorithm interpolates interface values with 5th-order spatial accuracy in smooth regions while applying a multi-stage limiter that monitors local cell curvature to preserve monotonicity near discontinuities without clipping physical extrema @suresh1997. Third-Order reconstruction is also an available option. In the case of this 1D study, it was needed to add ghost cells at the domain boundaries to ensure proper reconstruction in the directions where only one cell is present (3 ghost cells for the fifth order reconstruction).

- *HLLC Riemann Solver (`HLLC_FLUX`):*
  The local Riemann problem at interface $x_(i+1/2)$ defined by the state pair $(U_(i+1/2)^L, U_(i+1/2)^R)$ is resolved using the HLLC (Harten-Lax-van Leer-Contact) approximate solver @toro1994 @leidi2026. The HLLC solver restores the middle contact discontinuity wave $S^*$ omitted by the standard HLL solver, resolving a 3-wave, 4-state structure $(S_L, S^*, S_R)$ @toro1994:

  $ bold(F)_(i+1/2)^("HLLC") = cases(
    bold(F)(U^L) &"if" 0 <= S_L,
    bold(F)(U^L) + S_L (U^(*L) - U^L) &"if" S_L <= 0 <= S^*,
    bold(F)(U^R) + S_R (U^(*R) - U^R) &"if" S^* <= 0 <= S_R,
    bold(F)(U^R) &"if" 0 >= S_R
  ) $ <eq:hllc_flux>

- *Low-Mach Correction (`Mach_cutoff_make=1.0e-4_rp`):*
  In highly subsonic flow regimes ($M \ll 1$), standard Godunov-type fluxes suffer from excessive numerical dissipation. Setting the low-Mach cutoff parameter scales the wave speed dissipation to maintain accuracy and prevent damping of mild convective modes in stellar matter @leidi2026.

#heading(level: 4, outlined: false, numbering: none)[Temporal Integration: SSP-RK3]

The system of ordinary differential equations resulting from spatial discretization, $(upright(d) bar(U)) / (upright(d) t) = cal(L)(bar(U))$, is integrated in time using the 3rd-order #glsf("ssprk3") scheme (`RK3_STEPPER`) @shu1988 @leidi2026. 

The #glsf("ssprk3") algorithm advances the solution from $U^n$ to $U^(n+1)$ through three convex combinations of Forward Euler steps, preserving non-linear stability and TVD (Total Variation Diminishing) properties @shu1988:

$ U^((1)) &= U^n + Delta t cal(L)(U^n) \
  U^((2)) &= 3/4 U^n + 1/4 U^((1)) + 1/4 Delta t cal(L)(U^((1))) \
  U^(n+1) &= 1/3 U^n + 2/3 U^((2)) + 2/3 Delta t cal(L)(U^((2))) $ <eq:rk3_stepper>

The explicit time step $Delta t$ is updated dynamically (`VARIABLE_TIMESTEP`) based on the #glsf("cfl") condition (`cfl_make=0.8_rp`) @leidi2026:

$ Delta t_("hydro") = C_("CFL") dot min_i ((Delta x_i) / (max(|bold(u)_i|) + c_(s,i))) $ <eq:cfl_condition>

with $C_("CFL") = 0.8$ and $c_s$ the local sound speed. The value of the CFL was sometimes reduced down to 0.3 in order to ensure stability while testing new parameters or more instable flame fronts.

#heading(level: 4, outlined: false, numbering: none)[Microphysics Acceleration and Stiff Operator Treatment]

- *FastEOS Acceleration (`USE_FASTEOS`):*
  Calling the Helmholtz #glsf("eos") table repeatedly during the iterative Riemann flux evaluations at every cell interface is computationally costly, hence it is prohibitive. The `FastEOS` algorithm evaluates two auxiliary thermodynamic indices at cell centers @leidi2026:
  $ gamma_e = P / (rho e_("int")) + 1 quad "and" quad gamma_c = (rho c_s^2) / P $ <eq:fasteos_indices>
  These indices are interpolated to cell interfaces $x_(i+1/2)$, enabling direct calculation of interface pressures and sound speeds without iterative Newton-Raphson inversions, reducing EoS evaluation by a factor of up to 6 @leidi2026.

- *Thermal Diffusion via Super-Time-Stepping (`THERMAL_DIFFUSION_STS`):*
  Explicit time-stepping for parabolic heat conduction is constrained by the restrictive stability limit $Delta t_("diff") prop Delta x^2$. #glsf("phlegethon") circumvents this bottleneck using the second-order Runge-Kutta-Legendre #glsf("sts") scheme @meyer2012 @leidi2026. The #gls("sts") algorithm executes a sub-cycle of $s$ stabilized explicit Tchebychev/Legendre stages to match the hydrodynamical time step @meyer2012:
  $ Delta t_("STS") = Delta t_("hydro") = sum_(j=1)^s tau_j approx (s^2 + 2s - 2) / 2 Delta t_("diff") $ <eq:sts_timestep>
  lifting the parabolic constraint while maintaining explicit algorithm efficiency @meyer2012 @leidi2026.

- *Implicit Nuclear Network Integration (`NUCLEAR_NETWORK_BE`):*
  Due to the extreme stiffness of nuclear reaction timescales, the thermonuclear network is integrated using a 1st-order Backward Euler (#glsf("be")) implicit scheme @timmes1999 @leidi2026:
  $ X_k^(n+1) - X_k^n = Delta t dot(omega)_k (rho^(n+1), T^(n+1), X_j^(n+1)) $ <eq:backward_euler>
  This non-linear system is solved locally in each cell using a multi-dimensional Newton-Raphson solver backed by optimized linear algebra libraries @timmes1999 @leidi2026.



=== Software Implementation and HPC Architecture <sec:software_implementation>

#heading(level: 4, outlined: false, numbering: none)[Code Architecture and Execution Flow]

The #glsf("phlegethon") code is implemented in modern, modular Fortran (Fortran 2008/2018 standards) optimized for massively parallel high-performance computing (#glsf("hpc")) environments @leidi2026. The framework enforces a strict segregation of responsibilities between compile-time numerical definitions, hardcoded physical simulation parameters, and dynamic execution management on HPC clusters.

As illustrated in @fig:code_pipeline, the simulation setup is structured across three distinct layers:
- *Numerical & Discretization Parameters (`Makefile`):* Spatial grid resolution ($"nx1, nx2, nx3"$), ghost cell counts, nuclear reaction network size (number of isotopes and reactions), and high-order numerical scheme flags (`OPTS`) are defined at compile time. This allows the compiler to generate fully optimized static array allocations and remove inactive physical modules.
- *Physical & Boundary Configuration (`app.F90`):* Physical domain bounds (e.g., $"x2l"$ and $"x2u"$ defining lower/upper physical limits in centimeters), initial profiles, and physical boundary conditions are hardcoded within the primary driver module `app.F90`.
- *HPC Resource Management (`run.genoa`):* High-level cluster execution parameters are isolated from code compilation. The `run.genoa` submission script defines the hardware footprint on the cluster, specifying the requested number of compute nodes, CPU cores, and parallel MPI tasks, and issues the launch command (e.g., `mpirun`).



#figure(
  kind: image,
  placement: top,
  align(center)[
    #box(width: 85%)[
      // Step 0: Build System (Makefile)
      #rect(
        width: 100%,
        fill: rgb("#fff8e1"),
        stroke: 1pt + rgb("#f57c00"),
        radius: 4pt,
        inset: 10pt
      )[
        #align(center)[
          *0. Numerical Discretization & Build System* \
          #text(size: 9pt, font: "DejaVu Sans Mono")[Makefile] \
          #v(2pt)
          #text(size: 8.5pt)[
            - Numerical `OPTS` & preprocessor flags (`USE_FASTEOS`, `LIM5TH_REC`, etc.) \
            - Spatial grid resolution ($"nx1, nx2, nx3"$) & ghost cell counts \
            - Nuclear network dimensioning (number of species & reactions)
          ]
        ]
      ]

      #v(-4pt)
      #align(center)[#text(size: 14pt, fill: luma(100))[↓]]
      #v(-4pt)

      // Step 1: Physical Setup & Driver
      #rect(
        width: 100%,
        fill: rgb("#f0f4f9"),
        stroke: 1pt + rgb("#1a73e8"),
        radius: 4pt,
        inset: 10pt
      )[
        #align(center)[
          *1. Physical Setup & Simulation Driver* \
          #text(size: 9pt, font: "DejaVu Sans Mono")[app.F90] \
          #v(2pt)
          #text(size: 8.5pt)[
            - Physical domain limits (e.g., $"x2l"$ and $"x2u"$ in cm) \
            - Loading Helmholtz #glsf("eos") lookup tables & initial hydrostatic profiles \
            - Physical boundary conditions & abundance distributions
          ]
        ]
      ]

      #v(-4pt)
      #align(center)[#text(size: 14pt, fill: luma(100))[↓]]
      #v(-4pt)

      // Step 2: Main Loop Container
      #rect(
        width: 100%,
        fill: luma(253),
        stroke: 0.8pt + luma(150),
        radius: 4pt,
        inset: 10pt
      )[
        #align(left)[
          *2. Main Time Integration Loop* (#glsf("ssprk3")) \
          #v(4pt)
          #rect(width: 100%, fill: white, stroke: 0.5pt + luma(200), radius: 3pt, inset: 8pt)[
            *a. Hydrodynamic Reconstruction & Fluxes* \
            #text(size: 8.5pt)[
              - 5th-order #glsf("mp5") spatial reconstruction \
              - HLLC approximate Riemann flux solver
            ]
            
            #v(4pt)
            *b. Microphysics & Operator Splitting* \
            #text(size: 8.5pt)[
              - Thermal conduction via Super-Time-Stepping (#glsf("sts")) \
              - Stiff nuclear burning network via implicit Backward Euler (#glsf("be"))
            ]
            
            #v(4pt)
            *c. Adaptive Time Step Control* \
            #text(size: 8.5pt)[
              - Dynamic $Delta t$ based on #glsf("cfl") and microphysical constraints
            ]
          ]
        ]
      ]

      #v(-4pt)
      #align(center)[#text(size: 14pt, fill: luma(100))[↓]]
      #v(-4pt)

      // Step 3: Output & Diagnostics
      #rect(
        width: 100%,
        fill: luma(250),
        stroke: 0.8pt + luma(180),
        radius: 4pt,
        inset: 10pt
      )[
        #align(left)[
          *3. Output & Diagnostics* \
          #v(2pt)
          #text(size: 8.5pt)[
            - Radial profile outputs (`RPROFS`: files storing 1D radial profiles (density, temperature, pressure, abundances) as a function of radius at given time steps) \
            - Full-grid HDF5 and binary checkpoint / restart dumps \
          ]
        ]
      ] 

      #v(-4pt)
      #align(center)[#text(size: 14pt, fill: luma(100))[↓]]
      #v(-4pt)

      // Step 4: Cluster Job Submission
      #rect(
        width: 100%,
        fill: rgb("#f3e5f5"),
        stroke: 1pt + rgb("#8e24aa"),
        radius: 4pt,
        inset: 10pt
      )[
        #align(center)[
          *4. Cluster Job Execution* \
          #text(size: 9pt, font: "DejaVu Sans Mono")[run.genoa] \
          #v(2pt)
          #text(size: 8.5pt)[
            HPC resource allocation (nodes, cores, MPI tasks) & `mpirun` execution call
          ]
        ]
      ]
    ]
  ],
  caption: [Schematic overview of the Phlegethon software architecture, separating numerical build setup (`Makefile`), physical configuration (`app.F90`), core integration steps, and HPC execution control (`run.genoa`).],
) <fig:code_pipeline>




The algorithm follows a strict sequence during each global time step $Delta t$:
1. *Domain Setup & Initialization:* The driver parses execution options, initializes grid structures, loads pre-computed tabular data (e.g., Helmholtz #glsf("eos") tables), and applies physical boundary conditions.
2. *Explicit Hydrodynamic Update:* The spatial reconstruction #glsl("mp5") and interface flux calculations (HLLC) are evaluated across all spatial cells. Time advancement is performed via the #glsl("ssprk3") integrator.
3. *Microphysics & Source Term Integration:* Non-advective source terms are integrated using operator splitting. Thermal conduction is advanced via #gls("sts"), while thermonuclear reaction networks are solved implicitly using #gls("be") with a localized Newton-Raphson solver.
4. *Adaptive Time Step Control:* The dynamic time step $Delta t$ for the subsequent iteration is evaluated based on the minimum constrained timescale across all physical processes (CFL condition, diffusion limit, and nuclear burning rates).

#block(breakable: false)[
As detailed in @fig:code_pipeline, the numerical strategy relies on a operator-splitting approach to decouple the explicit hydrodynamic transport from the stiff microphysical source terms. During each global time step $Delta t$, the hydrodynamic fluxes are integrated explicitly using the #glsf("ssprk3") scheme, whereas thermal conduction (#gls("sts")) and stiff nuclear kinetics (#glsl("be")) are solved as sub-cycled or implicit steps. 

To maintain global stability and accuracy without triggering numerical artifacts, the dynamic time step $Delta t$ is adaptively constrained at the end of each iteration by taking the minimum timescale across all physical modules:
$ Delta t = eta dot min(Delta t_text("CFL"), Delta t_text("diff"), Delta t_text("nuc")) $ <eq:adaptive_dt>
where $eta < 1$ is a safety factor, $Delta t_text("CFL")$ represents the hydrodynamic Courant-Friedrichs-Lewy condition, $Delta t_text("diff")$ the thermal diffusion limit, and $Delta t_text("nuc")$ the nuclear burning timescale dictated by species abundance variations.]


#heading(level: 4, outlined: false, numbering: none)[Modular Compilation and Makefile Configuration]

Physical options and numerical schemes in #glsf("phlegethon") are toggled at compile time using preprocessor macro flags defined within the `Makefile`. By hardcoding the numerical grid resolution ($"nx1, nx2, nx3"$) and array dimensions directly into the build configuration, compiler-level vectorization and memory layouts are optimized for the targeted HPC hardware.

The primary compile-time preprocessor options utilized for the physical modeling presented in this study are summarized in @tbl:makefile_flags.


#figure(
  placement: top,
  scope: "parent",
  table(
    columns: (2.2fr, 2.2fr, 3fr),
    align: (left, left, left),
    stroke: 0.5pt + luma(150),
    fill: (x, y) => if y == 0 { luma(230) } else { none },
    [*Makefile Preprocessor Flag*], [*Physical / Numerical Module*], [*Description & Reference*],
    [`USE_FASTEOS`], [Fast EOS Interpolation], [Accelerates thermodynamic lookup calls @leidi2026],
    [`HELMHOLTZ_EOS`], [Helmholtz Equation of State], [Tabulated degenerate EoS @timmes1999eos],
    [`USE_TIMMES_KAPPA`], [Conductive & Radiative Opacities], [Timmes opacity evaluations @timmes1999eos],
    [`USE_NUCLEAR_NETWORK`], [Thermonuclear Network], [Coupled nuclear kinetics solver @timmes1999],
    [`USE_LMP_WEAK_RATES`], [Weak Interaction Rates], [Langanke & Martínez-Pinedo rates @langanke2000],
    [`USE_ELECTRON_SCREENING`], [Coulomb Electron Screening], [Screening corrections @graboske1973],
    [`LIM5TH_REC`], [5th-Order MP5 Reconstruction], [Monotonicity-preserving spatial scheme @suresh1997],
    [`HLLC_FLUX`], [HLLC Riemann Solver], [3-wave approximate Riemann flux @toro1994],
    [`RK3_STEPPER`], [SSP-RK3 Integrator], [3rd-order TVD time integration @shu1988],
    [`THERMAL_DIFFUSION_STS`], [Super-Time-Stepping (STS)], [Accelerated explicit heat diffusion @meyer2012],
    [`NUCLEAR_NETWORK_BE`], [Implicit Backward Euler], [Stiff nuclear network integrator @timmes1999]
  ),
  caption: [Key compile-time preprocessor flags configured in the Phlegethon `Makefile` for stellar hydrodynamics simulations.]
) <tbl:makefile_flags>

Key parameter blocks defined in `Makefile` include:

- *Grid Resolution and Extent:* Configuration of the spatial domain boundaries, cell counts ($"nx1, nx2, nx3"$), and coordinate geometry.
- *Courant Parameter:* Setting `cfl_make=0.8_rp` ensures strict compliance with the CFL hydrodynamic stability criterion.
- *Low-Mach Numerical Dissipation Cutoff:* Setting `Mach_cutoff_make=1.0e-4_rp` scales wave-dissipation terms in subsonic convective flows to minimize artificial damping.
- *Physical Boundary Conditions:* Definition of reflective, outflow, or hydrostatic boundary states at domain boundaries.
- *I/O and Diagnostics Controls:* Frequency of binary/HDF5 data dumps, checkpoint restarts, and integrated energy/mass conservation logging.

#place.flush()

#heading(level: 4, outlined: false, numbering: none)[Runtime Parameters and Run Configuration (`run.genoa`)]

While physical solvers and numerical schemes are compiled directly into the executable, the HPC-control parameters are controlled via the `run.genoa` input configuration file, in which are defined things such as the number of nodes of the cluster you ask for, the number of cores per node, the number of MPI tasks, and the command to launch the executable (e.g., `mpirun`). This separation allows for flexible execution on different HPC clusters without modifying the code.