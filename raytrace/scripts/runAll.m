%% re2500_we20_test
clear; clc; close all;

c = cfg.re2500_we20_cfg_test;

G = grid.make(c);
X = G.X;
Y = G.Y;

rt.raytrace(X, Y, c);

pp.raw_to_filtered(c);

anal.run_meanCorrVsHeight(c);

%% re2500_we10
clear; clc; close all;

c = cfg.re2500_we10_cfg;

G = grid.make(c);
X = G.X;
Y = G.Y;

rt.raytrace(X, Y, c);

pp.raw_to_filtered(c);

anal.run_meanCorrVsHeight(c);
%% re2500_we20
clear; clc; close all;

c = cfg.re2500_we20_cfg;

G = grid.make(c);
X = G.X;
Y = G.Y;

%rt.raytrace(X, Y, c);

%pp.raw_to_filtered(c);

anal.run_meanCorrVsHeight(c);

%% re1000_we10
clear; clc; close all;

c = cfg.re1000_we10_cfg;

G = grid.make(c);
X = G.X;
Y = G.Y;

rt.raytrace(X, Y, c);

pp.raw_to_filtered(c);

anal.run_meanCorrVsHeight(c);

%% re1000_we20
clear; clc; close all;

c = cfg.re1000_we20_cfg;

G = grid.make(c);
X = G.X;
Y = G.Y;

rt.raytrace(X, Y, c);

pp.raw_to_filtered(c);

anal.run_meanCorrVsHeight(c);

%% re1000_weInf
clear; clc; close all;

c = cfg.re1000_weInf_cfg;

G = grid.make(c);
X = G.X;
Y = G.Y;

rt.raytrace(X, Y, c);

pp.raw_to_filtered(c);


anal.run_meanCorrVsHeight(c);


%% re2500_weInf
clear; clc; close all;

c = cfg.re2500_weInf_cfg;

G = grid.make(c);
X = G.X;
Y = G.Y;

rt.raytrace(X, Y, c);

pp.raw_to_filtered(c);

anal.run_meanCorrVsHeight(c);

