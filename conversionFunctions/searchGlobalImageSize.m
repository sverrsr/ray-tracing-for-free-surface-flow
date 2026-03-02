function [gH, gW] = searchGlobalImageSize(inFolder)
%findMaxMinMultipleScreens 
%   Finds global image size over all screen.image entries in a folder
%   To be used in screen2png.m for scaling

arguments (Input)
    inFolder = "C:\Users\sverr\Documents\NTNU\Prosjekt\Experiments" + ...
        "\grey-variance and correlation\" + ...
        "re2500_weInf_surfElev_first2089_B1024_rayTrace_D3pi";
end

arguments (Output)
    gH
    gW
end

% Check that 'screen' class or function is on the path
if exist('screen','class') == 0 && exist('screen','file') == 0
    % Try to provide informative error with suggestion
    error("Required type or file 'screen' is not on the MATLAB path. Add the folder containing the 'screen' class/function to the path before running. (Optometrika)");
end


tic

f = dir(fullfile(inFolder,"*.mat"));
fprintf("Found %d .mat files\n", numel(f));
assert(~isempty(f), "No .mat files found in %s", inFolder);

thr = 1e-6;

N = numel(f);
sizes = zeros(N,2);
boxes = zeros(N,4);
gH = inf;
gW = inf;

for k = 1:numel(f)

    % Load only screen
    S = load(fullfile(f(k).folder, f(k).name), "screen");
    img = S.screen.image;

    if ~isa(img,"double")
        img = im2double(img);
    end

    % Update global min/max
    % tight crop box using threshold (same logic as your cropimg)
    rows = find(any(img > thr, 2));
    cols = find(any(img > thr, 1));

    r1 = rows(1); r2 = rows(end);
    c1 = cols(1); c2 = cols(end);

    h = r2 - r1 + 1;
    w = c2 - c1 + 1;

    boxes(k,:) = [r1 r2 c1 c2];
    sizes(k,:) = [h w];

    % update global smallest rectangle:
    gH = min(gH, h);
    gW = min(gW, w);

    if mod(k,100)==0 || k==1 || k==N
        fprintf("Read %d/%d  current global smallest [H W]=[%d %d], shortest=%d\n", ...
            k, N, gH, gW, min(gH,gW));
    end
end

gSize = [gH gW];
gShort = min(gH,gW);

fprintf("\n=== GLOBAL RESULTS ===\n");
fprintf("Global smallest rectangle [H W] : [%d %d]\n", gSize(1), gSize(2));
fprintf("Global shortest side            : %d\n", gShort);
disp("Done.");
toc
end
