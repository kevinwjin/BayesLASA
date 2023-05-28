### Simulated polygon data

This folder contains the simulated data for the analysis in the manuscript "Bayesian Landmark-based Shape Analysis of Tumor Pathology Images".

Simulated data of 1,504 polygonal chains generated by `sim_generating.R` were provided in Rdata format. An example of `Normal_4_equil_FALSE_pn_100_seed_1.Rdata` indicate the polygonal chain was generated with 4 landmark points, NOT equilateral, 100 total number of points and random seed = 1 using the simulation generation function `sim_randon_polygon_generator` provided in `code/landmark_detection/sim_polygon_gaussian.R`.

The Rdata  stores an R list item called `polygon`, which contains:

* `polyg$original_data`: generated polygonal chain. In the four columns, `x` and `y` indicate the corresponding coordinates, `gamma` indicates whether the point is a landmark points, `sigma` is the used sigma to generate the segment.

* `polyg$normalized`: normalized polygonal chain with unit length.

* `polyg$smooth001`: normalized polygonal chain with unit length after kernal smoothing.