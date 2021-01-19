function [lineseries] = fploth(varargin)
% [lineseries] = FPLOTH(varargin)
%    Shortcut for: figure; plot; hold on;
%
% Parameters:
%   varargin (optional keyword and name-value arguments): plot arguments
%
% Uses **superplot** instead of Matlab **plot**, but essentially the same.
% If no active figure exists, it is created.
%
% Returns:
%   line series handle: handle to line series
%
% Example:
%   Create a simple plot with two lines, hold and grid on.  First line red, second line blue::
%
%       figure;
%       plothg([1 2 3], [4 5 6], 'r-');
%       plothg([0 1 2], [6 5 4], 'b-');
%
% See also:
%   figure, plot, hold, superplot
%

figure;

lineseries = superplot(varargin{:});

hold on;

% Autolabeling
if length(lineseries) == 1 && isnumeric(varargin{1}) && isnumeric(varargin{2})
	% Single line x vs y
	
	xlabel(inputname(1),'Interpreter','none');
	ylabel(inputname(2),'Interpreter','none');
	
elseif length(lineseries) == 1 && isnumeric(varargin{1})
	% Single line y vs ticks
	
	ylabel(inputname(1),'Interpreter','none');
	xlabel('ticks')
	
else
	% Multiline
	
	if isnumeric(varargin{1}) && isnumeric(varargin{2})
		x_name = inputname(1);
	else
		x_name = 'ticks';
	end
	
	l = 1;	
	legend_str = {};
	while l < length(varargin)
	
		if isnumeric(varargin{l}) &&  isnumeric(varargin{l+1})
			legend_str{end+1} = inputname(l+1);
			if ~strcmp( x_name, inputname(l) )
				x_name = '';
			end
			l = l+2;
		elseif 	isnumeric(varargin{l})
			legend_str{end+1} = inputname(l);
			if ~strcmp( x_name, 'ticks' )
				x_name = '';
			end
			l = l+1;
		else
			l = l+1;
		end
		
	end
	
	legend(legend_str,'Interpreter','none');
	xlabel(x_name,'Interpreter','none');
	
end