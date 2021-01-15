function s = export2struct( varargin)
% function s = workspace2struct( varargin)
% varargs:
% clear_vars = parse_varargs(varargin,'clear',false,'toggle');
% select = parse_varargs(varargin,'select',{'*'},'cell');
% exclude = parse_varargs(varargin,'exclude',{},'cell');
% 
% % Convert Selects to Regular Expressions
% select = strcat('^',strrep(select,'*','.*'),'$');
% exclude = strcat('^',strrep(exclude,'*','.*'),'$');


vars = evalin('caller', 'who');

% exclude = {};		% Exclude None
% select = {'*'};		% Select All
% clear_vars = false;
% for j= 1:length(varargin)
% 	if( ~ ischar(varargin{j}) )
% 		continue;
% 	elseif( strcmpi( varargin{j}, 'clear' ))
% 		clear_vars = true;
% 	elseif( strcmpi( varargin{j}, 'select' ))		
% 		select = varargin{j+1};
% 	elseif( strcmpi( varargin{j}, 'exclude' ))
% 		exclude = varargin{j+1};
% 	end
% end

% Parse Varargin
clear_vars = parse_varargs(varargin,'clear',false,'toggle');
select = parse_varargs(varargin,'select',{'*'},'cell');
exclude = parse_varargs(varargin,'exclude',{},'cell');

% Convert Selects to Regular Expressions
select = strcat('^',strrep(select,'*','.*'),'$');
exclude = strcat('^',strrep(exclude,'*','.*'),'$');


% Empty Structure to Fill
s = {};

% loop through workspace vars
for k = 1:length(vars)

	sl = regexp( vars{k}, select );
	ex = regexp( vars{k}, exclude );
		
	if any([sl{:}]) && ~any([ex{:}])
		
		% Add to struct
		s.(vars{k}) = evalin('caller',vars{k});
		
		% Clear variable if requested
		if clear_vars
			evalin('caller',['clear ',vars{k}] );
		end		
	end
end	

end
