function [surfElev, u, v, w, zz] = load_data(caseName, rootDataDir, dataIndex)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function that reads the raw data files for the free-surface turbulence simulations
    %
    % Inputs:
    % caseName: Six possible cases, set name based on which case you want to analyze
    %           Name format for case 1: RE2500_WEinf. 
    %           Swap 2500 with 1000 and/or inf with 10 or 20 to read cases 2-6.
    % rootDataDir: Folder where the different simulations are stored. 
    %              Should contain subfolder with name set to caseName
    % dataIndex: What timestep to read. Range depends on case.
    %            Check how many datafiles the data directory for your case contains to find range.
    % 
    % Return:
    % This function returns the following 5 arrays:
    % surfElev: nx x ny field of the surface elevation at the spesified timestep
    % u: nx x ny x length(zz) horisontal velocity in x
    % v: nx x ny x length(zz) horisontal velocity in y
    % w: nx x ny x length(zz) vertical velocity in z
    % zz: length(zz) the vertical location of the velocities
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Set default arguments (Note: Requires Matlab version >= 2019b)
    arguments
        caseName = "RE2500_WEinf";
        rootDataDir = ".";
        dataIndex = 1;
    end

    runDir = pwd;

    % Reference length
    lRef = 2*pi;
    
    % Directory where the data is saved
    dataDir = fullfile(rootDataDir, caseName);

    % Get file identifier and path
    cd(dataDir);
    fileList = dir(".");
    filePath = fullfile(dataDir,fileList(dataIndex+2).name);
    cd(runDir);
    
    % Loading the depth zz and staggered depth zw (latter used for w variable)
    zz = double(flip(h5read(filePath, "/zz")));
    zw = double(flip(h5read(filePath, "/zw")));
    
    % Loading the surface elevation
    surfElev = single(h5read(filePath, "/surf_elev" )); %originally double
    
    % Loading velocities. Flip to get correct coordinate system
    u = h5read(filePath, "/v");  % Reading the u velocities
    v = h5read(filePath, "/u");  % Reading the v velocities
    w = h5read(filePath, "/w");  % Reading the w velocities

    u = double(flip(u, 3));
    v = double(flip(v, 3));
    w = double(flip(w, 3));

    % Since w is on a staggered grid, we interpolated to get it on the same depth 
    % coordiantes as the horizontal velocities u and v.
    [nx, ny, ~] = size(w);
    x = linspace(0, lRef, nx); % 
    y = linspace(0, lRef, ny); % 
    [xq, yq, zq] = meshgrid(x, y, zz); % Meshgrid query points
    [xo, yo, zo] = meshgrid(x, y, zw); % Meshgrid original points
    % interpolating
    w = interp3(xo, yo, zo, w, xq, yq, zq, "spline");
    
end
