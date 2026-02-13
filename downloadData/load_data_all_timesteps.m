function load_data_all_timesteps(caseName, rootDir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function that loads all timesteps from hdf5-files using load_data.m
% and saves surfElev for each timestep as a .mat file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


dataDir  = fullfile(rootDir, caseName);
outDir = fullfile(rootDir, caseName + "_surfelev_all");

% Create output folder if it does not exist
if ~isfolder(outDir)
    mkdir(outDir)
end

% Get list of HDF5 files
files = dir(dataDir); % all files and folders 
files = files(~[files.isdir]); % remove '.' and '..' and any subfolders
files = sort({files.name});


nSteps = numel(files);
fprintf("Found %d timesteps in %s\n", nSteps, dataDir);

nSamples = 100;
idx = round(linspace(1, nSteps, nSamples));


for k = 1:nSteps % Add this if all files should be included

% for i = 1:numel(idx) % Remove this if all files should be included
%     k = idx(i); % Remove this if all files should be included and not sampled

    fprintf("Processing file %d / %d ...\n", k, nSteps);

    [surfElev, ~, ~, ~, ~] = load_data(caseName, rootDir, k);

    % Save one timestep
    outFile = fullfile(outDir, sprintf("surfElev_%05d.mat", k));
    save(outFile, "surfElev", "-v7.3");
end

fprintf("Done. Files saved in:\n%s\n", outDir);

% Find the file index using "i = find(idx == 5847);"
end