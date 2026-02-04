function c = simenCase()

c.input.caseName = "simenCase";
c.input.surfElevDir = "C:\Users\sverr\Documents\NTNU\Prosjekt\Project-Thesis\data\datasets\DNS\raw\simenCase\surface";

c.simulation.distances = 6.01*pi;
c.simulation.nRays = 100000;

% Folder where surface ray-tracing is saved
%c.pp.rayTraceDir = "\\tsclient\E\DNS\re2500_we10\test\traced";
c.pp.baseRayTraceDir = "C:\Users\sverr\Documents\NTNU\Prosjekt\Project-Thesis\data\datasets\DNS\raw\simenCase\result";
% Folder where filtered ray-tracing is saved
c.pp.baseFilteredDir = "C:\Users\sverr\Documents\NTNU\Prosjekt\Project-Thesis\data\datasets\DNS\raw\simenCase\filtered";

c.grid.nx = 256;
c.grid.ny = 256;
c.grid.nz = 660;
c.grid.nt = 12500;
c.grid.lx = 2*pi;
c.grid.ly = 2*pi;

c.time.dt = 0.06;

c.physics.nu = 1/2500;
c.physics.overflatespenning = 0;
c.physics.g = 10;

end