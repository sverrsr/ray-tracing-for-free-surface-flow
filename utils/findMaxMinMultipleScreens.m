function [gmin, gmax] = findMaxMinMultipleScreens(inFolder)
%findMaxMinMultipleScreens 
%   Finds global min and max over all screen.image entries in a folder
%   To be used in png2blur.m for scaling

arguments (Input)
    inFolder = "C:\Users\sverr\Documents\NTNU\Prosjekt\Experiments" + ...
        "\grey-variance and correlation\" + ...
        "re2500_weInf_surfElev_first2089_B1024_rayTrace_D3pi";
end

arguments (Output)
    gmin
    gmax
end

tic

f = dir(fullfile(inFolder,"*.mat"));
fprintf("Found %d .mat files\n", numel(f));
assert(~isempty(f), "No .mat files found in %s", inFolder);

gmin = +inf;
gmax = -inf;

for k = 1:numel(f)

    % Load only screen
    S = load(fullfile(f(k).folder, f(k).name), "screen");
    img = S.screen.image;

    if ~isa(img,"double")
        img = im2double(img);
    end

    % Update global min/max
    imin = min(img(:));
    imax = max(img(:));

    gmin = min(gmin, imin);
    gmax = max(gmax, imax);

    if mod(k,100)==0 || k==1 || k==numel(f)
        fprintf("Processed %d/%d  current[min,max]=[%.6g %.6g]\n", ...
            k, numel(f), gmin, gmax);
    end
end

fprintf("\n=== GLOBAL RESULTS ===\n");
fprintf("Global min : %.6g\n", gmin);
fprintf("Global max : %.6g\n", gmax);

if gmin ~= 0
    fprintf("WARNING: global min is not zero!\n");
else
    fprintf("OK: global min is zero as expected.\n");
end

disp("Done.");
toc
end
