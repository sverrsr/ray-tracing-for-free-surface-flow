% Test for prepareSurface.m

%% surface_run:InvalidGrid
xMesh = 5;
yMesh = 5;
surfaceData = 10;

prepareSurface(xMesh, yMesh, surfaceData);

%% surface_run:InvalidSurfaceBounds
xMesh = [0 1; 0 1];
yMesh = [0 0; 1e-9 1e-9];  % almost identical y-values
surfaceData = rand(2);
prepareSurface(xMesh, yMesh, surfaceData);

%% Valid test
x = linspace(-10, 10, 50);
y = linspace(-5, 5, 30);
[X, Y] = meshgrid(x, y);
Z = exp(-(X.^2 + Y.^2)/25);

[Xs, Ys, Zs, info] = prepareSurface(X, Y, Z);
disp(info)

