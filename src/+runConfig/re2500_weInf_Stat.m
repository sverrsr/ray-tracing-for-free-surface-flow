function c = re2500_weinf_Stat()
c.dataSet.name = 're2500_weinf';

c.simulation.distances = linspace(pi, 12*pi, 20);

% Folder where surface elevation profile is found
snapshotDir = '\\tsclient\c\Users\sverrsr\VortexStructures\re2500_we10\re2500_we10_surfElev'; 

% Folder where surface elevation profile is going
rootDataDir = '\\tsclient\c\Users\sverrsr\VortexStructures\re2500_we10\re2500_we10_rayTrace'; 

end