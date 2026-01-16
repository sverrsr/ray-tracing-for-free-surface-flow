%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that loads all timesteps from hdf5-files using load_data.m
% and saves surfElev for each timestep as a .mat file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Settings

caseName = "re1000_we10";
rootDir  = "\\tsclient\C\Users\sverrsr\VortexStructures\re1000_we10";


%%
dataDir  = fullfile(rootDir, caseName);
outDir = fullfile(rootDir, caseName + "_surfelev_500sampled");

% Create output folder if it does not exist
if ~isfolder(outDir)
    mkdir(outDir)
end

% Get list of HDF5 files
files  = dir(dataDir);       % all files and folders
files  = files(~[files.isdir]); % remove '.' and '..' and any subfolders
nSteps = numel(files);
fprintf("Found %d timesteps in %s\n", nSteps, dataDir);


k = 500;
idx = floor(linspace(1, nSteps+1, k+1));
idx = idx(1:end-1);


% Loop over timesteps
for i = 1:length(idx)
    fprintf("Processing file %d / %d: %s\n", i, numel(idx), files(idx(i)).name);

    [surfElev, ~, ~, ~, ~] = load_data(caseName, rootDir, files(idx(i)).name);

    % Save one timestep
    outFile = fullfile(outDir, sprintf("surfElev_%05d.mat", files(idx(i)).name));
    save(outFile, "surfElev", "-v7.3");
end

fprintf("Done. Files saved in:\n%s\n", outDir);
