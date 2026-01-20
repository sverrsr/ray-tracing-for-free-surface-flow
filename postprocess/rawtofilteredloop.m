%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The script loops over multiple wall distances (distTags) for one DNS case
% (re*_we*) and process the image so it can later be correlated
%
% Input:
% For each distance, it reads ray-traced image files (.mat) from a fixed input folder.
% Each file contains a raw image stored as S.screen.image.
% Choose the main function:
%   finalPP_simple
%   finalPP
% 
% Output:
% Processed images are saved to a separate "filtered" output directory.
% Output filenames keep the original name and add _filtered_simple_.
% All ray-traced images are post-processed and saved, one output file per input file.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
        ['re2500_we20_raytrace_' distTag]); % Subfolder navn
    filteredDir = fullfile(baseFilteredDir, ...
        ['re2500_we20_raytrace_filtered' distTag]);

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
        img = finalPP(img_raw);

        % --- DEBUG: show raw vs processed for the very first file only ---
        if  k == 1
            figure('Name','Raw vs Processed (first image)','Color','w');
            
            subplot(1,2,1);
            imagesc(img_raw); axis image off;
            colormap(gca,'gray'); colorbar;
            title('Raw');
        
            subplot(1,2,2);
            imagesc(img); axis image off;
            colormap(gca,'gray'); colorbar;
            title('Processed');
        
            drawnow;  % force display update
        end


        % BUILD NEW FILENAME
        [~, baseName, ext] = fileparts(files(k).name);
        newName = [baseName '_filtered_simple' ext];

        % SAVE
        outPath = fullfile(filteredDir, newName);
        save(outPath, 'img');

        if printcounter == 61
            fprintf('... Processed %d images ...\n', k);
            printcounter = 0;
        end

        
    end
end
disp('All distances processed and saved.');
