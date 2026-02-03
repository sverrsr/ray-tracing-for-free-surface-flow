% This script loads 10 evenly spaced .mat files from a specified folder
% and saves them into a new folder

folderPath = '\\tsclient\C\Users\sverrsr\VortexStructures\re2500_weInf\re2500_weInf_surfElev_sampled500';

% Create a new folder to save processed files
outputFolder = "\\tsclient\C\Users\sverrsr\VortexStructures\re2500_weInf\re2500_weInf_surfelev_100sampled";

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
    fprintf('Created folder: %s\n', outputFolder);
end

files = dir(fullfile(folderPath, '*.mat'));
n = numel(files);

% pick k evenly spaced indices
k = 100;
idx = round(linspace(1, n, k));

for i = 1:length(idx)
    f = fullfile(folderPath, files(idx(i)).name);
    data = load(f);
    fprintf('Loaded %s\n', files(idx(i)).name);

    % Save the processed data in the new folder
    outputFileName = fullfile(outputFolder, sprintf('processed_%s', files(idx(i)).name));
    save(outputFileName, '-struct', 'data');
    fprintf('Saved processed data to %s\n', outputFileName);
end