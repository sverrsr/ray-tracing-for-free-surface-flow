% This script loads 10 evenly spaced .mat files from a specified folder
% and saves them into a new folder

folderPath = '\\tsclient\c\Users\sverrsr\VortexStructures\re2500we10\re2500_we20_surfElev';

% Create a new folder to save processed files
outputFolder = fullfile('\\tsclient\c\Users\sverrsr\VortexStructures\re2500we10', 're2500_we20_surfElev');

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
    fprintf('Created folder: %s\n', outputFolder);
end

files = dir(fullfile(folderPath, '*.mat'));
n = numel(files);

% pick 10 evenly spaced indices
k = 500;
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