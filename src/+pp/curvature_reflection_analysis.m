clear all; clc; close all;


% load processed_surfElev_333.34.mat %02
% load processed_surfElev_416.68.mat %03
 load processed_surfElev_499.96.mat %04
% load processed_surfElev_583.30.mat %05
% load processed_surfElev_666.64.mat %06
% load processed_surfElev_749.98.mat %07
% load processed_surfElev_833.26.mat %08
% load processed_surfElev_916.60.mat %09
% load processed_surfElev_999.94.mat %10
% load processed_surfElev_1000.00.mat %01

%% Loading Surface
Z = surfElev;
Z = rot90(Z, 2); %Rotate Z so it aligns with reflection

clear surfElev;

nx = 256;
ny = 256;
nt = 12500;

dx = 2 * pi / nx;
dy = 2 * pi / ny;

dt = 0.06;

lx = 2 * pi;
ly = 2 * pi;

nu = 1 / 2500;
overflatespenning = 0;
g = 10;

% Create a new mesh grid based on the specified dimensions
% Mesh from -pi to pi
[X, Y] = meshgrid( ...
    single(linspace(-pi, pi, nx)), ...
    single(linspace(-pi, pi, ny)) ...
);

figure;
imagescStdSurf(X, Y, Z, 'Surface Elevation');

%% Loading Reflection Image
% Image to compare with
img = im2double(imread('screen_1024bins_0004_largest_warm_areas.jpg'));

smoothedImg = imgaussfilt(img, 3);
img = smoothedImg

% Build source coordinates based on the *actual* image size
[imgNy, imgNx] = size(img);
xS = linspace(-pi, pi, imgNx);   % columns
yS = linspace(-pi, pi, imgNy);   % rows

% Resample image onto the 256x256 grid
reflectionToBase = interp2(xS, yS, img, X, Y, 'linear', 0);

figure;
imagescStdBW(X, Y, reflectionToBase, 'Reflection mapped to base grid');

%%
figure;

subplot(1,2,1);
imagescStdSurf(X, Y, Z, 'Surface Elevation');

subplot(1,2,2);
imagescStdBW(X, Y, reflectionToBase, 'Reflection mapped to base grid');

%%
% Curvature
[K,H,Pmax,Pmin] = curvature(X,Y,Z);

% Find correlation of H and surface elevation
R_H = corr(H(:), Z(:), 'rows', 'complete');

%%
figure;
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

nexttile;
imagesc(Z); axis image; colormap turbo; colorbar;
title('Z (høyde)');

nexttile;
imagesc(H); axis image; colormap turbo; colorbar;
title('H (kurvatur)');

%% Correlation between image and surface elevation
M = reflectionToBase;      % mask after resize
Z0 = Z(:);

% no flip
c_noflip = corr(M(:), Z0, 'rows','complete');

%% Statistics
% Convert reflection image to normalized grayscale for thresholding
M = mat2gray(reflectionToBase);
% Create binary mask using automatic global threshold
mask = imbinarize(M, graythresh(M));   % automatic threshold
% Remove small objects (noise) smaller than 20 pixels
mask = bwareaopen(mask, 20);
% Fill holes to produce solid foreground regions
mask = imfill(mask, 'holes');

H_scar = H(mask);           % curvature values on scars (mask)
H_bg   = H(~mask);          % curvature values off scars (mask)

figure;
histogram(H_scar); hold on;
histogram(H_bg);
legend('scar','background');
title('Mean curvature distribution');

figure;
boxplot([H_scar; H_bg], [ones(size(H_scar)); 2*ones(size(H_bg))])
%set(gca,'XTickLabel',{'scar','background'})
ylabel('Mean curvature');

mean_H_scar = mean(H_scar);
mean_H_bg   = mean(H_bg);
std_H_scar  = std(H_scar);
std_H_bg    = std(H_bg);

[~,p] = ttest2(H_scar, H_bg);    % two-sample t-test
d = (mean(H_scar) - mean(H_bg)) / sqrt( (std(H_scar)^2 + std(H_bg)^2)/2 );

scar_indicator = double(mask(:));   % 1 = scar, 0 = no scar
H_flat = H(:);

R = corr(scar_indicator, H_flat);   % Pearson correlation

figure;
imagesc(H); axis image; colorbar; hold on;
contour(mask, [0.5 0.5], 'w', 'LineWidth', 1);   % white contour of scars
title('Mean curvature with scar locations');


function imagescStdSurf(X, Y, Z, ttl)
    imagesc(X(1,:), Y(:,1), Z);
    title(ttl);
    axis image;
    colormap(gca, "turbo");
    colorbar;
    xlabel('X'); ylabel('Y');
end

function imagescStdBW(X, Y, Z, ttl)
    imagesc(X(1,:), Y(:,1), Z);
    title(ttl);
    axis image;
    colormap(gca, "gray");
    colorbar;
    xlabel('X'); ylabel('Y');
end


% Nice pi ticks
% xticks()
% xticklabels({'-\pi','-\pi/2','0','\pi/2','\pi'})
% 
% yticks([-pi -pi/2 0 pi/2 pi])
% yticklabels({'-\pi','-\pi/2','0','\pi/2','\pi'})

% axis image;
% colormap(jet);
% colorbar;
% title('Surface Elevation');
% xlabel('X');
% ylabel('Y');
