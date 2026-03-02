function [I] = cropimg_787_5p(img_raw, targetSize)
%CROPIMG_787_5p crops the image to a global size found by 
% searchGlobalImageSize.m
% 
%   The reason behind it is to remove coarse borders 
% and get all images teh same size


arguments (Input)
    img_raw
    targetSize
end

arguments (Output)
    I
end


[H, W, ~] = size(img_raw);

if H < targetSize || W < targetSize
    error('Image smaller than 787x787');
end

y0 = floor((H - targetSize)/2) + 1;
x0 = floor((W - targetSize)/2) + 1;

I = img_raw(y0:y0+targetSize-1, x0:x0+targetSize-1, :);

% % Crop another 5% (centered)
% [H2, W2, ~] = size(I);
% 
% cropY = round(0.05 * H2);
% cropX = round(0.05 * W2);
% 
% I = I( ...
%     cropY+1 : H2-cropY, ...
%     cropX+1 : W2-cropX, ...
%     :);

end




