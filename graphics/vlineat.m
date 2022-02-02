function [h] = vlineat(val, varargin)
% [h] = VLINEAT(val, varargin)
%
% Plots a vertical line on the x-axis at val using *superplot*.
% Returns a handle to the lineseries object and supports all superplot varargs.
%
% Exmaple:
%   vlineat(10,'r')  % draws a vertical red line at 10 on the x-axis
%
% See also superplot

ax = gca;

z = parse_varargs(varargin,'z',ax.ZTick(end),'numeric');
auto_refresh = parse_varargs(varargin, 'auto_refresh', true, 'bool');

% Remove varargs before passing to superplot
remove_varargs = strcmpi( varargin, 'z');
remove_varargs = remove_varargs | strcmpi( varargin, 'auto_refresh');
remove_varargs(2:end) = remove_varargs(2:end) | remove_varargs(1:end-1);
varargin(remove_varargs) = [];


y_range = ax.YLim;

for i = numel(val):-1:1
	h(i) = superplot([val(i) val(i)], y_range,[z z], varargin{:});
end

if auto_refresh
	addlistener(ax,'YLim','PostSet', @(src,evt)rescale_callback(src,evt, ax, h));
end

end


function rescale_callback(src,evt, ax, h)

y_range = ax.YLim;

for i = 1:length(h)
	set( h(i), 'Ydata',y_range);
end

end