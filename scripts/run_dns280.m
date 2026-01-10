% scripts/runOnlyOne.m
clear; clc; close all;

startup

% 1) choose config
c = dataConfig.dns_default();

% 2) choose case (what data to load)
input = cases.surf_280();

% 3) load surface data
Z = io.loadSurface(input.surfacePath);

% 4) build grid
G = grid.make(c);

% 5) run pipeline (bench, rays, etc.)
out = pipeline.rayPipeline(Z, G, c);

% 6) you can plot here or inside rayPipeline
fprintf("Dimensions (mm): %.2f × %.2f\n", c.grid.lx, c.grid.ly);
