function c = dns280()
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

c.input.caseName = "surf_280";
c.input.surfElevDir = "C:\Users\sverr\Documents\NTNU\Prosjekt\Project-Thesis\data\datasets\DNS\raw\oneSamples_DNS";

c.simulation.distances = 3*pi;
c.simulation.nRays = 1000;

% Folder where surface elevation profile is going
c.pp.baseRayTraceDir = = "C:\Users\sverr\Documents\NTNU\Prosjekt\Project-Thesis\data\datasets\DNS\raw\oneSamples_DNS\rayTraced_new";



end