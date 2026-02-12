function c = example_cfg()

c.input.caseName = "example";

%surface elevations is found here
c.input.surfElevDir =       "exampleData\tenDnsSurfaceElevations";
% Set outputfolder for screens. If not exists, it is created
c.pp.baseRayTraceDir =      "exampleData\tenDnsSurfaceElevations_traced";
% Set outputfolder for filtered pngs. If not exists, it is created
c.pp.baseFilteredDir =      "exampleData\tenDnsSurfaceElevations_tracedAndFiltered";

% Distance sweep. Can also be a range using linspace()
c.simulation.distances = 10;

% Number of rays
c.simulation.nRays = 500;

c.grid.nx = 256;
c.grid.ny = 256;

c.grid.nt = 12500;

c.grid.lx = 2*pi;
c.grid.ly = 2*pi;

c.time.dt = 0.06;

end