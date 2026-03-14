clear; clc; close all;

% Example: same optics + post-processing, but input is one 3D surface stack.

c = cfg.example_cfg;
G = grid.make(c);

% % Build one [ny,nx,Nt] stack from folder files.
% surfFiles = dir(fullfile(c.input.surfElevDir, '*.mat'));
% [~, idx] = sort({surfFiles.name});
% surfFiles = surfFiles(idx);

% for k = 1:numel(surfFiles)
%     S = load(fullfile(surfFiles(k).folder, surfFiles(k).name));
% 
%     if isfield(S, 'surfElev')
%         Z = double(S.surfElev);
%     elseif isfield(S, 'Z')
%         Z = double(S.Z);
%     elseif isfield(S, 'slice')
%         Z = double(S.slice);
%     elseif isfield(S, 'eta')
%         Z = double(S.eta);
%     else
%         error('Unknown variable in %s', surfFiles(k).name);
%     end
% 
%     if k == 1
%         surfElevStack = zeros(size(Z,1), size(Z,2), numel(surfFiles), 'double');
%     end
%     surfElevStack(:,:,k) = Z;
% end

load("example.mat");
surfElevStack(:,:,:) = example;
setenv( 'USE_GPU_ARRAYS', '1' );
backend = rt_backend();
fprintf( 'RT backend: %s (%s)\n', upper( backend.location ), backend.device_name );

% One-swoop pipeline: raytrace + screen2mat2-style processing + denoising.
rt.raytrace_stack_pipeline(G.X, G.Y, surfElevStack, c, ...
    useLog=true, ...
    applyDenoising=true, ...
    saveRawStack=false);
