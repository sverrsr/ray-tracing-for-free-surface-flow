function c = re2500_we20_cfg_test()

c.input.caseName = "re2500_we20_test";

% c.input.surfElevDir =       "\\tsclient\C\Users\sverrsr\VortexStructures\re2500_we20_test\re2500_we20_surfElev"; %surface elevations is found here
% c.pp.baseRayTraceDir =      "\\tsclient\C\Users\sverrsr\VortexStructures\re2500_we20_test\re2500_we20_rayTrace_400k";
% c.pp.baseFilteredDir =      "\\tsclient\C\Users\sverrsr\VortexStructures\re2500_we20_test\re2500_we20_rayTraced_400k_filtered_simple";

c.input.surfElevDir =     "D:\DNS\re2500_we20_test\re2500_we20_surfElev"; %surface elevations is found here
c.pp.baseRayTraceDir =    "D:\DNS\re2500_we20_test\re2500_we20_rayTraced"; % Folder where surface ray-tracing is saved
c.pp.baseFilteredDir =    "D:\DNS\re2500_we20_test\re2500_we20_rayTraced_filtered_simple"; % Folder where filtered ray-tracing is saved


c.simulation.distances = 6.001*pi;
c.simulation.nRays = 100000;

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