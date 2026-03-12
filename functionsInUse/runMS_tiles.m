function out = runMS_tiles(X, Y, c)

fprintf('\nStarting runMS_tiles...\n\n');

caseName = c.input.caseName;
baseStackedDir = c.pp.baseStackedDir;

fileName = fullfile(baseStackedDir, caseName + "_meanCorr.csv");
fprintf('Opening CSV file: %s\n', fileName);

distTable = readtable(fileName);
distTags = string(distTable.DistanceTag);

% Grid only once
% [X, Y] = meshgrid( ...
%     single(linspace(-pi, pi, c.grid.nx)), ...
%     single(linspace(-pi, pi, c.grid.ny)) ...
% );

% Surface files only once
surfFiles = dir(fullfile(c.input.surfElevDir, '*.mat'));
[~, ix] = sort({surfFiles.name});
surfFiles = surfFiles(ix);

fprintf('Found %d surface files in %s\n', numel(surfFiles), c.input.surfElevDir);

meanCorrByDist = nan(numel(distTags), 1);
heightByDist   = nan(numel(distTags), 1);

for d = 1:numel(distTags)
    distTag = distTags(d);

    tok = regexp(distTag, 'D([0-9.]+)pi', 'tokens', 'once');
    heightByDist(d) = str2double(tok{1}) * pi;

    reflDir = fullfile(c.pp.baseStackedDir, caseName + "_raytraced_" + distTag);
    fprintf('Reflection stacks are found in %s\n', reflDir);

    reflFiles = dir(fullfile(reflDir, '*.mat'));
    [~, ir] = sort({reflFiles.name});
    reflFiles = reflFiles(ir);

    n = min(numel(surfFiles), numel(reflFiles));
    if n == 0
        warning('No files found for %s', distTag);
        continue;
    end

    corrVec = nan(n,1);

    fprintf('Calculating correlations for %s ...\n', distTag);

    for k = 1:n
        % --- load surface stack ---
        surfPath = fullfile(c.input.surfElevDir, surfFiles(k).name);
        S = load(surfPath);

        % assumes variable is S.surfElev with size [nx, ny, 5]
        Zstack = S.surfElev;

        % Compute curvature stack once
        Hstack = curvature_stack(Zstack, X, Y);

        % Mean square of curvature for each frame in this stack
        MS_curv = MS_tiles(Hstack);

        % --- load reflection stack ---
        reflPath = fullfile(reflDir, reflFiles(k).name);
        R = load(reflPath);
        reflPath = fullfile(reflDir, reflFiles(k).name);
        whos('-file', reflPath)
        reflStack = R.RE2500_WEINF;

        % If needed, regrid each frame
        reflStack = newgrid_stack(reflStack, c.grid.nx, c.grid.ny);

        % Mean square of reflection for each frame in this stack
        MS_refl = MS_tiles(reflStack);

        % Correlate the 5-frame vectors
        corrVec(k) = corr(MS_refl(:), MS_curv(:), 'Rows', 'complete');

        % Debug first stack only
        if k == 1
            figure('Name', sprintf('First stack debug - %s', distTag), 'Color', 'w');

            subplot(2,2,1);
            imagesc(reflStack(:,:,1)); axis image off;
            colormap(gca, 'gray'); colorbar;
            title('Reflection frame 1');

            subplot(2,2,2);
            imagesc(Hstack(:,:,1)); axis image off;
            colormap(gca, 'gray'); colorbar;
            title('Curvature frame 1');

            subplot(2,2,3);
            plot(1:numel(MS_refl), MS_refl, '-o');
            grid on;
            xlabel('Frame');
            ylabel('MS reflection');
            title('MS reflection per frame');

            subplot(2,2,4);
            plot(1:numel(MS_curv), MS_curv, '-o');
            grid on;
            xlabel('Frame');
            ylabel('MS curvature');
            title('MS curvature per frame');

            drawnow;
        end
    end

    meanCorrByDist(d) = mean(corrVec, 'omitnan');
    distTable.MeanCorrelation(d) = meanCorrByDist(d);

    fprintf('%s: mean corr = %.6f (n=%d)\n', distTag, meanCorrByDist(d), n);
end

writetable(distTable, fileName);
fprintf('Correlations saved in %s\n', fileName);

% Plot mean correlation vs height
hPi = heightByDist / pi;

figure;
plot(hPi, meanCorrByDist, '-o');
grid on;
xlabel('Height (multiples of \pi)');
ylabel('Mean correlation');
title('Mean correlation vs height');

out.meanCorrByDist = meanCorrByDist;
out.heightByDist   = heightByDist;
out.table          = distTable;

end

function Hstack = curvature_stack(Zstack, X, Y)
% Zstack: nx x ny x T
% X, Y  : nx x ny
% Hstack: nx x ny x T

[ny, nx, nt] = size(Zstack); %#ok<ASGLU>
Hstack = nan(size(Zstack), 'like', Zstack);

for t = 1:nt
    Z = rot90(Zstack(:,:,t), 2);
    [~, H, ~, ~] = surfature(X, Y, Z);
    Hstack(:,:,t) = H;
end
end