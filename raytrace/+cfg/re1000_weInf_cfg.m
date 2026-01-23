function c = re1000_weInf_cfg()

c.input.caseName = "re1000_weInf";
<<<<<<< HEAD
c.input.surfElevDir = "\\tsclient\C\Users\sverrsr\VortexStructures\re1000_weInf\re1000_weInf_surfelev_100sampled";
=======
%c.input.surfElevDir = "\\tsclient\C\Users\sverrsr\VortexStructures\re1000_weInf\re1000_weInf_surfelev";
c.input.surfElevDir = "D:\DNS\re1000_weInf\re1000_weInf_surfelev_500sampled";
>>>>>>> d95958d634e55c71c187ea8c7f7aad6453dfd2cd

c.simulation.distances = linspace(pi, 15*pi, 15);
c.simulation.nRays = 150000;

<<<<<<< HEAD
% Folder where surface ray-tracing is going
c.output.rayTraceDir = "\\tsclient\C\Users\sverrsr\VortexStructures\re1000_weInf\re1000_weInf_100_sampled_rayTraced";
=======
% Folder where surface ray-tracing is saved
%c.pp.rayTraceDir = "\\tsclient\E\DNS\re2500_we10\test\traced";
c.pp.baseRayTraceDir = "D:\DNS\re1000_weInf\re1000_weInf_rayTrace";
% Folder where filtered ray-tracing is saved
c.pp.baseFilteredDir = "D:\DNS\re1000_weInf\re1000_weInf_rayTraced_filtered";

>>>>>>> d95958d634e55c71c187ea8c7f7aad6453dfd2cd

c.grid.nx = 128;
c.grid.ny = 128;
c.grid.nz = 348;
c.grid.nt = 12500;

c.grid.lx = 2*pi;
c.grid.ly = 2*pi;

c.time.dt = 0.06;

c.physics.nu = 1/2500;
c.physics.overflatespenning = 0;
c.physics.g = 10;

c.viz.enable = true;   % optional, for plots


end