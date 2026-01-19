function pipelineOut = raytrace(X, Y, c)
%RUNRAYTRACESNAPSHOTS Runs raytracing for all distances and snapshots.
%
%   pipelineOut = pipeline.runRaytraceSnapshots(G, c, benchFn)

distances   = c.simulation.distances;
nRays       = c.simulation.nRays;

caseName    = c.input.caseName;
snapshotDir = c.input.surfElevDir;
rootDataDir = c.output.rayTraceDir;

snapshotFiles = dir(fullfile(snapshotDir, '*.mat'));
Nt = numel(snapshotFiles);

fprintf('Found %d surface elevation files in %s.\n', Nt, snapshotDir);
fprintf('Starting ray tracing with %d rays ...\n', nRays);


pipelineOut = struct(); % optional return

for d = distances
    outDir = fullfile(rootDataDir, caseName + sprintf('_raytraced_D%.2fpi', d/pi));
    if ~exist(outDir, 'dir'); mkdir(outDir); end

    fprintf('... Tracing distance %.2f * pi. Saving image in %s\n', d/pi, outDir);

    tStart = tic;
    barLength = 30;

    for k = 1:Nt
        S = load(fullfile(snapshotDir, snapshotFiles(k).name));

        if isfield(S, 'surfElev')
            Z = double(S.surfElev);
        elseif isfield(S, 'Z')
            Z = double(S.Z);
        else
            error('Unknown variable inside %s', snapshotFiles(k).name);
        end

        % Run optics

        %[screen, ~, ~, ~] = benchFn(X, Y, Z, d, nRays);
        [screen, ~, ~, ~] = bench.DNS_Bench(X, Y, Z, d);

        % Save
        filename = fullfile(outDir, sprintf('screen_B1024_D%.2fpi_%04d.mat', d/pi, k));
        save(filename, 'screen');

        % Progress bar
        p = k / Nt;
        elapsed = toc(tStart);
        eta = (elapsed / p) - elapsed;

        barComplete = round(p * barLength);
        barString = ['[' repmat('#',1,barComplete) repmat('.',1,barLength-barComplete) ']'];
        fprintf('\r%s  %5.1f%%  ETA: %.1fs.', barString, p*100, eta);

        close all;
    end

    fprintf('\nDone distance %.2f\n', d);
end

fprintf('All snapshots processed!\n');
end
