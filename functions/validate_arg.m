function [ value ] = validate_arg( arg_in, arg_type, arg_attrib )
% [ value ] = validate_arg( arg_in, arg_type, arg_attrib )
% 
% Validate ``arg_in`` against ``arg_type`` and ``arg_attrib``. Extends
% behavior of Matlab as in ``validateattributes``, ``validatestring``
%
% Parameters:
%   arg_in: variable to be validated
%   arg_type: 
%       type to be validated against:
%           * 'cellstr': cell array of strings
%           * 'file': file identifier or file name
%           * 'dir': directory identifier or directory name
%           * 'colormap': matlab colormap
%           * 'char': char or string
%           * 'logical': logical value type
%           * arbitrary matlab type
%   arg_attrib: attributes as in ``validateattributes`` /
%       ``validatestring`` ``attributes`` parameter
%
% See also:
%   validateattributes, validatestring

	% Type & Attributes not required
    if nargin <2
		arg_type = {};  
    elseif ischar(arg_type)
        arg_type = {arg_type};  
    end
    
    if nargin < 3
        arg_attrib = {};
    elseif ischar(arg_attrib)
        arg_attrib = {arg_attrib};    
    end
	
	% Convert other data types to appropriate MATLAB class
% 	type = strrep(type,'string','char');
	arg_type = regexprep(arg_type,'^str(ing)?$','char','ignorecase');
	arg_type = regexprep(arg_type,'^bool$','logical','ignorecase');
	
    if	isempty(arg_type)
		% No Class Checking
		value = arg_in;
    elseif numel( arg_type) > 1
        % Check Class and Attributes - No special checking
		validateattributes( arg_in, arg_type, arg_attrib)
		value = arg_in;
    elseif strcmpi(arg_type,'cellstr')
		validateattributes( arg_in, {'char', 'cell'}, {});
        if iscell(arg_in)
			value = arg_in;
            for a = 1:numel(arg_in)
				value{a} = validate_arg( arg_in{a}, 'char', arg_attrib);
            end
        else
			value = {validate_arg( arg_in, 'char', arg_attrib)};	
        end	
    elseif strcmpi(arg_type,'file')
        if ~ischar(arg_in) || ~exist(arg_in, 'file')
            error( 'Unexpaced input format or file not found');
        end
        value = arg_in;
    elseif strcmpi(arg_type,'dir')
        if ~ischar(arg_in) || ~exist(arg_in, 'dir')
            error( 'Unexpaced input format or directory not found');
        end
        value = arg_in;	
    elseif strcmpi(arg_type,'colormap') && ischar(arg_in)
        validatestring(arg_in, {'parula','jet','hsv','hot','cool','spring','summer','autumn','winter','gray','bone','copper','pink','lines','colorcube','prism','flag','white','default'})
        value = arg_in;
    elseif strcmpi(arg_type,'colormap')
        validateattributes(arg_in, {'numeric'}, {'ncols',3})
        value = arg_in;   
    elseif strcmpi(arg_type,'char') && isempty(arg_attrib)
		% Check Class - No String Check
		validateattributes(arg_in, {'char'}, {})
		value = arg_in;		
    elseif strcmpi(arg_type,'char')
		% Check Class - Check List of Strings
		validateattributes(arg_in, {'char'}, {})
		value = validatestring(arg_in, arg_attrib);
    elseif strcmpi(arg_type,'logical') && isequal(arg_in, logical(arg_in))
		arg_in = logical(arg_in);
		validateattributes(arg_in, arg_type, arg_attrib)
		value = arg_in;
    else %Numeric and other types	
		% Check Class and Attributes
		validateattributes(arg_in, arg_type, arg_attrib)
		value = arg_in;
    end
	
end

