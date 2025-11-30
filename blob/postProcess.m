clear all; clc; close all;


outDir = 'C:\Users\sverr\Documents\NTNU\Prosjekt\Blob\square_rays_postProc';
inDir = 'C:\Users\sverr\Documents\NTNU\Prosjekt\Blob\square_rays';

if ~exist(outDir, 'dir'); mkdir(outDir); end

files = dir(fullfile(inDir, 'screen_*.mat'));
files = sort({files.name});

fprintf('Found %d screen files.\n', numel(files));


% USER PARAMETERS 
params.sigmaSmooth = 1;        % Gaussian smoothing, 2 seemed ok
params.thresh = 0.8;        % Gaussian smoothing, 2 seemed ok
params.invthresh   = 0.8;      % DoG high
params.areastokeep   = 100;        % DoG low

% pick a small threshold to ignore pure black and noise
thr = 1e-6;

% --- Main animation loop ---

for k = 1:numel(files)
    fileName = fullfile(inDir, files{k});

    data = load(fileName);

    img = double(data.screen_image);

    rows = find(any(img > thr, 2));
    cols = find(any(img > thr, 1));
    if isempty(rows) || isempty(cols)
        error('Image contains no values above threshold: %s', files{k});
    end

    r1 = rows(1); r2 = rows(end);
    c1 = cols(1); c2 = cols(end);
    imgCrop = img(r1:r2, c1:c2);

    imgSmooth = imgaussfilt(imgCrop, params.sigmaSmooth);

    screen_image = imgSmooth;

    % scale to [0,1] before imadjust if you're using doubles
    imgContrast = imadjust(mat2gray(imgSmooth));

    [~, baseName, ~] = fileparts(fileName);
    outFile = fullfile(outDir, [baseName '.mat']); % or [baseName '_smoothed.mat']

    save(outFile, 'screen_image');  % <-- only one variable saved
    fprintf('Saved: %s\n', outFile);
    
    % %% Connected Areas
    % X1 = imgContrast; %Setting it to bw can seem to make it better
    % 
    % %%%%%%%%%%%% CONNECTED AREAS ANALYSIS %%%%%%%%%%%%%%
    % % Provided by Simen Ådnøy Ellingsen
    % 
    % %Make binary images
    % X1w = X1*0 + (X1>params.thresh);       %For light-area
    % 
    % CC1w = bwconncomp(X1w);
    % 
    % areas1w = cell2mat(struct2cell(regionprops(CC1w,"Area")));
    % 
    % %Lists of sizes of areas
    % [Asz1,order1] = sort(areas1w,'descend');
    % n1 = length(order1); 
    % 
    % %Separate out the largest areas
    % bigidx1 = order1(1:params.areastokeep); 
    % smallidx1 = order1(params.areastokeep+1:n1); 
    % 
    % X1tBig = cc2bw(CC1w,ObjectsToKeep=bigidx1);
    % X1tSmall = cc2bw(CC1w,ObjectsToKeep=smallidx1);
    % 
    % 
    % % Save the binary image of the largest warm areas, X1tbig
    % [~, baseName, ~] = fileparts(fileName);
    % outImg = fullfile(outputFolder, baseName + "_largest_warm_areas.jpg");
    % 
    % % imwrite(X1tBig, outImg);
    % % fprintf('Saved: %s\n', outImg);
    % 
    % %% %%%%%%%%%%%% SAME FOR DARK AREAS %%%%%%%%%%%%%% 
    % X1b = X1*0 + (X1<params.invthresh);    %For dark-area analysis
    % 
    % CC1b = bwconncomp(X1b);
    % 
    % areas1b = cell2mat(struct2cell(regionprops(CC1b,"Area")));
    % 
    % [Asz1,order1] = sort(areas1b,'descend');

end

close(v);
fprintf('Saved post prosessecd screens in: %s\n', vidPath);
