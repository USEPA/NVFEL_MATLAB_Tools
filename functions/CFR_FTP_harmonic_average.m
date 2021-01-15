function [ dist_per_quant, quant_per_dist ] = CFR_FTP_harmonic_average( bag123_distances, bag123_quantities )
% FTP_harmonic_average calculates a weighted FTP result from 
% bag1..3 quantities (gallons / grams / energy) and distances
% weighted 43% "cold" (bags 1&2) and 57% "hot" (bags 3&2)
% as per CFR 86.144-94

quant_per_dist = 0.43 * ( (bag123_quantities(1) + bag123_quantities(2) ) / ( bag123_distances(1) + bag123_distances(2)) ) + ...
                 0.57 * ( (bag123_quantities(3) + bag123_quantities(2) ) / ( bag123_distances(3) + bag123_distances(2)) );

dist_per_quant = 1 / quant_per_dist;

end
