function MS = MS_tiles(field)
% field: H x W x T
% returns: T x 1 mean(square(field)) over the whole field

MS = squeeze(mean(field.^2, [1 2]));

end