function out = process_screen_stack(rawStack, useLog)
%PROCESS_SCREEN_STACK Apply screen2mat2-style preprocessing to a 3D image stack.
%
% Input
%   rawStack : [H,W,N] raw ray-traced images.
%   useLog   : true -> log(I+1) before normalization, false -> linear scaling.
%
% Output struct
%   out.normalizedStack : [256,256,N] single in [0,1]
%   out.gShort          : global crop side used for all frames
%   out.gmaxProc        : global max after preprocess (pre-transform)
%   out.transformMax    : max used in normalization domain

arguments
    rawStack (:,:,:) {mustBeNumeric, mustBeReal}
    useLog (1,1) logical = true
end

thr = 1e-6;
outSize = [256 256];
resizeMethod = 'bilinear';

[~, ~, N] = size(rawStack);

% Pass 1: global crop side
fprintf('Pass 1/3: find global crop size from raw stack\n');
gH = inf; gW = inf;
for k = 1:N
    img = double(rawStack(:,:,k));
    rows = find(any(img > thr, 2));
    cols = find(any(img > thr, 1));
    if isempty(rows) || isempty(cols)
        error('Frame %d contains no values above threshold thr=%.3g', k, thr);
    end

    gH = min(gH, rows(end) - rows(1) + 1);
    gW = min(gW, cols(end) - cols(1) + 1);
end

gShort = min(gH, gW);

% Pass 2: global max after preprocessing
fprintf('Pass 2/3: find global max after preprocess\n');
gmaxProc = -inf;
for k = 1:N
    I = preprocessFrame(rawStack(:,:,k), gShort, outSize, resizeMethod);
    gmaxProc = max(gmaxProc, max(I(:)));
end

if useLog
    transformMax = log(gmaxProc + 1);
else
    transformMax = gmaxProc;
end

% Pass 3: normalize stack
fprintf('Pass 3/3: build normalized stack\n');
normalizedStack = zeros(outSize(1), outSize(2), N, 'single');
for k = 1:N
    I = preprocessFrame(rawStack(:,:,k), gShort, outSize, resizeMethod);

    if useLog
        J = log(I + 1);
    else
        J = I;
    end

    if transformMax > 0
        normalizedStack(:,:,k) = single(mat2gray(J, [0, transformMax]));
    else
        normalizedStack(:,:,k) = 0;
    end
end

out = struct();
out.normalizedStack = normalizedStack;
out.gShort = gShort;
out.gmaxProc = gmaxProc;
out.transformMax = transformMax;
out.useLog = useLog;

end

function I = preprocessFrame(img, gShort, outSize, resizeMethod)
I = double(img);
I = cropimg_dynamic(I, gShort);
I = imresize(I, outSize, resizeMethod);
I = max(I, 0);
end
