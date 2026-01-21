function pipelineOut = raytrace2(X, Y, c)
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
fprintf('Starting ray tracing with %s rays ...\n', num2str(round(nRays),'%,d'));


timePerRay = zeros(size(nRays));

pipelineOut = struct(); % optional return

for ray = nRays
    d = distances;

    outDir = fullfile(rootDataDir, caseName + sprintf('_raytraced_%d', ray));
    if ~exist(outDir, 'dir'); mkdir(outDir); end

    fprintf('Tracing distance 3.0pi with %d rays. Saving image in %s\n', ray, outDir);

    % tStart = tic;
    % barLength = 30;

    tStart = tic;   % start timing for this ray count

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
        [screen, ~, ~, ~] = bench.DNS_Bench(X, Y, Z, d, ray);

        % Save
        filename = fullfile(outDir, sprintf('screen_D3.0pi_%d_%04d.mat', ray, k));
        save(filename, 'screen');

        % Progress bar
        % p = k / Nt;
        % elapsed = toc(tStart);
        %eta = (elapsed / p) - elapsed;

        %barComplete = round(p * barLength);
        %barString = ['[' repmat('#',1,barComplete) repmat('.',1,barLength-barComplete) ']'];
        %fprintf('\r%s  %5.1f%%  ETA: %.1fs.', barString, p*100, eta);
        

        % Update progress every 10%
        progressStep = 0.1;  % 10%
        p = k / Nt;          % fraction done
        
        % Check if we've crossed the next 10% boundary
        if p >= progressStep * floor(p / progressStep)
            if mod(k, ceil(Nt*progressStep)) == 0 || k == Nt
                fprintf('\rProgress: %3.0f%%', p*100);  % overwrite same line
            end
        end
        

        close all;
    end

    % Record elapsed time for this ray count
    timePerRay(ray) = toc(tStart);

    fprintf('Done distance %.2f * pi with %d rays in %.1f seconds\n', d/pi, ray, timePerRay(ray));
end

fprintf('All snapshots processed!\n');

% Optional: return timePerRay in the output structure
pipelineOut.timePerRay = timePerRay;
pipelineOut.nRays = nRays;
end

