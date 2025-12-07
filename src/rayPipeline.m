% src/pipeline.m
function out = rayPipeline(Z, G, ~)
    [screen, rays_out, bench, surf] = example_Bench(G.X, G.Y, Z);

    out.screen = screen;
    out.rays   = rays_out;
    out.bench  = bench;
    out.surf   = surf;
end