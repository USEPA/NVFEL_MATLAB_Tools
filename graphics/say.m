% SAY - set plot y-axis
%
% Sets plot y-axis min and max values based on the workspace variables
% ``gay1`` and ``gay2`` respectively
%
% Typically used with **gay**
%
% See also:
%   axis, gax, sax, gay, gaxy, saxy, saxall, gaz, saz
%

plot_axis = axis;
axis([plot_axis(1) plot_axis(2) gay1 gay2]);
