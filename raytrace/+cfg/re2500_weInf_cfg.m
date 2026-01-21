function c = re2500_weInf_cfg()

c.input.caseName = "re2500_we10";
c.input.surfElevDir = "//tsclient/E/DNS/re2500_weInf/re2500_weInf_surfElev_sampled500"; %surface elevations is found here

c.simulation.distances = 3*pi; %linspace(pi, 12*pi, 20);

% Makin nRays so it doubles each time
startRays = 200;
maxRays   = 819200;

% Calculate how many doubling steps we need
nSteps = floor(log2(maxRays / startRays)) + 1;

rayList = zeros(1, nSteps+1);  % preallocate
rayList(1) = startRays;

for k = 2:nSteps
    rayList(k) = rayList(k-1) * 2;
end

% Ensure the last value is exactly maxRays
rayList(end) = maxRays;

c.simulation.nRays = rayList;


% Folder where surface ray-tracing is saved
c.output.rayTraceDir = "//tsclient/E/DNS/re2500_weInf/re2500_weInf_rayConvergence";

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

c.viz.enable = true;   % optional, for plots

end