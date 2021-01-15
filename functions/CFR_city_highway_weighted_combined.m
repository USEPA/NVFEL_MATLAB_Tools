function [ answer ] = CFR_city_highway_weighted_combined( city, highway, varargin )
% city_highway_weighted_combined calculates a weighted combined result from
% city/highway quantities (gallons / grams / energy) per (mi / m / km) or
% (mi / m /km) per quantity (gallons / grams / energy), depending on the
% varargs, weighted 55% "city" and 45% "highway"

is_dist_per_quant = parse_varargs(varargin,'dist_per_quant',false,'toggle');
is_dist_per_quant = is_dist_per_quant || parse_varargs(varargin,'mpg',false,'toggle');

is_quant_per_dist = parse_varargs(varargin,'quant_per_dist',false,'toggle');
is_quant_per_dist = is_quant_per_dist || parse_varargs(varargin,'gpm',false,'toggle');

if is_dist_per_quant
    answer = 1 / (0.55 / city + 0.45 / highway);
elseif is_quant_per_dist
    answer = (0.55 * city + 0.45 * highway);
else
    error('Must specify dist_per_quant/mpg or quant_per_dist/gpm');
end

end
