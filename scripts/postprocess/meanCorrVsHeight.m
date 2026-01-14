    clear; clc; close all;
    
    % Blir brukt til å kjøre gjennom alle distanser for å finne korrleasjon
    
    % Distances (heights)
    S = load("distTags.mat");
    
    % To edit
    distTags = string(S.distTags.dns_re2500_we20{:,1})
    % Folders
    baseFilteredDir = 'D:\DNS\re2500_we20\re2500_we20_rayTrace_filtered';
    surfElevDir     = 'D:\DNS\re2500_we20\re2500_we20_surfElev';
    filteredPrefix  = 're2500_we20_raytrace_filtered_'; %remove distance only _{distance}
    
    % Grid (once)
    nx = 256; ny = 256;
    [X,Y] = meshgrid(single(linspace(-pi,pi,nx)), single(linspace(-pi,pi,ny)));
    
    % Surf files (once)
    surfFiles = dir(fullfile(surfElevDir,'*.mat'));
    surfBase  = erase(string({surfFiles.name}), ".mat");
    
    meanCorrByDist = nan(numel(distTags),1);
    heightByDist   = nan(numel(distTags),1);
    
    S.distTags.dns_re2500_we20{:,2} = nan(height(S.distTags.dns_re2500_we20),1);
    
    for d = 1:numel(distTags)
        distTag = distTags{d};
    
        tok = regexp(distTag,'D([0-9.]+)pi','tokens','once');
        heightByDist(d) = str2double(tok{1}) * pi;   % "height" in radians
    
        filteredDir = fullfile(baseFilteredDir, [filteredPrefix distTag]);
    
        surfFiles = dir(fullfile(surfElevDir,'*.mat'));
        filtFiles = dir(fullfile(filteredDir,'*.mat'));
        
        % Sort both by name to ensure consistent order
        [~,is] = sort({surfFiles.name});
        surfFiles = surfFiles(is);
        
        [~,iflt] = sort({filtFiles.name});
        filtFiles = filtFiles(iflt);
        
        n = min(numel(surfFiles), numel(filtFiles));
        if n == 0
            warning('No files found for %s', distTag);
            continue;
        end
        
        corrVec = zeros(n,1);
    
    
        for k = 1:n
            % --- filtered image ---
            A = load(fullfile(filteredDir, filtFiles(k).name));
            img = double(A.img);
            img = newgrid(img, nx, ny);
            img = (img - mean(img(:))) / std(img(:));
        
            % --- curvature ---
            T = load(fullfile(surfElevDir, surfFiles(k).name));
            Z = rot90(T.surfElev, 2);
            [~,H,~,~] = surfature(X,Y,Z);
            H = (H - mean(H(:))) / std(H(:));
        
            % --- correlation (no shift) ---
            corrVec(k) = corr2(img, H);
        end
    
    
        meanCorrByDist(d) = mean(corrVec, 'omitnan');
    
        % --- write back into table row d, column 2 ---
        S.distTags.dns_re2500_we20{d,2} = meanCorrByDist(d);
    
        fprintf('%s: mean corr = %.6f (n=%d)\n', distTag, meanCorrByDist(d), n);
    end
    
    % Plot mean correlation vs height
    valid = ~isnan(meanCorrByDist);
    hPi = heightByDist/pi;
    
    figure;
    plot(hPi(valid), meanCorrByDist(valid), '-o');
    grid on;
    xlabel('Height (multiples of \pi)');
    ylabel('Mean corr2 (filtered vs curvature)');
    title('Mean correlation vs height');

