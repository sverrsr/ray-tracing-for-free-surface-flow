clear all; clc; close all;

% This script is making the raw image figure in teh project thesis

fileName = 'screen_1024bins_0001.mat';   % <--- change to any file you want
% fileName = 'screen_1024bins_0002.mat';
% fileName = 'screen_1024bins_0003.mat';
% fileName = 'screen_1024bins_0004.mat';
% fileName = 'screen_1024bins_0005.mat';
% fileName = 'screen_1024bins_0006.mat';
% fileName = 'screen_1024bins_0007.mat';
% fileName = 'screen_1024bins_0008.mat';
% fileName = 'screen_1024bins_0009.mat';
% fileName = 'screen_1024bins_0010.mat';

% 1 stor dimple, 2 viser scars og boil, 9 er grei
% 3,4, 6,7 ikke spesielt bra

% Create a new folder to save processed files
outputFolder = fullfile('C:\Users\sverr\Documents\NTNU\thesisFigures', 'raw');

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
    fprintf('Created folder: %s\n', outputFolder);
end


%% LOAD IMAGE
data = load(fileName);
img_raw = double(data.screen.image);

%% Raw image with caxis
figure;
imshow(img_raw, []);
title('Raw Image');
colormap(gray);
caxis([0 4]); % Set color limits between 0 and 4
colorbar;

rayMin = min(img_raw(:));
rayMax = max(img_raw(:));
fprintf('Ray intensity range: [%.3e, %.3e]\n', rayMin, rayMax);

% Save the raw image as SVG
svgFileName = fullfile(outputFolder, fileName + "_raw_image.svg");
print(gcf, svgFileName, '-dsvg');

img_crop = cropimg(img_raw);

% show the result
figure;
imshow(img_crop, []);
title('Cropped Raw Image');
caxis([0 4]); % Set color limits between 0 and 4

%% Plot only raw normalized
% Normalize the cropped image
imgNormalized = mat2gray(img_crop);

% Display the normalized image
figure;
imshow(imadjust(imgNormalized), []);
title('Normalized Image');
colormap(gray);
colorbar;

%% Make it square (this is not teh real interp2. See below)

img_interp_1 = newgrid(imgNormalized, 1024, 1024);

% Display the interpolated image
figure;
imshow(imadjust(img_interp_1), []);
title('Interpolated Image');
colormap(gray);
colorbar;

% Enable data cursor mode for getting positions
datacursormode on;

% Show axes on this image
axis on; % Turn on the axes

hrect = drawrectangle(Position=[550 420 40 40]);
hrect2 = drawrectangle(Position=[720 100 250 250]);

% Crop the image from the specified positions
cropPosition = [550 420 40 40]; % [x, y, width, height]
img_cropped_area = imcrop(imadjust(img_interp_1), cropPosition);

% Display the cropped image
figure;
imshow(img_cropped_area, []);
title('Cropped Image from Specified Positions');
colormap(gray);
colorbar;

% Crop the image from the specified positions
cropPosition = [720 100 250 250]; % [x, y, width, height]
img_cropped_area2 = imcrop(imadjust(img_interp_1), cropPosition);

% Display the cropped image
figure;
imshow(img_cropped_area2, []);
title('Cropped Image from Specified Positions');
colormap(gray);
colorbar;

%t = tiledlayout(2,3);
t = tiledlayout(2,3,'TileSpacing','tight','Padding','tight');

% Tile 1: Display the interpolated image
nexttile([2 2])
imshow(imadjust(img_interp_1), []);
hrect = drawrectangle(Position=[550 420 40 40]);
hrect2 = drawrectangle(Position=[720 100 250 250]);
hrect2.LineWidth = 1;
hrect2.Color = 'w';
hrect2.InteractionsAllowed = 'none';

hrect.LineWidth = 1;
hrect.Color = 'w';
hrect.InteractionsAllowed = 'none';
%title('Interpolated Image');

% Tile 2: Display the first cropped image
nexttile
imshow(img_cropped_area2, []);

%title('Cropped Area 1');

% Tile 3: Display the second cropped image
nexttile
imshow(img_cropped_area, []);
%title('Cropped Area 2');

cb = colorbar;
cb.Layout.Tile = 'east';
cb.FontSize = 10;
cb.FontName = 'Times New Roman';   % optional, if your thesis uses it
cb.Position(3) = 0.005;   % smaller = thinner

% Adjust layout for better spacing
%title(t, 'Image Analysis Results');
set(gcf,'Color','w')
set(gca,'Color','w')

%%
% --- FIGURE SIZE IN CM ---
width_cm  = 13.7;     % Overleaf line width
height_cm = 6;        % adjust if needed

% Set figure units and paper size to produce centimeter-sized output
set(gcf,'Units','centimeters')
set(gcf,'Position',[2 2 width_cm height_cm])
set(gcf,'PaperUnits','centimeters')
set(gcf,'PaperPosition',[0 0 width_cm height_cm])
set(gcf,'PaperSize',[width_cm height_cm])
set(gcf,'Renderer','opengl')     % best for images

% --- FORCE WHITE BACKGROUND ---
set(gcf,'Color','w')
set(gca,'Color','w')
%set(findall(gcf,'Type','rectangle'),'LineWidth',0.05)
%set(findall(gcf,'Type','images.roi.Rectangle'),'InteractionsAllowed','none')
%set(findall(gcf,'Type','images.roi.Rectangle'),'Color','w')

% --- HIGH QUALITY EXPORT ---

fname = 'figure.png';

exportgraphics(gcf,fname, ...
    'Resolution',1024, ...
    'BackgroundColor','white')

fullpath = fullfile(pwd, fname);
disp(['Saved to: ' fullpath])

% --- HIGH QUALITY EXPORT AS PDF ---
pdfFileName = fullfile(pwd, "_figure.pdf");
exportgraphics(gcf, pdfFileName, ...
    'ContentType', 'vector', ...
    'BackgroundColor', 'white');
disp(['Saved to: ' pdfFileName]);

%%
% Save the cropped images as PNG files
pngFileName1 = fullfile(outputFolder, fileName + "_cropped_area1.png");
print(gcf, pngFileName1, '-dpng', '-r400');
fprintf('Saved cropped image 1 as: %s\n', pngFileName1);

pngFileName2 = fullfile(outputFolder, fileName + "_cropped_area2.png");
print(gcf, pngFileName2, '-dpng', '-r400');
fprintf('Saved cropped image 2 as: %s\n', pngFileName2);

% Save the normalized image as PNG file
pngFileName3 = fullfile(outputFolder, fileName + "_normalized_image.png");
print(gcf, pngFileName3, '-dpng', '-r400');
fprintf('Saved normalized image as: %s\n', pngFileName3);

%% Plot only raw normalized with magInset
% Normalize the cropped image
imgNormalized = mat2gray(img_interp_1);

% Display the normalized image
figure;
imshow(imadjust(imgNormalized), []);
title('Normalized Image');
colormap(gray);
colorbar;

xlim(gca)
ylim(gca)
datacursormode on

get(gca, 'Position')
MagInset(gcf, -1, [550 420 40 40], [600 780 200 420],{'NW','NW';'SE','SE'});

%% Interpolate image


% Denne normaliserer. Derfor er ikke Mat2gray nødvendig
img_enh = imadjust(img_interp);

rayMin = min(img_enh(:));
rayMax = max(img_enh(:));
fprintf('Ray intensity range: [%.3e, %.3e]\n', rayMin, rayMax);

% Show the current image with axes
figure;
imagesc(X(1,:), Y(:,1), img_enh);
title('Current Image with Axes');
axis image;
colormap(gray);
colorbar;
axis on; % Turn on the axes
hold off


%% Contrast enhanced
%img_enh = imadjust(img_norm);
%rayMin = min(img_enh(:));
%rayMax = max(img_enh(:));
%fprintf('Ray intensity range: [%.3e, %.3e]\n', rayMin, rayMax);

% figure;
% imshow(img_enh);
% title('Contrast Enhanced Image');
% %colormap(gray);
% colorbar;
% 
% %% SHOW NORMALIZED IMAGE and contrast enhansed
% 
% axMain = axes;
% imagesc(X(1,:), Y(:,1), img_interp);
% colormap(gray);
% colorbar;
% hold on;
% axis on; % Turn on the axes
% 
% 
% 
% %% SHOW NORMALIZED IMAGE and contrast enhansed
% 
% figure;
% 
% axMain = axes;
% imshow(imadjust(img), []);
% colormap(gray);
% colorbar;
% hold on;
% 
% % --- Match LaTeX linewidth ---
% set(gcf, 'Units', 'centimeters');
% set(gcf, 'Position', [0 0 13.7 8.5]);
% set(gcf, 'PaperUnits', 'centimeters');
% set(gcf, 'PaperPosition', [0 0 13.7 8.5]);
% set(gcf, 'PaperSize', [13.7 8.5]);
% 
% % ============================
% % ADD MAGNIFICATION INSET
% % ============================
% 
% %MagInset(gcf, axes, ZoomArea, InsetPos, {'NW','NW';'SE','SE'});
% % ============================
% % EXPORT
% % ============================
% pngFileName = fullfile(outputFolder, fileName + "_contrasting_normalized_image.png");
% print(gcf, pngFileName, '-dpng', '-r400')