[screen, rays_out, bench, surf] = pyramid();

%%
% normals
N = rays_out(2).n;   % each row is [nx ny nz]

tol = 1e-10;

% remove noise by rounding each component
Nclean = round(N ./ tol) .* tol;

% find unique rows
[U, ~, idx] = unique(Nclean, 'rows');

% count how many of each vector
counts = accumarray(idx, 1);

% print
for k = 1:size(U,1)
    fprintf('[%g  %g  %g]   (count: %d)\n', U(k,1), U(k,2), U(k,3), counts(k));
end