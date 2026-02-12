clear; clc; close all;


% 1) choose config
c = cfg.re2500_weInf_cfg;

% 2) build grid
G = grid.make(c);
X = G.X;
Y = G.Y;

% 3) print grid sizes
sx = size(X); sy = size(Y);
fprintf('size(X) = [%d %d]\n', sx(1), sx(2));
fprintf('size(Y) = [%d %d]\n', sy(1), sy(2));
%

% 3) ray trace

rt.raytrace2(X, Y, c);


