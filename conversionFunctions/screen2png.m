function screen2png(inFolder, outFolder)
% SCREEN2VIDEO inputs a folder with screen objects a sequence of png images
%   This function should be used as a step to making a video as all
%   information should be kept
%
%   Functionality
%   Crops the screens to 787x787 (to be fixed), and another 5% to be sure
%   that ray-coarse borders are removed


arguments (Input)
    inFolder = "re2500_weInf_400k";
    
    outFolder = "re2500_weInf_400k_png";
end

% Check that 'screen' class or function is on the path
if exist('screen','class') == 0 && exist('screen','file') == 0
    % Try to provide informative error with suggestion
    error("Required type or file 'screen' is not on the MATLAB path. Add the folder containing the 'screen' class/function to the path before running. (Optometrika)");
end

tic
% assert(isfolder(inFolder), "Folder not found: %s (pwd=%s)", inFolder, pwd);
if ~exist(outFolder,'dir'); mkdir(outFolder); end

f = dir(fullfile(inFolder,"*.mat"));
fprintf("Found %d .mat files\n", numel(f));
assert(~isempty(f), "No .mat files found in %s", inFolder);

fprintf("Step 1: Find global max / min\n");
[gmin, gmax] = findMaxMinMultipleScreens(inFolder);

fprintf("Step 2: Save all images\n");

for k = 1:numel(f)

    % Load only screen
    S = load(fullfile(f(k).folder, f(k).name), "screen");
    img = S.screen.image;     % This is the image

    validateImage(img, f(k));

    % Ensure image is of type double for processing
    if ~isa(img, "double")
        img = im2double(img);
    end
    
    % Crop settings
    I = cropimg_787_5p(img);
    validateImage(I, f(k), "after crop (pre-resize)");

    % Resample to 256x256
    I = imresize(I, [256 256]);
    validateImage(I, f(k), "after resize (pre-log)");
    %I = imresize(I, [256 256]); % Resample to 256x256
    % I = newgrid(I, 256, 256) % Resample to 256x256 to domain grid

    % Build file name
    [~, baseName] = fileparts(f(k).name);
    outBase = fullfile(outFolder, baseName);

    % Take the log of it.  Add 1 to avoid taking log of zero.
    if min(I(:)) < -1, fprintf("\nI has values < -1 in %s (min=%g)\n", f(k).name, min(I(:))); end
    I = max(I, 0);   % brute-force: kill negatives from imresize. SHould be fixed later
    logImage = log(I+1);
    validateImage(logImage, f(k), "after log");

    % Normalize to the range 0-1. Neccessarry for png
    I8 = im2uint16(mat2gray(logImage,[log(gmin+1), log(gmax+1)]));

    % Save image
    %I8 = im2uint16(mat2gray(I, [gmin, gmax])); %mat2gray is neccessary to keep gray variance
    imwrite(I8, outBase + ".png");

    % Print
    if mod(k,100)==0 || k==1 || k==numel(f)
        fprintf("Saved %d/%d\n", k, numel(f));
    end
end

disp("Done.");
toc
end

function validateImage(A, fileInfo, stage)
if nargin < 3, stage = "unknown"; end

bad = false;

% type checks
if ~(isnumeric(A) || islogical(A))
    bad = true;
end

% numeric checks
if ~bad
    bad = bad || ~isreal(A);
    bad = bad || issparse(A);
    bad = bad || any(~isfinite(A(:)));
end

if bad
    fprintf("\nBAD FILE: %s\n", fullfile(fileInfo.folder, fileInfo.name));
    fprintf("Stage  : %s\n", stage);
    fprintf("Class  : %s\n", class(A));
    fprintf("Size   : %s\n", mat2str(size(A)));
    fprintf("Real   : %d  Sparse: %d\n", isreal(A), issparse(A));
    fprintf("Min/Max real(I): [%g, %g]\n", min(real(A(:))), max(real(A(:))));

    if isnumeric(A) || islogical(A)
        fprintf("Finite : %d (NaN=%d, Inf=%d)\n", ...
            all(isfinite(A(:))), any(isnan(A(:))), any(isinf(A(:))));
        fprintf("Min/Max: [%g, %g]\n", min(A(:)), max(A(:)));
    end

    error("Invalid image detected (%s).", stage);
end
end