function LF = screen(Xs,Ys,X,Y,ETA,D,bR, timer)

% function LF = screenfun(Xs,Ys,X,Y,ETA,D,bR, timer)
%
% (Xs,Ys) are coordinates of the screen.
% (X,Y,ETA) is the surface
% D is the distance from surface to screen relative to surface sideslength.
% bR is the blur radius of the image. Typically between 0.005 and 0.05.
% timer: true/false. Whether to print tic/toc.
%
% Either enter all inputs or none; not flexible like that!

close all;
L = 1; %define size of incoming image (normalisation)
nearRs = 3; %number of standard deviations considered "nearby"
periodicBC = false; %much slower if this is "true". When false you slight rubbish near the edge
plotsurface = false; %Plot original surface with screen shown
plotscreen = true;

%Set values that are used if you just press F5
if nargin < 8
    D = 0.25;%Screen distance std 0.025
    swidth = L;
    data = load('RE2500_eta_t5000.mat');
    ETA = data.eta;
    Ns = 256; %resolution of screen is Ns x Ns
    X = data.X; Y=data.Y;
    bR = 0.005; %Blur radius relative to domain length
    clear data;
    hs = swidth/Ns;
    timer = true;
    [Xs,Ys] = meshgrid(0:hs:swidth); %here: screen coveres the whole shit
    %Note: the code can be perhaps be optimised if the screen is smaller 
    % than the surface. No need then to scatter from everywhere. 
else
    Ns = length(Xs(:,1));
    swidth = Xs(1,Ns)-Xs(1,1);
    hs = swidth/Ns;
end

if timer; tic; end

inv2pi =  0.159154943091895;
invbrr = 1/nearRs;
invbR = 1/bR;

%Derivatives of ETA (actually contained in input, so no need)
N = length(X(:,1)); 
width = X(1,N)-X(1,1);
scale = L/width;
X = X*scale; Y=Y*scale; ETA = ETA*scale;

%number of elements either side in smaller "neighbour" matrix
nside = ceil(nearRs*bR/hs);

%Plot original surface
if plotsurface
    figure(1);
    s=imagesc(ETA/scale);
    colormap gray;
    axis equal; axis tight; axis off;
    hold on;
    rectangle('Position',[Xs(1,1) Ys(1,1) swidth swidth]*width/L,'EdgeColor','r')
    title('Original surface');
end 

h = X(1,2)-X(1,1); %Assume uniform spacing.
[dEx,dEy] = gradient(ETA,h,h);

Xray = X + 2*(D-ETA).*dEx./(1-dEx.*dEx);
Yray = Y + 2*(D-ETA).*dEy./(1-dEy.*dEy);


if periodicBC   %move rays that leave the domain back in the other side
    Xray = mod(Xray,L);
    Yray = mod(Yray,L);
end

LF = Xs.*0; %zero matrix with right dimension

for j=1:N %Looping through the ETA coordinates
    for i=1:N
        dLF = LF*0;
        dX = Xs-Xray(i,j); 
        dY = Ys-Yray(i,j);
        if periodicBC
            %The distance must lie between -L/2 and L/2. This operation is
            %slow.
            dX = -.5*L + mod(dX+.5*L,L);
            dY = -.5*L + mod(dY+.5*L,L);
        end
        %Only regard points that are near enough
        dRsq = (dX.*dX+dY.*dY)*invbR*invbR;
        near = dRsq < (nearRs)^2;         
        %Gaussian blur
        dLF(near) = inv2pi*invbrr*exp(-.5*dRsq(near));

        LF = LF + dLF;
    end
end
% 

%Plot the surface
if plotscreen
    figure(2);
    s=imagesc(LF);
    colormap gray;
    axis equal; axis tight; axis off;
    title(sprintf('Light scatter, D=%.3f',D));
end

if nargin==0; LF=0; end %to avoid getting a massive output when pressing F5
if timer
    toc 
end

end
