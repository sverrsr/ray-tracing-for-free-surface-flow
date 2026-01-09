clc; close all; clear;

% For making figure all correlations togheter


% --- Load datasets ---
load("WeInf_corr_vs_height.mat");
hPi_inf  = hPi;
corr_inf = meanCorrByDist;
valid_inf = valid;

load("we_10_corr_vs_height_data.mat");
hPi_10  = hPi;
corr_10 = meanCorrByDist;
valid_10 = valid;

load("we_20_corr_vs_height_data.mat");
hPi_20  = hPi;
corr_20 = meanCorrByDist;
valid_20 = valid;


% -----------------------------
% FIGURE SIZE (cm)
% -----------------------------
width_cm  = 13.7;
aspect    = 3/2;
height_cm = width_cm / aspect;
figure;



% -----------------------------
% FIGURE
% -----------------------------

hold on;

c_black      = [0, 0, 0];
c_green      = [0,158,115] / 255;
c_blue       = [0,114,178] / 255;
c_lightblue  = [86,180,233] / 255;


% --- We = 10 ---
[x2, i2] = sort(hPi_10(valid_10));
y2 = corr_10(valid_10);
y2 = y2(i2);
plot(x2, y2, '-s', 'LineWidth', 1.0, 'Color', c_green);

% --- We = 20 ---
[x3, i3] = sort(hPi_20(valid_20));
y3 = corr_20(valid_20);
y3 = y3(i3);
plot(x3, y3, '-^', 'LineWidth', 1.0, 'Color', c_blue);

% --- We = ∞ ---
[x1, i1] = sort(hPi_inf(valid_inf));
y1 = corr_inf(valid_inf);
y1 = y1(i1);
plot(x1, y1, '-o', 'LineWidth', 1.0, 'Color', c_black);


hold off;

set(gcf,'Units','centimeters');
set(gcf,'Position',[2 2 width_cm height_cm]);
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',[0 0 width_cm height_cm]);
set(gcf,'PaperSize',[width_cm height_cm]);
set(gcf,'Color','w');


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

grid on; box on;

xlabel('Source distance $x/L$','FontSize',14);
ylabel('Correlation','FontSize',14);
legend({'We = 10', 'We = 20', 'We = ∞'}, ...
       'Location','best','FontSize',14);

% π ticks
allX = [x1; x2; x3];
xt = 0:3:ceil(max(allX));
xticks(xt);
xticklabels(arrayfun(@(x) makePiLabel(x), xt, 'UniformOutput', false));
set(gca,'XTickMode','manual','XTickLabelMode','manual');

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
