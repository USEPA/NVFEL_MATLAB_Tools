function [ col_out , varargout] = table2columns( mat, varargin)
%TABLE2COLUMNS convert lookup table to serialized column data
%
%


dims = size(mat);

arg_dims = [numel(varargin{1}), numel(varargin{2})];
swap_dims = ismatrix(mat) && any( arg_dims ~=  size( mat )) && all( arg_dims([2,1]) ==  size( mat ));

for d = 1:length(dims)
	
	dims_shape = ones(size(dims));
	dims_shape(d) = dims(d); 
	
	dims_rep = dims;
	dims_rep(d)=1;
	
	if ~swap_dims 
		arg_idx = d;
	elseif d ==1;
		arg_idx = 2;
	elseif d ==2
		arg_idx = 1;
	end
		
	
	temp = reshape(varargin{arg_idx}, dims_shape);
	
	temp = repmat( temp, dims_rep);
	
	varargout{arg_idx} = temp(:);
	
end

col_out = mat(:);

end

