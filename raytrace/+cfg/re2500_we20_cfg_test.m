function c = re2500_we20_cfg_test()

c.input.caseName = "re2500_we20_test";
%c.input.surfElevDir = "//tsclient/E/DNS/re2500_we10/test/surfelev"; %surface elevations is found here
c.input.surfElevDir = "D:\DNS\re2500_we20_test\re2500_we20_surfElev"; %surface elevations is found here


c.simulation.distances = linspace(3*pi, 6*pi, 3);
c.simulation.nRays = 50000;

% Folder where surface ray-tracing is saved
%c.pp.rayTraceDir = "\\tsclient\E\DNS\re2500_we10\test\traced";
c.pp.baseRayTraceDir = "D:\DNS\re2500_we20_test\re2500_we20_rayTrace";
% Folder where filtered ray-tracing is saved
c.pp.baseFilteredDir = "D:\DNS\re2500_we20_test\re2500_we20_rayTraced_filtered_simple";


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