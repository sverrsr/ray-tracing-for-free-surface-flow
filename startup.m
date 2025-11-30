% function startup()
% % load project paths based on this file's location
% 
% root = fileparts(mfilename("fullpath"));
% 
% % code folders you actually want
% addpath(fullfile(root, "src"));
% addpath(fullfile(root, "functions"));
% addpath(fullfile(root, "scripts"));
% addpath(fullfile(root, "data"));
% 
% addpath C:\Users\sverr\Documents\NTNU\Prosjekt\Optometrika\functions;
% 
% end

function loadPaths()

addpath(fullfile(pwd, 'data'));
basePath = 'C:\Users\sverr\Documents\NTNU\Prosjekt';
addpath(genpath(basePath));

%addpath(genpath('C:\Users\sverr\Documents\NTNU\Prosjekt\Optometrika\src'));
addpath 'C:\Users\sverr\Documents\NTNU\Prosjekt\Optometrika';
addpath C:\Users\sverr\Documents\NTNU\Prosjekt\Optometrika\functions;

end