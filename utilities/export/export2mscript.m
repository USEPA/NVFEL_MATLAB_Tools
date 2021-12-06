function  output = export2mscript(  var_val, var_in , varargin)
%WORKSPACE2MFILE
%   Write workspace variables to a nicely formatted string for use in an
%   m script file.
%
%   var2str( vars ) prints the entries in vars where vars
%

% TODO: Add varargs for handling hidden and transient properties

one_line_matrix = parse_varargs(varargin,'one_line_matrix',false,'toggle');
tab_separator = parse_varargs(varargin,'tab_separator',false,'toggle');

create_constructors = parse_varargs(varargin,'class_constructors',true,'toggle');

sort_fieldnames = parse_varargs(varargin,'sort_fieldnames',true,'toggle');
exclude_hidden = parse_varargs(varargin,'include_hidden',true,'toggle');
exclude_constant = parse_varargs(varargin,'include_constant',true,'toggle');
exclude_dependent = parse_varargs(varargin,'include_dependent',true,'toggle');
clear_indexed = parse_varargs(varargin,'clear_indexed',true,'toggle');
exclude_empty = parse_varargs(varargin,'exclude_empty',false,'toggle');


%TODO: Add support for newlines within strings

if tab_separator
	separator = '\t';
else
	separator = ' ';
end

output = '';
var_append_list = {''};
var_list_idx = 1;

while var_list_idx <= length(var_append_list)
	
	var_append = var_append_list{var_list_idx};
	var_current = ['var_val',var_append];
	
	
	try
		var_current_val = eval(var_current);
	catch
		warning(['Couldn''t evaluate ' var_current]);
	end
	
	if iscell( var_current_val) && ~isempty( var_current_val)
		% Cell Array
		
		dims = eval(['size( ',var_current, ');'] );
		idxs_str = cellstr(int2str(REVS_fullfact(dims)));
		idxs_str = regexprep(strtrim(idxs_str ),'\s*',',');
		add_fields = strcat(var_append,'{' , idxs_str,'}' );
		var_append_list = {var_append_list{:}, add_fields{:}};
		
		if  clear_indexed
			var_list_idx = var_list_idx + 1;
		else
			var_append_list(var_list_idx) = [];	% Remove Root
		end
		
	elseif isstruct( var_current_val) && (numel( var_current_val) > 1)
		% Array of structs
		dims = size(var_current_val);
		idxs_str = cellstr(int2str(REVS_fullfact(dims)));
		idxs_str = regexprep(strtrim(idxs_str) ,'\s*',',');
		add_fields = strcat(var_append,'(' , idxs_str,')' );
		var_append_list = {var_append_list{1:var_list_idx}, add_fields{:}, var_append_list{(var_list_idx+1):end}};
		var_append_list(var_list_idx) = [];	% Remove Root
		
	elseif isstruct( var_current_val)
		% Struct
		
		field_names = fieldnames( var_current_val);
		if sort_fieldnames
			field_names = sort(field_names);
		end
		add_fields = strcat(var_append, '.', field_names);
		var_append_list = {var_append_list{1:var_list_idx}, add_fields{:}, var_append_list{(var_list_idx+1):end}};
		var_append_list(var_list_idx) = []; % Remove Root from list
	elseif isobject( var_current_val) && isempty(var_current_val)
		var_append_list(var_list_idx) = []; % Remove root ( constructor )
	elseif isobject( var_current_val) && ismethod( var_current_val, 'properties2export' )
		
		property_names = var_current_val.properties2export( create_constructors );
		
		add_fields = strcat(var_append,'.', property_names );
		var_append_list = {var_append_list{1:var_list_idx}, add_fields{:}, var_append_list{(var_list_idx+1):end}};
		var_list_idx = var_list_idx+1;
		
	elseif isobject( var_current_val) && create_constructors
		% Classes w/ constructor call
		class_info = metaclass( var_current_val);
		property_mask = ~(exclude_hidden & [class_info.PropertyList.Hidden]) & ~(exclude_dependent & [class_info.PropertyList.Dependent]) & ~(exclude_constant & [class_info.PropertyList.Constant]);
		property_names = {class_info.PropertyList.Name};
		property_names = property_names(property_mask);
		
		add_fields = strcat(var_append,'.' , property_names );
		var_append_list = {var_append_list{1:var_list_idx}, add_fields{:}, var_append_list{(var_list_idx+1):end}};
		var_list_idx = var_list_idx+1;
	elseif  isobject( var_current_val)
		% Calss w/o constructor call - > will make a struct
		class_info = metaclass( var_current_val);
		property_mask = ~(exclude_hidden & [class_info.PropertyList.Hidden]);
		property_names = {class_info.PropertyList.Name};
		property_names = property_names(property_mask);
		
		add_fields = strcat(var_append,'.' , property_names );
		var_append_list = {var_append_list{1:var_list_idx}, add_fields{:}, var_append_list{(var_list_idx+1):end}};
		var_append_list(var_list_idx) = []; % Remove root ( constructor )
		
	else
		var_list_idx = var_list_idx+1;
	end
	
end


% Begin Processing Individual Items
for var_list_idx = 1:length(var_append_list)
	
	
	var_name = [var_in,var_append_list{var_list_idx}];
	var = eval(['var_val', var_append_list{var_list_idx} ]);
	
	if isenumeration(var)
		% Print Enumerated Type - mat2str method required
		% 			fprintf(fid,'%s = %s;\r\n', var_name,  mat2str(var) );
		[enum_val, enum_str] = enumeration(var);
		enum_idx = (var == enum_val);
		val_str = enum_str{enum_idx};
		var_str = sprintf('%s = %s.%s;\r\n', var_name,  class(var), val_str );
		
		% 		elseif isobject(var) && ismethod( var, 'export2mscript' )
		% 			var_str = var.export2mscript( var_name, create_constructors);
		%
	elseif isobject(var)
		% Create Class Constructor
		var_str = sprintf('%s = %s;\r\n', var_name,  class(var) );
		
		
	elseif isempty(var) && exclude_empty
		var_str = '';
		
	elseif iscell(var) % && isempty(var)
		% Print Empty Cell Array
		% It is empty or clear it out for further scripted assignment
		var_str = sprintf('%s = { };\r\n', var_name );
		
	elseif ischar(var) &&  isempty(var)
		% Print empty String
		var_str = sprintf('%s = '''';\r\n', var_name );
		
	elseif ischar(var)
		
		[addtl_idx, addtl_idx_str] = handle_addtl_dims(var);
		
		if size(var,1) == 1 % Row or single character
			open_mat_str = '';
			close_mat_str = ';';
			new_line_str = ' ';
		elseif size(var,2) == 1	%Column -> transpose
			dims = 1:ndims(var);
			dims(1:2) = [2,1];
			var = permute(var,dims);
			open_mat_str = '(';
			close_mat_str = ')'';';
			new_line_str = ' ';
		elseif one_line_matrix
			new_line_str = '  ';
			open_mat_str = '[';
			close_mat_str = '];';
		else % 2D
			new_line_str = ' \r\n';
			open_mat_str = '[';
			close_mat_str = '];';
		end
		
		
		if ~isempty(strfind(var,10))
			% String containing newline
			print_str = 'sprintf(''%s'')';
			var = strrep(var,char(10),'\n');
		else
			print_str = '''%s''';
		end
		
		var_rows = size(var,1);
		
		% Make entry to clear things out if using dimensional indexing
		if clear_indexed && size(addtl_idx,1) > 1
			var_str = sprintf('%s = '''';\r\n', var_name);
		else
			var_str = '';
		end
		
		
		for i = 1:size(addtl_idx,1)
			var_str = [var_str,sprintf('%s%s = %s%s', var_name,addtl_idx_str{i},open_mat_str,new_line_str )];
			for r = 1:var_rows-1
				var_str = [var_str,sprintf([print_str,';',new_line_str], strrep(var(r,:,i),'''',''''''))];
			end
			var_str = [var_str,sprintf([print_str,close_mat_str,' \r\n'] , strrep(var(end,:,i),'''',''''''))];
		end
		
		
	elseif (islogical(var) || isnumeric(var) ) && isempty(var)
		
		var_str = sprintf('%s = [];\r\n', var_name);
		
	elseif  islogical(var)
		
		[addtl_idx, addtl_idx_str] = handle_addtl_dims(var);
		
		
		if isscalar(var)	%Scalar
			open_mat_str = '';
			close_mat_str = ';';
			new_line_str = ' ';
		elseif isrow(var)	% Row
			open_mat_str = ['[',separator];
			close_mat_str = [separator,'];'];
			new_line_str = ' ';
		elseif iscolumn(var) % Column
			open_mat_str = ['[',separator];
			close_mat_str = [separator,'];'];
			new_line_str = ' ';
		elseif one_line_matrix	% Print 2D Matrix on 1 line
			new_line_str = '  ';
			open_mat_str = '[';
			close_mat_str = '];';
		else % 2D
			new_line_str = '\r\n';
			open_mat_str = '[';
			close_mat_str = '];';
		end
		
		var_rows = size(var,1);
		var_col = size(var,2);
				
		% Loop through additional dimensions to create bunch of 2D
		for i = 1:size(addtl_idx,1)
			
			% Print variable name & Additional indicies
			var_str = sprintf(['%s%s = ',open_mat_str,new_line_str ] , var_name,addtl_idx_str{i} );
			
			% Print most of the data
			for r = 1:var_rows
				
				row_str = repmat(sprintf(['false',separator]), 1, var_col);
				for c = find(var(r,:,i))
					write_idx = (c-1)*6+(1:5);
					row_str(write_idx ) = ' true';
				end
				
				var_str = [var_str ,sprintf(new_line_str), row_str, ';'];
			end
			
			% Close matrix
			var_str = [var_str(1:end-1), sprintf([close_mat_str,' \r\n'])];
						
		end
		
		% Prepend entry to clear things out if using dimensional indexing
		if clear_indexed && size(addtl_idx,1) > 1
			var_str = sprintf('%s = [];\r\n%s', var_name, var_str);
		end
		
	elseif isnumeric( var)
		
		[addtl_idx, addtl_idx_str] = handle_addtl_dims(var);
		
		if isscalar(var)	%Scalar
			open_mat_str = '';
			close_mat_str = ';';
			new_line_str = ' ';
		elseif isrow(var)	% Row
			open_mat_str = ['[',separator];
			close_mat_str = [separator,'];'];
			new_line_str = ' ';
		elseif iscolumn(var) % Column
			open_mat_str = ['[',separator];
			close_mat_str = [separator,'];'];
			new_line_str = ' ';
		elseif one_line_matrix	% Print 2D Matrix on 1 line
			new_line_str = '  ';
			open_mat_str = '[';
			close_mat_str = '];';
		else % 2D
			new_line_str = '\r\n';
			open_mat_str = '[';
			close_mat_str = '];';
		end
		
		var_rows = size(var,1);
		var_col = size(var,2);
		
		
		if 0 %TODO: add special format by variable name
			
		elseif isfloat(var) && isscalar(var) && length(sprintf( '%0.12g',var) ) < 8
			print_str = '%g';	% short scalar float
		elseif isfloat(var) && isscalar(var)
			print_str = '%0.17g';	% long scalar float
		elseif isfloat(var)
				
% 			var_exponent = floor(log10(max(eps,abs(var(:)))));
% 			var_coeff = var(:) ./( 10.^var_exponent);
% 			var_coeff_expand = var_coeff * 10.^(1:16);
% 			var_sig_digits = max(5,max(sum( cumprod(var_coeff_expand ~= round(var_coeff_expand), 2), 2) + 1));
% 			
% 			
% 			var_format = sprintf('%%#%d.%dg%s',var_sig_digits + 3, var_sig_digits, separator);
% 			print_str = repmat(var_format,1,var_col);  % .17 is as far as matlab will go
			
 			print_str = repmat(['%#22.17g',separator],1,var_col);  % .17 is as far as matlab will go
				
		else
			print_str = repmat(['%d',separator],1,var_col);
		end
		

		% Loop through additional dimensions to create bunch of 2D
        var_str ={};
		for i = 1:size(addtl_idx,1)
			
			% Print variable name & Additional indicies
			var_str{i} = sprintf(['%s%s = ',open_mat_str] , var_name,addtl_idx_str{i} );
			
			% Print most of the data
			for r = 1:var_rows
				var_str{i} = [var_str{i},sprintf([new_line_str,print_str,';'], var(r,:,i))];
			end
			
			% Close matrix
			% Exclude final semicolon
			var_str{i} = [var_str{i}(1:end-1), sprintf([close_mat_str,' \r\n'])];			
		end
		var_str = strjoin(var_str,'');
		% Prepend entry to clear things out if using dimensional indexing
		if clear_indexed && size(addtl_idx,1) > 1
			var_str = sprintf('%s = [];\r\n%s', var_name, var_str);
		end
		
	else
		
		fprintf( 'Unable to write variable %s to file!\n', var_name );
		
	end
	
	% Append String
	output = [output, var_str];
	
	
end



end


function [addtl_idx, addtl_idx_str] = handle_addtl_dims(var)

var_dims = ndims(var);


if var_dims > 2
	addtl_dims = var_dims-2;
	addtl_size = size(var);
	addtl_size = addtl_size(3:end);
	
	% construct list of all variations for dimensions beyond 2
	addtl_cases = prod(addtl_size);
	num_loops = addtl_cases;
	addtl_idx = zeros(addtl_cases,addtl_dims);
	
	for d = 1:addtl_dims
		options = (1:addtl_size(d));                % 1:num options for current dimension
		num_repeats = addtl_cases ./ num_loops;       % number times to repeat each value
		num_loops = num_loops ./ addtl_size(d);       % number times to repeat sequence
		options = options(ones(1,num_repeats),:);   % repeat each value
		options = options(:);						% convert to column vector
		options = options(:,ones(1,num_loops));		% repeat sequence to fill the array
		addtl_idx(:,d) = options(:);				% append to output
	end
	
	% construct formatting string - colon for first 2 dimensions
	addtl_idx_fstr = ['(:,:,%d', repmat(',%d',1,addtl_dims-1),')'];
	
	% Generate strings for each additional
	for i = 1:size(addtl_idx,1)
		addtl_idx_str{i} = sprintf( addtl_idx_fstr, addtl_idx(i,:));
	end
	
else % Nothing to do
	
	addtl_idx_str = {''};
	addtl_idx = 1;
	
end

end


function b = isenumeration(m)
b = ~isempty(enumeration(m));
end

