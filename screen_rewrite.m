clear; %clc;

%Set values that are used if you just press F5
D = 0.025; %1.5; %%Screen distance relative to surface side length

data = load('RE2500_eta_t5000.mat');
ETA = data.eta;
x = data.X(1,:);
y = data.Y(:,1);
[X,Y] = meshgrid(x,y);
clear data x y;

% D = linspace(0, 2, 10);
% Compute LF for each D value and store results in a 3D array
nD = numel(D);
% Ensure Ns is defined consistently with screen resolution used in screen()
N = length(X(:,1));
Ns = N; %resolution of screen is Ns x Ns
LF = zeros(Ns, Ns, nD);

for k = 1:nD
    LF(:,:,k) = screen(ETA,X,Y,D(k));
end
%LF = screen(ETA,X,Y,D);


function LF = screen(ETA,X,Y,D)

% function LF = screen(ETA,X,Y,D)
%
% (X,Y,ETA) is the surface
% D is the distance from surface to screen relative to surface sideslength.
%
% Other settings are set below.

%close all;
nearRs = 3; %number of standard deviations considered "nearby"
periodicBC = false; %much slower if this is "true". When false you slight rubbish near the edge
plotsurface = false; %Plot original surface with screen shown
plotscreen = true;
bR = 0.005; %Blur radius relative to domain length
timer = true; %Whether to print tic/toc.

% Reflection model for screen mapping:
%   false -> decoupled 2D tan(2*theta) mapping per axis (legacy)
%   true  -> exact 3D mirror reflection from n ∝ (-eta_x,-eta_y,1)
useExact3DReflection = true;

% Screen extent controls:
%   []   -> use full domain extents from X,Y (legacy)
%   > 0  -> use fixed square side length (same units as X,Y), centered in domain
fixedScreenSize = [];

N = length(X(:,1));
Ns = N; %resolution of screen is Ns x Ns


width = (X(1,N)-X(1,1));
swidth = width;

if ~isempty(fixedScreenSize)
    swidth = fixedScreenSize;
end

hs = swidth/Ns;
xCenter = 0.5*(X(1,1) + X(1,N));
yCenter = 0.5*(Y(1,1) + Y(N,1));
Xs1 = xCenter - 0.5*swidth + (0:Ns-1)*hs;
Ys1 = yCenter - 0.5*swidth + (0:Ns-1)*hs;
[Xs,Ys] = meshgrid(Xs1,Ys1);
%Note: the code can be perhaps be optimised if the screen is smaller 
% than the surface. No need then to scatter from everywhere. 

if timer; tic; end

inv2pi =  0.159154943091895;

%D and bR are relative to the surface side length
Drel = D;
bRrel = bR;

Lphys = 2*pi;
fprintf('Domain length = 2*pi = %.16g\n', Lphys);

%D and bR are relative to the surface side length
D = D*width;

fprintf('ETA range = [%g, %g], mean = %g\n', min(ETA(:)), max(ETA(:)), mean(ETA(:)));

DZ = D - ETA;
fprintf('D-ETA range = [%g, %g], mean = %g\n', min(DZ(:)), max(DZ(:)), mean(DZ(:)));

bR = bR*width;

fprintf('D = %.16g*pi = %.16g\n', 2*Drel, Drel*Lphys);
fprintf('bR = %.16g*pi = %.16g\n', 2*bRrel, bRrel*Lphys);
fprintf('Internal width = %.16g\n', width);
fprintf('Internal D = %.16g, internal bR = %.16g\n', D, bR);

invbrr = 1/nearRs;
invbR = 1/bR;

%number of elements either side in smaller "neighbour" matrix
nside = ceil(nearRs*bR/hs); %#ok<NASGU>

%Plot original surface
if plotsurface
    figure();
    s=imagesc(ETA); %#ok<NASGU>
    colormap gray;
    axis equal; axis tight; axis off;
    hold on;
    rectangle('Position',[Xs(1,1) Ys(1,1) swidth swidth],'EdgeColor','r')
    title('Original surface');
end 

h = X(1,2)-X(1,1); %Assume uniform spacing.
[dEx,dEy] = gradient(ETA,h,h);

if useExact3DReflection
    % Exact 3D reflection for incidence i = (0,0,-1) and surface z = eta(x,y)
    % n ~ (-eta_x,-eta_y,1)
    denom = 1 - dEx.*dEx - dEy.*dEy;
    Xray0 = X - 2*(D-ETA).*dEx./denom;
    Yray0 = Y - 2*(D-ETA).*dEy./denom;
else
    % Legacy decoupled 2D formula applied independently in x and y.
    Xray0 = X + 2*(D-ETA).*dEx./(1-dEx.*dEx);
    Yray0 = Y + 2*(D-ETA).*dEy./(1-dEy.*dEy);
end

dXray = Xray0 - X;
dYray = Yray0 - Y;
fprintf('X displacement range = [%g, %g], max abs = %g\n', min(dXray(:)), max(dXray(:)), max(abs(dXray(:))));
fprintf('Y displacement range = [%g, %g], max abs = %g\n', min(dYray(:)), max(dYray(:)), max(abs(dYray(:))));

Xray = Xray0;
Yray = Yray0;

if periodicBC   %move rays that leave the domain back in the other side
    Xray = mod(Xray-X(1,1),width) + X(1,1);
    Yray = mod(Yray-Y(1,1),width) + Y(1,1);
end

LF = Xs.*0; %zero matrix with right dimension

for j=1:N %Looping through the ETA coordinates
    for i=1:N
        dLF = LF*0;
        dX = Xs-Xray(i,j); 
        dY = Ys-Yray(i,j);
        if periodicBC
            %The distance must lie between -width/2 and width/2. This operation is
            %slow.
            dX = -.5*width + mod(dX+.5*width,width);
            dY = -.5*width + mod(dY+.5*width,width);
        end
        %Only regard points that are near enough
        dRsq = (dX.*dX+dY.*dY)*invbR*invbR;
        near = dRsq < (nearRs)^2;         
        %Gaussian blur
        dLF(near) = inv2pi*invbrr*exp(-.5*dRsq(near));

        LF = LF + dLF;
    end
end

%Plot the surface
if plotscreen
    figure();
    s=imagesc(LF); %#ok<NASGU>
    colormap gray;
    axis equal; axis tight; axis off;
    title(sprintf('Light scatter, D=%.3f',D/width));
end
fprintf('max |dEx| = %g\n', max(abs(dEx(:))));
fprintf('max |dEy| = %g\n', max(abs(dEy(:))));
fprintf('X range    = [%g, %g]\n', min(X(:)), max(X(:)));
fprintf('Y range    = [%g, %g]\n', min(Y(:)), max(Y(:)));
fprintf('Xray0 range = [%g, %g]\n', min(Xray0(:)), max(Xray0(:)));
fprintf('Yray0 range = [%g, %g]\n', min(Yray0(:)), max(Yray0(:)));
fprintf('Xray range = [%g, %g]\n', min(Xray(:)), max(Xray(:)));
fprintf('Yray range = [%g, %g]\n', min(Yray(:)), max(Yray(:)));

onScreen0 = Xray0 >= Xs(1,1) & Xray0 <= Xs(1,end) & ...
            Yray0 >= Ys(1,1) & Yray0 <= Ys(end,1);
fprintf('Unwrapped rays on screen = %.2f %%\n', 100*nnz(onScreen0)/numel(onScreen0));

onScreen = Xray >= Xs(1,1) & Xray <= Xs(1,end) & ...
           Yray >= Ys(1,1) & Yray <= Ys(end,1);
fprintf('Wrapped rays on screen = %.2f %%\n', 100*nnz(onScreen)/numel(onScreen));

if timer
    toc 
end

end
