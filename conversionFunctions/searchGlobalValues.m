function [gmin, gmax, gSize, gShort] = searchGlobalValues(inFolder)
% searchGlobalStats
% Combines:
%   - searchGlobalIntensityRange: global min/max intensity over all screen.image
%   - searchGlobalImageSize: global smallest (tight-crop) rectangle size + shortest side
%
% Outputs:
%   gmin   : global minimum pixel value across all images
%   gmax   : global maximum pixel value across all images
%   gSize  : [gH gW] global smallest tight-crop rectangle (height,width)
%   gShort : min(gH,gW) global shortest side from gSize

arguments (Input)
    inFolder (1,1) string = "C:\Users\sverr\Documents\NTNU\Prosjekt\Experiments" + ...
        "\grey-variance and correlation\" + ...
        "re2500_weInf_surfElev_first2089_B1024_rayTrace_D3pi";
end

arguments (Output)
    gmin
    gmax
    gSize
    gShort
end

tic

thr = 1e-6;

% Check that 'screen' class or function is on the path
if exist('screen','class') == 0 && exist('screen','file') == 0
    error("Required type or file 'screen' is not on the MATLAB path. Add the folder containing the 'screen' class/function to the path before running. (Optometrika)");
end

f = dir(fullfile(inFolder,"*.mat"));
fprintf("Found %d .mat files\n", numel(f));
assert(~isempty(f), "No .mat files found in %s", inFolder);

% intensity range init
gmin = +inf;
gmax = -inf;

% size init
gH = inf;
gW = inf;

for k = 1:numel(f)

    % Load only screen
    S = load(fullfile(f(k).folder, f(k).name), "screen");
    img = S.screen.image;

    if ~isa(img,"double")
        img = im2double(img);
    end

    % ---- global intensity range ----
    imin = min(img(:));
    imax = max(img(:));
    gmin = min(gmin, imin);
    gmax = max(gmax, imax);

    % ---- global smallest tight-crop rectangle ----
    rows = find(any(img > thr, 2));
    cols = find(any(img > thr, 1));

    if isempty(rows) || isempty(cols)
        error("Image contains no values above threshold (thr=%.3g). File: %s", thr, f(k).name);
    end

    r1 = rows(1); r2 = rows(end);
    c1 = cols(1); c2 = cols(end);

    h = r2 - r1 + 1;
    w = c2 - c1 + 1;

    gH = min(gH, h);
    gW = min(gW, w);

    if mod(k,100)==0 || k==1 || k==numel(f)
        fprintf("Read %d/%d  intensity[min,max]=[%.6g %.6g]  smallestSide=%d\n", ...
            k, numel(f), gmin, gmax, min(gH,gW));
    end
end

gSize = [gH gW];
gShort = min(gH, gW);

fprintf("\n=== GLOBAL RESULTS ===\n");
fprintf("Global intensity min : %.6g\n", gmin);
fprintf("Global intensity max : %.6g\n", gmax);
fprintf("Global smallest rectangle [H W] : [%d %d]\n", gSize(1), gSize(2));
fprintf("Global shortest side            : %d\n", gShort);

if gmin ~= 0
    fprintf("WARNING: global min is not zero!\n");
else
    fprintf("OK: global min is zero as expected.\n");
end

disp("Done.");
toc
end