# Configuration

## What does a simulation look like?

Here's an example of what a full simulation look like:

```matlab
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
```

## How to make a simulation
First step is to configurate the simulation
1. Make a data configuration file. It should contain the grid information of the data

Second step is to set the data
1. Make a cases file. It should contain the path to where the surafce data is found

Third step is to make the optical bench
1. Make a bench file
2. In pipeline, set the bench file