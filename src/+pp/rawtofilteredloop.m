clear; clc; close all;

caseTag = "re2500_we20";

% Distances (heights)
fileName = caseTag + "_meanCorr.csv";
S = readtable(fileName);
distTags = string(S.DistanceTag);

% BASE folders (never change these in the loop)
baseRayTraceDir = ...
    'D:\DNS\re2500_we20\re2500_we20_rayTrace';
baseFilteredDir = ...
    'D:\DNS\re2500_we20\re2500_we20_rayTrace_filtered';

for d = 1:numel(distTags)
    distTag = distTags{d};
    fprintf('Processing %s...\n', distTag);

    % Build folders safely
    rayTraceDir = fullfile(baseRayTraceDir, ...
        ['re2500_we20_rayTrace_' distTag]); % Subfolder navn
    filteredDir = fullfile(baseFilteredDir, ...
        ['re2500_we20_rayTrace_D1.00pi_filtered' distTag]);

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
    nSteps = numel(files);

    fprintf('... Reading %d ray traced images for %s ...\n', nSteps, distTag);

    printcounter = 1;

    for k = 1:numel(files)
        
        printcounter = printcounter + 1;
        

        filePath = fullfile(rayTraceDir, files(k).name);

        % LOAD
        S = load(filePath);
        img_raw = double(S.screen.image);

        % PROCESS
        % Apply final post-processing to the raw image (user function)
        img = finalPP_simple(img_raw);

        % BUILD NEW FILENAME
        [~, baseName, ext] = fileparts(files(k).name);
        newName = [baseName '_filtered_simple_' ext];

        % SAVE
        outPath = fullfile(filteredDir, newName);
        save(outPath, 'img');

        if printcounter == 30
            fprintf('... Processed %s images ...\n', k);
            printcounter = 0;
        end

        
    end
end
disp('All distances processed and saved.');
