function [X, Y, Z, info] = prepareSurface(xMesh, yMesh, surfaceData)
% prepareSurface  Prepares a surface mesh for interpolation or optimization.
%
% The function sorts the input mesh data, validates the grid spacing, 
% and computes metadata such as grid limits, center, and a safe usable 
% radius that avoids extrapolation at the boundaries.
%
% INPUTS:
%   xMesh        - 2D array of X coordinates from meshgrid
%   yMesh        - 2D array of Y coordinates from meshgrid
%   surfaceData  - 2D array of surface values corresponding to xMesh, yMesh
%
% OUTPUTS:
%   X, Y, Z      - Sorted mesh and surface arrays (same size as inputs)
%   info         - Structure with metadata:
%       .x_limits       [x_min, x_max]
%       .y_limits       [y_min, y_max]
%       .grid_center    [x_center, y_center]
%       .usable_radius  maximum safe radius from center (avoids edges)
%       .edge_buffer    inner margin to prevent extrapolation
%
% EXAMPLE:
%   load surfaceData1200.mat
%   load surfMesh.mat
%   [X, Y, Z, info] = prepareSurface(xMesh, yMesh, surfaceData1200);

% Sort axes
% Meshgrid -> ngrid
[xa, ix] = sort(xMesh(1,:));
[ya, iy] = sort(yMesh(:,1));
X = xMesh(:, ix);
Y = yMesh(iy, :);
Z = surfaceData(iy, ix);

% Compute limits and spacing
x_limits = [xa(1), xa(end)];
y_limits = [ya(1), ya(end)];
grid_center = [mean(x_limits), mean(y_limits)];
half_span = 0.5 * [diff(x_limits), diff(y_limits)];

dx = diff(xa);
dy = diff(ya);
dx_min = min(dx(:));
dy_min = min(dy(:));

if isempty(dx_min) || isempty(dy_min) || ~isfinite(dx_min) || ~isfinite(dy_min)
    error('prepareSurface:InvalidGrid', 'Surface grid must contain at least two unique samples per axis.');
end

min_spacing = min([dx_min, dy_min]);
edge_buffer = 0.5 * min_spacing;

usable_radius = min(half_span) - edge_buffer;
if usable_radius <= 0
    error('prepareSurface:InvalidSurfaceBounds', ...
        'Surface data has insufficient span once edge buffer is removed.');
end

% Return metadata
info = struct('x_limits', x_limits, ...
              'y_limits', y_limits, ...
              'grid_center', grid_center, ...
              'usable_radius', usable_radius, ...
              'edge_buffer', edge_buffer);
end
