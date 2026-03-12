function [gmin, gmax] = maxMinPng(inFolder)
%findMaxMinMultipleScreens 
%   Finds global min and max over all screen.image entries in a folder
%   To be used in png2blur.m for scaling

arguments (Input)
    inFolder = "re2500_weInf_surfElev_first2089_B1024_rayTrace_D3pi_png";
end

arguments (Output)
    gmin
    gmax
end

% Check inFolder
f = dir(fullfile(inFolder,"*.png"));
fprintf("Found %d .png files\n", numel(f));
assert(~isempty(f), "No .png files found in %s", inFolder);

gmin = +inf;
gmax = -inf;

for k = 1:numel(f)

    % Load the image
    I = imread(fullfile(f(k).folder, f(k).name));

    % Ensure image is of type double for processing
    if ~isa(I, "double")
        I = im2double(I);
    end
    

    % Update global min/max
    imin = min(I(:));
    imax = max(I(:));

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
end
