function [] = powerlines( varargin )
% function [] = POWERLINES( varargin )
%   Draw lines of constant power in increments on the current plot axis,
%   typically used with engine or motor map plots.
%
% Parameters:
%   varargin (optional keyword and name-value arguments):
%       * 'units' (str)
%           'W', 'kW' or 'hp' - hints that chart is in RPM & Nm, or RPM &
%           ft-lbs.
%
%       * 'convert' (numeric, requires 'units' to be supplied)
%           provides an arbitrary power scale.
%
%       * 'max' (numeric)
%           maximum power line in ``units`` (if supplied), taken as Watts 
%           if over 10,000 and no ``units`` are supplied, otherwise taken 
%           as kiloWatts if no ``units`` are supplied.
%
%       * 'min' (numeric)
%           minimum power line in ``units`` (if supplied), 
%           taken as Watts if ``max`` is over 10,000 and no ``units`` are 
%           supplied, otherwise taken as kiloWatts if no ``units`` are
%           supplied.
%
%       * 'increment' (numeric)
%           distance, in ``units`` (if supplied) between power lines.  
%           If not supplied, it will be calculated to draw 11 lines between
%           min and max power.
%
%       * 'z_offset' (numeric) 
%           height above chart to plot powerlines, default = 0, allows power
%           lines to 'hover' if they interfere with other plot elements.
%
%       * 'auto_refresh' (bool): 
%           if provided, then powerline re-draw will be enabled or disabled
%           on plot resizing. Default value is **true**.  Adds a listener
%           to the plot, calls **rescale_callback** subfunction
%
% Examples:
%   Powerlines from 10 kW to 100 kW in 5 kW increments::
%
%       powerlines('min', 10, 'max', 100, 'increment', 5);
%
%   or::
%
%       powerlines('min', 10, 'max', 100, 'units', 'kW', 'increment', 5);
%
%   Powerlines from 10 hp to 100 hp in automatic increments::
%
%       powerlines('min', 10, 'max', 100, 'units', 'hp');
%
%   Powerlines from 10 kW to 100 kW in 5 kW increments, automatic refresh turned off::
%
%       powerlines('min', 10, 'max', 100, 'increment', 5, 'auto_refresh', false);
%
% See Also:
%   rescale_callback (POWERLINES sub-function)
%

    ax = gca;
    x_range = xlim;
	y_range = ylim;

    power_units = parse_varargs(varargin, 'units', 'auto');
    power_scale = parse_varargs(varargin,'convert', [], 'numeric', {'scalar'});
    power_max = parse_varargs(varargin,'max', inf, 'numeric', {'scalar'});
	power_min = parse_varargs(varargin,'min', -inf ,'numeric', {'scalar'});
	z_offset    = parse_varargs(varargin, 'z_offset', 0, 'numeric');
    increment    = parse_varargs(varargin, 'increment', [], 'numeric');
    auto_refresh = parse_varargs(varargin, 'auto_refresh', true, 'bool');
	
    
if strcmpi( power_units, 'kW')
             power_scale = parse_varargs(varargin, 'convert', 1.047e-4, 'numeric',{'scalar'});     % Assume RPM & Nm for now
elseif strcmpi( power_units, 'W')
            power_scale = parse_varargs(varargin, 'convert', 1.047e-1, 'numeric',{'scalar'});      % Assume RPM & Nm for now
elseif strcmpi( power_units, 'hp')
            power_scale = parse_varargs(varargin, 'convert', 1.5867e-5, 'numeric',{'scalar'});     % Assume RPM & ft-lbs for now

elseif strcmpi( power_units, 'auto') && ~isempty(power_scale)
    error('Power conversion factor cannot be specified without specifying units');
elseif  strcmpi( power_units, 'auto')          
    % Auto W or kW                  
    max_pow = max(abs(kron(x_range,y_range)))*1.047e-1;	
    if max_pow > 10000
        power_scale = 1.047e-4; % Use kW
        power_units = 'kW';
    else
         power_scale = 1.047e-1; % Use W
         power_units = 'W';
    end
elseif isempty(power_scale)
    error('Unknown Power Units %s, a conversion factor is required', power_units);
else
    %UNknown Units, but conversion factor supplied        
end
    
	pow_max = max(kron(x_range,y_range)) * power_scale;
    pow_min = min(kron(x_range,y_range)) * power_scale;
    pow_range = pow_max - pow_min;  % Visible Range
    
    if isempty(increment )
    
    increment_num_lines = 11;   % Approximate Number of lines
    increment_scale = 10^floor(log10( pow_range/increment_num_lines ));
    increment = increment_scale .* interp1( [1, 1.5, 2, 2.5,  5, 10],[1, 1.5, 2, 2.5,  5, 10],pow_range/increment_num_lines/increment_scale,'nearest');
    
    end
    
    % Actual Range Plotted ( Larger for Zoom Out Ability ) 
    pow_max = min(max(0, pow_max + pow_range/2), power_max);
    pow_min = max(min(0, pow_min - pow_range/2), power_min);
    
    % Make actual levels
    neg_pow_levels = [-increment/2, -increment:-increment:pow_min];
    pos_pow_levels = [ increment/2,  increment: increment:pow_max];

    pow_levels = [neg_pow_levels, pos_pow_levels];
    		
	 
	line_hand = [];
	txt_hand = [];
    set(ax,'YLimMode','manual');
	
	z_pts = zeros(1,50) + z_offset;
    x1_pts = linspace(x_range(1), x_range(2), 25);
    y2_pts = linspace(y_range(1), y_range(2), 25);
	
	for p = length(pow_levels):-1:1
		        
		y1_pts = pow_levels(p) ./ (x1_pts * power_scale );
        y1_pts( y1_pts > y_range(2) | y1_pts < y_range(1)) = nan;
           
        x2_pts = pow_levels(p) ./ (y2_pts * power_scale );
        x2_pts( x2_pts > x_range(2) | x2_pts < x_range(1)) = nan;
        
        [x_pts, order] = sort( [x1_pts, x2_pts]);
        y_pts = [y1_pts, y2_pts];
        y_pts = y_pts(order);
              
		line_hand(p) = line(x_pts, y_pts, z_pts,'color',[0.5,0.5,0.5],'lineWidth',0.1,'HandleVisibility','off');
		txt_hand(p) = text(x_pts(end), y_pts(end), z_offset, sprintf(' %g %s',pow_levels(p),power_units),'HorizontalAlignment','Left','HandleVisibility','off');
    
	end
	
	rescale_callback([],[], ax, pow_levels, power_scale, line_hand, txt_hand, z_offset);
		
	if auto_refresh
		
		addlistener(ax,'XLim','PostSet', @(src,evt)rescale_callback(src,evt, ax, pow_levels, power_scale, line_hand, txt_hand, z_offset ));
		addlistener(ax,'YLim','PostSet', @(src,evt)rescale_callback(src,evt, ax, pow_levels, power_scale, line_hand, txt_hand, z_offset ));
		addlistener(ax,'LocationChanged', @(src,evt)rescale_callback(src,evt, ax, pow_levels, power_scale, line_hand, txt_hand, z_offset ));
		addlistener(ax,'SizeChanged', @(src,evt)rescale_callback(src,evt, ax, pow_levels, power_scale, line_hand, txt_hand, z_offset ));

	end
	
end

    
function rescale_callback(src, evt, ax, pow_levels, power_scale, line_hand, txt_hand, z_offset)
% function rescale_callback(src, evt, ax, pow_levels, power_scale, line_hand, txt_hand, z_offset)
%   Refreshes powerlines when plot is resized, if enabled by 'auto_refresh'
% 
	x_range = xlim;
	y_range = ylim;
	
	x1_pts = linspace(x_range(1), x_range(2), 25);
    y2_pts = linspace(y_range(1), y_range(2), 25);

	for i = 1:length(pow_levels)

 		p = pow_levels(i);

		y1_pts = p ./ (x1_pts * power_scale );
        y1_pts( y1_pts > y_range(2) | y1_pts < y_range(1)) = nan;
        
     
        x2_pts = p ./ (y2_pts * power_scale );
        x2_pts( x2_pts > x_range(2) | x2_pts < x_range(1)) = nan;
        
        [x_pts, order] = sort( [x1_pts, x2_pts]);
        y_pts = [y1_pts, y2_pts];
        y_pts = y_pts(order);

        % Update Right Labels
		if y1_pts(end) < y_range(2) && y1_pts(end) > y_range(1)
			set( txt_hand(i), 'position',[x1_pts(end), y1_pts(end),z_offset],'visible','on');
		else
			set( txt_hand(i),'visible','off');
		end
        
		set( line_hand(i), 'Xdata',x_pts,'Ydata',y_pts);
		
	end
	
end