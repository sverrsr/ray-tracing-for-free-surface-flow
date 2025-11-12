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

outDir = '\\sambaad.stud.ntnu.no\sverrsr\Documents\DNS_SCREENS_150k_dist3pi_fullSIM';
snapshotDir = '//tsclient/E/DNS - RE2500WEinf';
snapshotFiles = dir(fullfile(snapshotDir, '*.mat'));  % get all mat files

if ~exist(outDir, 'dir')
    mkdir(outDir);
end


Nt = length(snapshotFiles);
fprintf('Found %d snapshot files.\n', Nt);

for k = 1:Nt  % or however many surfaces you have
    fprintf('Processing frame %d of %d: %s ...\n', k, Nt, snapshotFiles(k).name);

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
    [screen, rays_out, bench, surf] = DNS(X, Y, Z);  % or examplesurface_lensRun
    
    % Save screen
    filename = fullfile(outDir, sprintf('screen_%04d.mat', k));
    screen_image = screen.image; %#ok<NASGU>
    save(filename, 'screen');  % saves entire screen object, not just image
    
    fprintf('Saved %s\n', filename);
    
    % Optionally close any figures to avoid memory issues
    close all;
end

fprintf('All snapshots processed!\n');