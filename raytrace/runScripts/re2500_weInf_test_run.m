clear all; clc;

%startup

% 1) choose config
c = cfg.re2500_weInf_cfg_test;

% 2) build grid
G = grid.make(c);
X = G.X;
Y = G.Y;

% 3) print grid sizes
sx = size(X); sy = size(Y);
fprintf('size(X) = [%d %d]\n', sx(1), sx(2));
fprintf('size(Y) = [%d %d]\n', sy(1), sy(2));


%% 4) ray trace

rt.raytrace(X, Y, c);

%% 5) Post processing
%pp.raw_to_filtered2(c);
build_screen_stacks(c);

%%
out = runMS_tiles(X, Y, c);

%%
%anal.run_meanCorrVsHeight(c);





