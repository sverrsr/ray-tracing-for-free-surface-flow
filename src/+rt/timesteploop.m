% I made this to only run one image to inspect
% I still use the DNS Bench

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

% Create a new mesh grid based on the specified dimensions
[X, Y] = meshgrid((linspace(0, lx, nx)), (linspace(0, ly, ny)));

outDir = '\\sambaad.stud.ntnu.no\sverrsr\Documents\Project-Thesis\tenSampledSurfaces_bin'  %'\\sambaad.stud.ntnu.no\sverrsr\Documents\DNS_SCREENS_150k_dist3pi_fullSIM2';
snapshotDir = '\\sambaad.stud.ntnu.no\sverrsr\Documents\Project-Thesis\tenSampledSurfaces' %'//tsclient/E/DNS - RE2500WEinf';
snapshotFiles = dir(fullfile(snapshotDir, '*.mat'));  % get all mat files

if ~exist(outDir, 'dir')
    mkdir(outDir);
end


Nt = length(snapshotFiles);
fprintf('Found %d snapshot files.\n', Nt);

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
    [screen, rays_out, bench, surf] = DNS_Bench(X, Y, Z);  % or examplesurface_lensRun
    
    % Save screen
    filename = fullfile(outDir, sprintf('screen_32bins_%04d.mat', k));
    screen_image = screen.image; %#ok<NASGU>
    save(filename, 'screen');  % saves entire screen object, not just image

    p = k / Nt;                             % percentage
    elapsed = toc(tStart);                  % elapsed time (s)
    eta = (elapsed / p) - elapsed;          % estimated time remaining (s)
    barComplete = round(p * barLength);
    barString = ['[' repmat('#',1,barComplete) repmat('.',1,barLength-barComplete) ']'];

    fprintf('\r[%s%s]  %5.1f%%  ETA: %.1fs', ...
    repmat('#',1,barComplete), ...
    repmat('.',1,barLength-barComplete), ...
    p*100, eta);
    
    
    % Optionally close any figures to avoid memory issues
    close all;
end

fprintf('All snapshots processed!\n');