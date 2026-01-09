% scripts/runOnlyOne.m
clear; clc; close all;

startup

% 1) choose config
c = dataConfig.dns_default();

% 2) choose case (what data to load)
input = cases.tenSampled();

% 3) load surface data
Z = io.loadSurface(input.surfacePath);



% 5) run pipeline (bench, rays, etc.)
out = pipeline.rayPipeline(Z, G, c);

% 6) you can plot here or inside rayPipeline
fprintf("Dimensions (mm): %.2f × %.2f\n", c.grid.lx, c.grid.ly);

%%
% 1) choose grid config
c = dataConfig.dns_default();

% 2) build grid
G = grid.make(c);

%3) choose simulation config

r = runConfig.re2500_weInf_Stat(); % distances = linspace(pi, 12*pi, 20); % Set what cases to run

%% Setting

caseName = "tenSampled";  % Define the case name


rootDataDir = '\\tsclient\c\Users\sverrsr\VortexStructures\re2500_we10\re2500_we10_rayTrace'; 
snapshotDir = '\\tsclient\c\Users\sverrsr\VortexStructures\re2500_we10\re2500_we10_surfElev'; 

snapshotFiles = dir(fullfile(snapshotDir, '*.mat'));  % get all mat files
Nt = length(snapshotFiles);
fprintf('Found %d snapshot files.\n', Nt);

% Loop over distances
for d = distances

    % Create a new output directory for this distance
    %outDir = fullfile(rootDataDir, caseName + "_raytrace_d" + string(d));
    outDir = fullfile(rootDataDir, caseName + sprintf('_raytrace_D%.2fpi', d/pi));
    
    
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    
    fprintf('Processing distance %.2f, output in %s\n', d, outDir);





    %% --- Cool logging setup ---
    tStart = tic;   % For ETA calculation
    barLength = 30; % visual width of bar
    
    for k = 1:Nt  % or however many surfaces you have
    
        % Load Z from mat file
        S = load(fullfile(snapshotDir, snapshotFiles(k).name));
    
        % Assume variable inside mat file is 'surfElev' or adjust accordingly
        if isfield(S, 'surfElev')
            Z = double(S.surfElev);
        elseif isfield(S, 'Z')
            Z = double(S.Z);
        else
            error('Unknown variable inside %s', snapshotFiles(k).name);
        end
        
        % --- Run your optics simulation ---
        [screen, rays_out, bench, surf] = DNS_Bench(X, Y, Z, d);  % or examplesurface_lensRun
        
        % Save screen
        filename = fullfile(outDir, sprintf('screen_B1024_D%.2fpi_%04d.mat', d/pi, k));

        %screen_image = screen.image; %#ok<NASGU>
        save(filename, 'screen');  % saves entire screen object, not just image
    
        p = k / Nt;                             % percentage
        elapsed = toc(tStart);                  % elapsed time (s)
        eta = (elapsed / p) - elapsed;          % estimated time remaining (s)
        barComplete = round(p * barLength);
        barString = ['[' repmat('#',1,barComplete) repmat('.',1,barLength-barComplete) ']'];
    
        fprintf('\r%s  %5.1f%%  ETA: %.1fs.', barString, p*100, eta);
        
        
        % Optionally close any figures to avoid memory issues
        close all;
    end

fprintf('All snapshots processed!\n');

end
