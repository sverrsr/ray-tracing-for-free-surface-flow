%% -------------------------------------------------------------------------
%  Memory-efficient combined 3D animation (wave + ray tracing)
%  Wave frames:   waveDir\u_00001.mat  (variable U)
%  Ray frames:    inDirRT\screen_*.mat (variable screen_image)
% -------------------------------------------------------------------------

clear all; clc; close all;

%% --- Paths ---
inDirRT   = 'C:\Users\sverr\Documents\NTNU\Prosjekt\Blob\square_rays_postProc';
waveDir   = 'C:\Users\sverr\Documents\NTNU\Prosjekt\Blob\bloMatFiles';  % <-- your screenshot folder

%% --- Settings ---
Zoffset      = 35;
smoothSigma  = 0.0;
alphaWave    = 1;
downsample   = 1;      % must match whatever you used when generating the wave MAT files

%% --- List wave frames ---
waveFiles = dir(fullfile(waveDir, 'u_*.mat'));
waveFiles = sort({waveFiles.name});
Nt_wave   = numel(waveFiles);
if Nt_wave == 0
    error('No wave frames found in %s', waveDir);
end

%% --- Determine mesh size from the FIRST wave frame ---
S0 = load(fullfile(waveDir, waveFiles{1}));   % contains U
U0 = S0.U;

% Downsample if needed
if downsample > 1
    U0 = U0(1:downsample:end, 1:downsample:end);
end

[Ny, Nx] = size(U0);

% Build mesh: SAME DOMAIN YOU USED FOR THE CFD SURFACE
xmin = -pi;  xmax = pi;
ymin = -pi;  ymax = pi;

[X, Y] = meshgrid( linspace(xmin, xmax, Nx), ...
                   linspace(ymin, ymax, Ny) );

X = single(X); Y = single(Y);

%% --- Ray frame list ---
rtFiles = dir(fullfile(inDirRT, 'screen_*.mat'));
rtFiles = sort({rtFiles.name});
Nt_rt = numel(rtFiles);

Nt = min(Nt_wave, Nt_rt);

%% --- Colormap stacking ---
cmapWave = parula(256);
cmapImg  = gray(256);
colormap([cmapWave; cmapImg]);
caxis([0 2]);

%% --- FIGURE ---
figure('Color','w'); hold on;
view(35, 15);
axis tight;
xlabel('y'); ylabel('z'); zlabel('x');

% Set ticks at meaningful points
set(gca, 'XTick', [-pi 0 pi]);
set(gca, 'YTick', [-pi 0 pi]);
set(gca, 'ZTick', [ 0  35]);

% Optional custom labels
set(gca, 'XTickLabel', {'-π','0','π'});
set(gca, 'YTickLabel', {'-π','0','π'});
set(gca, 'ZTickLabel', {'0','3π'});

%% --- VIDEO SETUP ---
saveVideo = true;                 % set false to disable
videoName = 'combined_wave_rays_v2.mp4';
videoPath = fullfile(pwd, videoName);

if saveVideo
    v = VideoWriter(videoPath, 'MPEG-4');
    v.FrameRate = 15;             % adjust if needed
    open(v);
end

%% --- Helper: load wave frame k ---
loadWave = @(k) single( load(fullfile(waveDir, waveFiles{k}), 'U').U );

%% --- Initial wave frame ---
waveK = loadWave(1);
if downsample > 1
    waveK = waveK(1:downsample:end, 1:downsample:end);
end

% Normalize wave to [0,1]
wmin = min(waveK(:)); wmax = max(waveK(:));
waveC = (waveK - wmin) ./ max(1e-12, wmax - wmin);

%% --- Initial ray frame ---
D0 = load(fullfile(inDirRT, rtFiles{1}));
img0 = double(D0.screen_image);

if smoothSigma > 0
    img0 = imgaussfilt(img0, smoothSigma);
end

[imgNy, imgNx] = size(img0);
xS = linspace(xmin, xmax, imgNx);
yS = linspace(ymin, ymax, imgNy);

imgBase0 = interp2(xS, yS, img0, X, Y, 'linear', 0);

imin = min(imgBase0(:)); imax = max(imgBase0(:));
imgC = (imgBase0 - imin) ./ max(1e-12, imax - imin);
imgC = imgC + 1;   % maps to gray colormap

%% --- Draw initial ---
hWave = surf(X, Y, waveK, ...
    'EdgeColor','none', ...
    'FaceAlpha', alphaWave, ...
    'CData', waveC);

hImg = surface(X, Y, Zoffset*ones(size(X), 'like', X), ...
    'CData', imgC, ...
    'EdgeColor','none', ...
    'FaceColor','interp');

zlim([-20 45]);   % example values – adjust as needed
drawnow;

%% --- Animation loop ---
for k = 1:Nt

    %% ---- Update wave ----
    waveK = loadWave(k);
    if downsample > 1
        waveK = waveK(1:downsample:end, 1:downsample:end);
    end

    wmin = min(waveK(:)); wmax = max(waveK(:));
    waveC = (waveK - wmin) ./ max(1e-12, wmax - wmin);

    set(hWave, 'ZData', waveK, 'CData', waveC);

    %% ---- Update ray ----
    D = load(fullfile(inDirRT, rtFiles{k}));
    img = double(D.screen_image);

    if smoothSigma > 0
        img = imgaussfilt(img, smoothSigma);
    end

    [imgNy, imgNx] = size(img);
    xS = linspace(xmin, xmax, imgNx);
    yS = linspace(ymin, ymax, imgNy);

    imgBase = interp2(xS, yS, img, X, Y, 'linear', 0);

    imin = min(imgBase(:)); imax = max(imgBase(:));
    imgC = (imgBase - imin) ./ max(1e-12, imax - imin);
    imgC = imgC + 1;

    set(hImg, 'CData', imgC);

    title(sprintf('Frame %d / %d', k, Nt));
    drawnow;

    if saveVideo
        frame = getframe(gcf);
        writeVideo(v, frame);
    end
end

if saveVideo
    close(v);
    fprintf('Video saved to: %s\n', videoPath);
end
