#import "./../backmatter/glossaire.typ": *

= Work Environment and Project Management

== The Heidelberg Institute for Theoretical Studies (HITS) and the PSO Group

The work presented in this report was carried out at the *Heidelberg Institute for Theoretical Studies (HITS)*, a private, non-profit research institute dedicated to data-driven and computationally intensive natural sciences. HITS maintains strong academic ties with Heidelberg University while offering a state-of-the-art, highly autonomous research environment.

The research was conducted within the *Physics of Stellar Objects (PSO)* research group, led by *Prof. Dr. Friedrich K. Röpke*. The PSO group specializes in the numerical modeling of complex astrophysical processes, ranging from stellar evolution and binary star mergers (e.g., #glsf("ce") interactions) to Type Ia supernova explosions. 

The group is housed across two distinct buildings within the HITS campus: the historic early 20th-century *Villa* (where part of the PSO team, including myself, was based) and the modern *Main Building*, which hosts the main group offices, meeting rooms, lunch room, and administration. Despite this physical distribution, cohesion is maintained through a highly collaborative work culture. Notably, PSO stands out as the most international research group at HITS. While many other groups predominantly speak German, PSO operates entirely in English, bringing together researchers from several continents with German native speakers accounting for less than a third of the team.

== Work Infrastructure and Technical Ecosystem

#heading(level: 3, outlined: false)[Computational Facilities and Data Storage Strategy]

Due to the multiphysical hydrodynamical and thermonuclear nature of Type Ia supernova simulations, access to #glsf("hpc") infrastructure is critical. Calculations were executed on *Genoa*, one of HITS’s dedicated HPC clusters running under the SLURM workload manager. *Genoa* is a CPU cluster composed of 256 nodes each equipped with 256 logical cores (AMD EPYC 9174F, 16 physical cores per socket, 2 threads per core) and 384 GB of RAM.
Contrary to other GPUS or CPU clusters available at HITS (like *Bergamo*, *Roma* or *Cascade*), it is not located at the HITS facility but is hosted in a building of the University, because of a cheaper electricity contract there. This also rules the way data is stored for the simulations and work we do at HITS.

Data storage is structured across two (soon to be, three) high-speed storage systems: `fast` (directly located into the HITS facility, used for the HITS-located clusters), and `basement` (located at the same place as the *Genoa* cluster) to store and use the data generated on the cluster without having to transfer it elsewhere. 
- *Volume Demands:* Hydrodynamic runs generate massive outputs (density profiles, velocity fields, mass fractions across species). By the end of the internship, my datasets occupied several tens of Terabytes. Most people in the PSO group have datasets worth multiple hundreds of Terabytes.
- *Group-Wide Impact:* The PSO group alone accounts for over 60% of the total multi-Petabyte storage capacity of `basement`. This is the main reason why the IT team worked in close collaboration with the PSO group to manage better the upcoming storage system.
- *Infrastructure Challenges:* During my time at HITS, `basement` operated near critical capacity (\~95% full). This required strict data hygiene (compressing raw outputs, removing redundant checkpoint files, and archiving) while the institute prepared to admit into active service the new storage system. The IT team held a lot of meetings and discussions with representatives of all the research groups to see how to best tune the settings and internal architecture of the new storage system to accommodate the diverse needs of the institute's research groups, especially in terms of bandwidth, data throughput and storage repartition. The cost of hardware, maintenance and electricity for storage space as well as clusters amounts to a significant portion of the institute's budget.

#heading(level: 3, outlined: false)[Software Engineering and Version Control]
The core simulation software used throughout this project is *Phlegethon*, an in-house astrophysics code hosted on GitHub, complemented by GitLab repositories.

To implement the methodological updates required for my project, for example enabling true 1D cartesian geometry mode or implementing a dynamic OpenMP parallelization, a dedicated branch was created from the main repository by *Dr. Giovanni LEIDI*, in charge of *Phlegethon*. Development workflows were designed with code merging in mind, allowing optimizations proven during the project to be integrated back into Phlegethon's main codebase. The 1D option will most likely be merged into the main as an option for more efficient computing for people needing no more than one dimension, and the OpenMP parallelization is worked upon by other people and alumnis of the PSO group to be more efficient and usable on GPU clusters instead of only CPU ones like it is now.

== Team Dynamics, Collaboration, and Communication

#heading(level: 3, outlined: false)[Supervisory Structure and Everyday Guidance]
Project governance was organized around a dual tier of supervision:
1. *Academic Supervision:* Weekly progress reviews and strategic direction were provided directly by *Prof. Dr. Friedrich K. Röpke*, whose office in the Main Building remains accessible for any discussions at any point where he is available. This also tends to show once again the horizontal hierarchy within the group, which allows for a more collaborative and less-constrained approach to research and problem-solving.
2. *Daily Operations & Technical Mentorship:* Day-to-day progress was supported by three key members of the PSO group:
   - *Kristián Vitovský (PhD Student):* He guided me with the initial onboarding, workspace configuration, and early familiarity with Phlegethon's runtime parameters and execution debugging.
   - *Dr. Giovanni Leidi (Postdoctoral Researcher):* As the primary developer of Phlegethon, Dr. Leidi assisted directly with code architecture, implementing customized code modifications (such as pure 1D geometries and enhanced data logging) on a dedicated git branch, as well as helping me understand the physics behind the results I got, wether those were expected or unplanned for.
   - *Dr. Alexander Holas (Postdoctoral Researcher, PhD candidate during the internship):* He provided crucial expertise on the physical formulation of Type Ia supernovae. Dr. Holas guided the selection of nuclear networks, of initial conditions, and the physical approximations to ensure that numerical simplifications remained physically sound. He supported me all throughout the internship, and was the main point of contact for any questions regarding the project.

Support extended beyond office hours and contract end dates, with colleagues providing continuous technical and physical insights via Mattermost and in-person discussions.

#heading(level: 3, outlined: false)[Meeting Routines and Cross-Group Synergies]
Research activities were structured around two fixed weekly meetings:

- *PSO Group Meeting (Wednesdays, 11:00 AM):* A joint session gathering the PSO team, members of the neighboring *SET* (Stellar Evolution Theory) group, and remote collaborators (including alumni now at institutions such as *Los Alamos National Laboratory*). Meetings combined operational updates (#gls("hpc") allocations, upcoming conferences) with a 40 to 60 minutes long scientific presentation. These presentations provided a platform for thesis defenses, conference dry-runs, and peer feedback across diverse topics in stellar physics. It showed the place that multi-disciplinary and diversification has for the group, which is one of the main benefits of HITS not being only a university department focused on one topic only.
- *SLH Subgroup Meeting (Thursdays, 4:00 PM):* Dedicated specifically to Stellar Hydrodynamics (SLH), this afternoon meeting accommodated international remote participants with its time slot adjusted for time zone differences. Discussions were highly interactive, focusing on intermediate results, numerical anomalies, and technical blockers. Key technical breakthroughs, such as diagnosing dense-matrix bottlenecks in nuclear reaction networks ($O(N^3)$ scaling), identifying acoustic wave reflections at domain boundaries, and proposing dynamic OpenMP parallelization, originated directly from these sessions.

Working in fundamental computational astrophysics highlighted a fundamental difference between industrial engineering projects and academic research: project planning is inherently non-linear. Unlike classical engineering projects with pre-defined Gantt charts and rigid weekly milestones, numerical research involves constant adaptation. Unexpected physical phenomena, numerical instabilities, or stiff matrix convergence issues frequently generate new investigation branches. To navigate this unpredictability, I managed priorities through dynamic task tracking and personal documentation files rather than trying to fit the work into a static initial timeline.

== Integration, Working Conditions, and Scientific Culture

The working environment at HITS emphasizes both physical comfort and operational flexibility. Workstations in the open-plan offices feature highly ergonomic chairs and motor-driven sit-stand desks, equipped with dual-monitor setups and dedicated laptops connected to the institute's network via secure VPN and SSH tunnels.

From an organizational standpoint, HITS operates under a flexible office space policy (*flex-office*), allowing researchers to reserve any available desk within the PSO group's rooms via an internal booking system. In practice, however, team members naturally established preferred daily seats, striking a comfortable balance between organizational flexibility and a sense of routine.

Beyond formal meetings, scientific ideas and technical troubleshooting were routinely shared during coffee breaks and lunch hours. Digital collaboration was sustained through specialized Mattermost channels, there was one dedicated to every project being worked on by the people of the PSO group, as well as some dedicated to scientific literature tracking and competitor analysis, or informal chats. 

Social integration was facilitated from the start through events such as the weekly "Mensa" evenings in Heidelberg, joint group hikes, and the annual PSO Summer Party. This inclusive culture fostered an ideal environment for scientific inquiry, international networking, and rapid professional as well as personal growth.