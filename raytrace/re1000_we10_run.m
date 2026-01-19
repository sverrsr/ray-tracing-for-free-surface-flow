clear; clc; close all;

startup

% 1) choose config
c = cfg.dns_re1000_we10_cfg;


% % 3) load surface data
% Z = io.loadSurface(input.surfacePath);

% 4) build grid
G = grid.make(c);
X = G.X;
Y = G.Y;

% % 5) run pipeline (bench, rays, etc.)
% out = pipeline.rayPipeline(Z, G, c);

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
