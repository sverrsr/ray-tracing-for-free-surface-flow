function c = re2500_we20_cfg()

c.input.caseName = "re2500_we20";
c.input.surfElevDir = "//tsclient/E/DNS/re2500_we20/test/surfelev"; %surface elevations is found here



c.simulation.distances = 3*pi; %linspace(pi, 12*pi, 20);
c.simulation.nRays = 150000;

% Folder where surface ray-tracing is saved
c.output.rayTraceDir = "\\tsclient\C\Users\sverrsr\VortexStructures\re2500_we20\re2500_we20_100_sampled_rayTraced";


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