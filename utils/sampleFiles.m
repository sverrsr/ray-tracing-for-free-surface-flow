function sampleFiles(inFolder,outFolder, nSamples)
%sampleFiles loads k evenly spaced .mat files from a specified folder
% and saves them into a new folder
arguments (Input)
    inFolder = '\\tsclient\C\Users\sverrsr\VortexStructures\re2500_weInf\re2500_weInf_surfElev_sampled500';
    outFolder = "\\tsclient\C\Users\sverrsr\VortexStructures\re2500_weInf\re2500_weInf_surfelev_100sampled";
    nSamples = 100;
end

if ~exist(outFolder, 'dir')
    mkdir(outFolder);
    fprintf('Created folder: %s\n', outFolder);
end

files = dir(fullfile(inFolder, '*.mat'));
n = numel(files);

idx = round(linspace(1, n, k));

for i = 1:length(idx)
    f = fullfile(inFolder, files(idx(i)).name);
    data = load(f);
    fprintf('Loaded %s\n', files(idx(i)).name);

    % Save the processed data in the new folder
    outputFileName = fullfile(outFolder, sprintf('processed_%s', files(idx(i)).name));
    save(outputFileName, '-struct', 'data');
    fprintf('Saved processed data to %s\n', outputFileName);
end

end