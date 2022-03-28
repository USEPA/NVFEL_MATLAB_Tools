function [out] = CFR_FTP_harmonic_average( bag_quantities, bag_distances, mode)
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
%   mode: calculation mode 
%       'qpd': quantity per distance
%       'dpq': distance per quantity
%       'avg': weighted average
%
% Returns:
%   value weighted per CFR calculation 
%


if numel(bag_quantities) ~= numel(bag_distances) || ~ismember(numel(bag_distances),[3,4])
    error('Input dimension mismatch, expecting quantites or equal size and length 3 or 4')
end

if numel( bag_distances) == 3  
    bag_distances(4) = bag_distances(2);
    bag_quantities(4) = bag_quantities(2);
end


switch mode
    
    case 'qpd'        
        out = 0.43 .* ( (bag_quantities(1) + bag_quantities(2) ) ./ ( bag_distances(1) + bag_distances(2)) ) + ...
              0.57 .* ( (bag_quantities(3) + bag_quantities(4) ) ./ ( bag_distances(3) + bag_distances(4)) );
          
    case 'dpq'        
        out = 1/( 0.43 .* ( (bag_quantities(1) + bag_quantities(2) ) ./ ( bag_distances(1) + bag_distances(2)) ) + ...
                  0.57 .* ( (bag_quantities(3) + bag_quantities(4) ) ./ ( bag_distances(3) + bag_distances(4)) ));
        
    case 'avg'       
        bag_quantities = bag_quantities .*  bag_distances;
        out = 0.43 .* ( (bag_quantities(1) + bag_quantities(2) ) ./ ( bag_distances(1) + bag_distances(2)) ) + ...
              0.57 .* ( (bag_quantities(3) + bag_quantities(4) ) ./ ( bag_distances(3) + bag_distances(4)) );

    otherwise        
        error('Unknown calculation method ''%s'', expecting ''qpd'', ''dpq'' or ''avg''', mode);

end

    

end
