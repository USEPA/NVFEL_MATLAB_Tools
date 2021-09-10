function  export2mfile( fname, vars , varargin)
%export2mfile
%   Write workspace variables to a nicely formatted m script file.


fid = fopen( fname ,'w+');

if ~iscell(vars)
	vars = {vars};
end

for i = 1:length(vars)
	var_str = export2mscript( evalin('caller',vars{i}),vars{i}, varargin{:} );
	fprintf(fid, '%s\n', var_str);
end

fclose(fid);


