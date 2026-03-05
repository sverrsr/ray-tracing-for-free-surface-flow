% load project paths based on this file's location for pc

function startup()

basePath = pwd;
addpath(genpath(basePath));

basePath2 = 'C:\Users\sverrsr\Documents\optometrika-meshgrid-extension';
addpath(genpath(basePath2));

end