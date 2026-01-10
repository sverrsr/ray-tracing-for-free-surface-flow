clear; clc; close all;
startup

c = cfg.dns_default();
G = grid.make(c);

benchFn = @optical.tenSampledBench;

rt.raytrace(G, c, benchFn);
