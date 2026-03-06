function screen2png3(inFolder, outFolder)
% SCREEN2PNG
% Converts a folder of .mat screen objects to globally normalized PNG files.
%
% Pipeline:
%   Pass 1: find global crop size (gShort)
%   Pass 2: find global processed max after crop -> pad -> resize -> clamp
%   Pass 3: process again, log-transform, globally normalize to [0,1], save
%
% Notes:
%   - Negative values introduced by interpolation are clamped to 0
%   - Saved PNGs use one common global mapping across the whole sequence
%   - Output is uint16 PNG

arguments
    inFolder  = "C:\Users\sverrsr\Documents\experiments\test_screens";
    outFolder = "C:\Users\sverrsr\Documents\experiments\re2500_we20_rayTrace_png_test";
end

% Settings
thr = 1e-6;
outSize = [256 256];
padSize = [3 3];
padMode = 'symmetric';
resizeMethod = 'bilinear';

% Check dependency
if exist('screen','class') == 0 && exist('screen','file') == 0
    error("Required type or file 'screen' is not on the MATLAB path.");
end

% Check folders
assert(isfolder(inFolder), "Folder not found: %s", inFolder);
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end

% List files
f = dir(fullfile(inFolder, "*.mat"));
fprintf("Found %d .mat files\n", numel(f));
assert(~isempty(f), "No .mat files found in %s", inFolder);

tic

%% Pass 1: find global shortest crop side
fprintf("Pass 1/3: Find global crop size\n");

gH = inf;
gW = inf;

for k = 1:numel(f)
    S = load(fullfile(f(k).folder, f(k).name), "screen");
    img = S.screen.image;

    validateImage(img, f(k), "raw");

    if ~isa(img, "double")
        img = im2double(img);
    end

    rows = find(any(img > thr, 2));
    cols = find(any(img > thr, 1));

    if isempty(rows) || isempty(cols)
        error("Image contains no values above threshold (thr=%.3g). File: %s", ...
            thr, f(k).name);
    end

    h = rows(end) - rows(1) + 1;
    w = cols(end) - cols(1) + 1;

    gH = min(gH, h);
    gW = min(gW, w);

    if mod(k,100)==0 || k==1 || k==numel(f)
        fprintf("Read %d/%d  current shortest side = %d\n", ...
            k, numel(f), min(gH, gW));
    end
end

gShort = min(gH, gW);
fprintf("Global crop size: [%d %d]\n", gH, gW);
fprintf("Using gShort = %d\n", gShort);

%% Pass 2: find global processed max after crop -> pad -> resize -> clamp
% Nothing from pass 2 is saved. Only to read values
% Except gmaxProc
fprintf("Pass 2/3: Find global processed max\n");

gmaxProc = -inf;

for k = 1:numel(f)
    S = load(fullfile(f(k).folder, f(k).name), "screen");
    img = S.screen.image;

    validateImage(img, f(k), "raw");

    I = preprocessFrame(img, gShort, padSize, padMode, outSize, resizeMethod);
    validateImage(I, f(k), "after preprocess");

    gmaxProc = max(gmaxProc, max(I(:)));

    if mod(k,100)==0 || k==1 || k==numel(f)
        fprintf("Scanned %d/%d  current processed max = %.6g\n", ...
            k, numel(f), gmaxProc);
    end
end

assert(isfinite(gmaxProc) && gmaxProc >= 0, ...
    "Invalid processed global max: %g", gmaxProc);

logMax = log(gmaxProc + 1);

fprintf("Processed global min/max after clamp: [0, %.6g]\n", gmaxProc);
fprintf("Log-domain global range            : [0, %.6g]\n", logMax);

%% Pass 3: save images with global normalization to [0,1]
fprintf("Pass 3/3: Save all images\n");

for k = 1:numel(f)
    S = load(fullfile(f(k).folder, f(k).name), "screen");
    img = S.screen.image;

    validateImage(img, f(k), "raw");

    I = preprocessFrame(img, gShort, padSize, padMode, outSize, resizeMethod);
    validateImage(I, f(k), "after preprocess");

    logImage = log(I + 1);
    validateImage(logImage, f(k), "after log");

    if logMax > 0
        Inorm = mat2gray(logImage, [0, logMax]);
    else
        Inorm = zeros(size(logImage), 'like', logImage);
    end

    I16 = im2uint16(Inorm);

    [~, baseName] = fileparts(f(k).name);
    outFile = fullfile(outFolder, baseName + ".png");
    imwrite(I16, outFile);

    if mod(k,100)==0 || k==1 || k==numel(f)
        fprintf("Saved %d/%d\n", k, numel(f));
    end
end

disp("Done.");
toc

end


function I = preprocessFrame(img, gShort, padSize, padMode, outSize, resizeMethod)
% Convert -> crop -> pad -> resize -> clamp

if ~isa(img, "double")
    img = im2double(img);
end

I = cropimg_dynamic(img, gShort);
%I = padarray(I, padSize, padMode, 'both');
I = imresize(I, outSize, resizeMethod);

% Clamp interpolation undershoot
I = max(I, 0);
end


function validateImage(A, fileInfo, stage)
if nargin < 3
    stage = "unknown";
end

bad = false;

if ~(isnumeric(A) || islogical(A))
    bad = true;
end

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
    fprintf("Min/Max real(A): [%g, %g]\n", min(real(A(:))), max(real(A(:))));

    if isnumeric(A) || islogical(A)
        fprintf("Finite : %d (NaN=%d, Inf=%d)\n", ...
            all(isfinite(A(:))), any(isnan(A(:))), any(isinf(A(:))));
        fprintf("Min/Max: [%g, %g]\n", min(A(:)), max(A(:)));
    end

    error("Invalid image detected (%s).", stage);
end
end