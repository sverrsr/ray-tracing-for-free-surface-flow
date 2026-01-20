function DistanceTag = extract_Dxxpi(directory)
% extract_Dpi_from_ls  Extract "D<number>[.fraction]pi" tokens from names
%   DistanceTag = extract_Dpi_from_ls(list)
%   Input 'list' can be
%     - an m-by-n char array (e.g., output of ls on Windows),
%     - a cell array of char vectors, or
%     - a string array.
%   Output is an N-by-1 string column vector of tokens (empty if none).

list = ls(directory);  % List files in the specified directory
% Normalize to string column vector of names
if ischar(list)
    names = string(cellstr(list));    % each row -> one string
else
    names = string(list(:));
end

% Pattern: D then digits, optional decimal part, then pi
pat = "\d+(\.\d+)";

% Extract DistanceTag (cell array of DistanceTag per element)
c = regexp(names, char(pat), 'match');

% Flatten and keep non-empty
flat = [c{:}];
if isempty(flat)
    Distance = string.empty(0,1);
else
    Distance = string(flat).';
end

% part 2
% Normalize to string column vector of names
if ischar(list)
    names = string(cellstr(list));    % each row -> one string
else
    names = string(list(:));
end

% Pattern: D then digits, optional decimal part, then pi
pat = "D\d+(\.\d+)?pi";

% Extract DistanceTag (cell array of DistanceTag per element)
c = regexp(names, char(pat), 'match');

% Flatten and keep non-empty
flat = [c{:}];
if isempty(flat)
    DistanceTag = string.empty(0,1);
else
    DistanceTag = string(flat).';
end

% Part2


meanCorrelation = zeros(size(DistanceTag,1), 1);

% simple and robust: make a two-variable table with desired order
T = table(DistanceTag, Distance, meanCorrelation, 'VariableNames', {'DistanceTag','Distance', 'MeanCorrelation'});
T.Distance = str2double(T.Distance);

T = sortrows(T, 'Distance');
DistanceTag = T;
end
