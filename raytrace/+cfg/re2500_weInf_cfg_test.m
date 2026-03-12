function c = re2500_weInf_cfg_test()

c.input.caseName    = "re2500_weInf_test";


%surface elevations is found here
c.input.surfElevDir =     "C:\Users\sverrsr\Documents\DATA\re2500_weInf_test\re2500_weInf_surfElev_5"; 
c.pp.baseRayTraceDir =    "C:\Users\sverrsr\Documents\DATA\re2500_weInf_test\re2500_weInf_test_rayTraced"; % Folder where surface ray-tracing is saved
c.pp.baseStackedDir =   "C:\Users\sverrsr\Documents\DATA\re2500_weInf_test\re2500_weInf_test_stackRaw";

%c.pp.baseFilteredDir =    "C:\Users\sverrsr\Documents\DATA\re2500_weInf_test\re2500_weInf_test_rayTraced_filtered_simple"; % Folder where filtered ray-tracing is saved


c.simulation.distances = linspace(1*pi, 16*pi, 4);
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