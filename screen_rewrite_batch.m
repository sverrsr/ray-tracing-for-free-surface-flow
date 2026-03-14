clear; clc;

% Batch-run the screen() logic for all RE2500_WEINF*.mat files.
% Update these paths for your machine before running.
inFolder = ".";
outFolder = fullfile(inFolder, "screen_outputs");
filePattern = "RE2500_WEINF*.mat";
D = 0.025; % screen distance relative to surface side length

if ~isfolder(outFolder)
    mkdir(outFolder);
end

files = dir(fullfile(inFolder, filePattern));
fprintf('Found %d files matching %s in %s\n', numel(files), filePattern, inFolder);

for fIdx = 1:numel(files)
    inFile = fullfile(files(fIdx).folder, files(fIdx).name);
    fprintf('\n[%d/%d] Processing %s\n', fIdx, numel(files), files(fIdx).name);

    data = load(inFile);

    % Support both lower/upper-case field conventions.
    if isfield(data, 'eta')
        ETA = data.eta;
    elseif isfield(data, 'ETA')
        ETA = data.ETA;
    else
        warning('Skipping %s (missing eta/ETA field).', files(fIdx).name);
        continue;
    end

    if isfield(data, 'X') && isfield(data, 'Y')
        X = data.X;
        Y = data.Y;
    else
        warning('Skipping %s (missing X/Y field).', files(fIdx).name);
        continue;
    end

    if isvector(X) && isvector(Y)
        [X, Y] = meshgrid(X(:).', Y(:));
    end

    nD = numel(D);
    N = length(X(:,1));
    Ns = N;
    LF = zeros(Ns, Ns, nD);

    for k = 1:nD
        LF(:,:,k) = screen(ETA, X, Y, D(k));
    end

    [~, baseName] = fileparts(files(fIdx).name);
    outFile = fullfile(outFolder, baseName + "_screen.mat");
    save(outFile, 'LF', 'D', '-v7.3');
    fprintf('Saved: %s\n', outFile);
end


function LF = screen(ETA,X,Y,D)

nearRs = 3; %number of standard deviations considered "nearby"
periodicBC = false; %much slower if this is "true". When false you slight rubbish near the edge
plotsurface = false; %Plot original surface with screen shown
plotscreen = false;
bR = 0.005; %Blur radius relative to domain length
timer = true; %Whether to print tic/toc.

N = length(X(:,1));
Ns = N; %resolution of screen is Ns x Ns

width = (X(1,N)-X(1,1));
swidth = width;
hs = swidth/Ns;
Xs1 = X(1,1) + (0:Ns-1)*hs;
Ys1 = Y(1,1) + (0:Ns-1)*hs;
[Xs,Ys] = meshgrid(Xs1,Ys1);

if timer; tic; end

inv2pi =  0.159154943091895;
D = D*width;
bR = bR*width;
invbrr = 1/nearRs;
invbR = 1/bR;

if plotsurface
    figure();
    imagesc(ETA);
    colormap gray;
    axis equal; axis tight; axis off;
    hold on;
    rectangle('Position',[Xs(1,1) Ys(1,1) swidth swidth],'EdgeColor','r')
    title('Original surface');
end

h = X(1,2)-X(1,1); %Assume uniform spacing.
[dEx,dEy] = gradient(ETA,h,h);

Xray0 = X + 2*(D-ETA).*dEx./(1-dEx.*dEx);
Yray0 = Y + 2*(D-ETA).*dEy./(1-dEy.*dEy);

Xray = Xray0;
Yray = Yray0;

if periodicBC
    Xray = mod(Xray-X(1,1),width) + X(1,1);
    Yray = mod(Yray-Y(1,1),width) + Y(1,1);
end

LF = Xs.*0;

for j=1:N
    for i=1:N
        dLF = LF*0;
        dX = Xs-Xray(i,j);
        dY = Ys-Yray(i,j);
        if periodicBC
            dX = -.5*width + mod(dX+.5*width,width);
            dY = -.5*width + mod(dY+.5*width,width);
        end
        dRsq = (dX.*dX+dY.*dY)*invbR*invbR;
        near = dRsq < (nearRs)^2;
        dLF(near) = inv2pi*invbrr*exp(-.5*dRsq(near));

        LF = LF + dLF;
    end
end

if plotscreen
    figure();
    imagesc(LF);
    colormap gray;
    axis equal; axis tight; axis off;
    title(sprintf('Light scatter, D=%.3f',D/width));
end

if timer
    toc
end

end
