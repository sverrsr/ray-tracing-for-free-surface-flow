clear all; clc; close all;



fileName = 'screen_1024bins_0001.mat';   % <--- change to any file you want
fileName = 'screen_1024bins_0002.mat';
% fileName = 'screen_1024bins_0003.mat';
% fileName = 'screen_1024bins_0004.mat';
% fileName = 'screen_1024bins_0005.mat';
% fileName = 'screen_1024bins_0006.mat';
% fileName = 'screen_1024bins_0007.mat';
% fileName = 'screen_1024bins_0008.mat';
% fileName = 'screen_1024bins_0009.mat';
% fileName = 'screen_1024bins_0010.mat';

% Create a new folder to save processed files
outputFolder = fullfile('C:\Users\sverr\Documents\NTNU\Figures', 'smoothing');

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
    fprintf('Created folder: %s\n', outputFolder);
end


%% USER PARAMETERS

%Set threshhold between 0 (black) and 1 (white)

params.sigmaSmooth = 3.5;        % Gaussian smoothing, 2 seemed ok
params.thresh = 0.3367;        % Gaussian smoothing, 2 seemed ok
params.invthresh   = 0.25;      % DoG high
params.areastokeep   = 15;        % DoG low
params.minArea = 10;
params.conn = 8;



%% LOAD IMAGE
data = load(fileName);
img_raw = double(data.screen.image);

%% Crop
img = cropimg(img_raw);

%% Mat2gray
% Normalize the raw image to the range [0, 1]
%imgNormalized = mat2gray(img);, imadjsut gjø det

%% STEP 1 — SMOOTH
imgSmooth = imgaussfilt(img, params.sigmaSmooth);


%% STEP 1.5 — INCREASE CONTRAST
imgContrast = imadjust(imgSmooth);


%% Extra code
Xs = imgContrast;   % already smoothed + contrast-adjusted

threshVec = linspace(0,1,400);
covVec = zeros(size(threshVec));

for i = 1:numel(threshVec)
    covVec(i) = nnz(Xs > threshVec(i)) / numel(Xs);
end

figure;
plot(threshVec, covVec, '-'); grid on;
xlabel('threshold');
ylabel('coverage');
title('Coverage vs threshold');

targetCov = 0.025;  % 2.5 %
[~, idx] = min(abs(covVec - targetCov));
params.thresh = threshVec(idx);

fprintf('Auto-chosen thresh = %.4f → coverage = %.3f %%\n', ...
        params.thresh, 100*covVec(idx));

% --- TARGET ---
targetCov = 1;      % 0.4 %
conn = params.conn;

% --- SEARCH RANGES ---
sigmaVec   = 0.01:0.1:4.0;     % tune if needed
minAreaVec = 1:5:150;        % pixels

bestErr = inf;
bestSigma = NaN;
bestMinArea = NaN;
bestCov = NaN;

for si = 1:numel(sigmaVec)
    sigma = sigmaVec(si);

    % smooth
    Xs = imgaussfilt(imgContrast, sigma);

    % threshold with your FIXED threshold
    BW = Xs > params.thresh;

    for ai = 1:numel(minAreaVec)
        minA = minAreaVec(ai);

        % area filter
        BW_keep = bwareaopen(BW, minA, conn);

        % coverage after filtering
        cov = nnz(BW_keep) / numel(BW_keep);

        % error to target
        err = abs(cov - targetCov);

        if err < bestErr
            bestErr = err;
            bestSigma = sigma;
            bestMinArea = minA;
            bestCov = cov;
        end
    end
end

fprintf('\nBEST MATCH:\n');
fprintf('  sigma    = %.2f\n', bestSigma);
fprintf('  minArea  = %d px\n', bestMinArea);
fprintf('  coverage = %.4f %%\n', 100*bestCov);

params.sigmaSmooth = bestSigma;
params.minArea = bestMinArea;

%% STEP 1 — SMOOTH
imgContrast = imgaussfilt(imgContrast, params.sigmaSmooth);

%%

BW = imgContrast > params.thresh;

% fjern alle komponenter mindre enn minArea
BW_keep = bwareaopen(BW, round(params.minArea), params.conn);

% (valgfritt) hvis du vil telle/rapportere
CC = bwconncomp(BW_keep, params.conn);
stats = regionprops(CC,"Area");
nComp = CC.NumObjects;
coverage_kept = nnz(BW_keep)/numel(BW_keep);

figure;
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile; imagesc(imgContrast); axis image off; colormap gray; title('imgContrast');
%nexttile; imagesc(BW);          axis image off; colormap gray; title('Threshold');
nexttile; imagesc(BW_keep);     axis image off; colormap gray;
title(sprintf('Kept: Area \\ge %d px', params.minArea));

fprintf('Kept area: %.3f %% of total image\n', 100*coverage_kept);

params.sigmaSmooth = bestSigma;
params.minArea = bestMinArea;

Xs = imgaussfilt(imgContrast, params.sigmaSmooth);
BW = Xs > params.thresh;
BW_keep = bwareaopen(BW, round(params.minArea), params.conn);

finalCoverage = nnz(BW_keep)/numel(BW_keep);

figure;
tiledlayout(1,3,'Padding','compact','TileSpacing','compact');
nexttile; imagesc(imgContrast); axis image off; colormap gray; title('imgContrast');
nexttile; imagesc(BW); axis image off; colormap gray; title('Threshold mask');
nexttile; imagesc(BW_keep); axis image off; colormap gray;
title(sprintf('Final kept (%.3f %%)', 100*finalCoverage));

%% Test function
figure;
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile; imagesc(imgContrast); axis image off; colormap gray; title('imgContrast');
%nexttile; imagesc(BW);          axis image off; colormap gray; title('Threshold');
nexttile; imagesc(finalPP(img_raw));     axis image off; colormap gray;
title(sprintf('Kept: Area \\ge %d px', params.minArea));
