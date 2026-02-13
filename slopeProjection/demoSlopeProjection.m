

clear all;
L = 2*pi; %define size of incoming image (normalisation)
nearRs = 3; %number of standard deviations considered "nearby"
periodicBC = false; %much slower if this is "true". When false you slight rubbish near the edge
plotsurface = false; %Plot original surface with screen shown
plotscreen = true;


%Set values that are used if you just press F5

D = L;%Screen distance std 0.025, 0.25*L
swidth = L;
data = load('RE2500_eta_t5000.mat');
ETA = data.eta;
Ns = 256; %resolution of screen is Ns x Ns
X = data.X; Y=data.Y;
bR = 0.005*L; %Blur radius relative to domain length
clear data;
hs = swidth/Ns;
timer = true;
[Xs,Ys] = meshgrid(0:hs:swidth); %here: screen coveres the whole shit
%Note: the code can be perhaps be optimised if the screen is smaller 
% than the surface. No need then to scatter from everywhere. 


LF1 = slopeProjection(L, Xs,Ys,X,Y,ETA, 0.5*L, bR, false);
LF2 = slopeProjection(L, Xs,Ys,X,Y,ETA, L, bR, false);

fprintf("Relative change: %.3e\n", norm(LF2(:)-LF1(:))/norm(LF1(:)));

c = demo_cfg(D);
rt.raytrace(X, Y, c)

% slopeProjection(L, Xs,Ys,X,Y,ETA,D,bR,true);

%%

function c = demo_cfg(D)

c.input.caseName = "example";

%surface elevations is found here
c.input.surfElevDir =       "slopeProjection\demoInput";
% Set outputfolder for screens. If not exists, it is created
c.pp.baseRayTraceDir =      "slopeProjection\demoInput_projected";
% Set outputfolder for filtered pngs. If not exists, it is created
c.pp.baseFilteredDir =      "slopeProjection\demoInput_projectedAndFiltered";

% Distance sweep. Can also be a range using linspace()
c.simulation.distances = D;

% Number of rays
c.simulation.nRays = 100000;

c.grid.nx = 256;
c.grid.ny = 256;

c.grid.nt = 12500;

c.grid.lx = 2*pi;
c.grid.ly = 2*pi;

c.time.dt = 0.06;

end
