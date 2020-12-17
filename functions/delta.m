function [answer] = delta(vector, mode)
% DELTA Approximate derivative with length(vector) elements.
%   DELTA(vector, mode) returns diff(vector), prepended with either
%       the first element of diff(vector) if mode == 1, or 0 if mode == 2.
%
% see also diff.
    
answer = diff(vector);

if (mode ~= 2) 
    mode = 1;
end

if size(vector,1) == 1
    if mode == 1
        answer = [answer(1) answer];
    elseif mode == 2
        answer = [0 answer];
    end
else
    if mode == 1
        answer = [answer(1); answer];
    elseif mode == 2
        answer = [0; answer];
    end
end
