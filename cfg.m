function cfg = defaultConfig()
    cfg.paths.data = "data";
    cfg.paths.results = "results";
    cfg.ray.nRays = 1e5;
    cfg.surface.method = "triangulated";
    cfg.debug.saveFigures = true;
end