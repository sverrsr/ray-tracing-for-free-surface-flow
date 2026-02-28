function [I] = cropimg_787_5p(img_raw)
%CROPIMG_787_5p crops the image to 787 x 787 and another 5% after that
% 
%   The reason behind it is to remove coarse borders in Re2500_WeInf case
%   and get all images teh same size


arguments (Input)
    img_raw
end

arguments (Output)
    I
end

target = 787;

[H, W, ~] = size(img_raw);

if H < target || W < target
    error('Image smaller than 787x787');
end

y0 = floor((H - target)/2) + 1;
x0 = floor((W - target)/2) + 1;

I = img_raw(y0:y0+target-1, x0:x0+target-1, :);

% % Crop another 5%
% cropX = round(0.05 * W);
% cropY = round(0.05 * H);
% 
% I = I( ...
%     cropY+1 : H-cropY, ...
%     cropX+1 : W-cropX, ...
%     :);

end




