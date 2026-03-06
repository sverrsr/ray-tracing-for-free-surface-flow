function mat2video(Y, videoName)
% MAT2VIDEO converts a 3D array (x, y, time) into an MP4 video.
% Each slice Y(:,:,k) is written directly as a grayscale frame.
% No normalization, clamping, or preprocessing is applied.
% The video is saved in the current working directory.

arguments
    Y
    videoName
end


workingDir = pwd;

[~,~,nFrames] = size(Y);

% Rescale
gmin = min(Y(:));
gmax = max(Y(:));
Y = (Y - gmin) ./ (gmax - gmin);

v = VideoWriter(fullfile(workingDir, videoName), 'MPEG-4');
v.FrameRate = 30;
v.Quality = 100;

open(v)

for k = 1:nFrames

    frame = Y(:,:,k);   % nothing done to the frame
    writeVideo(v, frame)


    if mod(k,250)==0 || k==1 || k==nFrames
        fprintf("Processed %d/%d\n", k, nFrames);
    end
end

close(v)

disp("Done.")

end

