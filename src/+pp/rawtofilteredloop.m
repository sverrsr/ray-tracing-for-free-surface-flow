clear; clc; close all;

% List of distances to process
% distTags = { ...
%     'D0.5pi', ...
%     'D1pi', ...
%     'D2.5pi', ...
%     'D2pi', ...
%     'D3.5pi', ...
%     'D3pi', ...
%     'D4pi', ...
%     'D5pi', ...
%     'D6pi', ...
%     'D8pi', ...
%     'D10pi', ...
%     'D12pi', ...
%     'D14pi' };

% distTags = {'D3pi'};

% distTags = { ...
%     'D2.00pi', ...
%     'D2.22pi', ...
%     'D2.44pi', ...
%     'D2.67pi', ...
%     'D2.89pi', ...
%     'D3.11pi', ...
%     'D3.33pi', ...
%     'D3.56pi', ...
%     'D3.78pi', ...
%     'D4.00pi' };

distTags = {
    'D1.00pi'
    'D1.29pi'
    'D1.57pi'
    'D1.86pi'
    'D2.14pi'
    'D2.43pi'
    'D2.71pi'
    'D3.00pi'
    'D3.29pi'
    'D3.57pi'
    'D3.86pi'
    'D4.14pi'
    'D4.43pi'
    'D4.71pi'
    'D5.00pi'
};

% BASE folders (never change these in the loop)
baseRayTraceDir = ...
    'D:\DNS\re2500_we10\re2500_we10_rayTrace';
baseFilteredDir = ...
    'D:\DNS\re2500_we10\re2500_we10_rayTrace_filtered';

for d = 1:numel(distTags)
    distTag = distTags{d};
    fprintf('Processing %s...\n', distTag);

    % Build folders safely
    rayTraceDir = fullfile(baseRayTraceDir, ...
        ['re2500_we10_rayTrace_' distTag]); % Subfolder navn
    filteredDir = fullfile(baseFilteredDir, ...
        ['re2500_we10_rayTrace_D1.00pi_filtered' distTag]);

    % Skip if input folder does not exist
    if ~exist(rayTraceDir, 'dir')
        warning('Folder not found: %s', rayTraceDir);
        continue;
    end

    % Create output folder if missing
    if ~exist(filteredDir, 'dir')
        mkdir(filteredDir);
    end

    % Get files
    files = dir(fullfile(rayTraceDir, '*.mat'));
    for k = 1:numel(files)
        filePath = fullfile(rayTraceDir, files(k).name);

        % LOAD
        S = load(filePath);
        img_raw = double(S.screen.image);

        % PROCESS
        % Apply final post-processing to the raw image (user function)
        img = finalPP(img_raw);

        % BUILD NEW FILENAME
        [~, baseName, ext] = fileparts(files(k).name);
        newName = [baseName '_filtered' ext];

        % SAVE
        outPath = fullfile(filteredDir, newName);
        save(outPath, 'img');
    end
end
disp('All distances processed and saved.');
