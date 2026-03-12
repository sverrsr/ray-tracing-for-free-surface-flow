function screen2mat2(outFile, useLog, inFolder)
% SCREEN2MAT
% Converts a folder of .mat screen objects to one globally normalized MAT file.
%
% Pipeline:
%   Pass 1: find global crop size (gShort)
%   Pass 2: find global processed max after crop -> resize -> clamp
%   Pass 3: process again, log-transform, globally normalize to [0,1], store
%
% Output:
%   A MAT file containing:
%       RE2500_WEINF       : [256,256,N] single, globally normalized to [0,1]

arguments
    outFile  (1,1) string
    useLog   (1,1) logical = true; % Choose intensity scaling before normalization.
                % true  -> apply log(I+1) to compress large outliers from ray-tracing noise.
                % false -> keep linear intensity and normalize directly.
                % Log scaling reduces the influence of rare high-energy pixels,
                % while linear scaling preserves the original signal amplitudes.
    inFolder (1,1) string = "C:\Users\sverrsr\Documents\experiments\test_screens";
end

% Settings
thr = 1e-6;
outSize = [256 256];
padSize = [3 3];
padMode = 'symmetric'; % Haven't applied
resizeMethod = 'bilinear';




% % Automatic output file in current working directory
% if useLog
%     outFile = fullfile(pwd, "RE2500_WEINF_log.mat");
% else
%     outFile = fullfile(pwd, "RE2500_WEINF_lin.mat");
% end


% Check dependency
if exist('screen','class') == 0 && exist('screen','file') == 0
    error("Required type or file 'screen' is not on the MATLAB path.");
end

% Check input folder
assert(isfolder(inFolder), "Folder not found: %s", inFolder);

% List files
f = dir(fullfile(inFolder, "*.mat"));
fprintf("Found %d .mat files\n", numel(f));
assert(~isempty(f), "No .mat files found in %s", inFolder);

% Sort by filename for deterministic order
[~, idx] = sort({f.name});
f = f(idx);

N = numel(f);

tic

%% Pass 1: find global shortest crop side
fprintf("Pass 1/3: Find global crop size\n");

gH = inf;
gW = inf;

for k = 1:N
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

    if mod(k,100)==0 || k==1 || k==N
        fprintf("Read %d/%d  current shortest side = %d\n", ...
            k, N, min(gH, gW));
    end
end

gShort = min(gH, gW);
fprintf("Global crop size: [%d %d]\n", gH, gW);
fprintf("Using gShort = %d\n", gShort);

%% Pass 2: find global processed max
fprintf("Pass 2/3: Find global processed max\n");

gmaxProc = -inf;

for k = 1:N
    S = load(fullfile(f(k).folder, f(k).name), "screen");
    img = S.screen.image;

    validateImage(img, f(k), "raw");

    I = preprocessFrame(img, gShort, padSize, padMode, outSize, resizeMethod);
    validateImage(I, f(k), "after preprocess");

    gmaxProc = max(gmaxProc, max(I(:)));

    if mod(k,100)==0 || k==1 || k==N
        fprintf("Scanned %d/%d  current processed max = %.6g\n", ...
            k, N, gmaxProc);
    end
end

assert(isfinite(gmaxProc) && gmaxProc >= 0, ...
    "Invalid processed global max: %g", gmaxProc);

%logMax = log(gmaxProc + 1);
if useLog
    logMax = log(gmaxProc + 1);
else
    logMax = gmaxProc;
end

fprintf("Processed global min/max after clamp: [0, %.6g]\n", gmaxProc);
fprintf("Log-domain global range            : [0, %.6g]\n", logMax);

%% Pass 3: build final 3D array
fprintf("Pass 3/3: Build output array\n");

RE2500_WEINF = zeros(outSize(1), outSize(2), N, 'single');
files = strings(N,1);

for k = 1:N
    S = load(fullfile(f(k).folder, f(k).name), "screen");
    img = S.screen.image;

    validateImage(img, f(k), "raw");

    I = preprocessFrame(img, gShort, padSize, padMode, outSize, resizeMethod);
    validateImage(I, f(k), "after preprocess");

    % % logImage = log(I + 1);
    % % validateImage(logImage, f(k), "after log");
    % % 
    % % if logMax > 0
    % %     Inorm = mat2gray(logImage, [0, logMax]);
    % % else
    % %     Inorm = zeros(size(logImage), 'like', logImage);
    % % end

    if useLog
        J = log(I + 1);
        validateImage(J, f(k), "after log");
    else
        J = I;
        validateImage(J, f(k), "after transform");
    end
    
    if logMax > 0
        Inorm = mat2gray(J, [0, logMax]);
    else
        Inorm = zeros(size(J), 'like', J);
    end

    RE2500_WEINF(:,:,k) = single(Inorm);
    files(k) = string(f(k).name);

    if mod(k,100)==0 || k==1 || k==N
        fprintf("Stored %d/%d\n", k, N);
    end
end

%% Save once
fprintf("Saving MAT file: %s\n", outFile);
save(outFile, 'RE2500_WEINF', '-v7.3');

disp("Done.");
toc

end


function I = preprocessFrame(img, gShort, ~, ~, outSize, resizeMethod)
% Convert -> crop -> pad -> resize -> clamp

if ~isa(img, "double")
    img = im2double(img);
end

I = cropimg_dynamic(img, gShort);

% Enable this if you want padding:
% I = padarray(I, padSize, padMode, 'both');

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