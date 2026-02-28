function c = re2500_weInf_cfg()

c.input.caseName = "re2500_weInf";

c.input.surfElevDir =       "C:\Users\sverrsr\Documents\DATA\re2500_weInf\re2500_weInf_surfElev"; %surface elevations is found here
c.pp.baseRayTraceDir =      "C:\Users\sverrsr\Documents\DATA\re2500_weInf\re2500_weInf_rayTraced_12500_400k"; % Folder where surface ray-tracing is saved
c.pp.baseFilteredDir =      "C:\Users\sverrsr\Documents\DATA\re2500_weInf\re2500_weInf_rayTraced_12500_400k_filtered_simple"; % Folder where filtered ray-tracing is saved

% c.input.surfElevDir =     "D:\DNS\re1000_weInf\re1000_weInf_surfelev_100sampled";
% c.pp.baseRayTraceDir =    "D:\DNS\re1000_weInf\re1000_weInf_100_sampled_rayTraced"; % Folder where surface ray-tracing is saved
% c.pp.baseFilteredDir =    "D:\DNS\re1000_weInf\re1000_weInf_100_sampled_rayTraced_filtered"; % Folder where filtered ray-tracing is saved

c.simulation.distances = 3.14*pi;
c.simulation.nRays = 400000;

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

c.analysis.csvFile    = "rayconvergence.csv"; % your file
c.analysis.imgField   = "img";
c.analysis.rotateSurf = true;

% if images are under a distance subfolder inside each ray folder:
c.analysis.fixedDistTag = "D3pi";   % set "" if .mat are directly inside ray folder

c.analysis.rowLoop  = "all";        % or e.g. 1:10
c.analysis.saveCsv  = true;
c.analysis.makePlot = true;

end



function rayList = makeRayList()
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
end
