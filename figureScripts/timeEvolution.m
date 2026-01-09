clear; close all; clc;

filteredDir = 'D:\DNS\re2500_weInf\re2500_weInf_surfElev_first2089_B1024_filtered\re2500_weInf_surfElev_first2089_B1024_filtered_D3pi';
surfElevDir = 'D:\DNS\re2500_weInf\re2500_weInf_surfElev_first2089_B1024';

% List files + sort to keep pairing consistent
filteredFiles = dir(fullfile(filteredDir, '*.mat'));
surfElevFiles = dir(fullfile(surfElevDir, '*.mat'));

filteredNames = sort(string({filteredFiles.name}));
surfNames     = sort(string({surfElevFiles.name}));

n = min(numel(filteredNames), numel(surfNames));
if n == 0
    error('No .mat files found in one (or both) folders.');
end

% Grid (once)
nx = 256; ny = 256;
[X, Y] = meshgrid(single(linspace(-pi, pi, nx)), single(linspace(-pi, pi, ny)));

% How many frames to include
include = 1000;

% Storage (RELATIVE areas)
relAreaFilt = zeros(include,1);
relAreaCurv = zeros(include,1);

for k = 1:include
    filteredPath = fullfile(filteredDir, filteredNames(k));
    surfElevPath = fullfile(surfElevDir, surfNames(k));

    % --- Filtered image ---
    S = load(filteredPath);
    filtImg = newgrid(double(S.img), nx, ny);

    % smooth  = imadjust(imgaussfilt(filtImg, 2));
    % smoothp = smooth - mean(smooth(:));

    smooth = filtImg;
    smoothp = smooth - mean(smooth(:));

    % Relative area > 0
    BWf = smoothp > 0;
    relAreaFilt(k) = sum(BWf(:)) / numel(BWf);

    % --- Curvature ---
    T = load(surfElevPath);
    Z = rot90(T.surfElev, 2);

    [~, H, ~, ~] = surfature(X, Y, Z);
    Hp = H - mean(H(:));

    % Relative area where curvature > 0
    BWc = Hp > 0;
    %relAreaCurv(k) = mean(abs(H(:)));
    relAreaCurv(k) = sqrt(mean(Hp(:).^2));
    % relAreaCurv(k) = sum(BWc(:)) / numel(BWc);
end

% --- Plot with two y-axes ---
figure;

yyaxis left
plot(1:include, relAreaFilt, '-o');
ylabel('Filtered: Relative area (> 0)');

yyaxis right
plot(1:include, relAreaCurv, '-o');
ylabel('Curvature: Relative area (> 1)');

grid on;
xlabel('File index (sorted order)');
title('Relative area: filtered vs curvature');
legend('Filtered (>0)', 'Curvature (>1)', 'Location', 'best');
