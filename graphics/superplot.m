function h = superplot(varargin)
% SUPERPLOT upgraded linear plotting compatible with Matlab **plot** function
%
% SUPERPLOT is a replacement for the built-in matlab plotting with 
% additional options and functionaliy.  Default colors based on SAE
% guidelines for technical papers
%
% Parameters:
%   varargin (optional keyword and name-value arguments): plot arguments
%
% Returns:
%   line series handle: vector of line series handles
%
% SUPERPLOT(Y) and SUPERPLOT(X,Y) behaves similar to ``plot(Y)`` and
% ``plot(X,Y)`` except that the defualt line width is 2 for easier readability
% 
% SUPERPLOT(X,Y,S) accepts line and marker style properties like **plot**, 
% but has additional colors and features available.  Whereas the line 
% specification for plot only contains color, marker and line style 
% SUPERPLOT can take arguments composed of the following parameters, all
% of which are optional:
% 
% ::
%
%     marker edge color - see color list below
%     marker face color - see color list below
%     marker shape - see list below
%     marker size - default value = 6
%     line color - see color list below
%     line style - see list below
%     line width - default value = 2
% 
% SUPERPLOT(X1,Y1,S1,X2,Y2,S2,...) allows multiple lines to be plotted 
% just as with plot
%
% Examples:
% Light blue circle markers of size 7 with a black dashed line of size 3::
%
%       superplot(X,Y,'lbo7k--3');
%
% Red square markers with yellow centers connected by a blue solid line::
%
%       superplot(X,Y,'rysb-');
%
% Note if only one color is supplied it will be used for all marker and line elements 
%
%   ::
%
%	Color Codes
%		lb		light blue		matches SAE Blue
%		b		medium blue*
%		db		dark blue		matches SAE Dark Blue
%		lg		light green		matches SAE Light Green
%		g		green*			matches SAE Dark Green
%		dg		dark green		
%		y		yellow*			matches SAE Yellow
%		r		red*			matches SAE Red
%		lr		light red
%		dr		dark red
%		gy		gray			matches SAE Medium Gray
%		or		orange			matches SAE Orange
%		m		magenta
%		w		white
%		c		cyan
%		k		black
%		vt		violet / purple
%		pu		violet / purple
%		* denotes codes shared matlab plot using different color values
%
%	Markers Types				Line Styles
%       .     point					  -     solid
%       o     circle				  :     dotted
%       x     x-mark				  -.    dashdot 
%       +     plus					  --    dashed   
%		*     star					(none)  no line
%		s     square
%       d     diamond
%       v     triangle (down)
%       ^     triangle (up)
%       <     triangle (left)
%       >     triangle (right)
%       p     pentagram
%       h     hexagram



colors = {
	'lb',	[  1, 160, 233]/255; % SAE Blue
	'g',	[  0, 119,  61]/255; % SAE Dark Green
	'y',	[255, 178,   1]/255; % SAE Yellow	
	'gy',   [154, 155, 157]/255; % SAE Medium Gray
	'db',   [  0,  81, 149]/255; % SAE Dark Blue	
	'lg',	[ 46, 177,  53]/255; % SAE Light Green		
	'or',	[234, 113,  37]/255; % SAE Orange
	'vt',	[180,  40, 180]/255;
	'dr',	[150,  20,  15]/255; %	
	'dg',   [  0, 100,  45]/255; %	
	'b',	[  0, 120, 190]/255; % 
	'lr',	[255,  92,  70]/255; %
	'k',	[0,		0,	 0]/255
	'm',	[255,   0, 255]/255;
	'c',	[0,   255, 255]/255;
	'w',	[255, 255, 255]/255;
	'pu',	[180,	40,	180]/255;
	'r',	[220,  41,  30]/255; % SAE Red
	};

markers = {'+','o','*','.','x','s','square','d','diamond','p','pentagram','h','hexagram','v','<','>','^'};
line_styles = {'-','--',':','-.'};


newplot;
h = [];


args = length(varargin);

legend_str = {};
legend_hand = [];

i = 1;

while i <= args
	
	x_dat = varargin{i};
	y_dat = [];
	z_dat = [];
	spec = '';
	i = i+1;
	
	% check for y data
	if i <= args &&( islogical(varargin{i}) ||  isnumeric(varargin{i}) ||  isduration(varargin{i}))
		y_dat = varargin{i};
		i = i+1;
	end
	
	% Check for z data
	if i <= args &&( islogical(varargin{i}) ||  isnumeric(varargin{i}) ||  isduration(varargin{i}))
		z_dat = varargin{i};
		i = i+1; 
	end
	
	% check for line spec
	if i <= args && ischar(varargin{i})
		spec = varargin{i};
		i = i+1;
	end
	
	% handle single vector vs ticks
	if isempty(x_dat) && isempty(y_dat) && isempty(z_dat)
		% Both Empty - Skip it
% 		continue;
	elseif isempty(y_dat)
		% Single Vector - Plot vs ticks
		y_dat = x_dat;
		x_dat = 1:length(x_dat);
	end
	
	% Make Rows columns
	if isrow(x_dat)
		x_dat = x_dat(:);
	end
	
	if isrow(y_dat)
		y_dat = y_dat(:);
	end
	if isrow(z_dat)
		z_dat = z_dat(:);
	end

	
	% Expand any scalar inputs
	dat_size = max( [size(x_dat); size(y_dat); size(z_dat) ] );
	
	
	if isscalar( x_dat)
		x_dat = x_dat * ones(dat_size);
	end
	
	if isscalar( y_dat)
		y_dat = y_dat * ones(dat_size);
	end
	
	if isscalar( z_dat)
		z_dat = z_dat * ones(dat_size);
	end

	% Save Existing lines for Reference
% 	existing_lines = get(gca,'children');
% 	is_line = strcmp( get( existing_lines, 'type') ,'line');
% 	existing_lines = existing_lines(is_line);
	existing_lines = findobj( gcf, 'type','line');
	
	% Draw Line
	if isempty( z_dat ) || ( isempty( x_dat) && isempty( y_dat ) ) 
		line_hand = line( x_dat, y_dat,'LineWidth',1.25);
	else
		line_hand = line( x_dat, y_dat, z_dat, 'LineWidth',1.25);
	end
	
	%Nothing to draw jump to next line
	if isempty(line_hand)
		% check for additional param value pairs
		while i <= args && ischar(varargin{i})
			i = i+2;
		end
		continue;
	end
	
	color_set = false;
	
	% Determine Color - Global or Marker Edge Color
	[match, spec] = match_str( spec, colors(:,1) );
	if any(match)
		color_val = colors{match,2};
		set(line_hand,'Color',color_val);
		set(line_hand,'MarkerEdgeColor',color_val);
		color_set = true;
	end
	
	% Determine Color - Marker Face Color
	[match, spec] = match_str( spec, colors(:,1) );
	if any(match)
		color_val = colors{match,2};
		set(line_hand,'MarkerFaceColor',color_val);
    end
    
    % Determine Marker shape and size
	[match, spec] = match_str( spec, markers);
	marker_size_mod = 1.0;
	if any(match)
        
		 set(line_hand,'Marker',markers{match});
		
        %Special case for dot (create circle and fill)
        if markers{match} == '.'
            set(line_hand,'Marker','o');
            marker_size_mod = 0.7;
            
			%set default dot size and fill
            set(line_hand,'Markersize', 4);
      			
			if strcmp(line_hand.MarkerEdgeColor,'auto')
				set(line_hand,'MarkerEdgeColor',get_next_color(existing_lines,colors));
			end
				
			if strcmp(line_hand.MarkerFaceColor,'none')
				set(line_hand,'MarkerFaceColor',line_hand.MarkerEdgeColor);
			end  
            
        else 
            set(line_hand,'Marker',markers{match}); %normal case
        end
        
        %Remove line
		set(line_hand,'LineStyle','none');
		

        %Set Marker Size
		num = regexp(spec,'^\d+','match');		
		if ~isempty(num)
			num = num{1};
            set(line_hand,'MarkerSize',str2double(num)* marker_size_mod ); %normal case           
			spec = spec((1+length(num)):end);
		end
		
	end
    
    
    % Determine Line Color - Set Via Global - try for compatability with matlab linespec can be in any order
	[match, spec] = match_str( spec, colors(:,1) );
	
	if any(match)
		color_val = colors{match,2};
		set(line_hand,'Color',color_val);
		color_set = true;
	elseif color_set
		% Already Set - DO Nothing
    else
        set(line_hand,'Color',get_next_color(existing_lines,colors));
    end
	
	% Determine Line Color - Set Via Global
	[match, spec] = match_str( spec, colors(:,1) );
	
	if any(match)
		color_val = colors{match,2};
		set(line_hand,'Color',color_val);
		color_set = true;
	end

	
	% Determine Line Style
	[match, spec] = match_str( spec, line_styles);
	if any(match)
		set(line_hand,'LineStyle',line_styles{match});
		
		num = regexp(spec,'^\d+','match');		
		if ~isempty(num)
			num = num{1};
			set(line_hand,'LineWidth',str2double(num) );
			spec = spec((1+length(num)):end);
		end
	end
	

	
	
	% check for additional param value pairs
	while i <= args && ischar(varargin{i})
		
		if strcmpi( varargin{i}, 'legend')
			line_hand.displayName = varargin{i+1};
			legend_hand(end+1) = line_hand;			
% 			legend_str{end+1} = varargin{i+1};
        else
			% Handle built in line value pair properties
			set(line_hand, varargin{i}, varargin{i+1});
		end
		i = i+2;
	end
	
	h = [h; line_hand(:)];
	
end

if ~isempty(legend_hand)
	legend(legend_hand);
end

end


function [match, spec_rem] = match_str( spec, opts)

% Go long to short need to check for -- vs -

match = 0;
for l = length(spec):-1:1
	
	match = strcmpi( spec(1:l), opts );
	
	if any(match)
		spec_rem = spec((l+1):end);
		return
	end
	
end


spec_rem = spec;

end


function color_val = get_next_color(existing_lines, colors)

if isempty(existing_lines)
     color_val = colors{1,2};
else
    % Color Not Specified - Check What is Used
		existing_colors = get(existing_lines,'color');
		
		if iscell( existing_colors )
			existing_colors = cell2mat(existing_colors);
		end
		
		[~, available_idx] = setdiff( cell2mat(colors(:,2)), existing_colors,'rows');
		
		if ~isempty(available_idx)
			color_val = colors{min(available_idx),2}; % Use first available on the list
		else
			color_val = rand(1,3); % All the colors used? Go Random!
        end
end
end




