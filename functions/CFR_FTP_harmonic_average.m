function [dist_per_quant, quant_per_dist] = CFR_FTP_harmonic_average(bag123_distances, bag123_quantities)
% [dist_per_quant, quant_per_dist] = CFR_FTP_HARMONIC_AVERAGE(bag123_distances, bag123_quantities)
%
% CFR_FTP_HARMONIC_AVERAGE calculates a weighted FTP result from 
% bag1..3 quantities (gallons / grams / energy) and distances
% weighted 43% "cold" (bags 1&2) and 57% "hot" (bags 3&2)
% as per CFR 86.144-94, https://www.ecfr.gov/cgi-bin/retrieveECFR?gp=&n=sp40.21.86.b&r=SUBPART&ty=HTML#se40.21.86_1144_694
%
% Parameters:
%   bag123_distances: vector of "bag" 1,2,3 distances (as in miles)
%   bag123_quantities: vector of "bag" 1,2,3 quantities (as in grams or gallons)
%
% Returns:
%   tuple: 
%       harmonic average distance per quantity (as in miles per gallon),
%       harmonic average quantity per distance (as in grams per mile)
%

quant_per_dist = 0.43 * ( (bag123_quantities(1) + bag123_quantities(2) ) / ( bag123_distances(1) + bag123_distances(2)) ) + ...
                 0.57 * ( (bag123_quantities(3) + bag123_quantities(2) ) / ( bag123_distances(3) + bag123_distances(2)) );

dist_per_quant = 1 / quant_per_dist;

end
