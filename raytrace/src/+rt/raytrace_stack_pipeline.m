function pipelineOut = raytrace_stack_pipeline(X, Y, surfElevStack, c, opts)
%RAYTRACE_STACK_PIPELINE Ray trace a 3D surface stack and post-process per distance.
%
% Input
%   X, Y          : meshgrid coordinates
%   surfElevStack : [H,W,Nt] surface elevations in time
%   c             : config structure (uses c.input.caseName, c.simulation.*, c.pp.baseStackedDir)
%   opts          : optional settings
%
% Output
%   Writes one .mat file per distance in c.pp.baseStackedDir.
%   Each file contains rawStack, normalizedStack, denoisedStack, and metadata.

arguments
    X (:,:) {mustBeNumeric, mustBeReal}
    Y (:,:) {mustBeNumeric, mustBeReal}
    surfElevStack (:,:,:) {mustBeNumeric, mustBeReal}
    c struct
    opts.useLog (1,1) logical = true
    opts.applyDenoising (1,1) logical = true
    opts.outputDir string = "C:\Users\sverrsr\Documents\path-trace-for-free-surface-flow\testNewMatTrace"
    opts.saveRawStack (1,1) logical = false
    opts.denoiseOptions struct = struct()
end

if opts.outputDir == ""
    if isfield(c, 'pp') && isfield(c.pp, 'baseStackedDir')
        outputDir = string(c.pp.baseStackedDir);
    else
        error('Set opts.outputDir or c.pp.baseStackedDir for output.');
    end
else
    outputDir = opts.outputDir;
end

if ~isfolder(outputDir)
    mkdir(outputDir);
end

caseName = string(c.input.caseName);
distances = c.simulation.distances;
nRays = c.simulation.nRays;
Nt = size(surfElevStack, 3);

fprintf('Input stack size: %s\n', mat2str(size(surfElevStack)));
fprintf('Distances: %s\n', mat2str(distances));
fprintf('Output folder: %s\n', outputDir);

pipelineOut = struct([]);


tic
for ii = 1:numel(distances)
    d = distances(ii);
    fprintf('\nTracing distance %.2f*pi (%d/%d)\n', d/pi, ii, numel(distances));

    rawStack = [];

    for k = 1:Nt
        Z = double(surfElevStack(:,:,k));
        [screen, ~, ~, ~] = bench.DNS_Bench(X, Y, Z, d, nRays);
        frame = single(screen.image);

        if k == 1
            rawStack = zeros(size(frame,1), size(frame,2), Nt, 'single');
        end
        rawStack(:,:,k) = frame;
        
        fprintf('  traced frame %d/%d\n', k, Nt);
        if mod(k, 50) == 0 || k == Nt
            fprintf('  traced frame %d/%d\n', k, Nt);
        end
    end

    ppOut = pp.process_screen_stack(rawStack, opts.useLog);
    normalizedStack = ppOut.normalizedStack;

    if opts.applyDenoising
        nv = namedargs2cell(opts.denoiseOptions);
        denoisedStack = pp.denoise_stack_tv(normalizedStack, nv{:});
    else
        denoisedStack = normalizedStack;
    end

    outPath = fullfile(outputDir, caseName + sprintf('stack_D%.2fpi.mat', d/pi));

    distance = d; %#ok<NASGU>
    distanceTag = sprintf('D%.2fpi', d/pi); %#ok<NASGU>
    metadata = struct( ...
        'caseName', caseName, ...
        'nRays', nRays, ...
        'Nt', Nt, ...
        'distance', d, ...
        'distanceTag', distanceTag, ...
        'useLog', opts.useLog, ...
        'denoised', opts.applyDenoising, ...
        'gShort', ppOut.gShort, ...
        'gmaxProc', ppOut.gmaxProc, ...
        'transformMax', ppOut.transformMax);

    if opts.saveRawStack
        save(outPath, 'rawStack', 'normalizedStack', 'denoisedStack', 'metadata', '-v7.3');
    else
        save(outPath, 'normalizedStack', 'denoisedStack', 'metadata', '-v7.3');
    end

    pipelineOut(ii).distance = d;
    pipelineOut(ii).outPath = string(outPath);
    pipelineOut(ii).sizeNormalized = size(normalizedStack);
    pipelineOut(ii).sizeDenoised = size(denoisedStack);

    fprintf('Saved %s\n', outPath);
end

fprintf('\nDone. Generated %d distance stacks.\n', numel(distances));

toc

end
