clear all; %close all;


%%

% Jeg henter inspirasjon fra curvature_reflection_analysis_loop for å lage en ny loop 10/12/2025

% Two images to compare
filteredDir      = 'D:\DNS\re2500_weInf\re2500_weInf_surfElev_first2089_B1024_filtered\re2500_weInf_surfElev_first2089_B1024_filtered_D3pi';
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

    %cc = normxcorr2(smoothp, Hp);
    cc = corr2(smoothp, Hp);
    meanCorr(k) = cc;
    disp(meanCorr(k))

end

meanOfAll = mean(meanCorr);
fprintf('Mean of all correlations: %.6f\n', meanOfAll);