% src/+io/loadSurface.m
function Z = loadSurface(path)
s = load(path);
if isfield(s, "surfElev")
    Z = double(s.surfElev);
else
    error("loadSurface: missing surfElev in file")
end
end