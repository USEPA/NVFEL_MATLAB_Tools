% SAZ - set plot z-axis
%
% Sets plot z-axis min and max values based on the workspace variables
% ``gaz1`` and ``gaz2`` respectively
%
% Typically used with **gaz**
%
% See also:
%   axis, gax, sax, gay, gaxy, saxy, saxall, saz
%

plot_axis = axis;
axis([plot_axis(1) plot_axis(2) plot_axis(3) plot_axis(4) gaz1 gaz2]);
