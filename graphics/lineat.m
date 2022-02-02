function [h] = lineat(val, varargin)
% [h] = LINEAT(val, varargin)
%
% Plots a horizontal line on the y-axis at val using *superplot*.
% Returns a handle to the lineseries object and supports all superplot varargs.
%
% Exmaple:
%   lineat(10,'r')  % draws a horizontal red line at height 10 on the y-axis
%
% See also superplot

ax = gca;

z = parse_varargs(varargin, 'z', ax.ZTick(end), 'numeric');
auto_refresh = parse_varargs(varargin, 'auto_refresh', true, 'bool');

% Remove varargs before passing to superplot
remove_varargs = strcmpi( varargin, 'z');
remove_varargs = remove_varargs | strcmpi( varargin, 'auto_refresh');
remove_varargs(2:end) = remove_varargs(2:end) | remove_varargs(1:end-1);
varargin(remove_varargs) = [];

x_range = ax.XLim;

for i = numel(val):-1:1
	h(i) = superplot(x_range,[val(i) val(i)], [z z], varargin{:});
end

if auto_refresh
	addlistener(ax,'XLim','PostSet', @(src,evt)rescale_callback(src,evt, ax, h ));
end

end

function rescale_callback(src, evt, ax, h)

x_range = ax.XLim;

for i = 1:length(h)
	set(h(i), 'Xdata', x_range);
end

end