% function [value] = parse_varargs(varargs, name, default, class, attributes )
%   Searches varargs for name, checks the following value for type class and attributes.
%   The class and attributes arguments are optional.  Arguments not matching the class
%	and/or attributes provided will return an error. For a list of available attributes 
%	used with numeric data types consult the MATLAB validateattributes function 
%	documentation. If the requested class is 'char' then the attributes argument can be 
%	used to specify a list available strings.  An entry not matching one of the provided 
%	string will generate an error.

function [value] = parse_varargs(varargs, name, default, varargin)
    
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
