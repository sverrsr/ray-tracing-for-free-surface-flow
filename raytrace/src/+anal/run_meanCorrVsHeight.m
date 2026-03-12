function out = run_meanCorrVsHeight(c)

fprintf('\nStarting meanCorrVsHeight function...\n');
fprintf('\n');


caseName = c.input.caseName;
baseStackedDir  = c.pp.baseStackedDir;

% Distances (heights)

%fileName = caseName + "_meanCorr.csv";

%fileName = fullfile(baseStackedDir, caseTag + "_meanCorr.csv");
fileName = fullfile(baseStackedDir, caseName + "_meanCorr.csv");


fprintf('Opening CSV file: %s\n', fileName);
distTable = readtable(fileName);
distTags = string(distTable.DistanceTag);


% grid once
[X,Y] = meshgrid(single(linspace(-pi,pi,c.grid.nx)), single(linspace(-pi,pi,c.grid.ny)));
fprintf('Creating mesh grid...\n');

% surf files once + sort once
surfFiles = dir(fullfile(c.input.surfElevDir,'*.mat'));
[~,ix] = sort({surfFiles.name});
surfFiles = surfFiles(ix);

fprintf('Found %d surface elevation files in %s\n', numel(surfFiles), c.input.surfElevDir);


meanCorrByDist = nan(numel(distTags),1);
heightByDist   = nan(numel(distTags),1);

% First loop through heights
for d = 1:numel(distTags)
    distTag = distTags(d);

    tok = regexp(distTag,'D([0-9.]+)pi','tokens','once');
    heightByDist(d) = str2double(tok{1}) * pi;   % "height" in radians

    % filteredDir = fullfile( ...
    %     c.pp.baseFilteredDir, ...
    %     caseName + "_raytrace_filtered_" + distTag ...
    % );
    % example: re1000_we10_raytrace_filtered_D8.00pi

    filteredDir = fullfile(c.pp.baseRayTraceDir, caseName + "_raytraced_" + distTag);

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
    

    fprintf('Calculating correlation ...');

    % Second loop through all frames
    for k = 1:n
        % --- filtered image ---
        filteredImagePath = fullfile(filteredDir, filtFiles(k).name);
        A = load(filteredImagePath);
        % img = double(A.img);
        img = A.screen.image;
        img = newgrid(img, c.grid.nx, c.grid.ny);
        % img = (img - mean(img(:))) / std(img(:));

        % --- curvature ---
        curvaturePath = fullfile(c.input.surfElevDir, surfFiles(k).name);
        T = load(curvaturePath);
        Z = rot90(T.surfElev, 2);
        [~,H,~,~] = surfature(X,Y,Z);
        % H = (H - mean(H(:))) / std(H(:));

        % mean square of image
        imgMS(k) = mean(img(:).^2);
        % mean square of curvature
        HMS(k) = mean(H(:).^2);


        % Calculate Mean square of image and H



                % --- DEBUG: show raw vs processed for the very first file only ---
        if  k == 1
            figure('Name', sprintf('Raw vs Actual Surface Curvature (first image) - %s', distTag), 'Color', 'w');
            
            subplot(1,2,1);
            imagesc(img); axis image off;
            colormap(gca,'gray'); colorbar;
            title('Raw');
        
            subplot(1,2,2);
            imagesc(H); axis image off;
            colormap(gca,'gray'); colorbar;
            title('Surface Curvature');
        
            drawnow;  % force display update
        end
    end

    % meanCorrByDist(d) = mean(corrVec, 'omitnan'); % omnitan ignores nan
    meanCorrByDist(d) = corr(imgMS(:), HMS(:), 'Rows','complete');

    distTable.MeanCorrelation(d) = meanCorrByDist(d);
    
    fprintf('%s: mean corr = %.6f (n=%d)\n', distTag, meanCorrByDist(d), n);
end

writetable(distTable, fileName)
fprintf('Correlations saved in table S and the file %s\n', fileName);

% Plot mean correlation vs height
hPi = heightByDist/pi;

figure;
plot(hPi, meanCorrByDist, '-o');
grid on;
xlabel('Height (multiples of \pi)');
ylabel('Mean corr2 (filtered vs curvature)');
title('Mean correlation vs height');