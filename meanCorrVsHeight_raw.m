%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fileName: meanCorrVsHeigh_raw
% 
% Script that computes mean correlation between filtered ray-tracing images and surface
% curvature from DNS free-surface turbulence simulations.
%
% What it does:
% - Reads a CSV table containing distance tags (heights from ray-tracing) and stores results back
%   into the same table.
% - For each distance tag:
%     1) Loads the corresponding set of filtered ray-tracing images.
%     2) Loads the matching surface-elevation fields.
%     3) Computes mean curvature (H) from the surface elevation.
%     4) Normalizes both fields (zero mean, unit standard deviation).
%     5) Computes corr2(img, H) for each timestep/file pair.
%     6) Takes the mean correlation across all pairs (ignoring NaNs) and writes it to
%        S.MeanCorrelation for that distance.
% - Saves the updated table to disk and plots mean correlation versus height (in multiples
%   of pi).
%
% Inputs / settings (edit in script):
% - fileName: CSV file containing at least the column S.DistanceTag.
% - baseFilteredDir: root folder containing filtered ray-tracing image folders.
% - surfElevDir: folder containing surface elevation .mat files (surfElev).
% - filteredPrefix: prefix used to build the per-distance filtered folder name.
% - nx, ny: target grid size used when regridding the filtered images.
%
% Notes:
% - Files are sorted by filename to pair the same timestep between image and surface data.
%
% Output:
% - Updates S.MeanCorrelation for each distance tag and overwrites fileName.
% - Generates a figure: mean correlation vs height (multiples of pi).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

% Distances (heights)
% ---- set case once ----
caseTag = "re2500_we20";
rootDir = "D:\DNS";

%%
% Distances (heights)
fileName = caseTag + "_meanCorr.csv";
S = readtable(fileName);

% Folders
baseFilteredDir = "D:\DNS\re2500_we20\re2500_we20_rayTrace"; %fullfile(rootDir, caseTag, caseTag + "_rayTrace_filtered");
surfElevDir     = "D:\DNS\re2500_we20\re2500_we20_surfElev"; %fullfile(rootDir, caseTag, caseTag + "_surfElev");
filteredPrefix  = caseTag + "_raytrace_";   % + distTag
% Prefix for re2500_weInf:
%filteredPrefix  = "RayTrace_500SAMPLED_B1024_";


fprintf('Filtered ray tracing images are found in %s\n', baseFilteredDir);
fprintf('Surface elevations %s\n', surfElevDir);

distTags = string(S.DistanceTag);
% Grid (once)
nx = 256; ny = 256;
[X,Y] = meshgrid(single(linspace(-pi,pi,nx)), single(linspace(-pi,pi,ny)));

% Find surface elevation files
surfFiles = dir(fullfile(surfElevDir,'*.mat'));

meanCorrByDist = nan(numel(distTags),1);
heightByDist   = nan(numel(distTags),1);

% First loop through heights
for d = 1:3
    distTag = distTags(d);

    

    tok = regexp(distTag,'D([0-9.]+)pi','tokens','once');
    heightByDist(d) = str2double(tok{1}) * pi;   % "height" in radians

    filteredDir = fullfile(baseFilteredDir, filteredPrefix + distTag);
    fprintf('Filtered ray tracing images are found in %s\n', filteredDir);

    filtFiles = dir(fullfile(filteredDir,'*.mat'));
    
    % Sort both by name to ensure consistent order
    [~,is] = sort({surfFiles.name});
    surfFiles = surfFiles(is);
    
    [~,iflt] = sort({filtFiles.name});
    filtFiles = filtFiles(iflt);

    %% Random sorting to test correlation bias
    % I tested this and teh correlations increased as before
    % rng(1)   % fixed seed so you can reproduce the test
    % 
    % perm = randperm(numel(filtFiles));
    % filtFiles = filtFiles(perm);
    %%
    
    n = min(numel(surfFiles), numel(filtFiles));
    if n == 0
        warning('No files found for %s', distTag);
        continue;
    end
    
    corrVec = zeros(n,1);

    % Second loop through all frames
    for k = 1:n
        % --- filtered image ---
        filteredImagePath = fullfile(filteredDir, filtFiles(k).name);
        A = load(filteredImagePath);
        img = double(A.screen.image);%double(A.img);
        img = newgrid(img, nx, ny);
        img = (img - mean(img(:))) / std(img(:));
    
        % --- curvature ---
        curvaturePath = fullfile(surfElevDir, surfFiles(k).name);
        T = load(curvaturePath);
        Z = rot90(T.surfElev, 2);
        [~,H,~,~] = surfature(X,Y,Z);
        H = (H - mean(H(:))) / std(H(:));

        imshow(img);
    
        % --- correlation (no shift) ---
        corrVec(k) = corr2(img, H);
    end

    meanCorrByDist(d) = mean(corrVec, 'omitnan'); % omnitan ignores nan

    S.MeanCorrelation(d) = meanCorrByDist(d);
    
    fprintf('%s: mean corr = %.6f (n=%d)\n', distTag, meanCorrByDist(d), n);
end

writetable(S, fileName)
fprintf('Correlations saved in table S and the file %s\n', fileName);

% Plot mean correlation vs height
hPi = heightByDist/pi;

figure;
plot(hPi, meanCorrByDist, '-o');
grid on;
xlabel('Height (multiples of \pi)');
ylabel('Mean corr2 (filtered vs curvature)');
title('Mean correlation vs height');

