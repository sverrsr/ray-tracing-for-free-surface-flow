function c = re1000_weInf_cfg()

c.input.caseName = "re1000_weInf";

c.input.surfElevDir =       "\\tsclient\C\Users\sverrsr\VortexStructures\re1000_weInf\re1000_weInf_surfelev_100sampled"; %surface elevations is found here
c.pp.baseRayTraceDir =      "\\tsclient\C\Users\sverrsr\VortexStructures\re1000_weInf\re1000_weInf_100_sampled_rayTraced_400k";
c.pp.baseFilteredDir =      "\\tsclient\C\Users\sverrsr\VortexStructures\re1000_weInf\re1000_weInf_100_sampled_rayTraced_400k_filtered_simple";

% c.input.surfElevDir =     "D:\DNS\re1000_weInf\re1000_weInf_surfelev_100sampled";
% c.pp.baseRayTraceDir =    "D:\DNS\re1000_weInf\re1000_weInf_100_sampled_rayTraced"; % Folder where surface ray-tracing is saved
% c.pp.baseFilteredDir =    "D:\DNS\re1000_weInf\re1000_weInf_100_sampled_rayTraced_filtered"; % Folder where filtered ray-tracing is saved

c.simulation.distances = linspace(9*pi, 13*pi, 8);
c.simulation.nRays = 400000;

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