clear all; clc; close all;


% load processed_surfElev_333.34.mat %02
% load processed_surfElev_416.68.mat %03
% load processed_surfElev_499.96.mat %04
% load processed_surfElev_583.30.mat %05
% load processed_surfElev_666.64.mat %06
% load processed_surfElev_749.98.mat %07
% load processed_surfElev_833.26.mat %08
% load processed_surfElev_916.60.mat %09
% load processed_surfElev_999.94.mat %10
 load processed_surfElev_1000.00.mat %01


 % Image to compare with
img = double(imread('screen_1024bins_0001_largest_warm_areas.jpg'));

Z = surfElev;
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

[XS, YS] = meshgrid( ...
    linspace(-pi, pi, 1024), ...
    linspace(-pi, pi, 1024) ...
);


mirrorOnScreen = interp2(X, Y, Z, XS, YS, "linear", 0);

mirrorXmin = -pi;
mirrorXmax =  pi;
mirrorYmin = -pi;
mirrorYmax =  pi;

mask = XS >= mirrorXmin & XS <= mirrorXmax & ...
       YS >= mirrorYmin & YS <= mirrorYmax;

%%
% --- fixed = mirror reference (make it 1024x1024 first)
mirrorFixed = mirrorOnScreen;          % 1024x1024 from your interp2 step

% --- moving = screen image
moving = double(imread('screen_1024bins_0001_largest_warm_areas.jpg'));
if ndims(moving)==3, moving = mean(moving,3); end   % grayscale if RGB

% Optional: normalize for display/robustness
fixedN  = mat2gray(mirrorFixed);
movingN = mat2gray(moving);

% Pick matching points (at least 3; 5–10 is better)
[movingPts, fixedPts] = cpselect(movingN, fixedN, 'Wait', true);

% Transform (usually enough if corners drift a bit)
tform = fitgeotrans(movingPts, fixedPts, 'similarity'); % or 'affine'

% Warp moving -> fixed grid, keeping -pi..pi as "world" axes
Rfixed = imref2d(size(fixedN), [-pi pi], [-pi pi]);
movingAligned = imwarp(movingN, tform, 'OutputView', Rfixed);

% Side-by-side in -pi..pi
x = linspace(-pi,pi,size(fixedN,2));
y = linspace(-pi,pi,size(fixedN,1));

figure;
subplot(1,3,1); imagesc(x,y,fixedN); axis image; set(gca,'YDir','normal'); title('Mirror (fixed)'); colorbar
subplot(1,3,2); imagesc(x,y,movingN); axis image; set(gca,'YDir','normal'); title('Screen (moving)'); colorbar
subplot(1,3,3); imagesc(x,y,movingAligned); axis image; set(gca,'YDir','normal'); title('Screen aligned'); colorbar

save('screen_to_mirror_tform.mat','tform');


