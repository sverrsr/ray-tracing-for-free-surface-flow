   %% smoothedTiles_export_good.m
clear; clc; close all;

% Denne ble brukt for  5.3.1. Printe 4 bilder

% -----------------------------
% INPUT FILES
% -----------------------------
files = {
    'screen_1024bins_0001.mat'
    'screen_1024bins_0002.mat'
};

% -----------------------------
% SETTINGS
% -----------------------------
params.sigmaSmooth = 3.5;

% Figure size (match Overleaf linewidth etc.)
width_cm  = 13.7;
height_cm = 13.7;

% Export folder
outputFolder = fullfile('C:\Users\sverr\Documents\NTNU\Figures', 'smoothingPP');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end



% Choose export DPI by desired pixel width (sharp in PDF viewers / Overleaf)
targetWidthPx = 5000;                         % 4000–7000 is usually plenty
dpi = round(targetWidthPx / (width_cm/2.54)); % dpi = pixels / inches

% -----------------------------
% BUILD FIGURE
% -----------------------------
fig = figure('Color','w','Units','centimeters','Position',[2 2 width_cm height_cm]);
set(fig,'Renderer','opengl','InvertHardcopy','off');

t = tiledlayout(fig, 2, 2, 'Padding','none', 'TileSpacing','tight');

panelLabels = {'a)','b)','c)','d)'};
tileIdx = 1;

for k = 1:numel(files)
    data = load(files{k});
    img_raw = double(data.screen.image);

    % LEFT: contrast image
    img = cropimg(img_raw);
    imgSmooth   = imgaussfilt(img, params.sigmaSmooth);
    imgContrast = imadjust(imgSmooth);

    % RIGHT: filtered image
    img_filt = finalPP(img_raw);

    % ---- LEFT TILE (a,c) ----
    ax1 = nexttile(t, tileIdx);
    h1 = imshow(imgContrast, 'Parent', ax1);
    axis(ax1,'image'); axis(ax1,'off');
    colormap(ax1, flipud(sky));
    if isprop(h1,'Interpolation'), h1.Interpolation = 'nearest'; end

    text(ax1, 60, 60, panelLabels{tileIdx}, ...
        'Color','w','FontSize',14,'FontWeight','normal','FontName','Times New Roman');

    tileIdx = tileIdx + 1;

    % ---- RIGHT TILE (b,d) ----
    ax2 = nexttile(t, tileIdx);
    h2 = imshow(img_filt, 'Parent', ax2);
    axis(ax2,'image'); axis(ax2,'off');
    colormap(ax2, sky);
    if isprop(h2,'Interpolation'), h2.Interpolation = 'nearest'; end

    text(ax2, 60, 60, panelLabels{tileIdx}, ...
        'Color','k','FontSize',14,'FontWeight','normal','FontName','Times New Roman');

    tileIdx = tileIdx + 1;
end

% --- FIGURE SIZE IN CM (must match what you want in LaTeX) ---
width_cm  = 13.7;
height_cm = 13.7;

set(gcf,'Units','centimeters')
set(gcf,'Position',[2 2 width_cm height_cm])
set(gcf,'PaperUnits','centimeters')
set(gcf,'PaperPosition',[0 0 width_cm height_cm])
set(gcf,'PaperSize',[width_cm height_cm])

% --- EXACT SAME SETTINGS AS MANUAL SAVE ---
set(gcf,'Renderer','painters')     % <-- THIS is what manual save uses
set(gcf,'InvertHardcopy','off')
set(gcf,'Color','w')
set(findall(gcf,'Type','axes'),'Color','w')

pdfFileName = fullfile(outputFolder, 'smoothedTiles.pdf');

print(gcf, pdfFileName, '-dpdf', '-painters')
disp(['Saved (true manual quality): ' pdfFileName])

% -----------------------------
% EXPORT (THIS IS THE KEY)
% -----------------------------
pngName = fullfile(outputFolder, 'smoothedTiles.png');
pdfName = fullfile(outputFolder, 'smoothedTiles2.pdf');

% PNG (high DPI)
exportgraphics(fig, pngName, ...
    'Resolution', dpi, ...
    'BackgroundColor','white');

% PDF exported as IMAGE (sharp in Overleaf; avoids MATLAB vector-raster pitfalls)
exportgraphics(fig, pdfName, ...
    'ContentType','image', ...      % <-- KEY CHANGE vs your first script
    'Resolution', dpi, ...
    'BackgroundColor','white');

disp("Saved:");
disp(pngName);
disp(pdfName);
disp("DPI used: " + dpi);
