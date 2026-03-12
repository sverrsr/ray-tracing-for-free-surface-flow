function surface = stackSurface(f)
%f = dir("C:\Users\sverrsr\Documents\DATA\re2500_weInf_test\re2500_weInf_surfElev_5\*.mat");

[~,idx] = sort({f.name});
f = f(idx);

S = load(fullfile(f(1).folder,f(1).name));
A = S.(fieldnames(S){1});

stack = zeros(256,256,numel(f),class(A));
stack(:,:,1) = A;

for k = 2:numel(f)
    S = load(fullfile(f(k).folder,f(k).name));
    stack(:,:,k) = S.(fieldnames(S){1});
end

surface = stack;
end