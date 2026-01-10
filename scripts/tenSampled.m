clear; clc; close all;
startup

c = cfg.dns_default();
G = grid.make(c);

%benchFn = @optical.tenSampledBench;
benchFn = @(G,Z,d) optical.tenSampledBench(G.X, G.Y, Z, d, c.simulation.nRays);


rt.raytrace(G, c, benchFn);
