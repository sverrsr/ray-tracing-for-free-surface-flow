function [img_crop] = cropimg2(img_raw)
%CROPIMG Removing the outermost 5%
arguments (Input)
    img_raw
end

arguments (Output)
    img_crop
end

[Nr, Nc] = size(img_raw);

cropR = floor(0.05 * Nr);
cropC = floor(0.05 * Nc);

img_crop = img_raw( ...
    cropR+1 : Nr-cropR, ...
    cropC+1 : Nc-cropC );


end