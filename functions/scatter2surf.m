function [x_out, y_out, z_out] = scatter2surf( x, y, z, xq, yq, varargin )
%SCATTER2SURF Scattered data interpolation and fitting
%
%	Zq = SCATTER2SURF(X,Y,Z,Xq,Yq) converts 3 dimensional scattered data
%	(x, y, z) to a surface on a 2d grid specified by Xq and Yq. Replicates
%	are allowed, but may result in warnings. It allows extrapolation in
%	most cases. Supports interpolation via MATLAB scatteredinterpolant or
%	surface fitting via gridfit algorithm which features tunable smoothness
%	parameters.  SCATTER2SURF also generates a variety of plots to help
%	tune parameters and demonstate results.
%
%	[Xq, Yq, Zq] = SCATTER2SURF(X,Y,Z, Xq, Yq) is an alternate syntax that
%	allows export of the corresponding mesh grid for additional plotting.
%
%	SCATTER2SURF(..., prop, val)can be used to set a variety of properties
%	that control the behavior of the surface generation. Details of the
%	properties are specified below.
%
%	Optional Parameters:
%
%	method - ['scatteredinterp'] 'gridfit'
%	Selects the method used to generate the surface.
%
%		'scatteredinterp' uses the matlab scatteredinterpolant or
%		triscatteredinterp functions to generate a delaunay triangulation
%		of the scattered data and interpolate.  Since it is an interpolant
%		it should pass through each provided data point, assuming there are
%		no repeats.
%
%		'gridfit' uses the gridfit algorithm, which is similar to a curve
%		fit Gridfit is not an interpolant. Its goal is a smooth surface
%		that approximates your data, but allows you to control the amount
%		of smoothing.  It accomplishes this by connecting the data points
%		to nearby grid points and solving for a least squares solution.
%
%		'greens'
%
%	'interp' - ['linear'], 'triangle','nearest','natural','bilinear','bicubic'
%	Determines the interpolation method used
%
%		'triangle' or 'linear' for the 'scatterinterp' method uses the
%		delaunay triangulation to interpolate each grid point via the plane
%		connecting the 3 nearest data points. For 'gridfit' it connects each
%		data point with the 3 nearest grid points.
%
%       'nearest' for the 'scatteredinterp' method uses the data point
%		nearest the grid for the value at that point. For 'gridfit' it
%		connects each data point only to the nearest grid point. This will
%		rarely be a good option.
%
%		'natural' is used only with 'scatteredinterp' and performs natural
%		neighbor interpolation that factors in additional nearby points
%		when interpolating.
%
%		'bilinear' is only used with the 'gridfit' method and connects each
%		data point to the 4 nearest grid points. The bilinear interpolation
%		within is also known as tensor product linear interpolation and is
%		similar to the interpolation used for gridded data
%
%	'xscale' - scalar number
%	'xnormalize' - no argument
%	'yscale' - scalar number
%	'ynormalize' - no argument
%	These inputs provide options for scaling the axes of the data to a
%	common scale.  Since interpolation is based on distance if the scale of
%	x and y data is significantly different it may not be interpolated as
%	expected. 'xscale' and 'yscale' scale the data by the specified amount.
%	'xnormalize'and 'ynormalize' normalize the data down to the range 0..1
%
%	'xsmooth' - scalar number - default:1
%	'ysmooth' - scalar number - default:1
%	Specify the desired smoothing along each axis and relative to the data.
%	Increasing the smoothness will create a more uniform surface but may
%	deviate from the data. While decreasing the smoothing will match the
%	data better but have a more undulating shape.
%
%
%   'solver' - ['\'],'symmlq','lsqr','normal'
%	Set the solver to be used with the 'gridfit' method to solve the linear
%	system. Different solvers will have different solution times depending
%	upon the specific problem to be solved. Up to a certain size grid, the
%   direct \ solver will often be speedy, until memory is limited. Problems
%	with a significant amount of extrapolation should avoid lsqr. \ may be
%	best numerically for small smoothnesss parameters and high extents of
%	extrapolation.
%
%		'\' uses matlab's backslash operator to solve the sparse system.
%
%		'symmlq' uses matlab's iterative symmlq solver
%
%		'lsqr' uses matlab's iterative lsqr solver
%
%		'normal' uses \ to solve the normal equations.
%
%
%   'maxiter' - scalar number - default:min(10000,size of grid)
%   Specified the maximum number of iterations for an iterative solver
%
%   'surf' - generates a surface plot
%   'no_dots' - disables black dots on surface plot with 'surf' option

% Portions of code courtesy of GRIDFIT algorithm by John D'Errico


validateattributes( x, {'numeric'},{'finite', 'real','vector'});
validateattributes( y, {'numeric'},{'finite', 'real','vector'});
validateattributes( y, {'numeric'},{'finite', 'real','vector'});

validateattributes( xq, {'numeric'},{'finite', 'real','vector'});
validateattributes( yq, {'numeric'},{'finite', 'real','vector'});

cfg.xscale = parse_varargs( varargin, 'xscale',1,'numeric',{'scalar','finite','real'});
cfg.yscale = parse_varargs( varargin, 'yscale',1,'numeric',{'scalar','finite','real'});

cfg.xnorm = parse_varargs( varargin, 'xnormalize',false,'toggle');
cfg.ynorm = parse_varargs( varargin, 'ynormalize',false,'toggle');

cfg.xsmooth = parse_varargs( varargin, 'xsmooth', 1, 'numeric', {'scalar','finite','real'});
cfg.ysmooth = parse_varargs( varargin, 'ysmooth', 1, 'numeric', {'scalar','finite','real'});

cfg.x_monotonic = parse_varargs( varargin, 'xmonotonic',false,'toggle');
cfg.y_monotonic = parse_varargs( varargin, 'ymonotonic',false,'toggle');

cfg.cleanup = parse_varargs( varargin, 'cleanup', Inf, 'numeric', {'scalar','finite','real'});
cfg.method = parse_varargs( varargin, 'method', 'scatterinterp', 'char', {'scatterinterp','gridfit'});
cfg.extrap = parse_varargs( varargin, 'noextrap',true,'toggle' );

cfg.weighting = parse_varargs( varargin, 'weighting', ones(size(x)), 'numeric');
cfg.spatial_weighting = parse_varargs( varargin, 'spatial_weighting', 0, 'numeric');

if strcmpi( cfg.method,'scatterinterp' )
	cfg.interp = parse_varargs( varargin, 'interp','linear','char', {'nearest','triangle','linear','natural'});
elseif 	strcmpi( cfg.method,'gridfit' )
	cfg.interp = parse_varargs( varargin, 'interp','triangle','char', {'nearest','bilinear','triangle','bicubic'});
% 	cfg.smoother = parse_varargs( varargin, 'smoother','gradient','char', {'gradient','laplacian','diffusion','spring'});
	cfg.solver = parse_varargs( varargin, 'solver','\','char', {'\','backslash','lsqr','symmlq','normal'});
	cfg.maxiter = parse_varargs( varargin, 'maxiter',0,'numeric', {'scalar','finite','real','>',0});
end

cfg.voronoi = parse_varargs( varargin, 'voronoi',false,'toggle' );
cfg.surf = parse_varargs( varargin, 'surf',false,'toggle' );
cfg.contour = parse_varargs( varargin, 'contour',false,'toggle' );
cfg.contours =  parse_varargs( varargin, 'contours', [], 'numeric', {'finite','real'});
cfg.dots = parse_varargs( varargin,'no_dots',true,'toggle' );
cfg.make_figure = parse_varargs( varargin, 'hold', true, 'toggle');

% Make Data into Column Vectors
x = reshape(x,[],1);
y = reshape(y,[],1);
z = reshape(z,[],1);
weighting = reshape(cfg.weighting, [], 1);

if length(x) ~= length(z) || length(y) ~= length(z)
	error([mfilename,':input'],'Input data x, y, z must be vectors or the same length\n')
end

% Check X Scaling
if cfg.xnorm
	x_scale = max(xq) - min(xq);
% 	x_scale = mean(diff(xq));
elseif isscalar(cfg.xscale) && isreal(cfg.xscale) && isfinite(cfg.xscale)
	x_scale = cfg.xscale;
else
	error([mfilename,':input'],'Argument ''xscale'' failed validation with error:\nExpected input to be a real finite scalar or one of the following strings:\n\t''norm''\n')
end

% Check Y Scaling
if cfg.ynorm
		y_scale = max(yq) - min(yq);
% 	y_scale = mean(diff(yq));
elseif isscalar(cfg.yscale) && isreal(cfg.yscale) && isfinite(cfg.yscale)
	y_scale = cfg.yscale;
else
	error([mfilename,':input'],'Argument ''yscale'' failed validation with error:\nExpected input to be a real finite scalar or one of the following strings:\n\t''norm''\n')
end

xg_points = reshape(unique(xq),[],1);
xg_out_idx = true(size(xg_points));

yg_points = reshape(unique(yq),[],1);
yg_out_idx = true(size(yg_points));

% Add Points to X if necessary and mark indecies
if min(x) < min(xg_points)
	xg_points = [min(x); xg_points];
	xg_out_idx = [false; xg_out_idx];
end

if max(x) > max(xg_points)
	xg_points = [ xg_points; max(x)];
	xg_out_idx = [xg_out_idx; false];
end

% Add Points to y if necessary and mark indecies
if min(y) < min(yg_points)
	yg_points = [min(y); yg_points];
	yg_out_idx = [false; yg_out_idx];
end

if max(y) > max(yg_points)
	yg_points = [ yg_points; max(y)];
	yg_out_idx = [yg_out_idx; false];
end

xg_count = length(xg_points);
yg_count = length(yg_points);
data_count = length(z);

% Normalize Data
xd_norm = x / x_scale;
yd_norm = y / y_scale;

% Plot Vorornoi if requested to show dispersion
if cfg.voronoi
	if cfg.make_figure
        figure;
    end
	[vx, vy] = voronoi(xd_norm,yd_norm);
	plot(x,y,'r+')
	ax = axis;
	hold on
	plot(vx*x_scale,vy*y_scale,'b-');
	axis(ax);
end


%warning off

% Interpolate Normalized Data & Filnd Outliers
%good_pts = true(size(z));

%
% if cleanup_thresh > 0
%    pts = 1:length(z);
%    for i = 1:length(z)
%         F = TriScatteredInterp(x_norm(pts ~= i),y_norm(pts ~= i),z(pts ~= i));
%         if abs(F( x_norm(i), y_norm(i))  - z(i) ) > cleanup_thresh;
%             good_pts(i) = 0;
%         end
%    end
% end

%warning on

% % determine which cell in the array each point lies in
% [junk,xd_idx] = histc(x,xg_points); %#ok
% [junk,yd_idx] = histc(y,yg_points); %#ok
% 
% % Move Points on Edge earlier bin
% xd_idx(xd_idx == xg_count) = xg_count -1;
% yd_idx(yd_idx == yg_count) = yg_count -1;

% Construct Grid of normalized Points
[x_grid_norm, y_grid_norm] =  meshgrid(xg_points/x_scale, yg_points/y_scale);

% determine point density
den_grid_x = [-inf; (xg_points(1:end-1) + xg_points(2:end))/2; inf];
den_grid_y = [-inf; (yg_points(1:end-1) + yg_points(2:end))/2; inf];
density_counts = histcounts2( x, y, den_grid_x, den_grid_y);
point_density = interp2( xg_points, yg_points, density_counts',x, y);
raw_density_weighting = 1./max(point_density,1);



switch cfg.method
	
	case 'scatterinterp'
		
		% Matlab Interp Calls Triangle 'linear'
		interp_type = strrep(cfg.interp, 'triangle','linear' );
		
		if exist('scatteredInterpolant','file')	% Newer Matlab Use Scattered Interpolant
			if cfg.extrap
				F = scatteredInterpolant(xd_norm,yd_norm,z, interp_type);
			else
				F = scatteredInterpolant(xd_norm,yd_norm,z, interp_type,'none');
			end
			
			z_out = F( x_grid_norm, y_grid_norm );
			
		else
			if strcmpi(cfg.extrap,'on') && any(strcmpi(interp_type,{'linear','natural'}))
				warning('prog:input','This version of Matlab does not support ''scatteredinterpolant'' class. \nUsing Older ''TriScatteredInterp'' which does not support some types of extrapolation');
				extrap_type = 'none';
			end
			
			% Interpolate
			F = TriScatteredInterp(xd_norm,yd_norm,z, interp_type);
			z_out = F( x_grid_norm, y_grid_norm );
			
		end
		
		
	case 'gridfit'
			
		weighting = weighting .* (1 + cfg.spatial_weighting * ( raw_density_weighting - 1));
		
% 		[z_out] = gridfit( xd_norm, yd_norm, z,xg_points/x_scale, yg_points/y_scale, 'interp',cfg.interp,'regularizer',cfg.smoother,'solver',cfg.solver,'maxiter',cfg.maxiter,'autoscale','off','smoothness',[cfg.xsmooth, cfg.ysmooth ] );
		[z_out] = RegularizeData3D( xd_norm, yd_norm, z,xg_points/x_scale, yg_points/y_scale, weighting, 'interp',cfg.interp,'solver',cfg.solver,'maxiter',cfg.maxiter,'smoothness',[cfg.xsmooth, cfg.ysmooth ] );
		
			
end

% Remove points outside convex hull
if ~cfg.extrap
	% Find Boundaries for Extrapolation
	k = convhull(xd_norm,yd_norm);
	outer = ~inpolygon( x_grid_norm, y_grid_norm, xd_norm(k), yd_norm(k) );

	z_out( outer ) = nan;
end

% Only OUtput Requested Indecies
x_out = x_grid_norm(yg_out_idx, xg_out_idx)*x_scale;
y_out = y_grid_norm(yg_out_idx, xg_out_idx)*y_scale;
z_out = z_out(yg_out_idx, xg_out_idx);

% make monotonic


if cfg.y_monotonic && cfg.x_monotonic
	
	x_diff = diff(z_out,1,2) ;
	y_diff = diff(z_out,1,1) ;
	
	while any(any( y_diff < -1e-10 ))  ||  any(any( x_diff < -1e-10 )) 
		
		z_out(:,1:end-1) = z_out(:,1:end-1) + (x_diff < 0 ) .* x_diff / 2;
		z_out(:,2:end) = z_out(:,2:end) - (x_diff < 0 ) .* x_diff / 2;
		
		z_out(1:end-1,:) = z_out(1:end-1,:) + (y_diff < 0 ) .* y_diff / 2;
		z_out(2:end,:) = z_out(2:end,:) - (y_diff < 0 ) .* y_diff / 2;
		
		x_diff = diff(z_out,1,2) ;
		y_diff = diff(z_out,1,1) ;
	end
	
elseif cfg.x_monotonic
	
	x_diff = diff(z_out,1,2) ;
	while 	any(any( x_diff < -1e-10 ))
		z_out(:,1:end-1) = z_out(:,1:end-1) + (x_diff < 0 ) .* x_diff / 2;
		z_out(:,2:end) = z_out(:,2:end) - (x_diff < 0 ) .* x_diff / 2;
		
		x_diff = diff(z_out,1,2);
	end
	
elseif cfg.y_monotonic
	
	y_diff = diff(z_out,1,1) ;
	while  any(any( y_diff < -1e-10 ))
		
		z_out(1:end-1,:) = z_out(1:end-1,:) + (y_diff < 0 ) .* y_diff / 2;
		z_out(2:end,:) = z_out(2:end,:) - (y_diff < 0 ) .* y_diff / 2;
		y_diff = diff(z_out,1,1);
	end
	
end








if cfg.surf
	if cfg.make_figure 
        figure
    end
	surf(x_out, y_out, z_out,'EdgeColor','none','LineStyle','none','FaceColor','interp');
	
    if cfg.dots
    	hold on;
        plot3(x, y, z,'k.');
    end
	%   plot3(x, y, z,'m.');
end

if cfg.contour
	if cfg.make_figure
        figure
    end
	
	% Plot Contour Map
	if isempty( cfg.contours )
		[cs,h] = contourf(x_out,y_out,z_out);
	else
		[cs,h] = contourf(x_out,y_out,z_out,cfg.contours);
	end
	clabel(cs, h, 'Color', 'k')
	
	if cfg.dots
    	hold on;
        plot(x, y,'k.');
		for i = 1:length(z)
			text( x(i),y(i), num2str(z(i)), 'VerticalAlignment','Bottom');
		end
		
    end
	
end

% Handle When Only 1 Output is requested
if nargout <= 1
	x_out = z_out;
end

end

