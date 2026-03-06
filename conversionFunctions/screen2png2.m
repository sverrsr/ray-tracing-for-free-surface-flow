function screen2png2(inFolder, outFolder)

arguments
    inFolder  = "C:\Users\sverrsr\Documents\experiments\test_screens";
    outFolder = "C:\Users\sverrsr\Documents\experiments\re2500_we20_rayTrace_png_test";
end

% Settings
outSize = [256 256];
padSize = [3 3];
padMode = 'replicate';   % keep this identical in pass 2 and pass 3
resizeMethod = 'lanczos3';

% Check dependency
if exist('screen','class') == 0 && exist('screen','file') == 0
    error("Required type or file 'screen' is not on the MATLAB path.");
end

tic

if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end

f = dir(fullfile(inFolder, "*.mat"));
fprintf("Found %d .mat files\n", numel(f));
assert(~isempty(f), "No .mat files found in %s", inFolder);

%% Pass 1: find global crop size info
fprintf("Pass 1/3: Find global crop size\n");
[~, ~, ~, gShort] = searchGlobalValues(inFolder);
fprintf("Using gShort = %d\n", gShort);

%% Pass 2: find global processed max after crop -> pad -> resize -> clamp
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
        fprintf("Scanned %d/%d  current global max = %.6g\n", k, numel(f), gmaxProc);
    end
end

assert(isfinite(gmaxProc) && gmaxProc >= 0, ...
    "Invalid global processed max: %g", gmaxProc);

logMax = log(gmaxProc + 1);   % global log-range is [0, logMax]
fprintf("Processed global max: %.6g\n", gmaxProc);
fprintf("Global log range    : [0, %.6g]\n", logMax);

%% Pass 3: process, normalize globally to [0,1], save
fprintf("Pass 3/3: Save all images\n");

for k = 1:numel(f)
    S = load(fullfile(f(k).folder, f(k).name), "screen");
    img = S.screen.image;

    validateImage(img, f(k), "raw");

    I = preprocessFrame(img, gShort, padSize, padMode, outSize, resizeMethod);
    validateImage(I, f(k), "after preprocess");

    logImage = log(I + 1);
    validateImage(logImage, f(k), "after log");

    % Global normalization to [0,1]
    if logMax > 0
        Inorm = mat2gray(logImage, [0, logMax]);
    else
        % all images are zero everywhere
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
I = padarray(I, padSize, padMode, 'both');
I = imresize(I, outSize, resizeMethod);

% Clamp negatives from interpolation
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