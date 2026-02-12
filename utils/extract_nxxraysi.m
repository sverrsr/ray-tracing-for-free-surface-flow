function T = extract_nxxraysi(directory)
% Extract the last number in each name (ray count), e.g.
% re2500_we10_raytraced_5100 -> 5100

if nargin < 1 || isempty(directory)
    directory = uigetdir(matlabroot, 'Select folder with raytraced cases');
    if isequal(directory,0)
        T = table();  % or: T = [];
        return;
    end
end

list = ls(directory);

% Normalize to string column vector
if ischar(list)
    names = string(cellstr(list));
else
    names = string(list(:));
end
names = strtrim(names);
names(names == "") = [];

% Match last run of digits at end of string
tok = regexp(names, '(\d+)$', 'tokens', 'once');

RayCount = nan(numel(names),1);
for i = 1:numel(names)
    if ~isempty(tok{i})
        RayCount(i) = str2double(tok{i}{1});
    end
end

% Keep only entries that actually had a trailing number
keep = ~isnan(RayCount);
T = table(names(keep), RayCount(keep), 'VariableNames', {'Name','RayCount'});

% Optional: sort by ray count
T = sortrows(T, 'RayCount');
end
