clear all; clc;

%startup

% 1) choose config
c = cfg.simenCase;

% 2) build grid
data1 = load("C:\Users\sverrsr\Documents\path-trace-for-free-surface-flow\RE2500_eta_t5000.mat");

%ETA = load("C:\Users\sverrsr\Documents\path-trace-for-free-surface-flow\eta\myArray.mat");

x = data1.X(1,:);
y = data1.Y(:,1);
[X,Y] = meshgrid(x,y);

% 3) print grid sizes
sx = size(X); sy = size(Y);
fprintf('size(X) = [%d %d]\n', sx(1), sx(2));
fprintf('size(Y) = [%d %d]\n', sy(1), sy(2));


%% 4) ray trace
    
rt.raytrace(X, Y, c);





