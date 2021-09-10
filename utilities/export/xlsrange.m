function range = xlsrange( c, r, w, h )
	
if ischar( c)
	c = xlscol(c);
end

if nargin <= 2
	range = sprintf('%s%d', xlscol(c), r);
else
	
	if nargin < 3
		w = 1;
	end
	
	if nargin < 4
		h = 1;
	end
	
	if isinf(w) && isinf(h)
		range = '1:1048576';
	elseif isinf(w)
		range = sprintf('%d:%d',  r, r+h-1);
	elseif isinf(h)
		range = sprintf('%s:%s', xlscol(c), xlscol(c+w-1));
	else
		range = sprintf('%s%d:%s%d', xlscol(c), r, xlscol(c+w-1), r+h-1);
	end
end

end
