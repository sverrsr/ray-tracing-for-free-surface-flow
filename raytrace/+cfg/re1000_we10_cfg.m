function c = re1000_we10_cfg()

c.input.caseName = "dns_re1000_we10";
c.input.surfElevDir = "D:\DNS\re1000_we10\test";

c.simulation.distances = linspace(pi, 12*pi, 20);
c.simulation.nRays = 1000;

% Folder where surface ray-tracing is going
c.output.rayTraceDir = "D:\DNS\re1000_we10\raytraceTestResults";


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