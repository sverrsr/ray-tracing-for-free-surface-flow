clear all; clc; close all;

distance = 3*pi;

outputFolder = 'D:\CorrelationAnalysis_finished\RayTrace_500SAMPLED_B1024_D3pi';

rayDir      = 'D:\CorrelationAnalysis_connected\RayTrace_500SAMPLED_B1024_D3pi';


surfDir      = 'D:\CorrelationAnalysis_rayTrace\DNS_500SAMPLED';

if ~exist(outputFolder,'dir'); mkdir(outputFolder); end

rayFiles = dir(fullfile(rayDir, '*_largest_warm_areas.jpg'));
surfFiles = dir(fullfile(surfDir, '*.mat'));

rayNames = sort(string({rayFiles.name}));
surfNames = sort(string({surfFiles.name}));

assert(numel(rayNames) == numel(surfNames), ...
    "Different counts: %d rays vs %d surfaces", numel(rayNames), numel(surfNames));

% grid (make once)
nx = 256; ny = 256;
[X, Y] = meshgrid(single(linspace(-pi, pi, nx)), single(linspace(-pi, pi, ny)));

fprintf('Found %f files', numel(rayNames))

for k = 1:numel(rayNames)
    rayPath = fullfile(rayDir, rayNames(k));
    surfPath = fullfile(surfDir, surfNames(k));

    % Convert Z to double if not already
    S = load(surfPath);  % surfPath is string filename
    Z = S.surfElev;       % or whatever variable the mat file contains
    Z = im2double(Z);
    Z = rot90(Z, 2); %Rotate Z so it aligns with reflection

    % --- load ray image (jpg) ---
    rayImg = im2double(imread(rayPath));

    % Build source coordinates based on the *actual* image size
    [imgNy, imgNx] = size(rayImg);
    xS = linspace(-pi, pi, imgNx);   % columns
    yS = linspace(-pi, pi, imgNy);   % rows

    % Find surface curvature
    [~,H,~,~] = surfature(X,Y,Z);
    
    % Resample image onto the 256x256 grid
    reflectionToBase = interp2(xS, yS, rayImg, X, Y, 'linear', 0);
    rayImg = reflectionToBase;

    % Convert Z to double if not already
    %H = im2double(H);
    
    % Compute correlation
    % pos = H > 0;
    % Rpos(k) = corr(H(pos), rayImg(pos), 'rows','complete');

    T = prctile(H(:), 95);   % Top 5&
    pos = H > T;            % logical pos

    % Set the top 30% of curvature to 1
    Hbin = zeros(size(H));     % Less is set to 0
    Hbin(pos) = 1;            % Set all remaining to 1

    Rpos(k) = corr(Hbin(:), rayImg(:), 'rows','complete');

    
    fprintf('corr2 similarity between MAT-surface and JPG-image: %.4f\n', Rpos(k));


    Hpos = nan(size(H));   % keeps the 256x256 shape
    Hpos(pos) = H(pos);    % fill only the top 30%
    
    % % Plot H and rayImg next to each other in tiles
    % figure;
    % tiledlayout(1, 2); % Create a 1x2 tiled layout
    % 
    % % Plot H
    % nexttile;
    % imagesc(X(1,:), Y(:,1), Hbin); % Display H
    % axis equal tight;
    % title('Surface Curvature (H)');
    % xlabel('X-axis');
    % ylabel('Y-axis');
    % colormap(flipud("sky"))
    % colorbar;
    % 
    % % Plot rayImg
    % nexttile;
    % imagesc(X(1,:), Y(:,1), rayImg); % Display rayImg
    % axis equal tight;
    % title('Ray Image');
    % xlabel('X-axis');
    % ylabel('Y-axis');
    % colormap(flipud("sky"))
    % colorbar;
    % 
    % sgtitle(sprintf('Comparison of Surface Curvature and Ray Image. Correlation: %f', Rpos(k)), 'FontSize', 16);
    
    if k == 250
        figure;
        imagesc(X(1,:), Y(:,1), Hbin); axis image off; colormap gray;
        title(sprintf('Curvature'));
    end

    if k == 250
        figure;
        imagesc(X(1,:), Y(:,1), rayImg); axis image off; colormap gray;
        title(sprintf('Most intense areas'));
    end
    
    if k == 250
        figure;
        tiledlayout(1, 2); % Create a 1x2 tiled layout
    
        % Plot H
        nexttile;
        imagesc(X(1,:), Y(:,1), Hbin); % Display H
        axis equal tight;
        title(sprintf('Surface Curvature (H) - Image %d', k));
        xlabel('X-axis');
        ylabel('Y-axis');
        colormap(flipud("sky"))
        colorbar;
    
        % Plot rayImg
        nexttile;
        imagesc(X(1,:), Y(:,1), rayImg); % Display rayImg
        axis equal tight;
        title(sprintf('Ray Image - Image %d', k));
        xlabel('X-axis');
        ylabel('Y-axis');
        colormap(flipud("sky"))
        colorbar;
    
        sgtitle(sprintf('Comparison of Surface Curvature and Ray Image for Image %d. Correlation: %f', k, Rpos(k)), 'FontSize', 16);
    end
    

end

meanRpos = mean(Rpos);
fprintf('Mean positive correlation (Rpos): %.4f\n', meanRpos);

% Save the mean correlation value and distance into a CSV file in the main working directory

M = [distance, meanRpos];  % Convert distance from string to double

writematrix(M,'corr_dist.txt','WriteMode','append')
