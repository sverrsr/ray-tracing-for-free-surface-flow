function matrice2Seperate(surfElev, outFolder)
%MATRICE2SEPERATE Summary of this function goes here
%   Detailed explanation goes here

arguments (Input)
    surfElev
    outFolder = "C:\Users\sverrsr\Documents\DATA\re2500_weInf\re2500_weInf_surfElev";
end


[nFrames, ~, ~] = size(surfElev);

for k = 1:nFrames
    frame = squeeze(surfElev(k,:,:));   %#ok<NASGU>

    filename = fullfile(outFolder, ...
        sprintf('re2500_weInf_surfElev_%05d.mat', k));

    tmp.surfElev = squeeze(surfElev(k,:,:));
    save(filename, '-struct', 'tmp');

    if mod(k,100)==0 || k==1 || k==nFrames
        fprintf('Saved %d / %d\n', k, nFrames);
    end
end

disp('Done.')

end