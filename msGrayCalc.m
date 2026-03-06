inFolder = "re2500_weInf_surfElev_first2089_B1024_rayTrace_D3pi_png_crop787";

f = dir(fullfile(inFolder, "*.png"));
assert(~isempty(f), "No PNG files found.");

[~, idx] = sort({f.name});
f = f(idx);

rmsGray = zeros(numel(f),1);

for k = 1:numel(f)
    img = imread(fullfile(f(k).folder, f(k).name));
    img = im2double(img);

    if k == 5
        figure, imshow(img), title(['Processed Image: ', f(k).name]); colorbar
        drawnow
    end
    
    % Standard deviation
    % Square root of variance
    % RMS of AC component (removing mean)
    % Fluctuation amplitude
    % rmsGray(k) = std(img(:), 1);
    rmsGray(k) = std2(img);

end

%%

figure;
plot(rmsGray, "-"), grid on
title('Square root of variance')
xlabel("Bildeindeks")
ylabel("Square root of variance")
xlim([1 numel(f)]);
