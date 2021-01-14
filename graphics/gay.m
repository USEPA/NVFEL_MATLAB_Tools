% GAY - grab plot y-axis
%
% Sets workspace variables ``gay1`` and ``gay2`` with the min and max y-axis
% values, respectively, of the current plot
%
% Typically used with **say**
%
% See also:
%   axis, gax, sax, say, gaxy, saxy, saxall
%

plot_axis = axis;
gay1= plot_axis(3);
gay2= plot_axis(4);
