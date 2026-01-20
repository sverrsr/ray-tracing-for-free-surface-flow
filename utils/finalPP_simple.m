function [img_filt] = finalPP_simple(img_raw)
%   Simplyfied version of finalPP without removing parts
%   Preprocess image: crop, smooth, enhance, 


arguments (Input)
    img_raw
end

arguments (Output)
    img_filt
end

params.sigmaSmooth = 3.5;        % Gaussian smoothing, 3.5 seemed ok

img = cropimg(img_raw);
imgSmooth = imgaussfilt(img, params.sigmaSmooth);
imgContrast = imadjust(imgSmooth);
img_filt = imgContrast;

end