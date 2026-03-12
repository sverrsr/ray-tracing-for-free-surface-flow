function build_screen_stacks(c, useLog)
% STACK_SCREENS_BY_DISTANCE
% Iterates over ray-traced distance folders and converts
% each folder of screen objects into a stacked, normalized MAT file.
%
% For each distance tag:
%   1. Locate the corresponding ray-traced image folder.
%   2. Process all screen images in that folder.
%   3. Stack them into a single 3D array.
%   4. Save the result as one MAT file in the output directory.
%
% Inputs
%   c       : configuration structure containing case name and folder paths
%   useLog  : logical flag controlling intensity scaling
%             true  -> apply log(I+1) before normalization
%             false -> use linear intensity scaling
%
% Output
%   One stacked MAT file per distance containing normalized image data.


arguments (Input)
    c
    useLog   (1,1) logical = true; % Choose intensity scaling before normalization.
                % true  -> apply log(I+1) to compress large outliers from ray-tracing noise.
                % false -> keep linear intensity and normalize directly.
                % Log scaling reduces the influence of rare high-energy pixels,
                % while linear scaling preserves the original signal amplitudes.
end


fprintf('\nStarting build_screen_stacks function...\n');

caseTag = c.input.caseName;
distTable = extract_Dxxpi(c.pp.baseRayTraceDir);
distTags = string(distTable.DistanceTag);

baseRayTraceDir = c.pp.baseRayTraceDir;
baseStackedDir  = c.pp.baseStackedDir;

if ~exist(baseStackedDir, 'dir')
    mkdir(baseStackedDir);
end

for d = 1:numel(distTags)
    distTag = distTags(d);
    fprintf('Processing %s...\n', distTag);

    rayTraceDir = fullfile(baseRayTraceDir, caseTag + "_raytraced_" + distTag);

    if ~exist(rayTraceDir, 'dir')
        warning('Folder not found: %s', rayTraceDir);
        continue;
    end

    if useLog
        outFile = fullfile(baseStackedDir, caseTag + "_" + distTag + "_log.mat");
    else
        outFile = fullfile(baseStackedDir, caseTag + "_" + distTag + "_lin.mat");
    end

    screen2mat2(outFile, useLog, rayTraceDir);
end

outputFileName = fullfile(baseStackedDir, caseTag + "_meanCorr.csv");
writetable(distTable, outputFileName);
fprintf('Saved distance table to: %s\n', outputFileName);

end