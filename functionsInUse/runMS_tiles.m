function out = runMS_tiles(X, Y, c)

fprintf('\nStarting runMS_tiles...\n\n');

caseName = c.input.caseName;
baseStackedDir = c.pp.baseStackedDir;

fileName = fullfile(baseStackedDir, caseName + "_meanCorr.csv");
fprintf('Opening CSV file: %s\n', fileName);

distTable = readtable(fileName);
distTags = string(distTable.DistanceTag);

% Surface files
surfFiles = dir(fullfile(c.input.surfElevDir, '*.mat'));
[~, ix] = sort({surfFiles.name});
surfFiles = surfFiles(ix);

fprintf('Found %d surface files in %s\n', numel(surfFiles), c.input.surfElevDir);

% Build curvature stack once from all surface files
fprintf('Building curvature stack...\n');
Hstack = build_curvature_stack(surfFiles, c.input.surfElevDir, X, Y);
MS_curv = MS_tiles(Hstack);

fprintf('Size of Hstack:  %s\n', mat2str(size(Hstack)));
fprintf('Size of MS_curv: %s\n', mat2str(size(MS_curv)));
disp('MS_curv =');
disp(MS_curv(:).');

CorrByDist = nan(numel(distTags), 1);
heightByDist   = nan(numel(distTags), 1);


for d = 1:numel(distTags)
    distTag = distTags(d);

    tok = regexp(distTag, 'D([0-9.]+)pi', 'tokens', 'once');
    heightByDist(d) = str2double(tok{1}) * pi;

    reflPath = fullfile(baseStackedDir, caseName + "_" + distTag + "_log.mat");
    fprintf('Reflection stack file: %s\n', reflPath);

    if ~isfile(reflPath)
        warning('No reflection file found for %s', distTag);
        continue;
    end

    R = load(reflPath);
    rfn = fieldnames(R);
    reflStack = R.(rfn{1});

    fprintf('Size of reflStack: %s\n', mat2str(size(reflStack)));

    MS_refl = MS_tiles(reflStack);

    fprintf('Size of MS_refl: %s\n', mat2str(size(MS_refl)));
    fprintf('numel(MS_refl) = %d\n', numel(MS_refl));
    fprintf('numel(MS_curv) = %d\n', numel(MS_curv));

    disp('MS_refl =');
    disp(MS_refl(:).');

    if numel(MS_refl) ~= numel(MS_curv)
        error('Length mismatch: MS_refl has %d elements, MS_curv has %d elements.', ...
            numel(MS_refl), numel(MS_curv));
    end

    CorrByDist(d) = corr(MS_refl(:), MS_curv(:), 'Rows', 'complete');
    distTable.Correlation(d) = CorrByDist(d);

    fprintf('%s: corr = %.6f\n', distTag, CorrByDist(d));


    % --- show raw vs processed for the very first file only ---
    figure('Name', sprintf('Raw vs Actual Surface Curvature (first image) - %s', distTag), 'Color', 'w');
    
    subplot(1,2,1);
    imagesc((reflStack(:,:,1)));
    axis image off;
    colormap(gca, 'gray');
    colorbar;
    title(sprintf('Reflection frame 1 - %s', distTag));
    
    subplot(1,2,2);
    imagesc(Hstack(:,:,1));
    axis image off;
    colormap(gca, 'gray');
    colorbar;
    title('Curvature frame 1');
    
    drawnow;
    
    
end

writetable(distTable, fileName);
fprintf('Correlations saved in %s\n', fileName);

hPi = heightByDist / pi;

figure;
plot(hPi, CorrByDist, '-o');
grid on;
xlabel('Height (multiples of \pi)');
ylabel('Correlation');
title('Correlation vs height');

out.CorrByDist = CorrByDist;
out.heightByDist   = heightByDist;
out.table          = distTable;

end

function Hstack = build_curvature_stack(surfFiles, surfDir, X, Y)

nSurf = numel(surfFiles);

for k = 1:nSurf
    surfPath = fullfile(surfDir, surfFiles(k).name);
    S = load(surfPath);

    Z = S.surfElev;

    if k == 1
        [ny, nx] = size(Z);
        Hstack = nan(ny, nx, nSurf, 'like', Z);
    end

    Z = rot90(Z, 2);
    [~, H, ~, ~] = surfature(X, Y, Z);
    Hstack(:,:,k) = H;
end

end