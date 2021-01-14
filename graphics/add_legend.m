function [ LEGH ] = add_legend( legend_string, varargin )
% function [ LEGH ] = ADD_LEGEND( legend_string, varargin )
%   Adds ``legend_string`` to the current legend, if a legend does not exist
%   it is created.  Supports normal **legend** varargs
%
% Parameters:
%   legend_string (str): The legend string to add
%   varargin (optional keyword and name-value arguments): optional arguments passed to the **legend** function
%
% Returns:
%   legend handle: handle to the current legend
%
% Note:
%   Sets legend Interpreter to 'none', so underscores display properly
%
% See also:
%   legend
%

LEGH = legend;

warning('off','MATLAB:legend:IgnoringExtraEntries')
if isempty(LEGH) || isempty(LEGH.String) || isequal(LEGH.String{1},'')
    LEGH = legend(legend_string, varargin{:} );  % first legend string
else
    LEGH = legend(unique({LEGH.String{:},legend_string},'stable'), varargin{:} ); % subsequent strings
end
warning('on','MATLAB:legend:IgnoringExtraEntries')

set(LEGH,'Interpreter','none');