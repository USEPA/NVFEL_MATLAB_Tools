% function [ answer ] = normalize( var, index )
% returns var normalized to var(index)
function [ answer ] = normalize( var, index )
% returns var normalized to var(index)

answer = var./var(index);

end

