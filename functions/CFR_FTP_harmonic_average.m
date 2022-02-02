function [dist_per_quant, quant_per_dist] = CFR_FTP_harmonic_average(bag_distances, bag_quantities)
% [dist_per_quant, quant_per_dist] = CFR_FTP_HARMONIC_AVERAGE(bag123_distances, bag123_quantities)
%
% CFR_FTP_HARMONIC_AVERAGE calculates a weighted FTP result
%
% bag1..3 quantities (gallons / grams / energy) and distances
% weighted 43% "cold" (bags 1&2) and 57% "hot" (bags 3&2)
% as per CFR 86.144-94, https://www.ecfr.gov/cgi-bin/retrieveECFR?gp=&n=sp40.21.86.b&r=SUBPART&ty=HTML#se40.21.86_1144_694
%
% bag1..4 quantities (gallons / grams / energy) and distances
% weighted 43% "cold" (bags 1&2) and 57% "hot" (bags 3&4)
% as per 40 CFR § 1066.820, https://www.ecfr.gov/cgi-bin/text-idx?node=pt40.37.1066&rgn=div5#se40.37.1066_1820
%
% Parameters:
%   bag_distances: vector of distances (as in miles)
%   bag_quantities: vector of quantities (as in grams or gallons)
%
% Returns:
%   tuple: 
%       harmonic average distance per quantity (eg. miles per gallon),
%       harmonic average quantity per distance (eg. grams per mile)
%


if numel( bag_distances) == 3
    
    quant_per_dist = 0.43 .* ( (bag_quantities(1) + bag_quantities(2) ) ./ ( bag_distances(1) + bag_distances(2)) ) + ...
                     0.57 .* ( (bag_quantities(3) + bag_quantities(2) ) ./ ( bag_distances(3) + bag_distances(2)) );
    
elseif numel( bag_distances) == 4
    
    quant_per_dist = 0.43 .* ( (bag_quantities(1) + bag_quantities(2) ) ./ ( bag_distances(1) + bag_distances(2)) ) + ...
                     0.57 .* ( (bag_quantities(3) + bag_quantities(4) ) ./ ( bag_distances(3) + bag_distances(4)) );
    
else
    
    error('Incorrect number of bags provided, expecting 3 or 4')
    
end

dist_per_quant = 1 / quant_per_dist;

end
