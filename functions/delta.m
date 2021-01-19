function [answer] = delta(vector, mode)
% [answer] = DELTA(vector, mode)
%
% Approximate derivative with ``length(vector)`` elements.
%
% Returns ``diff(vector)``, prepended with either the first element of 
% ``diff(vector)`` if ``mode`` == 1, or 0 if ``mode`` == 2.
%
% Parameters:
%   vector: variable to create approximate derivative of
%   mode: 
%       first element of result is first element of ``diff(vector)`` if 
%       mode == 1, first element is 0 otherwise
%
% Returns:
% ``diff(vector)``, prepended with either the first element of 
% ``diff(vector)`` if mode == 1, or 0 if mode == 2.
%
% See also: diff
%

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
