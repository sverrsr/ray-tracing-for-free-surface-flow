function raw_to_filtered(c)

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
% Example
% 
% Output:
% Processed images are saved to a separate "filtered" output directory.
% Output filenames keep the original name and add _filtered_simple_.
% All ray-traced images are post-processed and saved, one output file per input file.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nStarting raw_to_filtered function...\n');
fprintf('\n');

caseTag = c.input.caseName;

% Distances (heights)
fileName = caseTag + "_meanCorr.csv";
fprintf('Opening CSV file: %s\n', fileName);
distTable = extract_Dxxpi(c.pp.baseRayTraceDir);
distTable
%distTable = readtable(fileName);
distTags = string(distTable.DistanceTag);


% BASE folders (never change these in the loop)
baseRayTraceDir = c.pp.baseRayTraceDir;
baseFilteredDir = c.pp.baseFilteredDir;

for d = 1:numel(distTags)
    distTag = distTags{d};
    fprintf('Processing %s...\n', distTag);

    % Finding subfolders:
    rayTraceDir = fullfile( ...
        baseRayTraceDir, ...
        caseTag + "_raytraced_" + distTag ...
    );

    % Building subfolders:
    filteredDir = fullfile( ...
        baseFilteredDir, ...
        caseTag + "_raytrace_filtered_" + distTag ...
    );

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

        % extract trailing number
        tokens = regexp(baseName, '^(.*)_(\d+)$', 'tokens', 'once');
        
        namePart = tokens{1};
        numPart  = tokens{2};
        
        newName = sprintf('%s_filtered_simple_%s%s', namePart, numPart, ext);

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

% Save the distance table to a CSV file
outputFileName = caseTag + "_meanCorr.csv";
writetable(distTable, outputFileName);
fprintf('Saved distance table to: %s\n', outputFileName);

end