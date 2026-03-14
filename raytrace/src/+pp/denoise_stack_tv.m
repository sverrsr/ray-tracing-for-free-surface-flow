function vid = denoise_stack_tv(y, opts)
%DENOISE_STACK_TV Denoise 3D stack using spatiotemporal TV (in-memory version).
%
% This keeps the denoising core used by denoisingMat/exp_denoising but avoids
% writing intermediate frame folders.

arguments
    y (:,:,:) {mustBeNumeric, mustBeReal}
    opts.useGPU (1,1) logical = true
    opts.lamSpatial (1,1) double = 5e-2/2
    opts.lamTemporal (1,1) double = 15e-2/2
    opts.nIters (1,1) double = 150/2
end

y = single(y);
K_total = size(y, 3);

if K_total < 2
    vid = y;
    return;
end

K = floor(K_total/2);
K = max(2, K);
if mod(K, 2) ~= 0
    K = K - 1;
end
if K < 2
    K = 2;
end

frame_start = 1;
frame_step = K/2;
frame_end = K_total;

useGPU = opts.useGPU && canUseGPU();
if useGPU
    device = gpuDevice();
    reset(device);
end

vid = zeros(size(y), 'single');
flag = true;

for frame = frame_start:frame_step:frame_end-K+1
    y_batch = y(:,:,frame:frame+K-1);
    if useGPU
        y_batch = gpuArray(y_batch);
    end

    [n1,n2,n3] = size(y_batch);
    w_est = zeros(n1,n2,n3,3, 'like', y_batch);
    v_est = zeros(n1,n2,n3,3, 'like', y_batch);

    for iter = 1:opts.nIters
        w_next = v_est + 1/12 * Df(y_batch - DTf(v_est));

        a = abs(w_next(:,:,:,1)); w_next(:,:,:,1) = w_next(:,:,:,1) .* min(1, opts.lamSpatial ./ max(a, 1e-8));
        a = abs(w_next(:,:,:,2)); w_next(:,:,:,2) = w_next(:,:,:,2) .* min(1, opts.lamSpatial ./ max(a, 1e-8));
        a = abs(w_next(:,:,:,3)); w_next(:,:,:,3) = w_next(:,:,:,3) .* min(1, opts.lamTemporal ./ max(a, 1e-8));

        v_est = w_next + iter/(iter+3) * (w_next - w_est);
        w_est = w_next;
    end

    if useGPU
        vid_denoised = gather(real(y_batch - DTf(w_est)));
    else
        vid_denoised = real(y_batch - DTf(w_est));
    end

    if flag
        vid(:,:,frame:frame+K-1) = vid_denoised;
        flag = false;
    else
        a = reshape(linspace(0,1,K/2), 1,1,[]);
        blendRange = frame:frame+K/2-1;
        vid(:,:,blendRange) = (1-a).*vid(:,:,blendRange) + a.*vid_denoised(:,:,1:K/2);
        vid(:,:,frame+K/2:frame+K-1) = vid_denoised(:,:,K/2+1:K);
    end
end

% Tail frames when K_total is not fully covered by batches
if frame_end > (frame_end-K+1) + K - 1
    tailStart = (frame_end-K+1) + K;
    vid(:,:,tailStart:end) = y(:,:,tailStart:end);
end

vid = max(min(single(vid), 1), 0);

end

function tf = canUseGPU()
tf = false;
try
    tf = gpuDeviceCount("available") > 0;
catch
    tf = false;
end
end

function w = Df(x)
if size(x,3) > 1
    w = cat(4, x(1:end,:,:) - x([2:end,end],:,:), ...
               x(:,1:end,:) - x(:,[2:end,end],:), ...
               x(:,:,1:end) - x(:,:,[2:end,end]));
else
    w = cat(4, x(1:end,:,:) - x([2:end,end],:,:), ...
               x(:,1:end,:) - x(:,[2:end,end],:), ...
               zeros(size(x(:,:,1)), 'like', x));
end
end

function u = DTf(w)
u1 = w(:,:,:,1) - w([end,1:end-1],:,:,1);
u1(1,:,:) = w(1,:,:,1);
u1(end,:,:) = -w(end-1,:,:,1);

u2 = w(:,:,:,2) - w(:,[end,1:end-1],:,2);
u2(:,1,:) = w(:,1,:,2);
u2(:,end,:) = -w(:,end-1,:,2);

if size(w,3) > 1
    u3 = w(:,:,:,3) - w(:,:,[end,1:end-1],3);
    u3(:,:,1) = w(:,:,1,3);
    u3(:,:,end) = -w(:,:,end-1,3);
else
    u3 = 0;
end

u = u1 + u2 + u3;
end
