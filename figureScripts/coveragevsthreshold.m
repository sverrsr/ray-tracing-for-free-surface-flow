% Clear workspace and figures

% For making figure 5.2.1, threshold graph

clear all; clc; close all;
fileName = 'screen_1024bins_0001.mat';   % <--- change to any file you want
fileName = 'screen_1024bins_0002.mat';
% fileName = 'screen_1024bins_0003.mat';
% fileName = 'screen_1024bins_0004.mat';
% fileName = 'screen_1024bins_0005.mat';
% fileName = 'screen_1024bins_0006.mat';
% fileName = 'screen_1024bins_0007.mat';
% fileName = 'screen_1024bins_0008.mat';
% fileName = 'screen_1024bins_0009.mat';
% fileName = 'screen_1024bins_0010.mat';
% Create a new folder to save processed files
outputFolder = fullfile('C:\Users\sverr\Documents\NTNU\Figures', 'smoothing');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
    fprintf('Created folder: %s\n', outputFolder);
end
%% USER PARAMETERS
%Set threshhold between 0 (black) and 1 (white)
params.sigmaSmooth = 3.5;        % Gaussian smoothing, 2 seemed ok
%% LOAD IMAGE
data = load(fileName);
img_raw = double(data.screen.image);

% Crop
img = cropimg(img_raw);
imgSmooth = imgaussfilt(img, params.sigmaSmooth);
imgContrast = imadjust(imgSmooth);
Xs = imgContrast;   % already smoothed + contrast-adjusted
threshVec = linspace(0,1,400);
covVec = zeros(size(threshVec));

% Compute fraction of pixels above each threshold
for i = 1:numel(threshVec)
    covVec(i) = nnz(Xs > threshVec(i)) / numel(Xs);
end
% -----------------------------
% FIGURE SIZE (cm)
% -----------------------------
width_cm  = 13.7;
aspect    = 2.35;
height_cm = width_cm / aspect;
figure;
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

plot(threshVec, covVec, 'k-', 'LineWidth', 1.5);
hold on;
xline(0.8411, 'k--', 'LineWidth', 1.2);
hold off;
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
xlabel('Threshold $I_{\mathrm{thr}}$','FontSize',14);
ylabel('Coverage','FontSize',14);


title('','FontSize',14);   % empty title to match your reference
% -----------------------------
% OPTIONAL: LIMITS (match look)
% -----------------------------
xlim([min(threshVec) max(threshVec)]);
ylim([0 1]);
% -----------------------------
% EXPORT (MANUAL-QUALITY PDF)
% -----------------------------
set(gcf,'Renderer','painters','InvertHardcopy','off');
pdfFile = 'coverage_vs_threshold.pdf';
print(gcf, pdfFile, '-dpdf', '-painters');