function pipelineOut = raytrace(X, Y, c)
%RUNRAYTRACESNAPSHOTS Runs raytracing for all distances and snapshots.roo
%
%   pipelineOut = pipeline.runRaytraceSnapshots(G, c, benchFn)

distances   = c.simulation.distances;
nRays       = c.simulation.nRays;

caseName    = c.input.caseName;
surfElevDir = c.input.surfElevDir;


baseRayTraceDir = c.pp.baseRayTraceDir;

fprintf("Saving simulations in: %s\n", baseRayTraceDir);

snapshotFiles = dir(fullfile(surfElevDir, '*.mat'));
Nt = numel(snapshotFiles);

fprintf('Found %d surface elevation files in %s\n', Nt, surfElevDir);
fprintf('Starting ray tracing with %d rays ...\n', nRays);

pipelineOut = struct(); % optional return

for d = distances
    outDir = fullfile(baseRayTraceDir, caseName + sprintf('_raytraced_D%.2fpi', d/pi));

    if ~exist(outDir, 'dir'); mkdir(outDir); end
       

    fprintf('... Tracing distance %.2f * pi. Saving images in %s\n', d/pi, outDir);

    tStart = tic;
    barLength = 30;

    for k = 1:Nt
        S = load(fullfile(surfElevDir, snapshotFiles(k).name));

        if isfield(S, 'surfElev')
            Z = double(S.surfElev);
        elseif isfield(S, 'Z')
            Z = double(S.Z);
        elseif isfield(S, 'slice')
            Z = double(S.slice);
        else
            error('Unknown variable inside %s', snapshotFiles(k).name);
        end

        % Run optics

        %[screen, ~, ~, ~] = benchFn(X, Y, Z, d, nRays);
        [screen, ~, ~, ~] = bench.DNS_Bench(X, Y, Z, d, nRays);

        % Save
        filename = fullfile(outDir, caseName + sprintf('_screen_D%.2fpi_%05d.mat', d/pi, k));
        save(filename, 'screen');

        if mod(k, 50) == 0
            fprintf('... Traced %d of %d images for distance %.2f * pi\n', k, Nt, d/pi);
        end

        close all;
    end

    fprintf('\nDone distance %.2f * pi\n', d/pi);
end

fprintf('All snapshots processed!\n');
end
