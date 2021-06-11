function [dist_per_quant, quant_per_dist] = CFR_FTP_4bag_harmonic_average(bag1234_distances, bag1234_quantities)
% [dist_per_quant, quant_per_dist] = CFR_FTP_HARMONIC_AVERAGE(bag123_distances, bag123_quantities)
%
% CFR_FTP_HARMONIC_AVERAGE calculates a weighted FTP result from 
% bag1..4 quantities (gallons / grams / energy) and distances
% weighted 43% "cold" (bags 1&2) and 57% "hot" (bags 3&4)
% as per 40 CFR § 1066.820, https://www.ecfr.gov/cgi-bin/text-idx?node=pt40.37.1066&rgn=div5#se40.37.1066_1820
%
% Parameters:
%   bag1234_distances: vector of "bag" 1,2,3,4 distances (as in miles)
%   bag1234_quantities: vector of "bag" 1,2,3,4 quantities (as in grams or gallons)
%
% Returns:
%   tuple: 
%       harmonic average distance per quantity (as in miles per gallon),
%       harmonic average quantity per distance (as in grams per mile)
%

quant_per_dist = 0.43 * ( (bag1234_quantities(1) + bag1234_quantities(2) ) / ( bag1234_distances(1) + bag1234_distances(2)) ) + ...
                 0.57 * ( (bag1234_quantities(3) + bag1234_quantities(4) ) / ( bag1234_distances(3) + bag1234_distances(4)) );

dist_per_quant = 1 / quant_per_dist;

end
