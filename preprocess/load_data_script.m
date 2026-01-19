%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that loads all timesteps from hdf5-files using load_data.m
% and saves surfElev for each timestep as a .mat file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;

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


% k = 500;
% idx = floor(linspace(1, nSteps+1, k+1));
% idx = idx(1:end-1);


% Loop over timesteps
for k = 1:nSteps
    fprintf("Processing file %d / %d\n ...", k, nSteps);

    [surfElev, ~, ~, ~, ~] = load_data(caseName, rootDir, k);

    % Save one timestep
    outFile = fullfile(outDir, sprintf("surfElev_%05d.mat", k));
    save(outFile, "surfElev", "-v7.3");
end

fprintf("Done. Files saved in:\n%s\n", outDir);
