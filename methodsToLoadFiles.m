outDir = '\\sambaad.stud.ntnu.no\sverrsr\Documents\Project-Thesis\tenSampledSurfaces_bin'  %'\\sambaad.stud.ntnu.no\sverrsr\Documents\DNS_SCREENS_150k_dist3pi_fullSIM2';
snapshotDir = '\\sambaad.stud.ntnu.no\sverrsr\Documents\Project-Thesis\tenSampledSurfaces' %'//tsclient/E/DNS - RE2500WEinf';
snapshotFiles = dir(fullfile(snapshotDir, '*.mat'));  % get all mat files

if ~exist(outDir, 'dir')
    mkdir(outDir);
end


Nt = length(snapshotFiles);
fprintf('Found %d snapshot files.\n', Nt);

% --- Cool logging setup ---
tStart = tic;   % For ETA calculation
barLength = 30; % visual width of bar

for k = 1:Nt  % or however many surfaces you have

    % Load Z from mat file
    S = load(fullfile(snapshotDir, snapshotFiles(k).name));



%%
% Load the data
u = h5read('wave.h5', '/u');   % shape: [Ny, Nx, Nt]

load surfaceData1200.mat 
load surfMesh.mat


X = xMesh; Y = yMesh; %Z = surfaceData1200;
Nt = 200;

A = 50;

% Set up figure
figure
hSurf = surf(X, Y, u(:,:,1));
shading interp
colormap parula
axis tight
axis([min(X(:)) max(X(:)) min(Y(:)) max(Y(:)) -A A])
xlabel('x'); ylabel('y'); zlabel('Amplitude');

% Animate
for k = 1:Nt
    set(hSurf, 'ZData', u(:,:,k));
    title(sprintf('Frame %d / %d', k, Nt));
    % Set x limits
    zLimits = [-50, 50];
    zlim(zLimits);
    drawnow
end

end

%%
close all; clear all;

%GaussFiltVal = 0.5; %0.5 er bra med lim
%caxis([0, 4]);

% Create output folder
outDir = 'C:\Users\sverr\Documents\NTNU\Prosjekt\Blob\square_rays_finished';
inDir = 'C:\Users\sverr\Documents\NTNU\Prosjekt\Blob\square_rays_postProc';


vidName = 'blob.mp4';

% outDir = '\\sambaad.stud.ntnu.no\sverrsr\Documents\DNS_SCREENS_150k_dist3pi';
% inDir = '\\sambaad.stud.ntnu.no\sverrsr\Documents\DNS_SCREENS_150k_dist3pi';

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% AVI file:
%vidName = 'blurred_animation.avi'
%vidPath = fullfile(outDir, vidName);
%v = VideoWriter(vidPath);

% MP4 file:
vidPath = fullfile(outDir, vidName);
v = VideoWriter(vidPath, 'MPEG-4');


files = dir(fullfile(inDir, 'screen_*')); %.mat 
files = {files.name};
files = sort(files);

v.FrameRate = 20; % fps
open(v);

% --- Load first frame to initialize ---
data = load(fullfile(inDir, files{1}));
img = data.screen_image;

%img = imgaussfilt(img, GaussFiltVal);

% % --- Set up figure once ---
figure;
hImg = imagesc(img);
axis image;
set(gca, 'YDir', 'normal');
colormap(flipud(sky)); 
colorbar;
% 
% % Compute global limits across all frames
% minVal = inf; maxVal = -inf;
% 
% for k = 1:numel(files)
%     data = load(fullfile(inDir, files{k}));
%     img = data.screen_image;
%     minVal = min(minVal, min(img(:)));
%     maxVal = max(maxVal, max(img(:)));
% end
% 
% fprintf('Global intensity range: [%.3e, %.3e]\n', minVal, maxVal);
% 
% % adjust range to match your data
% % Must be adjusted to Gauss filtering. More gauss, lower axis
% 
% %caxis([minVal, maxVal]);
% colorbar; hold on;
% caxis([0, 4]);

%%
% --- Main animation loop ---
for k = 1:numel(files)
    data = load(fullfile(inDir, files{k}));

    img = data.screen_image;

    %img = imgaussfilt(img, GaussFiltVal);
    set(hImg, 'CData', img);  % update only the image data
    view(180,90)
    title(sprintf('Frame %d / %d', k, numel(files)));
    drawnow;
    hold on;

    originalFilename = files{k};
    frame = getframe(gcf);
    %writeVideo(v, frame);
    % Save each screen as a .png file

    % Optional blur
    
    img = imgaussfilt(img, 1.5);
    
    imwrite(img, fullfile(outDir, sprintf('screen_filtered_1.5_%03d_%s.png', k, originalFilename)));

end

close(v);
fprintf('Saved animation in: %s\n', vidPath);

%%
clear all; clc; close all;


outDir = 'C:\Users\sverr\Documents\NTNU\Prosjekt\Blob\square_rays_postProc';
inDir = 'C:\Users\sverr\Documents\NTNU\Prosjekt\Blob\square_rays';

if ~exist(outDir, 'dir'); mkdir(outDir); end

files = dir(fullfile(inDir, 'screen_*.mat'));
files = sort({files.name});

fprintf('Found %d screen files.\n', numel(files));


% USER PARAMETERS 
params.sigmaSmooth = 1;        % Gaussian smoothing, 2 seemed ok
params.thresh = 0.8;        % Gaussian smoothing, 2 seemed ok
params.invthresh   = 0.8;      % DoG high
params.areastokeep   = 100;        % DoG low

% pick a small threshold to ignore pure black and noise
thr = 1e-6;

% --- Main animation loop ---

for k = 1:numel(files)
    fileName = fullfile(inDir, files{k});

    data = load(fileName);

    img = double(data.screen_image);

    rows = find(any(img > thr, 2));
    cols = find(any(img > thr, 1));
    if isempty(rows) || isempty(cols)
        error('Image contains no values above threshold: %s', files{k});
    end

    r1 = rows(1); r2 = rows(end);
    c1 = cols(1); c2 = cols(end);
    imgCrop = img(r1:r2, c1:c2);

    imgSmooth = imgaussfilt(imgCrop, params.sigmaSmooth);

    screen_image = imgSmooth;

    % scale to [0,1] before imadjust if you're using doubles
    imgContrast = imadjust(mat2gray(imgSmooth));

    [~, baseName, ~] = fileparts(fileName);
    outFile = fullfile(outDir, [baseName '.mat']); % or [baseName '_smoothed.mat']

    save(outFile, 'screen_image');  % <-- only one variable saved
    fprintf('Saved: %s\n', outFile);
    
    % %% Connected Areas
    % X1 = imgContrast; %Setting it to bw can seem to make it better
    % 
    % %%%%%%%%%%%% CONNECTED AREAS ANALYSIS %%%%%%%%%%%%%%
    % % Provided by Simen Ådnøy Ellingsen
    % 
    % %Make binary images
    % X1w = X1*0 + (X1>params.thresh);       %For light-area
    % 
    % CC1w = bwconncomp(X1w);
    % 
    % areas1w = cell2mat(struct2cell(regionprops(CC1w,"Area")));
    % 
    % %Lists of sizes of areas
    % [Asz1,order1] = sort(areas1w,'descend');
    % n1 = length(order1); 
    % 
    % %Separate out the largest areas
    % bigidx1 = order1(1:params.areastokeep); 
    % smallidx1 = order1(params.areastokeep+1:n1); 
    % 
    % X1tBig = cc2bw(CC1w,ObjectsToKeep=bigidx1);
    % X1tSmall = cc2bw(CC1w,ObjectsToKeep=smallidx1);
    % 
    % 
    % % Save the binary image of the largest warm areas, X1tbig
    % [~, baseName, ~] = fileparts(fileName);
    % outImg = fullfile(outputFolder, baseName + "_largest_warm_areas.jpg");
    % 
    % % imwrite(X1tBig, outImg);
    % % fprintf('Saved: %s\n', outImg);
    % 
    % %% %%%%%%%%%%%% SAME FOR DARK AREAS %%%%%%%%%%%%%% 
    % X1b = X1*0 + (X1<params.invthresh);    %For dark-area analysis
    % 
    % CC1b = bwconncomp(X1b);
    % 
    % areas1b = cell2mat(struct2cell(regionprops(CC1b,"Area")));
    % 
    % [Asz1,order1] = sort(areas1b,'descend');

end

close(v);
fprintf('Saved post prosessecd screens in: %s\n', vidPath);
