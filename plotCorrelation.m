% ---- READ TABLES ----
re1000_we10_meanCorr  = readtable('re1000_we10_meanCorr.csv');
re1000_we20_meanCorr  = readtable('re1000_we20_meanCorr.csv');
re1000_weInf_meanCorr = readtable('re1000_weInf_meanCorr.csv');

re2500_we10_meanCorr  = readtable('re2500_we10_meanCorr.csv');
re2500_we20_meanCorr  = readtable('re2500_we20_meanCorr.csv');
re2500_weInf_meanCorr = readtable('re2500_weInf_meanCorr.csv');

% ---- PLOT ----
figure; hold on; grid on;

plot(re1000_we10_meanCorr{:,3},  re1000_we10_meanCorr{:,4},  'DisplayName','re1000 we10');
plot(re1000_we20_meanCorr{:,3},  re1000_we20_meanCorr{:,4},  'DisplayName','re1000 we20');
plot(re1000_weInf_meanCorr{:,3}, re1000_weInf_meanCorr{:,4}, 'DisplayName','re1000 weInf');

plot(re2500_we10_meanCorr{:,3},  re2500_we10_meanCorr{:,4},  'DisplayName','re2500 we10');
plot(re2500_we20_meanCorr{:,3},  re2500_we20_meanCorr{:,4},  'DisplayName','re2500 we20');
plot(re2500_weInf_meanCorr{:,3}, re2500_weInf_meanCorr{:,4}, 'DisplayName','re2500 weInf');

legend('Location','best');
xlabel('X - as multiples of pi');
ylabel('Y - Correlation');
title('Mean Correlation at each distance');
