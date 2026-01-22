function c = re2500_we10_cfg()

c.input.caseName = "re2500_we10";
%c.input.surfElevDir = "//tsclient/E/DNS/re2500_we10/test/surfelev"; %surface elevations is found here
c.input.surfElevDir = "D:\DNS\re2500_we10\re2500_we10_surfElev"; %surface elevations is found here


c.simulation.distances = linspace(pi, 15*pi, 15);
c.simulation.nRays = 150000;

% Folder where surface ray-tracing is saved
%c.pp.rayTraceDir = "\\tsclient\E\DNS\re2500_we10\test\traced";
c.pp.baseRayTraceDir = "D:\DNS\re2500_we10\re2500_we10_rayTrace";
% Folder where filtered ray-tracing is saved
c.pp.baseFilteredDir = "D:\DNS\re2500_we10\re2500_we10_rayTraced_filtered";


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