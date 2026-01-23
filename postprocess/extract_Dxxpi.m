function T = extract_Dxxpi(directory)
% Extract DistanceTag ("D<number>[.fraction]pi"), numeric Distance,
% and the full folder name. Returns a sorted table.

list = ls(directory);

% Normalize to string column vector
if ischar(list)
    names = string(cellstr(list));
else
    names = string(list(:));
end
names = strtrim(names);
names = names(names ~= "");

% Match tokens like D0.5pi, D12pi, ...
pat = "D\d+(\.\d+)?pi";
c = regexp(names, char(pat), 'match');

% Keep only entries with a match
has = ~cellfun(@isempty, c);

% Folder names (this is what you want for reopening later)
FolderName = names(has);
FolderName = FolderName(:);   % force column

% Distance tag (e.g. "D0.5pi")
DistanceTag = string(cellfun(@(x) x{1}, c(has), 'UniformOutput', false));
DistanceTag = DistanceTag(:); % force column

% Numeric distance (e.g. 0.5)
DistanceStr = erase(erase(DistanceTag, "D"), "pi");
Distance = str2double(DistanceStr);
Distance = Distance(:);       % force column

% Placeholder for later filling
meanCorrelation = zeros(numel(DistanceTag), 1);

% Build table
T = table(FolderName, DistanceTag, Distance, meanCorrelation, ...
    'VariableNames', {'FolderName','DistanceTag','Distance','MeanCorrelation'});

% Sort by physical distance
T = sortrows(T, 'Distance');
end
