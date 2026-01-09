%% USER PARAMETERS

clear all; close all;

%Set threshhold between 0 (black) and 1 (white)

params.sigmaSmooth = 3.5;        % Gaussian smoothing, 2 seemed ok
params.thresh = 0.3367;        % Gaussian smoothing, 2 seemed ok
params.invthresh   = 0.25;      % DoG high
params.areastokeep   = 15;        % DoG low
params.minArea = 10;
params.conn = 8;

folderPath = 'D:\DNS\re2500_weInf\re2500_weInf_surfElev_sampled500_rayTrace\RayTrace_500SAMPLED_B1024_D3pi';

files = dir(fullfile(folderPath, 'screen_B1024_D3pi_*.mat'));

if isempty(files)
    fprintf('No files found in the specified directory: %s\n', folderPath);
else
    files = arrayfun(@(x) fullfile(folderPath, x.name), files, 'UniformOutput', false);
    fprintf('Number of files found: %d\n', numel(files));

end
targetCov = 0.025;                 % 2.5% pre-filter coverage
threshVec = linspace(0,1,400);

thChosen = nan(size(files));

for f = 1:numel(files)
    data = load(files{f});
    img = double(data.screen.image);

    img = cropimg(img);
    imgNorm = mat2gray(img);

    imgSmooth = imgaussfilt(imgNorm, params.sigmaSmooth);
    imgContrast = imadjust(imgSmooth);

    covVec = zeros(size(threshVec));
    for i = 1:numel(threshVec)
        covVec(i) = nnz(imgContrast > threshVec(i)) / numel(imgContrast);
    end

    [~, idx] = min(abs(covVec - targetCov));
    thChosen(f) = threshVec(idx);

    fprintf('%s: thresh = %.4f (cov ≈ %.3f%%)\n', files{f}, thChosen(f), 100*covVec(idx));
end

meanThresh = mean(thChosen, 'omitnan');
stdThresh  = std(thChosen,  'omitnan');

fprintf('\nMEAN thresh over %d images: %.4f (std %.4f)\n', numel(files), meanThresh, stdThresh);

figure; plot(1:numel(files), thChosen, '-o'); grid on;
xlabel('image #'); ylabel('auto-chosen threshold'); title('Threshold per image');
yline(meanThresh,'--','Mean');
