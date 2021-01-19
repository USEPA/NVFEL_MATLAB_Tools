% SAYALL - set plot y-axis for all active plots
%
% Sets plot y-axis min and max values based on the workspace variables
% ``gay1`` and ``gay2`` respectively, for all active plots
%
% Typically used with **gay**
%
% See also:
%   axis, gax, gay, say, gaxy, saxy, saxall, gaz, saz
%

figs = findobj(0,'type','axes');
for i = 1:length(figs)
    ylim(figs(i),[gay1 gay2]);
end
