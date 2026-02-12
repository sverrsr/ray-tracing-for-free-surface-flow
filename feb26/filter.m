I = im2double(I);
if ndims(I) == 3
    I = rgb2gray(I);
end

F = fftshift(fft2(I));
[M,N] = size(F);

H = ones(M,N);

% ---- tune these ----
d  = 5;     % notch radius (pixels)
u0 = 20;    % horizontal offset from center
v0 = 20;    % vertical offset from center
% --------------------

[X,Y] = meshgrid(1:N, 1:M);
xc = (N+1)/2; 
yc = (M+1)/2;

H(((X-xc-u0).^2 + (Y-yc-v0).^2) < d^2) = 0;
H(((X-xc+u0).^2 + (Y-yc+v0).^2) < d^2) = 0;

I_clean = real(ifft2(ifftshift(F .* H)));
imshow(I_clean,[])
