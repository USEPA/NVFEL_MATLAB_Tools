function [sum, found] = sum_fields_regexp(s, expr)
% [sum, found] = SUM_FIELDS_REGEXP(s, expr)
%
% Return sum of fieldnames/properties of ``s`` that match ``expr``
%
% Parameters:
%   s: object or structure variable to sum fields of
%   expr: regular expression supported by ``regexp``
%
% Returns: sum of fieldname/property vectors of ``s`` that match ``expr``
%
% Example::
%
%   input_energy_pos = sum_fields_regexp(obj, '^input[0-9]*_pos_kJ$');
%
% See also: regexp

if isstruct(s)
    fields = fieldnames(s);
elseif isobject(s)
    fields = properties(s);
else
    error('First input argument must be a structure or class');
end

match_idx = ~cellfun(@isempty, regexp(fields, expr));
match_idx = find(match_idx);

sum = 0;
found = length(match_idx);

for i = 1:found
    sum = sum + s.(fields{match_idx(i)});
end
    
end