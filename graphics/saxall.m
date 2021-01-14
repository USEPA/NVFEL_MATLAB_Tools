% SAXALL - set plot x-axis for all active plots
%
% Sets plot x-axis min and max values based on the workspace variables
% ``gax1`` and ``gax2`` respectively, for all active plots
%
% Typically used with **gax**
%
% See also:
%   axis, gax, gay, say, gaxy, saxy, saxall
%

figs = findobj(0,'type','axes');
for i = 1:length(figs)
    xlim(figs(i),[gax1 gax2]);
end
