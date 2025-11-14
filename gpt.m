clear all; close all; clc;

%% Set Mesh and Surface Properties
load surfElev_280.00.mat;

Z = double(surfElev);
clear surfElev;

nx = 256;
ny = 256;
nt = 12500;

dx = 2 * pi / nx;
dy = 2 * pi / ny;

dt = 0.06;

lx = 2 * pi;
ly = 2 * pi;

nu = 1 / 2500;
overflatespenning = 0;
g = 10;

[X, Y] = meshgrid(linspace(0, lx, nx), linspace(0, ly, ny));

outDir = '\\sambaad.stud.ntnu.no\sverrsr\Documents\DNS_SCREENS_150k_dist3pi_fullSIM2';
snapshotDir = '//tsclient/E/DNS - RE2500WEinf';
snapshotFiles = dir(fullfile(snapshotDir, '*.mat'));

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

Nt = length(snapshotFiles);
fprintf('Found %d snapshot files.\n', Nt);

%% --- Cool logging setup ---
tStart = tic;   % For ETA calculation
barLength = 30; % visual width of bar

for k = 1:Nt
    
    %% Load .mat file
    S = load(fullfile(snapshotDir, snapshotFiles(k).name));

    if isfield(S, 'surfElev')
        Z = double(S.surfElev);
    elseif isfield(S, 'Z')
        Z = double(S.Z);
    else
        error('Unknown variable inside %s', snapshotFiles(k).name);
    end

    %% Run simulation
    [screen, rays_out, bench, surf] = DNS(X, Y, Z);

    %% Save result
    filename = fullfile(outDir, sprintf('screen_%04d.mat', k));
    screen_image = screen.image; %#ok<NASGU>
    save(filename, 'screen');

    %% --- COOL PROGRESS BAR WITH ETA ---
    p = k / Nt;                             % percentage
    elapsed = toc(tStart);                  % elapsed time (s)
    eta = (elapsed / p) - elapsed;          % estimated time remaining (s)
    barComplete = round(p * barLength);
    barString = ['[' repmat('#',1,barComplete) repmat('.',1,barLength-barComplete) ']'];

    fprintf('\r%s  %5.1f%%  (%d/%d)  ETA: %6.1fs', barString, p*100, k, Nt, eta);
    
    % avoid flooding with figures
    close all;
end

fprintf('\nAll snapshots processed!\n');