% GAZ - grab plot z-axis
%
% Sets workspace variables ``gaz1`` and ``gaz2`` with the min and max z-axis
% values, respectively, of the current plot
%
% Typically used with **saz**
%
% See also:
%   axis, gax, sax, say, gaxy, saxy, saxall, saz
%

plot_axis = axis;
gaz1= plot_axis(5);
gaz2= plot_axis(6);
