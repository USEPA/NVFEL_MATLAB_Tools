function image_data_extractor( varargin )
%IMAGE_MAP_BUILDER A simple interface for extracting data from images by
%selecting data points


% New Instance
if( nargin == 0 )
	
	[fn, pn] = uigetfile({'*.bmp;*.jpg;*.tif;*.gif;*.png','Image Files (*.bmp *.jpg *.tif *.gif *.png)';'*.*','All Files (*.*)'}, 'Select Image File');
	
    d.image_file = [pn, fn];
    d.image_var = imread(d.image_file);
	d.output_var = '';
    
%    assignin('base',d.output_var,[]);
    
    % Draw Axes
    d.fig = figure('Name','Map Image Interpreter','NumberTitle','off');
	%set(d.fig,'HandleVisibility','off');
	%set(d.fig,'Name','Map Image Interpreter');

    d.ax = axes('position',[0.05, 0.05, 0.9,0.9]);
	d.dim_x = size(d.image_var, 2);
	d.dim_y = size(d.image_var, 1);
    d.image = image([0,1],[1,0],d.image_var);
	d.ax.YDir = 'normal';

	

	m = uimenu(d.fig,'Label','Set Axis');
		uimenu(m,'Label','X','callback','image_data_extractor(''set_axis'',''X'',''linear'');');
		uimenu(m,'Label','Y','callback','image_data_extractor(''set_axis'',''Y'',''linear'');');
		uimenu(m,'Label','XLog','callback','image_data_extractor(''set_axis'',''X'',''log'');');
		uimenu(m,'Label','YLog','callback','image_data_extractor(''set_axis'',''Y'',''log'');');
	m = uimenu(d.fig,'Label','Select Data');		
		uimenu(m,'Label','Point','callback','image_data_extractor(''select_pts'');');
		uimenu(m,'Label','Match Brightness','callback','image_data_extractor(''select_gray'');');
		uimenu(m,'Label','Match Hue','callback','image_data_extractor(''select_hue'');');
    set(d.fig,'UserData',d);
	
	return;
end

d = get(gcbf,'UserData');

switch varargin{1}
	
	case 'set_axis'
		
		axis_str = varargin{2};
		axis_num = 1+ strcmpi(axis_str,'Y');
		
		scale_type = varargin{3};
		
		[pt1] = ginput(1);
		pt1 = pt1( axis_num);
		pt1_val = inputdlg([axis_str,' Value 1:'],['Scale ',axis_str,' Axis']);
		pt1_val = str2double(pt1_val{1});
		
		[pt2] = ginput(1);
		pt2 = pt2(axis_num);
		pt2_val = inputdlg([axis_str,' Value 1:'],['Scale ',axis_str,' Axis']);
		pt2_val = str2double(pt2_val{1});

		% Find New Endpoints

		if strcmpi( scale_type, 'log')
			new_ax_lim = 10.^(interp1( [pt1, pt2], log10([pt1_val, pt2_val]), d.ax.([axis_str,'Lim']) , 'linear' ,'extrap' ));
			new_im_data = 10.^(interp1( [pt1, pt2], log10([pt1_val, pt2_val]),  d.image.([axis_str,'Data']), 'linear' ,'extrap' ));	
		else
			new_ax_lim = interp1( [pt1, pt2], [pt1_val, pt2_val], d.ax.([axis_str,'Lim']) , 'linear' ,'extrap' );
			new_im_data = interp1( [pt1, pt2], [pt1_val, pt2_val],  d.image.([axis_str,'Data']), 'linear' ,'extrap' );	
		end

		
		
		% Flip Axis if Necessary
		if xor( issorted(new_ax_lim) , strcmp(d.ax.YDir,'normal'))					
			d.ax.([axis_str,'Dir']) = 'reverse';
		else
			d.ax.([axis_str,'Dir']) = 'normal';
		end
			
		d.image.([axis_str,'Data']) = new_im_data;
		d.ax.([axis_str,'Lim']) = sort(new_ax_lim);
		d.ax.([axis_str,'Scale']) = scale_type;
		
				
	case 'select_pts'
		
		points = [];
		button = 1;
		
		out = inputdlg({'Variable:','Value:'},'Select Variable & Value',1,{d.output_var,''});
		out_var = out{1};
		out_str = out{2};
		out_val = str2double(out{2});
		
		d.output_var = out_var;
		
		while button == 1		
			[pt_x, pt_y, button] = ginput(1);
			
			if( button == 1 )
				points = [points; pt_x, pt_y,out_val] ;
				text(pt_x,pt_y,out_str,'HorizontalAlignment','center','VerticalAlignment','middle','BackgroundColor','w');
			end
			
		end
		
		
		%line(pt_x,pt_y,'MarkerFaceColor','w','LineStyle','none','Marker','s','MarkerSize',20);
		try 
			evalin('base',[ out_var,' = [', out_var,' ; ', sprintf('%f %f %f; ',points'), '];']);
		catch
			evalin('base',[ out_var,' = [', sprintf('%f %f %f; ',points'), '];']);
		end
		
		
case 'select_gray'
		
		points = [];
		button = 1;
		
		out = inputdlg({'Variable:','Value:','Threshold:'},'Select Variable & Value',1,{d.output_var,'','0.10'});
		out_var = out{1};
		out_str = out{2};
		out_val = str2double(out{2});
		thresh = str2double(out{3});
		
		d.output_var = out_var;
		
		% Get Image Location
		im_x = get(d.image,'XData');
		im_y = get(d.image,'YData');
		
		[pt_x, pt_y, button] = ginput(1);		% start point

		idx_x = round(interp1( im_x, [1, d.dim_x],pt_x));
		idx_y = round(interp1( im_y, [1, d.dim_y],pt_y));
		

		pts = [idx_x, idx_y];
		new_pts = [idx_x, idx_y];
		
		grow = [ 1, 1; 1, 0; 1, -1; 0,1; 0,-1; -1,1; -1,0; -1,-1 ];
		
		im_gs = sum( get(d.image,'CData'), 3);
		im_gs = 1 - im_gs ./ max(im_gs(:));
		

		while ~isempty(new_pts)
			
	
			test_pts = kron(new_pts,ones(size(grow,1),1)) + kron(ones(size(new_pts,1),1),grow);
			test_pts(:,1) = min(max(test_pts(:,1),1),d.dim_x); 
			test_pts(:,2) = min(max(test_pts(:,2),1),d.dim_y);	
			test_pts = unique(test_pts,'rows');
		
			% Check the points			
			for j = size(test_pts,1):-1:1
				
				if im_gs(test_pts(j,2), test_pts(j,1)) < thresh
						test_pts(j,:) =[];
				end		
				
			end

			% Determine New points & append to list 
			new_pts = setdiff(test_pts, pts,'rows');
			pts = [pts;new_pts];
			
		end

		
		pts(:,1) = interp1( [1, d.dim_x], im_x, pts(:,1));
		pts(:,2) = interp1( [1, d.dim_y], im_y, pts(:,2));
		pts(:,3) = out_val;
		
		
		line(pts(:,1),pts(:,2),'MarkerFaceColor','k','LineStyle','none','Marker','x');
		text(pt_x,pt_y,out_str,'HorizontalAlignment','center','VerticalAlignment','middle','BackgroundColor','w');

		if evalin('base',['exist(''',out_var,''',''var'');'] )
			assignin('base','MAPINTERPRETER_TEMP',pts);
			evalin('base',[ out_var,' = [', out_var,' ; MAPINTERPRETER_TEMP ];']);
			evalin('base','clear MAPINTERPRETER_TEMP');
		else
			assignin('base',out_var,pts);
		end	
					
		
case 'select_hue'
		
		points = [];
		button = 1;
		
		out = inputdlg({'Variable:','Value:','Threshold:'},'Select Variable & Value',1,{d.output_var,'','0.01'});
		out_var = out{1};
		out_str = out{2};
		out_val = str2double(out{2});
		thresh = str2double(out{3});
		
		out_pts = [];
		
		d.output_var = out_var;
		
		% Get Image Location
		im_x = get(d.image,'XData');
		im_y = get(d.image,'YData');
		
		im_rgb = get(d.image,'CData');
		
		
		im_hsv = rgb2hsv(im_rgb);		
		im_rgb = double(im_rgb) / double( intmax( class(im_rgb)));		
		
		[pt_x, pt_y, button] = ginput(1);		% start point
		
		while button == 1	

			idx_x = round(interp1( im_x, [1, d.dim_x],pt_x));
			idx_y = round(interp1( im_y, [1, d.dim_y],pt_y));


			pts = [idx_x, idx_y];
			new_pts = [idx_x, idx_y];

			pt_rgb = squeeze(im_rgb(idx_y, idx_x,:));
			pt_hsv = squeeze(im_hsv(idx_y, idx_x,:));	

			grow = [ 1, 1; 1, 0; 1, -1; 0,1; 0,-1; -1,1; -1,0; -1,-1 ];

			while ~isempty(new_pts)


				test_pts = kron(new_pts,ones(size(grow,1),1)) + kron(ones(size(new_pts,1),1),grow);
				test_pts(:,1) = min(max(test_pts(:,1),1),d.dim_x); 
				test_pts(:,2) = min(max(test_pts(:,2),1),d.dim_y);	
				test_pts = unique(test_pts,'rows');

				% Check the points			
				for j = size(test_pts,1):-1:1

					test_hsv = squeeze(im_hsv(test_pts(j,2), test_pts(j,1),:));

					if abs(test_hsv(1) - pt_hsv(1)) > thresh || test_hsv(2) < 0.1 || test_hsv(3) < 0.1
							test_pts(j,:) =[];
					end	



	% 				test_rgb = squeeze(im_rgb(test_pts(j,2), test_pts(j,1),:));
	% 				test_dist = mean(abs( test_rgb - pt_rgb ) );
	% 				
	% 				if test_dist > thresh
	% 						test_pts(j,:) =[];
	% 				end	



				end

				% Determine New points & append to list 
				new_pts = setdiff(test_pts, pts,'rows');
				pts = [pts;new_pts];

			end

			out_pts_x = interp1( [1, d.dim_x], im_x, pts(:,1));
			out_pts_y = interp1( [1, d.dim_y], im_y, pts(:,2));

			line(out_pts_x,out_pts_y,'MarkerFaceColor','k','LineStyle','none','Marker','x');
			text(pt_x,pt_y,out_str,'HorizontalAlignment','center','VerticalAlignment','middle','BackgroundColor','w');

			out_pts = [ out_pts; out_pts_x, out_pts_y, ones(size(pts,1),1) * out_val];

			[pt_x, pt_y, button] = ginput(1);		% next start point
	
		end
		

		if evalin('base',['exist(''',out_var,''',''var'');'] )
			assignin('base','MAPINTERPRETER_TEMP',out_pts);
			evalin('base',[ out_var,' = [', out_var,' ; MAPINTERPRETER_TEMP ];']);
			evalin('base','clear MAPINTERPRETER_TEMP');
		else
			assignin('base',out_var,out_pts);
		end	
					
	otherwise
		disp(['Unknown Callback "', varargin{1} , '"']); 


end


	set(d.fig,'UserData',d);


end

