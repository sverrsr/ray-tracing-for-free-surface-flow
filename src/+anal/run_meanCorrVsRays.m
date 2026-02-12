function out = run_meanCorrVsRays(cfg)
clc;
fprintf('=== run_meanCorrVsRays START ===\n');

% ---- read csv ----
T = readtable(cfg.analysis.csvFile);
fprintf('[OK] CSV: %s (rows=%d)\n', cfg.analysis.csvFile, height(T));

names    = string(T.Name);
rayCount = T.RayCount;

% rows to process
if ischar(cfg.analysis.rowLoop) || isstring(cfg.analysis.rowLoop)
    idx = 1:height(T);
else
    idx = cfg.analysis.rowLoop;
end
fprintf('[INFO] Processing %d rows\n', numel(idx));

% ---- grid ----
nx = cfg.grid.nx; ny = cfg.grid.ny;
fprintf('[INFO] Grid: %dx%d\n', nx, ny);
[X,Y] = meshgrid(single(linspace(-pi,pi,nx)), single(linspace(-pi,pi,ny)));

% ---- surface files (HARDCODE PATTERN) ----
surfPattern = "processed_surfElev_*";
fprintf('[INFO] surfElevDir: %s\n', cfg.input.surfElevDir);
fprintf('[INFO] surf pattern: %s\n', surfPattern);

surfPattern = "processed_surfElev_*";
surfFiles = dir(fullfile(cfg.input.surfElevDir, surfPattern));
surfFiles = sortFilesByName(surfFiles);
fprintf('[OK] Found %d surface files\n', numel(surfFiles));
if isempty(surfFiles)
    error('No surface files found. Check cfg.input.surfElevDir and pattern %s', surfPattern);
end

% keep existing values unless overwritten
if ismember("MeanCorrelation", string(T.Properties.VariableNames))
    meanCorrByRow = T.MeanCorrelation;
else
    meanCorrByRow = nan(height(T),1);
end

% ---- main loop ----
for ii = 1:numel(idx)
    i = idx(ii);

    baseName = names(i);      % e.g. re2500_we10_raytraced_102400
    nRays    = rayCount(i);

    % HARDCODE folder mapping:
    % CSV says "..._raytraced_<n>", disk folder is "..._raytraced_filtered_<n>"
    folderName = strrep(baseName, "_raytraced_", "_raytraced_filtered_");
    rayDir = fullfile(cfg.input.imgBaseDir, folderName);

    fprintf('\n--- [%d/%d] nRays=%d ---\n', ii, numel(idx), nRays);
    fprintf('[INFO] CSV folder name: %s\n', baseName);
    fprintf('[INFO] Disk folder name: %s\n', folderName);
    fprintf('[INFO] rayDir: %s\n', rayDir);

    if ~isfolder(rayDir)
        warning('[SKIP] Folder not found: %s', rayDir);
        continue;
    end

    % images inside rayDir
    imgFiles = dir(fullfile(rayDir, '*.mat'));
    imgFiles = sortFilesByName(imgFiles);
    fprintf('[OK] Found %d image files\n', numel(imgFiles));

    n = min(numel(imgFiles), numel(surfFiles));
    fprintf('[INFO] Pairing n = %d (img=%d, surf=%d)\n', n, numel(imgFiles), numel(surfFiles));

    if n == 0
        warning('[SKIP] No pairs (check image files and surface files)');
        continue;
    end

    corrVec = nan(n,1);

    for k = 1:n
        if mod(k,50)==0 || k==1 || k==n
            fprintf('[INFO]   frame %d/%d\n', k, n);
        end

        imgPath  = fullfile(rayDir, imgFiles(k).name);
        surfPath = fullfile(cfg.input.surfElevDir, surfFiles(k).name);

        img = loadRayImage(imgPath, cfg.analysis.imgField, nx, ny);
        img = zscore2(img);

        H = loadCurvature(surfPath, X, Y, cfg.analysis.rotateSurf);
        H = zscore2(H);

        corrVec(k) = corr2(img, H);
    end

    meanCorrByRow(i) = mean(corrVec, 'omitnan');
    fprintf('[RESULT] %s (nRays=%d): mean corr = %.6f\n', baseName, nRays, meanCorrByRow(i));
end

% ---- save back to csv ----
T.MeanCorrelation = meanCorrByRow;

if cfg.analysis.saveCsv
    writetable(T, cfg.analysis.csvFile);
    fprintf('\n[OK] Saved updated CSV: %s\n', cfg.analysis.csvFile);
end

% ---- plot ----
if cfg.analysis.makePlot
    figure;
    semilogx(T.RayCount, T.MeanCorrelation, '-o');
    grid on;
    xlabel('Number of rays');
    ylabel('Mean corr2 (image vs curvature)');
    title(cfg.input.caseName + " mean correlation vs rays");
end

out.table = T;
fprintf('=== run_meanCorrVsRays END ===\n');
end

% ================= helpers =================

function files = sortFilesByName(files)
if isempty(files), return; end
[~,ix] = sort({files.name});
files = files(ix);
end

function A = zscore2(A)
mu = mean(A(:),'omitnan');
sg = std(A(:),'omitnan');
A = A - mu;
if sg > 0 && ~isnan(sg)
    A = A / sg;
end
end

function img = loadRayImage(path, imgField, nx, ny)
S = load(path);
switch string(imgField)
    case "img"
        img = double(S.img);
    case "screen.image"
        img = double(S.screen.image);
    otherwise
        error("Unknown imgField: %s", imgField);
end
img = newgrid(img, nx, ny);
end

function H = loadCurvature(path, X, Y, doRotate)
T = load(path);                 % works even if file has no .mat extension
Z = T.surfElev;
if doRotate
    Z = rot90(Z,2);
end
[~,H,~,~] = surfature(X,Y,Z);
end
