clear; clc;


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


% 4) ray trace

rt.raytrace(X, Y, c);

pp.raw_to_filtered(c);

anal.run_meanCorrVsHeight(c);

%%
inFolder = "C:\Users\sverrsr\Documents\DATA\re2500_we20\re2500_we20_14800_rayTraced_400k\re2500_we20_raytraced_D5.33pi";

outFolder = "C:\Users\sverrsr\Documents\DATA\re2500_we20\re2500_we20_14800_rayTraced_400k_png";
%%
screen2png(inFolder, outFolder)

%%
exp_denoising(outFolder);

%%
png2video("C:\Users\sverrsr\Documents\ray-tracing-for-free-surface-flow\cache_DENOISED\png_input\denoised_png");





