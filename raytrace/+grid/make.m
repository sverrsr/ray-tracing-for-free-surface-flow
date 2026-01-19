function G = make(c)
G.dx = c.grid.lx / c.grid.nx;
G.dy = c.grid.ly / c.grid.ny;

x = linspace(0, c.grid.lx, c.grid.nx);
y = linspace(0, c.grid.ly, c.grid.ny);

[G.X, G.Y] = meshgrid(x, y);
end