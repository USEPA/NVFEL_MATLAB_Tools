function [answer] = normalize(var, index)
% [answer] = NORMALIZE(var, index)
%
% answer = var./var(index);
%
% Parameters:
%   var: vector to normalize
%   index: index of var to normalize by
%
% Returns: var normalized by var(index)
%

answer = var./var(index);

end

