function [img_interp] = newgrid(img, nx, ny)
% NEWGRID  Resample 2-D image onto an Nx-by-Ny grid in [-pi,pi]×[-pi,pi].
% img_interp = newgrid(img, nx, ny)
%
% Inputs:
%   img        - 2-D numeric array (rows = y, cols = x).
%   nx, ny     - Scalars specifying output grid size in x (cols) and y (rows).
%
% Output:
%   img_interp - ny-by-nx array interpolated from img using linear
%                interpolation; points outside the source domain are set to 0.
%
% Notes:
%   - Maps source columns to x ∈ [-pi,pi] and rows to y ∈ [-pi,pi] before
%     interpolation.
%   - For multi-channel (RGB) images, call per channel or extend the function.
%   - interp2 may promote numeric class (commonly to double); cast back if needed.

arguments (Input)
    img
    nx
    ny
end

arguments (Output)
    img_interp
end

[X, Y] = meshgrid( ...
    single(linspace(-pi, pi, nx)), ...
    single(linspace(-pi, pi, ny)) ...
);


[imgNy, imgNx] = size(img);

xS = linspace(-pi, pi, imgNx);   % columns
yS = linspace(-pi, pi, imgNy);   % rows

% Resample image onto the 256x256 grid
img_interp = interp2(xS, yS, img, X, Y, 'linear', 0);

end



