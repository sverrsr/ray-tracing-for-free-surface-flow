clear all; %close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fileName: corr2_analysis_script
% Script that reads 
%
% Inputs:
% caseName: Six possible cases, set name based on which case you want to analyze
%           Name format for case 1: RE2500_WEinf. 
%           Swap 2500 with 1000 and/or inf with 10 or 20 to read cases 2-6.
% traceDir: Folder where the different simulations are stored.
%           Should contain a ray-traced images at one distance
%           Could be filtered or raw images
% surfElevDir: Folder where the different surface elevations are stored
%              The same for all distances, but inique for each caseName
% 
% Return:
% This script returns the following:
% meanCorr: correlation for each image
% meanCorr: mean of meanCorr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Jeg henter inspirasjon fra curvature_reflection_analysis_loop for å lage en ny loop 10/12/2025

% Two images to compare
caseName = ""
distanceTag = "";
traceDir      = 'D:\DNS\re2500_weInf\re2500_weInf_surfElev_first2089_B1024_filtered\re2500_weInf_surfElev_first2089_B1024_filtered_D3pi';
surfElevDir      = 'D:\DNS\re2500_weInf\re2500_weInf_surfElev_first2089_B1024';


% Get filteredFiles
filteredFiles = dir(fullfile(filteredDir, '*.mat'));
surfElevFiles = dir(fullfile(surfElevDir, '*.mat'));

if numel(filteredFiles) ~= numel(surfElevFiles)
    error('The number of filtered files and surface elevation files do not match. Please check the directories.');
end

% grid (make once)
nx = 256; ny = 256;
[X, Y] = meshgrid(single(linspace(-pi, pi, nx)), single(linspace(-pi, pi, ny)));

meanCorr = zeros(numel(filteredFiles),1);


for k = 1:numel(filteredFiles)
    filteredPath = fullfile(filteredDir, filteredFiles(k).name);
    surfElevPath = fullfile(surfElevDir, surfElevFiles(k).name);
    
    % FIltered image
    S = load(filteredPath);
    filt_Img_raw = newgrid(double(S.img), nx, ny);

    %smooth = imadjust(imgaussfilt(filt_Img_raw, 2));

    smooth = filt_Img_raw;

    % Elevation and curvature
    T = load(surfElevPath);
    Z = T.surfElev;
    Z = rot90(Z, 2); %Rotate Z so it aligns with reflection
    [~,H,~,~] = surfature(X,Y,Z);

    smoothp = (smooth - mean(smooth(:))) / std(smooth(:));
    Hp      = (H      - mean(H(:)))     / std(H(:));

    % Alternatively use normxcorr2(smoothp, Hp) later
    corrCoeff = corr2(smoothp, Hp);
    disp(meanCorr(k))

end

meanCorr = mean(corrCoeff);
fprintf('Mean of all correlations: %.6f\n', meanCorr);