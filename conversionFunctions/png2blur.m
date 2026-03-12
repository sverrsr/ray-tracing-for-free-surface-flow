function png2blur(inFolder, outFolder)
% PNG2BLUR inputs a folder with a sequence of raw png images and blurs them
%
% The function is to be used at raw png photos from screen2png

arguments (Input)
    inFolder = "re2500_weInf_surfElev_first2089_B1024_rayTrace_D3pi_png";
    outFolder = "re2500_weInf_surfElev_first2089_B1024_rayTrace_D3pi_png_pp";
end

% MAking new folder
assert(isfolder(inFolder), "Folder not found: %s (pwd=%s)", inFolder);
if ~exist(outFolder,'dir'); mkdir(outFolder); end

% Check inFolder
f = dir(fullfile(inFolder,"*.png"));
fprintf("Found %d .png files\n", numel(f));
assert(~isempty(f), "No .png files found in %s", inFolder);

%% kernel
win = 25;
thr = 40;
SE = ones(win,win);
SE = SE / sum(SE(:));

for k = 1:numel(f)

    % Load the image
    I = imread(fullfile(f(k).folder, f(k).name));

    % Ensure image is of type double for processing
    if ~isa(I, "double")
        I = im2double(I);
    end
    
    % Adjust settings. Don't use mat2gray and imadjust togheter

    % % im be your image
    % pad = floor(win/2);
    % Ipad = padarray(I, [pad pad], 'symmetric', 'both');   % or 'replicate'
    % M = conv2(Ipad, SE, 'valid');                         % same size as I

    I = imgaussfilt(I, 1);

    %I = imadjust(I); Denne ødelegger global informasjo. ALt blir skallert

    
    % % Print the scale of the values in the image
    % minVal = min(I(:));
    % maxVal = max(I(:));
    % fprintf("Image value range: min = %.6g, max = %.6g\n", minVal, maxVal);

    % Build file name
    [~, baseName] = fileparts(f(k).name);
    outBase = fullfile(outFolder, baseName);

    % Save image
    %mat2gray is neccessary to keep gray variance, but files shoudl alreay
    %be normalized
    I8 = im2uint16((I)); 
    imwrite(I8, outBase + ".png");

    % Print
    if mod(k,100)==0 || k==1 || k==numel(f)
        fprintf("Saved %d/%d\n", k, numel(f));
    end
end

disp("Done.");
end