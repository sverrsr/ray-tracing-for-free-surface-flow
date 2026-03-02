% load project paths based on this file's location for pc

function startup()

basePath = pwd;
addpath(genpath(basePath));

basePath2 = 'C:\Users\sverr\Documents\NTNU\Prosjekt\optometrika-meshgrid-extension';
addpath(genpath(basePath2));

end