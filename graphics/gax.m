% GAX - grab plot x-axis
%
% Sets workspace variables ``gax1`` and ``gax2`` with the min and max x-axis
% values, respectively, of the current plot
%
% Typically used with **sax**
%
% See also:
%   axis, sax, gay, say, gaxy, saxy, saxall
%

plot_axis = axis;
gax1= plot_axis(1);
gax2= plot_axis(2);
