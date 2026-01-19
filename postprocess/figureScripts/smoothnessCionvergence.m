clear all; clc; close all;

fileName = 'screen_1024bins_0001.mat';   % <--- change to any file you want

%% LOAD IMAGE
data = load(fileName);
img_raw = double(data.screen.image);

img_crop = cropimg(img_raw);

% Normalize the cropped image
imgNormalized = mat2gray(img_crop);

img_interp_1 = newgrid(imgNormalized, 1024, 1024);

imgContrast = imadjust(img_interp_1);  % Use the interpolated image for contrast analysis



%% imgContrast: your intensity field (double or single), mostly zeros
X = imgContrast;

thresh = 0.7870;          % or your params.thresh
sigmas = 0.2:0.1:4;      % sweep smoothing
conn   = 8;            % 4 or 8

nComp    = zeros(size(sigmas));
coverage = zeros(size(sigmas));

for k = 1:numel(sigmas)
    s = sigmas(k);

    % smooth
    if s == 0
        Xs = X;
    else
        Xs = imgaussfilt(X, s);
    end

    % threshold -> binary hits
    BW = Xs > thresh;

    % connected components
    CC = bwconncomp(BW, conn);
    nComp(k) = CC.NumObjects;

    % optional: how many pixels are "on"
    coverage(k) = nnz(BW) / numel(BW);
end

figure;
plot(sigmas, nComp, '-o'); grid on;
xlabel('Gaussian sigma (px)');
ylabel('# connected components');
title('Connected areas vs smoothing');

figure;
plot(sigmas, coverage, '-o'); grid on;
xlabel('Gaussian sigma (px)');
ylabel('Coverage (fraction of pixels > thresh)');
title('Coverage vs smoothing');

%% Part 2

X = imgContrast;




% Thresholding mode (pick ONE)
mode = "fixed";          % "fixed" or "percentile"

target = 0.005;          % used if mode="percentile" (fraction ON, e.g. 0.5%)

% Stability requirements
Jmin   = 0.99;           % Jaccard close to 1 means BW stops changing
dNmax  = 1;              % nComp change allowed between steps
win    = 8;              % must stay stable for this many consecutive steps

% --- compute metrics ---
nComp = zeros(size(sigmas));
J     = nan(size(sigmas));
BW_prev = [];

for k = 1:numel(sigmas)
    s = sigmas(k);

    if s == 0
        Xs = X;
    else
        Xs = imgaussfilt(X, s);
    end

    % Build BW for this sigma
    switch mode
        case "fixed"
            BW = (Xs > thresh);

        case "percentile"
            t  = quantile(Xs(:), 1 - target);   % makes coverage ~ target
            BW = (Xs > t);
    end

    CC = bwconncomp(BW, conn);
    nComp(k) = CC.NumObjects;

    if ~isempty(BW_prev)
        inter = nnz(BW & BW_prev);
        uni   = nnz(BW | BW_prev);
        J(k)  = inter / max(uni, 1);           % 1 = identical masks
    end

    BW_prev = BW;
end

dN = [nan, abs(diff(nComp))];                  % change in component count

% --- find earliest stable sigma (plateau detector) ---
stable = (J >= Jmin) & (dN <= dNmax);

kStar = NaN;
for k = 2:(numel(sigmas) - win + 1)
    if all(stable(k:k+win-1))
        kStar = k;
        break
    end
end

% --- plots ---
figure; plot(sigmas, nComp, '-o'); grid on;
xlabel('Gaussian sigma (px)'); ylabel('# connected components');
title('nComp vs sigma');

figure; plot(sigmas, J, '-o'); grid on; ylim([0 1]);
xlabel('Gaussian sigma (px)'); ylabel('Jaccard vs previous (1=stable)');
title('Structure stability (Jaccard) vs sigma');

figure; plot(sigmas, dN, '-o'); grid on;
xlabel('Gaussian sigma (px)'); ylabel('|Δ nComp| vs previous');
title('Component-count change vs sigma');

% --- report suggestion ---
if ~isnan(kStar)
    fprintf("Suggested sigma ≈ %.3f px (stable for %d steps)\n", sigmas(kStar), win);
else
    fprintf("No stable sigma found with current settings. Try:\n");
    fprintf("- percentile mode, or\n- lower Jmin, or\n- smaller win, or\n- adjust threshold.\n");
end

%%
X = imgContrast;           % ray-intensitetsfeltet ditt

% Ta bare med pikslene som faktisk brukes (unngå ekstrem outlier)
nz = X(X>0);
tMin = prctile(nz, 1);     % "lav" men robust
tMax = prctile(nz, 99.9);  % "høy" men robust

threshVec = linspace(tMin, tMax, 200);

coverageThresh = zeros(size(threshVec));

for k = 1:numel(threshVec)
    th = threshVec(k);
    BW = X > th;
    coverageThresh(k) = nnz(BW) / numel(BW);
end

figure;
plot(threshVec, coverageThresh, '-');
grid on;
xlabel('Terskelverdi');
ylabel('Coverage (andel piksler > terskel)');
title('Areal som funksjon av terskel');

%%
W = imgContrast;                 % eller waveletfeltet ditt
W = max(W,0);                    % hvis du vil sikre ikke-negativt

% Velg terskel-akse (robust)
nz = W(W>0);
tmin = min(nz);
tmax = max(nz);

Wthr = logspace(log10(tmin), log10(tmax), 200);

coverage = zeros(size(Wthr));
for k = 1:numel(Wthr)
    coverage(k) = nnz(W > Wthr(k)) / numel(W);
end

figure; semilogx(Wthr, coverage, '-'); grid on;
xlabel('W_{thr}'); ylabel('Coverage'); title('Coverage vs threshold');


sigmas = 0.2:0.1:4;
X = imgContrast;

covPos = zeros(size(sigmas));
for k = 1:numel(sigmas)
    Xs = imgaussfilt(X, sigmas(k));
    covPos(k) = nnz(Xs > 0) / numel(Xs);   % area covered by positive pixels
end

figure;
plot(sigmas, covPos, '-o'); grid on;
xlabel('Gaussian sigma (px)');
ylabel('Coverage (fraction of pixels > 0 after smoothing)');
title('Coverage of X_s > 0 vs smoothing');

%%
X = imgContrast;

threshVec = 0.0:0.1:1;    % <-- choose thresholds here
sigmas = 0.1:0.1:4;
conn = 8;

figure; hold on; grid on;
for ti = 1:numel(threshVec)
    thresh = threshVec(ti);

    nComp = zeros(size(sigmas));
    coverage = zeros(size(sigmas));

    for k = 1:numel(sigmas)
        s = sigmas(k);
        Xs = imgaussfilt(X, s);

        BW = Xs > thresh;

        CC = bwconncomp(BW, conn);
        nComp(k) = CC.NumObjects;

        coverage(k) = nnz(BW) / numel(BW);
    end

    plot(sigmas, coverage, '-o', 'DisplayName', sprintf('thresh = %.2f', thresh));
end

xlabel('Gaussian sigma (px)');
ylabel('Coverage (fraction of pixels > thresh)');
title('Coverage vs smoothing for different thresholds');
legend show;

%%
targetCov = 0.025;                 % 2.5%
threshVec = 0:0.01:1;

covMat = zeros(numel(threshVec), numel(sigmas));

for i = 1:numel(sigmas)
    Xs = imgaussfilt(X, sigmas(i));
    for j = 1:numel(threshVec)
        covMat(j,i) = nnz(Xs > threshVec(j)) / numel(Xs);
    end
end

threshAtTarget = zeros(size(sigmas));
for i = 1:numel(sigmas)
    [~,jbest] = min(abs(covMat(:,i) - targetCov));
    threshAtTarget(i) = threshVec(jbest);
end

figure; plot(sigmas, threshAtTarget, '-o'); grid on;
xlabel('sigma'); ylabel('threshold giving target coverage');
title(sprintf('Threshold for coverage %.2f%%', 100*targetCov));

%%
params.minArea = 10;
clear X;
X = imgContrast;

sigmaStar = 2.0;                     % pick your favourite smoothing
Xs = imgaussfilt(X, sigmaStar);

threshVec = linspace(0, 1, 200);     % because imgContrast is in [0,1]
covVec = zeros(size(threshVec));

for j = 1:numel(threshVec)
    BWtmp = Xs > threshVec(j);
    covVec(j) = nnz(BWtmp)/numel(BWtmp);
end

targetCov = 0.025;                   % 2.5 % like the paper
[~, jbest] = min(abs(covVec - targetCov));
params.thresh = threshVec(jbest);

fprintf('Chosen thresh = %.4f, coverage before filtering = %.3f %%\n', ...
        params.thresh, 100*covVec(jbest));

BW      = Xs > params.thresh;                % use the same Xs (sigmaStar)
BW_keep = bwareaopen(BW, params.minArea, conn);

coverage_before = nnz(BW)/numel(BW);
coverage_kept   = nnz(BW_keep)/numel(BW_keep);

fprintf('Before filtering: %.3f %%\n', 100*coverage_before);
fprintf('After filtering : %.3f %%\n', 100*coverage_kept);
