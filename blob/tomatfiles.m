%% -------------------------------------------------------------------------
%  Convert large HDF5 wave dataset into individual .mat files
%  Each file becomes: u_00001.mat, u_00002.mat, ...
%  Saves each frame as single-precision (4 bytes per entry).
%
%  Much more efficient for time-stepped streaming.
% -------------------------------------------------------------------------

clear; clc; close all;

h5file   = 'wave.h5';
dataset  = '/u';
outDir   = 'C:\Users\sverr\Documents\NTNU\Prosjekt\Blob\bloMatFiles';
downsample = 1;    % set >1 to reduce resolution (e.g., 2,4,8)

%% --- Prepare output directory ---
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% --- Get dataset info ---
info  = h5info(h5file, dataset);
Ny    = info.Dataspace.Size(1);
Nx    = info.Dataspace.Size(2);
Nt    = info.Dataspace.Size(3);

fprintf('Dataset size: %d x %d x %d\n', Ny, Nx, Nt);

%% --- Conversion loop ---
for k = 1:Nt

    fprintf('Reading frame %d / %d\n', k, Nt);

    % Read ONE slice
    U = h5read(h5file, dataset, [1 1 k], [Ny Nx 1]);

    % Downsample if requested
    if downsample > 1
        U = U(1:downsample:end, 1:downsample:end);
    end

    % Convert to single to save 50% memory
    U = single(U);

    % Save to .mat with predictable filename
    fname = fullfile(outDir, sprintf('u_%05d.mat', k));
    save(fname, 'U', '-v7.3');   % -v7.3 for large arrays >2GB

end

fprintf('Finished converting %d frames.\nSaved to folder: %s\n', Nt, outDir);
