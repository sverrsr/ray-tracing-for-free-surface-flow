clear; clc; close all;

startup

% 1) choose config
c = cfg.re2500_we10_cfg;

% 2) build grid
G = grid.make(c);
X = G.X;
Y = G.Y;

%%
sx = size(X); sy = size(Y);
fprintf('size(X) = [%d %d]\n', sx(1), sx(2));
fprintf('size(Y) = [%d %d]\n', sy(1), sy(2));
%%

% 3

rt.raytrace(X, Y, c);

% 6) you can plot here or inside rayPipeline
fprintf("Dimensions (mm): %.2f × %.2f\n", c.grid.lx, c.grid.ly);

% %%
% clear; clc; close all;
% startup
% 
% c = cfg.dns280();
% G = grid.make(c);
% 
% %benchFn = @optical.DNS_Bench;
% benchFn = @(G,c,Z,d) optical.DNS_Bench(Z, G, setfield(c,'simulation',setfield(c.simulation,'distance',d)));
% 
% 
% rt.raytrace(G, c, benchFn);
