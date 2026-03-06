function c = re1000_we10_cfg()

c.input.caseName = "re1000_we10";

c.input.surfElevDir =       "C:\Users\sverrsr\Documents\DATA\re1000_we10\re1000_we10_surfelev_100sampled"; %surface elevations is found here
c.pp.baseRayTraceDir =      "C:\Users\sverrsr\Documents\DATA\re1000_we10\re1000_we10_100_sampled_rayTraced_400k";
c.pp.baseFilteredDir =      "\\tsclient\C\Users\sverrsr\VortexStructures\re1000_we10\re1000_we10_100_rayTraced_400k_filtered_simple";



c.simulation.distances = linspace(8*pi, 12*pi, 8);
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

