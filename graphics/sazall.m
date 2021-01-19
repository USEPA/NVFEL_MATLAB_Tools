% SAZALL - set plot z-axis for all active plots
%
% Sets plot z-axis min and max values based on the workspace variables
% ``gaz1`` and ``gaz2`` respectively, for all active plots
%
% Typically used with **gaz**
%
% See also:
%   axis, gax, gay, say, gaxy, saxy, saxall, gaz, saz
%

figs = findobj(0,'type','axes');
for i = 1:length(figs)
    zlim(figs(i),[gaz1 gaz2]);
end
