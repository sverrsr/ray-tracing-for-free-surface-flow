close all; clc; clear all;

folderPath = 'C:\Users\sverr\Documents\NTNU\figures\250';
tileSquare(folderPath);

function tileSquare(folderPath)

files = dir(fullfile(folderPath,'*.fig'));
n = numel(files);

outFig = figure;
tl = tiledlayout(outFig, ceil(sqrt(n)), ceil(n/ceil(sqrt(n))), ...
    'TileSpacing','compact', ...     % even tighter than 'compact'
    'Padding','tight');            % minimal outer padding

for k = 1:n
    f = openfig(fullfile(files(k).folder, files(k).name), 'invisible');

    % get axes
    axOld = findobj(f,'Type','axes', '-not','Tag','legend', '-not','Tag','Colorbar');
    axOld = axOld(1);

    axNew = nexttile(tl);

    % copy plotted content
    copyobj(allchild(axOld), axNew);

    % copy key limits
    axNew.XLim = axOld.XLim;
    axNew.YLim = axOld.YLim;
    axNew.YDir = axOld.YDir;

    % apply colormap
    colormap(axNew, gray);     % <-- change to parula, turbo, hot, etc.

    % square aspect
    axis(axNew,'square');

    % remove clutter
    axNew.XTick = [];
    axNew.YTick = [];
    axNew.XLabel = [];
    axNew.YLabel = [];
    %title(axNew, axOld.Title.String);

    % turn off box if you want it cleaner
    box(axNew,'off');

    close(f);
end

end


figure;
files = dir(fullfile(folderPath,'*.png'));
names = fullfile({files.folder},{files.name});
montage(names);


files = dir(fullfile(folderPath, '*.fig'));
% take first three only
files = files(1:min(3,numel(files)));

figure;
tl = tiledlayout(1, numel(files), ...
    'TileSpacing','compact', ...
    'Padding','compact');

for k = 1:numel(files)
    f = openfig(fullfile(files(k).folder, files(k).name), 'invisible');

    % get axes
    axOld = findobj(f, 'Type','axes', '-not','Tag','legend', '-not','Tag','Colorbar');
    axOld = axOld(1);

    axNew = nexttile(tl);

    

    % copy plotted content
    copyobj(allchild(axOld), axNew);

    % sync axis settings
    axNew.XLim = axOld.XLim;
    axNew.YLim = axOld.YLim;
    axNew.YDir = axOld.YDir;

    % colormap
    colormap(axNew, gray);

    % axis(axNew,'square');

    % cleanup
    % axNew.XTick = [];
    % axNew.YTick = [];
    % axNew.XLabel = [];
    % axNew.YLabel = [];
    % box(axNew,'off');

    title(axNew, axOld.Title.String);

    close(f);
end

%%
clc; close all; clear all;
folderPath = 'C:\Users\sverr\Documents\NTNU\figures\250';

files = dir(fullfile(folderPath, '*.fig'));
%files = files(1:min(3, numel(files)));   % first three only
% Last three
files = files(end-1:end);  % take last three only

figure;
tl = tiledlayout(1, numel(files), ...
    'TileSpacing','compact', ...
    'Padding','compact');

for k = 1:numel(files)
    f = openfig(fullfile(files(k).folder, files(k).name), 'invisible');

    % get axes
    axOld = findobj(f, 'Type','axes', '-not','Tag','legend', '-not','Tag','Colorbar');
    axOld = axOld(1);

    axNew = nexttile(tl);

    % copy plotted content
    copyobj(allchild(axOld), axNew);

    % keep core axis settings
    axNew.XLim = axOld.XLim;
    axNew.YLim = axOld.YLim;
    axNew.YDir = axOld.YDir;

    % aspect ratio preserved (no stretching)
    axis(axNew, 'image');

    % Get actual numeric limits from the figure
    x0 = axNew.XLim(1);
    x1 = axNew.XLim(2);
    y0 = axNew.YLim(1);
    y1 = axNew.YLim(2);
    
    % Choose how many tick marks you want
    ticks = linspace(0, 2*pi, 5);   % 0, π/2, π, 3π/2, 2π
    
    % Map ticks to the original axis scale
    axNew.XTick = x0 + (x1 - x0) * (ticks / (2*pi));
    axNew.YTick = y0 + (y1 - y0) * (ticks / (2*pi));
    
    % Set LaTeX labels for the new ticks
    axNew.XTickLabel = {"0","\pi/2","\pi","3\pi/2","2\pi"};
    axNew.YTickLabel = {"0","\pi/2","\pi","3\pi/2","2\pi"};
    
    axNew.TickLabelInterpreter = "latex";% set ticks from 0 to 2π
 

    % keep original title
    title(axNew, axOld.Title.String);

    % colormap
    colormap(axNew, gray);

    close(f);
end
