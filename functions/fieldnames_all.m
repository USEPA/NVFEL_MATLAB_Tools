function [ vars, var_containers ] = fieldnames_all( varname_str, varargin )
%returns names of all fields/properties of varname_str and a list of which
% fields contain other fields

vars = {varname_str};

var_containers = {};

sort_fieldnames = parse_varargs(varargin,'sort_fieldnames', true, 'toggle');

var_list_idx = 1;
while var_list_idx <= length(vars)
%    var_list
    var_current = vars{var_list_idx};
    
    try
        field_names = evalin('caller',['fieldnames( ', var_current, ');'] );
        if sort_fieldnames
            field_names = sort(field_names);
        end
        
        add_fields = strcat(var_current , '.', field_names);
        vars = {vars{1:var_list_idx}, add_fields{:}, vars{(var_list_idx+1):end}};
        vars(var_list_idx) = []; % Remove Root from list
        var_containers{end+1} = var_current; %#ok<AGROW>
    catch
        var_list_idx = var_list_idx+1;        
    end
end

vars = vars';
var_containers = var_containers';

end

