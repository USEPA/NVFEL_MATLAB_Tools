function [ answer ] = was_provided( var )
% [ answer ] = was_provided( var )
% Used in data classes to see if property was ever provided by the user.
% Returns true if var is not empty and has non-NaN values
%
% Parameters:
%   var: variable to test for non-empty, non-NaN values
%
% Returns:
%   ``true`` if ``var`` is non-empty and has non-NaN values
%

    answer = ~isempty(var) && ~all(isnan(var));
    
end

