function [out] = REVS_fullfact(opts)
% [out] = REVS_fullfact(opts) 
%
% Full-factorial matrix generator
%
% Creates a design matrix OUT containing the settings for a full factorial.
% The input vector opts specifies the number of options for each level in
% the design.
%
% Parameters:
%   opts: Vector of factorial dimensions
%
% Returns:
%   Full factorial matrix with levels defined by ``opts``
%
% Example::
%
%  >> REVS_fullfact([1,2,3])
%
%     ans =
% 
%          1     1     1
%          1     2     1
%          1     1     2
%          1     2     2
%          1     1     3
%          1     2     3

if ~isvector( opts ) || any( (round(opts)~= opts) | (opts < 1) )
    error('Input must be a vector of positive integers')
end

out = (1:opts(1))';

for idx = 2:length(opts)
       
    o = opts(idx);    
    
    l = repmat(out, o, 1);
    s = size( out,1);
    r = ceil( (1:(s*o))' ./ s );
    out = [l, r];
        
end


