function [match] = regexpcmp( str, expression, varargin )
% [match] = REGEXPCMP( str, expression, varargin )
% 
% Compare string via regular expression. Similar to strcmp except the 
% comparison utilizes regular expressions.
%
% Parameters:
%   str: string or cell array of strings to compare with expression
%   expression: regular expression or cell array of regular expressions
%   varargin: varargs supported by ``regexp()``
%
% Returns:
%   Cell array of boolean comparison results
%
% See also: regexp, cellfun, strcmp
%

if ischar(str) && ischar(expression)
	match = ~isempty(regexp(str, expression, 'once', varargin{:}));
else
	
	if ~iscell( str)
		str = {str};
	end
	
	if ~iscell( expression)
		expression = {expression};
	end
	
	if numel(str) == 1 && numel(expression) > 1
		str = repmat(str, size(expression));
	end
		
	if numel(expression) == 1 && numel( str) > 1
		expression = repmat(expression,size(str));
	end
			
	match = ~cellfun(@isempty, regexp(str, expression, 'once', varargin{:}));

end


end

