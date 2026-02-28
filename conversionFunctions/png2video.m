function png2video(inFolder)
% PNG2VIDEO inputs a folder with a sequence of png images
%   This function should be used after making screen objects pngs as all
%   information should be kept
%

arguments (Input)
    inFolder = "re2500_weInf_400k_png";
end

assert(isfolder(inFolder), "Folder not found: %s ", inFolder);
%if ~exist(outFolder,'dir'); mkdir(outFolder); end

f = dir(fullfile(inFolder,"*.png"));
fprintf("Found %d .mat files\n", numel(f));
assert(~isempty(f), "No .png files found in %s", inFolder);


workingDir = pwd;

%inFolder = "C:\Users\sverr\Documents\NTNU\Prosjekt\Experiments\grey-variance and correlation\re2500_weInf_surfElev_first2089_B1024_rayTrace_D3pi_png_crop787";
% inFolder = fullfile(workingDir, "images");   % folder with pngs

imageNames = dir(fullfile(inFolder, "*.png"));
names = {imageNames.name}';
tok = regexp(names, '\d+', 'match', 'once');   % first number in name
idxNum = cellfun(@(t) str2double(t), tok);

[~, ord] = sort(idxNum);
imageNames = names(ord);

outputVideo = VideoWriter(fullfile(workingDir, "video"), 'MPEG-4');
outputVideo.FrameRate = 30;
outputVideo.Quality = 100;

open(outputVideo)

for k = 1:length(imageNames)
    img = imread(fullfile(inFolder, imageNames{k}));
    %img = imadjust(im2uint8(img));
    writeVideo(outputVideo, img)

    % Print
    if mod(k,10)==0 || k==1 || k==numel(f)
        fprintf("Processed %d/%d\n", k, numel(f));
    end
end

close(outputVideo)


disp("Done.");


end