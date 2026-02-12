clc; clear; close all;

% Base folder containing all RayTrace_* subfolders
baseDir = 'D:\DNS\re2500_weInf\re2500_weInf_surfElev_sampled500_rayTrace';

folders = dir(fullfile(baseDir, 'RayTrace_*'));
folders = folders([folders.isdir]);

% Sort folders alphabetically by name (to fix the order)
% Extract numeric distances from folder names
distances = zeros(numel(folders),1);

for k = 1:numel(folders)
    tok = regexp(folders(k).name, '_D([0-9.]+)pi', 'tokens');
    distances(k) = str2double(tok{1}{1});
end

% Sort by distance
[distances, order] = sort(distances);
folders = folders(order);

% Print sorted order
fprintf("Sorted folder order (distance increasing):\n");
for k = 1:numel(folders)
    fprintf("%2d : %s   (%.3f π)\n", k, folders(k).name, distances(k));
end



% Print the order used in the montage
fprintf('Montage order (index : folder name):\n');
for k = 1:numel(folders)
    fprintf('%2d : %s\n', k, folders(k).name);
end

frameIndex = 250;
imgs = cell(numel(folders), 1);


panelLabels = {
    'D0.5pi'
    'D1pi'
    'D1.5pi'
    'D2pi'
    'D2.5pi'
    'D3pi'
    'D3.5pi'
    'D4pi'
    'D5pi'
    'D6pi'
    'D8pi'
    'D10pi'
    'D12pi'
    'D14pi'
};




for k = 1:numel(folders)
    subDir = fullfile(baseDir, folders(k).name);

    files = dir(fullfile(subDir, '*.mat'));
    if isempty(files)
        warning('No .mat files in %s', folders(k).name);
        imgs{k} = [];
        continue;
    end

    % Sort files by name
    [~, idx] = sort({files.name});
    files = files(idx);

    if frameIndex > numel(files)
        warning('Folder %s has only %d files. Skipping.', folders(k).name, numel(files));
        imgs{k} = [];
        continue;
    end

    % Load .mat file #250
    S = load(fullfile(subDir, files(frameIndex).name));

    % Extract image from struct: S.screen.image
    img_raw = double(S.screen.image);
    img = imadjust((img_raw));

    if ~isnumeric(img)
        warning('Image in %s frame %d is not numeric. Skipping.', folders(k).name, frameIndex);
        imgs{k} = [];
        continue;
    end

    % Convert to uint8 for montage
    img = mat2gray(img);
    img = im2uint16(img);

    scale = size(img,1) / 1024;   % =1 for 1024 px, auto if bigger/smaller
    fontSize = round(80 * scale); % 80 px looks good after montage

    img = insertText(img, [100 0], panelLabels{k}, ...
        'FontSize', fontSize, ...
        'Font', 'Times New Roman', ...
        'BoxOpacity', 0, ...         % no background box
        'TextColor', 'white');
    
    imgs{k} = img;
end

figure;

% -----------------------------
% FIGURE SIZE (cm)
% -----------------------------
width_cm  = 13.7;
height_cm = 29.7;   % full page height

set(gcf,'Units','centimeters');
set(gcf,'Position',[2 2 width_cm height_cm]);
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',[0 0 width_cm height_cm]);
set(gcf,'PaperSize',[width_cm height_cm]);
set(gcf,'Color','w');
ax = gca;
ax.FontSize = 14;
ax.LineWidth = 1;
ax.TickLabelInterpreter = 'latex';
ax.XLabel.Interpreter   = 'latex';
ax.YLabel.Interpreter   = 'latex';
ax.Title.Interpreter    = 'latex';




montage(imgs,"Size",[4 3], Indices=3:14);
%title('Frame 250 from each RayTrace subfolder');

print(gcf, 'montage.pdf', '-dpdf', '-painters');
print(gcf, 'montage_output.pdf', '-dpdf', '-r600');

% Calculate the dimensions of the montage image in cm
montageWidth = width_cm; % Width of the figure in cm
montageHeight = height_cm; % Height of the figure in cm

fprintf('The dimensions of the montage image are: %.2f cm x %.2f cm\n', montageWidth, montageHeight);

%%
%% --- NEW MONTAGE: RAW 6pi AND RAW 14pi ---
disp('Building RAW 6pi / RAW 14pi montage...');

% Find index of 6pi and 14pi folders
idx6  = find(distances == 6);
idx14 = find(distances == 14);

if isempty(idx6) || isempty(idx14)
    error('Could not find D6pi or D14pi in sorted folder list.');
end

rawImgs = cell(1,2);
rawLabels = {'D6pi','D14pi'};

% ----------------------------------------
% LOAD RAW FRAME 250 FROM EACH FOLDER
% ----------------------------------------
loadIndices = [idx6 idx14];

for n = 1:2
    folderIdx = loadIndices(n);

    subDir = fullfile(baseDir, folders(folderIdx).name);

    % Sorted .mat files in folder
    files = dir(fullfile(subDir,'*.mat'));
    [~,idx] = sort({files.name});
    files = files(idx);

    % Load RAW frame
    S = load(fullfile(subDir, files(frameIndex).name));
    img_raw = double(S.screen.image);

    % Normalize + improve contrast (same style as your earlier script)
    img = mat2gray(img_raw);
    img = imadjust(img);

    % Convert to montage-compatible format
    img = im2uint16(img);

    scale = size(img,1) / 1024;   % =1 for 1024 px, auto if bigger/smaller
    fontSize = round(40 * scale); % 80 px looks good after montage

    % Insert text label (Times New Roman, no box)
    img = insertText(img, [150 40], rawLabels{n}, ...
        'FontSize', fontSize, ...
        'Font', 'Times New Roman', ...
        'BoxOpacity', 0, ...
        'TextColor', 'white');

    rawImgs{n} = img;
end

% ----------------------------------------
% BUILD FIGURE (same export formatting as your thesis figures)
% ----------------------------------------
fig2 = figure;
width_cm  = 13.7;
height_cm = 6.0;

set(fig2,'Units','centimeters');
set(fig2,'Position',[2 2 width_cm height_cm]);
set(fig2,'PaperUnits','centimeters');
set(fig2,'PaperPosition',[0 0 width_cm height_cm]);
set(fig2,'PaperSize',[width_cm height_cm]);
set(fig2,'Color','w');

montage(rawImgs, "Size", [1 2]);

% ----------------------------------------
% EXPORT
% ----------------------------------------
print(fig2, 'RAW_D6pi_D14pi.pdf', '-dpdf','-painters');
print(fig2, 'RAW_D6pi_D14pi_r600.pdf', '-dpdf','-r600');

disp('Saved RAW D6pi + RAW D14pi montage.');
