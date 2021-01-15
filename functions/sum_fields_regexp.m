function [sum, found] = sum_fields_regexp( s, expr)

if isstruct(s)
    fields = fieldnames( s);
elseif isobject(s)
    fields = properties(s);
else
    error('First input argument must be a structure or class');
end

match_idx = ~cellfun(@isempty,regexp(fields, expr));
match_idx = find(match_idx);

sum = 0;
found = length(match_idx);

for i = 1:found
    sum = sum + s.(fields{match_idx(i)});
end
    
end