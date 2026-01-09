function [img_filt] = finalPP(img_raw)
% finalPP  Preprocess image: crop, smooth, enhance, threshold, remove small objects
%   img_filt = finalPP(img_raw)
%   Returns a binary mask after basic preprocessing.

arguments (Input)
    img_raw
end

arguments (Output)
    img_filt
end

%Set threshhold between 0 (black) and 1 (white)

params.sigmaSmooth = 3.5;        % Gaussian smoothing, 2 seemed ok
params.thresh = 0.8411;        % Gaussian smoothing, 2 seemed ok
params.minArea = 10;
params.conn = 8;

% Crop
img = cropimg(img_raw);


imgSmooth = imgaussfilt(img, params.sigmaSmooth);


imgContrast = imadjust(imgSmooth);

BW = imgContrast > params.thresh;

% fjern alle komponenter mindre enn minArea
BW_keep = bwareaopen(BW, round(params.minArea), params.conn);

img_filt = BW_keep; % Assign the filtered binary image to the output variable

end