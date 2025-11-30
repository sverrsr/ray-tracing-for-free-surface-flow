clear all; clc; close all;

%fileName = 'screen_1024bins_0001.mat';   % <--- change to any file you want
% fileName = 'screen_1024bins_0002.mat';
% fileName = 'screen_1024bins_0003.mat';
 fileName = 'screen_1024bins_0004.mat';
% fileName = 'screen_1024bins_0005.mat';
% fileName = 'screen_1024bins_0006.mat';
% fileName = 'screen_1024bins_0007.mat';
% fileName = 'screen_1024bins_0008.mat';
% fileName = 'screen_1024bins_0009.mat';
% fileName = 'screen_1024bins_0010.mat';

% Create a new folder to save processed files
outputFolder = fullfile('C:\Users\sverr\Documents\NTNU\Prosjekt\Project-Thesis', 'tenSampledSurfaces_smoothed_filtered');

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
    fprintf('Created folder: %s\n', outputFolder);
end

%% USER PARAMETERS

%Set threshhold between 0 (black) and 1 (white)

params.sigmaSmooth = 4;        % Gaussian smoothing, 2 seemed ok
params.thresh = 0.8;        % Gaussian smoothing, 2 seemed ok
params.invthresh   = 0.8;      % DoG high
params.areastokeep   = 100;        % DoG low

%% LOAD IMAGE
data = load(fileName);
img = double(data.screen.image);

% img is your 1024x1024 double image

% pick a small threshold to ignore pure black and noise
thr = 1e-6;

% find all rows that contain something above threshold
rows = find(any(img > thr, 2));

% find all columns that contain something above threshold
cols = find(any(img > thr, 1));

% if nothing found, avoid crash
if isempty(rows) || isempty(cols)
    error('Image contains no values above threshold.');
end

% compute bounding box
r1 = rows(1);
r2 = rows(end);
c1 = cols(1);
c2 = cols(end);

% crop the image
img = img(r1:r2, c1:c2);

% show the result
figure;
imshow(img, []);
title('Cropped Image');


%% STEP 1 — SMOOTH
imgSmooth = imgaussfilt(img, params.sigmaSmooth);

%% SHOW SMOOTHED IMAGE
figure;
imagesc(imgSmooth); axis image off; colormap gray;
title('Smoothing Result');

%% STEP 1.5 — INCREASE CONTRAST
imgContrast = imadjust(imgSmooth);


%% SHOW CONTRAST ENHANCED IMAGE
figure;
imagesc(imgContrast); axis image off; colormap gray;
title('Contrast Enhanced Result');

%% SAVE SMOOTHED IMAGE
%imwrite(uint8(imgSmooth), 'screen_1024bins_0002_smoothed.jpg');
[~, baseName, ~] = fileparts(fileName);   % baseName = "screen_1024bins_0002"
outFile = fullfile(outputFolder, baseName + "_smoothed.mat");


%% Connected Areas
X1 = imgContrast; %Setting it to bw can seem to make it better

%%%%%%%%%%%% CONNECTED AREAS ANALYSIS %%%%%%%%%%%%%%
% Provided by Simen Ådnøy Ellingsen

%Make binary images
X1w = X1*0 + (X1>params.thresh);       %For light-area

CC1w = bwconncomp(X1w);

areas1w = cell2mat(struct2cell(regionprops(CC1w,"Area")));

%Lists of sizes of areas
[Asz1,order1] = sort(areas1w,'descend');
n1 = length(order1); 


%Separate out the largest areas
bigidx1 = order1(1:params.areastokeep); 
smallidx1 = order1(params.areastokeep+1:n1); 

X1tBig = cc2bw(CC1w,ObjectsToKeep=bigidx1);
X1tSmall = cc2bw(CC1w,ObjectsToKeep=smallidx1);


f=figure;
%set(f,"Position",[ 133         549        1594         730])
colormap gray
 
t=tiledlayout(2,2,'Padding','compact','TileSpacing','compact');
nexttile, imagesc(X1), axis image off,title('Original');

nexttile, imagesc(X1w), axis image off,title(sprintf('Threshold: %d',params.thresh));

nexttile, imagesc(X1tBig), axis image off, title(sprintf('Threshold: %d, Only %d largest warm areas',params.thresh,params.areastokeep));

nexttile, imagesc(X1tSmall), axis image off, title(sprintf('Threshold: %d, Without %d largest warm areas',params.thresh,params.areastokeep));


% Save the binary image of the largest warm areas, X1tbig
[~, baseName, ~] = fileparts(fileName);
outImg = fullfile(outputFolder, baseName + "_largest_warm_areas.jpg");

imwrite(X1tBig, outImg);
fprintf('Saved: %s\n', outImg);

%% %%%%%%%%%%%% SAME FOR DARK AREAS %%%%%%%%%%%%%% 
X1b = X1*0 + (X1<params.invthresh);    %For dark-area analysis

CC1b = bwconncomp(X1b);

areas1b = cell2mat(struct2cell(regionprops(CC1b,"Area")));

[Asz1,order1] = sort(areas1b,'descend');

figure

semilogy(1:length(Asz1), Asz1)
ylim([5 max([Asz1(1)])])
title('Area sizes, hot areas areas');
ylabel('Area (pixels)');
xlabel('Area index');

figure

semilogy(1:length(Asz1),Asz1)
ylim([5 max([Asz1(1)])])
title('Area sizes, cold areas');
ylabel('Area (pixels)');
xlabel('Area index');

%Just the largest areas
n1 = length(order1);
bigidx1 = order1(1:n1); 
X1tBig = cc2bw(CC1b,ObjectsToKeep=bigidx1);

f=figure;
%set(f,"Position",[ 183         349        1594         620])
colormap gray
 
t=tiledlayout(3,2,'Padding','compact','TileSpacing','compact');
nexttile, imagesc(X1), axis image off,title('Original');
nexttile, imagesc(1-X1b), axis image off,title(sprintf('Threshold: %d',params.invthresh));
nexttile, imagesc(1-X1tBig), axis image off, title(sprintf('Threshold: %d, Only %d largest cold areas',params.invthresh,params.areastokeep));

