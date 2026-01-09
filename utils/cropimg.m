function [img_crop] = cropimg(img_raw)
%CROPIMG Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    img_raw
end

arguments (Output)
    img_crop
end

thr = 1e-6;

% find all rows that contain something above threshold
rows = find(any(img_raw > thr, 2));

% find all columns that contain something above threshold
cols = find(any(img_raw > thr, 1));

% if nothing found, avoid crash
if isempty(rows) || isempty(cols)
    error('Image contains no values above threshold.');
end

% compute bounding box
r1 = rows(1);
r2 = rows(end);
c1 = cols(1);
c2 = cols(end);

% crop the image
img_crop = img_raw(r1:r2, c1:c2);

end




