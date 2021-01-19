function [value] = parse_varargs(varargs, name, default, varargin)
% [value] = PARSE_VARARGS(varargs, name, default, class, attributes )
%
% Search varargs for name, checks the following value for type class and attributes.
% The class and attributes arguments are optional.  Arguments not matching the class
% and/or attributes provided will return an error. For a list of available attributes 
% used with numeric data types consult the MATLAB validateattributes function 
% documentation. If the requested class is 'char' then the attributes argument can be 
% used to specify a list available strings.  An entry not matching one of the provided 
% string will generate an error.
%
% Parameters:
%   varargs: 
%        cell array of names/name-value pairs, ``varargin`` from calling function
%   name:
%       string name of varargin to parse
%   default:
%       default value for ``value`` if ``name`` not found
%   varargin (optional keyword and name-value arguments):
%       * 'toggle', or validation / vararg type information supported by
%           ``validate_arg()`` and ``validateattributes()``
%
% Returns:
%   Default value or value provided by ``varargs``
%
% See also: validate_arg, validateattributes, validatestring
%
% Hint:
%   'toggle' type varargs have a default boolean value and providing the
%   named vararg string toggles the value from true to false or vice versa
%

	% Check Number of Arguments
	narginchk(3, 5);

	% Set Default Value
	value = default;

    % Find matching Entries
	match = strcmpi( name, varargs);
	idx = find(match,1) + 1;
    
    if sum(match) < 1
       value = default; 
    elseif sum(match) > 1
        % Error if multiple matches found
		error(['Multiple entries for parameter ', name ]);
	elseif isempty(varargin)
		value = varargs{idx};
	elseif strcmpi( varargin{1}, 'toggle')
        value = ~default;
    elseif idx > length(varargs) 
        % Last argument does not have a pair
        error(['No matching argument provided for parameter ',name]);
    else
		% Index of matching parameter
        value = validate_arg( varargs{idx}, varargin{:} );
    end
        
end
