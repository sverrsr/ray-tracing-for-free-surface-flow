clc; close all; clear all;
%%
load("WeInf_corr_vs_height.mat")
%%
load("we_20_corr_vs_height_data.mat")
%%
load("we_10_corr_vs_height_data.mat")
%%

% Clear workspace and figures

% For making figure 5.2.1, threshold graph


% Create a new folder to save processed files
outputFolder = fullfile('C:\Users\sverr\Documents\NTNU\Figures', 'corrvsheight');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
    fprintf('Created folder: %s\n', outputFolder);
end


% -----------------------------
% FIGURE SIZE (cm)
% -----------------------------
width_cm  = 13.7;
aspect    = 2.35;
height_cm = width_cm / aspect;
figure;

hold on;

% --- dataset 1 ---
[x1, i1] = sort(hPi(valid));
y1 = meanCorrByDist(valid);
y1 = y1(i1);
plot(x1, y1, '-o', 'LineWidth', 1.0, 'Color', [0 0 0]);     % black

% --- dataset 2 ---
[x2, i2] = sort(x);        % from we_10_corr_vs_height_data.mat
y2 = y(i2);
plot(x2, y2, '-s', 'LineWidth', 1.0, 'Color', [0.2 0.4 1]); % blue-ish

% --- dataset 3 ---
[x3, i3] = sort(hPi20(valid20));       % adjust names if needed
y3 = meanCorr20(valid20);
y3 = y3(i3);
plot(x3, y3, '-^', 'LineWidth', 1.0, 'Color', [1 0.3 0.3]); % red-ish

hold off;



set(gcf,'Units','centimeters');
set(gcf,'Position',[2 2 width_cm height_cm]);
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',[0 0 width_cm height_cm]);
set(gcf,'PaperSize',[width_cm height_cm]);
set(gcf,'Color','w');
% -----------------------------
% PLOT
% -----------------------------
% Insert a vertical dashed line at x = 0.8411



% Sort by threshold
[xSorted, idx] = sort(hPi(valid));
ySorted = meanCorrByDist(valid);
ySorted = ySorted(idx);

plot(xSorted, ySorted, '-o', 'Color',"k", 'LineWidth', 1.0);

grid on;
box on;
% -----------------------------
% AXES FORMATTING
% -----------------------------
ax = gca;
ax.FontSize = 14;
ax.LineWidth = 1;
ax.TickLabelInterpreter = 'latex';
ax.XLabel.Interpreter   = 'latex';
ax.YLabel.Interpreter   = 'latex';
ax.Title.Interpreter    = 'latex';

% -----------------------------
% LABELS (LaTeX)
% -----------------------------
xlabel('Source distance $x/L$','FontSize',14,'Interpreter','latex');
ylabel('Correlation','FontSize',14,'Interpreter','latex');

maxX = max(xSorted);
nMax = ceil(maxX / pi);

xt = 0:3:ceil(max(xSorted));   % tick every 1*pi
xticks(xt);

xticklabels( arrayfun(@(x) makePiLabel(x), xt, 'UniformOutput', false) );

set(gca, 'XTickMode', 'manual', 'XTickLabelMode', 'manual');


title('','FontSize',14);   % empty title to match your reference
% -----------------------------
% OPTIONAL: LIMITS (match look)
% -----------------------------
% xlim([min(threshVec) max(threshVec)]);
% ylim([0 1]);
% -----------------------------
% EXPORT (MANUAL-QUALITY PDF)
% -----------------------------
set(gcf,'Renderer','painters','InvertHardcopy','off');
pdfFile = 'coverage_vs_threshold.pdf';
print(gcf, pdfFile, '-dpdf', '-painters');

function s = makePiLabel(x)
    % x is already measured in multiples of pi
    % x = 1 => π
    % x = 2 => 2π
    % x = 0.5 => 0.5π

    if abs(x) < 1e-12
        s = '0';
        return;
    end

    if abs(x - 1) < 1e-12
        s = '\pi';
        return;
    end

    s = sprintf('%.3g\\pi', x);
end
