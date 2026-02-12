clear; clc; close all;

% Can be run without any changes

% 1) choose config
c = cfg.example_cfg;

% 2) build grid
G = grid.make(c);
X = G.X;
Y = G.Y;

% 3) ray trace

rt.raytrace(X, Y, c);

% 4) process raw data
pp.raw_to_filtered(c);

% 4) check how it correlates with teh actual surface
anal.run_meanCorrVsHeight(c);
