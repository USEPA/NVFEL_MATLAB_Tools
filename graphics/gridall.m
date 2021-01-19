% GRIDALL - turn x-, y- and z-axis grids on for all active plots
%
% See also:
%   grid
%

figs = findobj(0,'type','figure');
for i = 1:length(figs)
    set (gca(figs(i)), 'XGrid', 'on');
    set (gca(figs(i)), 'YGrid', 'on');
    set (gca(figs(i)), 'ZGrid', 'on');
end
