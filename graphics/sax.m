% SAX - set plot x-axis
%
% Sets plot x-axis min and max values based on the workspace variables
% ``gax1`` and ``gax2`` respectively
%
% Typically used with **gax**
%
% See also:
%   axis, gax, gay, say, gaxy, saxy, saxall
%

plot_axis = axis;
axis([gax1 gax2 plot_axis(3) plot_axis(4)]);
