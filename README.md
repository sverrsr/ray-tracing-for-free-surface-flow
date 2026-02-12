# Ray tracing for fluid dynamics
<div style="text-align: center;">
  <img src="noisy.gif" width="150">
</div>



# Contents
## startHere/
*startHere* contains off-the-shelf examples on ray tracing on surfaces defined by a meshgrid.
For more examples see Optometrika [^1] or [^2]

- *z_surface.m* : Ray tracing on a flat plane
- *tiltedPlane.m* : Ray tracing a flat tiltedby 45 deg plane
- *pyramid.m* : Ray tracing on a pyramid
- *pyrmaid_pp.m* : Prints the directions rays are leaving the pyrmaid

## downloadData/
downloadData contains code for downloading datasets of direct numerical simulation (DNS) flow from [^3]

## exampleData/
Contains 10 example water surfaces from direct numerical simulations.

- *surface_analysis.m* : Plots surface elevation and surface normals of a surface

## rayTrace/
This is where ray-tracing is happening
- raytrace/
  - *+bench/* : Here you set your optical environment.
  - *+cfg/* : Here you set the configuration of the dataset
  - *runScripts/* : Here you make a script that runs the ray-tracing
  - *src/* : What makes it work

## outputs/
Outputs from the ray tracing
# utils/
Some nice-to-have utils

# General workflow


[^1]: https://github.com/caiuspetronius/Optometrika

[^2]: https://github.com/alexschultze/Optometrika

[^3]: Aarnes, Jørgen Røysland; Babiker, Omer; Xuan, Anqing; Shen, Lian; Ellingsen, Simen, 2025, "Replication Data for: "Vortex structures under dimples and scars in turbulent free-surface flows" (PART 1/4)", https://doi.org/10.18710/XQ81WH, DataverseNO, V1 



Keywords: meshgrid raytracing, water raytracing