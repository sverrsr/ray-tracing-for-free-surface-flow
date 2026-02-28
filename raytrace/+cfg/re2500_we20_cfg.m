function c = re2500_we20_cfg()

c.input.caseName = "re2500_we20";

c.input.surfElevDir =       "C:\Users\sverrsr\Documents\DATA\re2500_we20\re2500_we20_14800_surfElev";
c.pp.baseRayTraceDir =      "C:\Users\sverrsr\Documents\DATA\re2500_we20\re2500_we20_14800_rayTraced_400k";
c.pp.baseFilteredDir =      "C:\Users\sverrsr\Documents\DATA\re2500_we20\re2500_we20_14800_rayTraced_400k_filtered_simple";

% c.input.surfElevDir =     "D:\DNS\re1000_weInf\re1000_weInf_surfelev_100sampled";
% c.pp.baseRayTraceDir =    "D:\DNS\re1000_weInf\re1000_weInf_100_sampled_rayTraced"; % Folder where surface ray-tracing is saved
% c.pp.baseFilteredDir =    "D:\DNS\re1000_weInf\re1000_weInf_100_sampled_rayTraced_filtered"; % Folder where filtered ray-tracing is saved


c.simulation.distances = 5.33*pi;
c.simulation.nRays = 400000;

c.grid.nx = 256;
c.grid.ny = 256;
c.grid.nt = 12500;

c.grid.lx = 2*pi;
c.grid.ly = 2*pi;

c.time.dt = 0.06;

c.physics.nu = 1/2500;
c.physics.overflatespenning = 0;
c.physics.g = 10;

c.viz.enable = true;   % optional, for plots


end