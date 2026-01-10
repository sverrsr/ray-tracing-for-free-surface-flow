function c = dns_default()
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


c.dataset.name = 're2500_weinf';
% Folder where surface elevation profile is found
c.dataset.dir = '\\tsclient\c\Users\sverrsr\VortexStructures\re2500_we10\re2500_we10_surfElev'; 

c.simulation.distances = linspace(pi, 12*pi, 20);



% Folder where surface elevation profile is going
rootDataDir = '\\tsclient\c\Users\sverrsr\VortexStructures\re2500_we10\re2500_we10_rayTrace'; 


end