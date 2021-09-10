function [vgrid, varargout] = ndgridfit(pts,v,weighting, grid_pts, varargin)
% ndGridfit: Produces a smooth surface surface from scattered input data.
%
%          NDGridfit is a refactoring of RegularizeData3D and Gridfit,
%          expanding the approach to solve higher dimensional cases. It
%          also adds support for weighting each of the individual input
%          points. 
%
%           This code incorporates some improvements from
%           RegularizeData3D, specifically the revised smoothing parameters
%           to be more consistient accross different grid sizes. ndGridfit does
%           not currently support the cubic interpolation, but that can
%           hopefully be revised and included in the future.
% 
%           Gridfit featured multiple regularizer functions, but only the 'gradient' option which seeks to minimize the 2nd derivative is included in this version.
%
%           A quick summary of the Gridfit method:
%           Gridfit creates a system of equations to solve for a best fit
%           surface corresponding to a scattered dataset. The surface is defined ovar a grid of points, passed as the breakpoints for each dimension.
%           To accomplish its fitting
%           it generates two sets of equations. The first set connects the
%           provided data to the grid. There are various options to make
%           these connections passed via the 'interp' argument. The second
%           set of equations are the regularizer. The regularizer is what
%           seeks to contrain the resulting output to a smooth surface.  
%           The combined set of equations can be very large but also
%           sparse, and a variety of solvers are avaialble.
%
%          There are snippets of Gritfit and RegularizeData3D code remaining, and the overall program flow matches as well.
%          
%           The original GridFit page is:
%          http://www.mathworks.com/matlabcentral/fileexchange/8998-surface-fitting-using-gridfit
%
% usage #1: vgrid = ndgridfit(pts, v, weighting, grid_points);
% usage #2: [vgrid, xgrid, ygrid] = ndgridfit([x, y], z, [], {xnodes, ynodes});
% usage #3: vgrid = ndgridfit([x, y, z], v, [], {xnodes, ynodes, znodes}, prop, val, prop, val,...);
%
% Arguments: (input)
%  pts,v -  scattered data on which to fit the surface. Each row in pts
%           represents a point in the n-dimensional
%           space. the vector v represents the value of data at each point in
%           pts. Replicate points will be treated in a least squares sense
%           and any  points containing a NaN are ignored in the estimation.
%
%  weighting - vector of length equal to v, containing weightings for
%           individual data points. This parameter may be omitted (replaced by [])
%           for a equal weighting of all points.
%
%  grid_pts - cell array containing the corresponding grid nodes for each
%           dimension. The number of elements in grid_pts should match the
%           number of columns in pts. The nodes need not be equally spaced.
%           The grid points for each dimension must completely span the
%           data. If they do not, then the 'extend'property is applied,
%           adjusting the first and last nodes to be extended as necessary.
%           See below for a complete description of the 'extend' property.
%
%
%  Additional arguments follow in the form of property/value pairs.
%  Valid properties are:
%    'smoothness', 'interp', 'solver', 'maxiter'
%    'extend', 'tilesize', 'overlap'
%
%  Any UNAMBIGUOUS shortening (even down to a single letter) is
%  valid for property names. All properties have default values,
%  chosen (I hope) to give a reasonable result out of the box.
%
%   'smoothness' - scalar or vector - the ratio of
%          smoothness to fidelity of the output surface. This must be a
%          positive real number.
%
%          A smoothness of 1 gives equal weight to fidelity (goodness of fit)
%          and smoothness of the output surface.  This results in noticeable
%          smoothing.  If your input data has little or no noise, use
%          0.01 to give smoothness 1% as much weight as goodness of fit.
%          0.1 applies a little bit of smoothing to the output surface.
%
%          If this parameter is a vector, then it defines
%          the relative smoothing to be associated with the different dimensions. This allows the user to apply a different amount
%          of smoothing in each dimension.
%
%          DEFAULT: 0.01
%
%
%   'interp' - character, denotes the interpolation scheme used
%          to interpolate the data.
%
%          DEFAULT: 'triangle'
%
%          'cubic' - use bicubic interpolation within the grid,more
%                     accurate because it accountsfor surface curvature, but can be
%                     slower than the other methods.
%                     4^n equations per data point
%
%          'linear' - use linear interpolation within the grid, connecting
%                     the two nearest points along each dimension. 
%                     2^n equations per data point
%
%          'triangle' - use only the points encompassing the datapoint for
%                     interpolation.
%                     n+1 equations per data point
%
%          'nearest' - nearest neighbor interpolation. This will
%                     rarely be a good choice, but is included for completeness.
%                     1 equation per data point
%
%
%   'solver' - character flag - denotes the solver used for the
%          resulting linear system. Different solvers will have
%          different solution times depending upon the specific
%          problem to be solved. Up to a certain size grid, the
%          direct \ solver will often be speedy, until memory
%          swaps causes problems.
%
%          What solver should you use? Problems with a significant
%          amount of extrapolation should avoid lsqr. \ may be
%          best numerically for small smoothnesss parameters and
%          high extents of extrapolation.
%
%          Large numbers of points will slow down the direct
%          \, but when applied to the normal equations, \ can be
%          quite fast. Since the equations generated by these
%          methods will tend to be well conditioned, the normal
%          equations are not a bad choice of method to use. Beware
%          when a small smoothing parameter is used, since this will
%          make the equations less well conditioned.
%
%          DEFAULT: 'normal'
%
%          '\' - uses matlab's backslash operator to solve the sparse
%                     system. 'backslash' is an alternate name.
%
%          'symmlq' - uses matlab's iterative symmlq solver
%
%          'lsqr' - uses matlab's iterative lsqr solver
%
%          'normal' - uses \ to solve the normal equations.
%
%
%   'maxiter' - only applies to iterative solvers - defines the
%          maximum number of iterations for an iterative solver
%
%          DEFAULT: min(10000,length(xnodes)*length(ynodes))
%
% Arguments: (output)
%  vgrid   - n dimensional array containing the fitted hypersurface
%
%
%
% Speed considerations:
%  Remember that gridfit must solve a LARGE system of linear
%  equations. There will be as many unknowns as the total
%  number of nodes in the final lattice. While these equations
%  may be sparse, solving a system of 10000 equations may take
%  a second or so. Very large problems may benefit from the
%  iterative solvers or from tiling.
%
%
% Example usage:
%
%  x = rand(100,1);
%  y = rand(100,1);
%  z = exp(x+2*y);
%  xnodes = 0:.1:1;
%  ynodes = 0:.1:1;
%
%  g = RegularizeData3D(x,y,z,xnodes,ynodes);
%
% Note: this is equivalent to the following call:
%
%  g = RegularizeData3D(x,y,z,xnodes,ynodes, ...
%              'smooth',1, ...
%              'interp','triangle', ...
%              'solver','normal', ...
%              'gradient', ...
%              'extend','warning', ...
%              'tilesize',inf);
%
%
% 
% Refactored for n-dimensional support and released as ndgridfit
%   2021
%   - Able to solve for adiditional dimensions
%   - Added weighting function for input data points
%   - Tiling functionality omitted for now
% Rereleased with improvements as RegularizeData3D
%   2014
%   - Added bicubic interpolation
%   - Fixed a bug that caused smoothness to depend on grid fidelity
%   - Removed the "regularizer" setting and documented the calculation process
% Original Version:
%   Author: John D'Errico
%   e-mail address: woodchips@rochester.rr.com
%   Release: 2.0
%   Release date: 5/23/06




% set defaults
% The default smoothness is 0.01.  i.e. assume the input data x,y,z
% have little or no noise.  This is different from the legacy code,
% which used a default of 1.
params.smoothness = 0.01;
params.interp = 'linear';
params.solver = 'backslash';
params.maxiter = [];
% params.extend = 'warning';
% params.tilesize = inf;
% params.overlap = 0.20;
% params.mask = []; 

% check the parameters for acceptability
params = parse_pv_pairs(params,varargin);
params = check_params(params);

if isempty(weighting)
    weighting = ones(size(v));
end


k = any(isnan(pts),2) | isnan(v) | isnan(weighting);
if any(k)
  pts(k)=[];
  v(k)=[];
  weighting(k) = [];
end

n = length(v);
ndim = size(pts,2);
dim_min = min(pts);
dim_max = max(pts);
accum = 1;
ind_mult = zeros(1,ndim);

if numel( grid_pts) <2
    error('The output grid points must contain at least two dimensions');
end

for dim = [2,1,3:ndim]
    
    if numel(grid_pts{dim}) < 3
        error('The output grid points for axis %d must have at least 3 elements.', dim);
    end
    
    if dim_min(dim) < grid_pts{dim}(1)
        error('Some values in dimension %d falls below the specified grid points.', dim)
    end
    
    if dim_max(dim) > grid_pts{dim}(end)
        error('Some values in dimension %d falls above the specified grid points.', dim)
    end
    
    grid(dim).pts = grid_pts{dim}(:);
    grid(dim).range = grid(dim).pts(end) - grid(dim).pts(1);
    grid(dim).diff = diff(grid(dim).pts);
    grid(dim).len = numel( grid_pts{dim});
    
    ind_mult(dim) = accum;
    accum = accum * grid(dim).len;
end


grid_dims = [grid.len];
grid_tot_pts = prod( grid_dims);

% Generate function to transform grid index to linear index
grid_index_to_linear_index = @(grid_ind) (grid_ind-1) * ind_mult' +1;


  % default for maxiter?
  if isempty(params.maxiter)
    params.maxiter = min(10000,grid_tot_pts);
  end

  
  
  % Discretize the data, mapping to the nearest grid points and returning
  % the n-dimensional index to prepare for interpolation.
  pt_dim_ind = zeros(size(pts));  
  pt_dim_part = zeros(size(pts)); 
  for dim  = 1:size(pts,2)
    pt_dim_ind(:,dim) = discretize(pts(:,dim), grid_pts{dim});
    pt_dim_part(:,dim) = min(1,max(0,(pts(:,dim) - grid(dim).pts(pt_dim_ind(:,dim)))./grid(dim).diff(pt_dim_ind(:,dim))));  
  end
    
  % interpolation equations for each point
  switch params.interp
%     case 'triangle'
%       % linear interpolation inside each triangle
%       k = (tx > ty);
%       L = ones(n,1);
%       L(k) = ny;
%       
%       t1 = min(tx,ty);
%       t2 = max(tx,ty);
%       A = sparse(repmat((1:n)', 1, 3), [ind, ind + ny + 1, ind + L], [1 - t2, t1, t2 - t1], n, ngrid);
      
    case 'nearest'
      % nearest neighbor interpolation
      
      nearest_lind = grid_index_to_linear_index( pt_dim_ind + round(pt_dim_part));     
      A = sparse((1:n)',nearest_lind,ones(n,1),n,grid_tot_pts);
      
    case 'linear'
      % linear interpolation in a cell
      
       % Get bounding points and convert to their linear index offset
       interp_pts = binary_factorial(ndim);
       interp_offset = grid_index_to_linear_index(interp_pts+1)-1;
       
       % Convert dimensional index into linear index and add offsets for each point
       interp_ind = grid_index_to_linear_index( pt_dim_ind) + interp_offset' ; 
       
       % Get weighting for each connection by multiplying distance along
       % each dimension
       % TODO: find a way to avoid looping
       for p = 1:size(pt_dim_part,1)
            interp_wts(p,:) = prod((1-interp_pts) + (2* interp_pts -1) .*  pt_dim_part(p,:),2)';
       end
       
      A = sparse(repmat((1:n)',1,2.^ndim),interp_ind,interp_wts, n,grid_tot_pts);
      
%     case 'bicubic'
%       % Legacy code calculated the starting index ind for bilinear interpolation, but for bicubic interpolation we need to be further away by one
%       % row and one column (but not off the grid).  Bicubic interpolation involves a 4x4 grid of coefficients, and we want x,y to be right
%       % in the middle of that 4x4 grid if possible.  Use min and max to ensure we won't exceed matrix dimensions.
%       % The sparse matrix format has each column of the sparse matrix A assigned to a unique output grid point.  We need to determine which column
%       % numbers are assigned to those 16 grid points.
%       % What are the first indexes (in x and y) for the points?
%       XIndexes = min(max(1, indx - 1), nx - 3);
%       YIndexes = min(max(1, indy - 1), ny - 3);
%       % These are the first indexes of that 4x4 grid of nodes where we are doing the interpolation.
%       AllColumns = (YIndexes + (XIndexes - 1) * ny)';
%       % Add in the next three points.  This gives us output nodes in the first row (i.e. along the x direction).
%       AllColumns = [AllColumns; AllColumns + ny; AllColumns + 2 * ny; AllColumns + 3 * ny];
%       % Add in the next three rows.  This gives us 16 total output points for each input point.
%       AllColumns = [AllColumns; AllColumns + 1; AllColumns + 2; AllColumns + 3];
%       % Coefficients are calculated based on:
%       % http://en.wikipedia.org/wiki/Lagrange_interpolation
%       % Calculate coefficients for this point based on its coordinates as if we were doing cubic interpolation in x.
%       % Calculate the first coefficients for x and y.
%       XCoefficients = (x(:) - xnodes(XIndexes(:) + 1)) .* (x(:) - xnodes(XIndexes(:) + 2)) .* (x(:) - xnodes(XIndexes(:) + 3)) ./ ((xnodes(XIndexes(:)) - xnodes(XIndexes(:) + 1)) .* (xnodes(XIndexes(:)) - xnodes(XIndexes(:) + 2)) .* (xnodes(XIndexes(:)) - xnodes(XIndexes(:) + 3)));
%       YCoefficients = (y(:) - ynodes(YIndexes(:) + 1)) .* (y(:) - ynodes(YIndexes(:) + 2)) .* (y(:) - ynodes(YIndexes(:) + 3)) ./ ((ynodes(YIndexes(:)) - ynodes(YIndexes(:) + 1)) .* (ynodes(YIndexes(:)) - ynodes(YIndexes(:) + 2)) .* (ynodes(YIndexes(:)) - ynodes(YIndexes(:) + 3)));
%       % Calculate the second coefficients.
%       XCoefficients = [XCoefficients, (x(:) - xnodes(XIndexes(:))) .* (x(:) - xnodes(XIndexes(:) + 2)) .* (x(:) - xnodes(XIndexes(:) + 3)) ./ ((xnodes(XIndexes(:) + 1) - xnodes(XIndexes(:))) .* (xnodes(XIndexes(:) + 1) - xnodes(XIndexes(:) + 2)) .* (xnodes(XIndexes(:) + 1) - xnodes(XIndexes(:) + 3)))];
%       YCoefficients = [YCoefficients, (y(:) - ynodes(YIndexes(:))) .* (y(:) - ynodes(YIndexes(:) + 2)) .* (y(:) - ynodes(YIndexes(:) + 3)) ./ ((ynodes(YIndexes(:) + 1) - ynodes(YIndexes(:))) .* (ynodes(YIndexes(:) + 1) - ynodes(YIndexes(:) + 2)) .* (ynodes(YIndexes(:) + 1) - ynodes(YIndexes(:) + 3)))];
%       % Calculate the third coefficients.
%       XCoefficients = [XCoefficients, (x(:) - xnodes(XIndexes(:))) .* (x(:) - xnodes(XIndexes(:) + 1)) .* (x(:) - xnodes(XIndexes(:) + 3)) ./ ((xnodes(XIndexes(:) + 2) - xnodes(XIndexes(:))) .* (xnodes(XIndexes(:) + 2) - xnodes(XIndexes(:) + 1)) .* (xnodes(XIndexes(:) + 2) - xnodes(XIndexes(:) + 3)))];
%       YCoefficients = [YCoefficients, (y(:) - ynodes(YIndexes(:))) .* (y(:) - ynodes(YIndexes(:) + 1)) .* (y(:) - ynodes(YIndexes(:) + 3)) ./ ((ynodes(YIndexes(:) + 2) - ynodes(YIndexes(:))) .* (ynodes(YIndexes(:) + 2) - ynodes(YIndexes(:) + 1)) .* (ynodes(YIndexes(:) + 2) - ynodes(YIndexes(:) + 3)))];
%       % Calculate the fourth coefficients.
%       XCoefficients = [XCoefficients, (x(:) - xnodes(XIndexes(:))) .* (x(:) - xnodes(XIndexes(:) + 1)) .* (x(:) - xnodes(XIndexes(:) + 2)) ./ ((xnodes(XIndexes(:) + 3) - xnodes(XIndexes(:))) .* (xnodes(XIndexes(:) + 3) - xnodes(XIndexes(:) + 1)) .* (xnodes(XIndexes(:) + 3) - xnodes(XIndexes(:) + 2)))];
%       YCoefficients = [YCoefficients, (y(:) - ynodes(YIndexes(:))) .* (y(:) - ynodes(YIndexes(:) + 1)) .* (y(:) - ynodes(YIndexes(:) + 2)) ./ ((ynodes(YIndexes(:) + 3) - ynodes(YIndexes(:))) .* (ynodes(YIndexes(:) + 3) - ynodes(YIndexes(:) + 1)) .* (ynodes(YIndexes(:) + 3) - ynodes(YIndexes(:) + 2)))];
%       % Allocate space for all of the data we're about to insert.
%       AllCoefficients = zeros(16, n);
%       % There may be a clever way to vectorize this, but then the code would be unreadable and difficult to debug or upgrade.
%       % The matrix solution process will take far longer than this, so it's not worth the effort to vectorize this.
%       for i = 1 : n
%         % Multiply the coefficients to accommodate bicubic interpolation.  The resulting matrix is a 4x4 of the interpolation coefficients.
%         TheseCoefficients = repmat(XCoefficients(i, :)', 1, 4) .* repmat(YCoefficients(i, :), 4, 1);
%         % Add these coefficients to the list.
%         AllCoefficients(1 : 16, i) = TheseCoefficients(:);
%       end
%       % Each input point has 16 interpolation coefficients (because of the 4x4 grid).
%       AllRows = repmat(1 : n, 16, 1);
%       % Now that we have all of the indexes and coefficients, we can create the sparse matrix of equality conditions.
%       A = sparse(AllRows(:), AllColumns(:), AllCoefficients(:), n, ngrid);
  end
  rhs = v;

  % Do we have relative smoothing parameters?
  if isscalar(params.smoothness)
		stiffness = ones(ndim, 1) * params.smoothness;
  else
		stiffness = params.smoothness(:);
  end

  % Build a regularizer to minimize the second derivative.  This used to be called "gradient" even though it uses a second
  % derivative, not a first derivative.  This is an important distinction because "gradient" implies a horizontal
	% surface, which is not correct.  The second derivative favors flatness, especially if you use a large smoothness
	% constant.  Flat and horizontal are two different things, and in this script we are taking an irregular surface and
	% flattening it according to the smoothness constant.
	% The second-derivative calculation is documented here:
	% http://mathformeremortals.wordpress.com/2013/01/12/a-numerical-second-derivative-from-three-points/

  gradient_mesh_base = arrayfun( @(n) 1:n, grid_dims, 'UniformOutput', false);

  reg = cell(1,ndim);
  reg_equations = zeros(1,ndim);

  for dim = 1:ndim
      
     mesh_pts = gradient_mesh_base;
     mesh_pts{dim} = 2:(grid_dims(dim)-1);
     
     gradient_mesh = cell(ndim,1);
     [gradient_mesh{:}] = ndgrid( mesh_pts{:} );

     gradient_ind = cellfun(@(m) m(:),gradient_mesh,'UniformOutput',false);
     gradient_ind = [ gradient_ind{:} ];

     gradient_lower_ind = gradient_ind;
     gradient_lower_ind(:,dim) = gradient_lower_ind(:,dim)-1;
     gradient_lower_ind = grid_index_to_linear_index(gradient_lower_ind);
          
     gradient_upper_ind = gradient_ind;
     gradient_upper_ind(:,dim) = gradient_upper_ind(:,dim)+1;
     gradient_upper_ind = grid_index_to_linear_index(gradient_upper_ind);
     
     gradient_ind = grid_index_to_linear_index(gradient_ind);
     
     diff_lower = grid(dim).diff(gradient_mesh{dim}(:)-1);
     diff_upper = grid(dim).diff(gradient_mesh{dim}(:));
     
     reg{dim} = sparse(repmat(gradient_ind ,1,3),[gradient_lower_ind, gradient_ind, gradient_upper_ind], ...
		stiffness(dim)*[-2./(diff_lower.*(diff_lower+diff_upper)), 2./(diff_lower.*diff_upper), -2./(diff_upper.*(diff_lower+diff_upper))], grid_tot_pts,grid_tot_pts);
     
     reg_equations(dim) = length(gradient_ind);
    
  end
  
    % The smoothness parameter has already been applied to each dimension, but
    % additional adjustments are necessary. First is balancing the number of
    % data points and grid size. This can be done by scaling the regularizer
    % matrix to the square root of the ratio of interpolation constraints to
    % regularizer constraints. As we are minimizing squared error this puts
    % them on equal footing. The total range of the grid also needs to be
    % considered and adjusted for.

    smoothness_scaling = sqrt( size(A, 1) / sum(reg_equations)) * prod( [grid.range]);

    Areg = vertcat(reg{:});
    A = [A .* weighting ; Areg * smoothness_scaling];

    rhs = [rhs .* weighting; zeros(size(Areg,1),1)];

  % solve the full system, with regularizer attached
  switch params.solver
    case {'\' 'backslash'}
        
        vgrid = A\rhs;
      
    case 'normal'
      % The normal equations, solved with \. Can be faster
      % for huge numbers of data points, but reasonably
      % sized grids. The regularizer makes A well conditioned
      % so the normal equations are not a terribly bad thing
      % here.

        vgrid = (A'*A)\(A'*rhs);

      
    case 'symmlq'
      % iterative solver - symmlq - requires a symmetric matrix,
      % so use it to solve the normal equations. No preconditioner.
      tol = abs(max(v)-min(v))*1.e-13;
      [vgrid,flag] = symmlq(A'*A,A'*rhs,tol,params.maxiter);

      % display a warning if convergence problems
      switch flag
        case 0
          % no problems with convergence
        case 1
          % SYMMLQ iterated MAXIT times but did not converge.
          warning('GRIDFIT:solver',['Symmlq performed ',num2str(params.maxiter), ...
            ' iterations but did not converge.'])
        case 3
          % SYMMLQ stagnated, successive iterates were the same
          warning('GRIDFIT:solver','Symmlq stagnated without apparent convergence.')
        otherwise
          warning('GRIDFIT:solver',['One of the scalar quantities calculated in',...
            ' symmlq was too small or too large to continue computing.'])
      end
      
    case 'lsqr'
      % iterative solver - lsqr. No preconditioner here.
      tol = abs(max(v)-min(v))*1.e-13;
      [vgrid,flag] = lsqr(A,rhs,tol,params.maxiter);
        
      % display a warning if convergence problems
      switch flag
        case 0
          % no problems with convergence
        case 1
          % lsqr iterated MAXIT times but did not converge.
          warning('GRIDFIT:solver',['Lsqr performed ', ...
            num2str(params.maxiter),' iterations but did not converge.'])
        case 3
          % lsqr stagnated, successive iterates were the same
          warning('GRIDFIT:solver','Lsqr stagnated without apparent convergence.')
        case 4
          warning('GRIDFIT:solver',['One of the scalar quantities calculated in',...
            ' LSQR was too small or too large to continue computing.'])
      end
      
  end  % switch params.solver
  
% Reshape to proper dimensions
vgrid = reshape(vgrid,grid_dims([2,1,3:ndim]));


% Add ndgrid output if desired
if nargout > 1
   varargout = cell(1,numel(grid_pts));
   [varargout{:}] = ndgrid(grid_pts{[2,1,3:ndim]});
   varargout = varargout([2,1,3:ndim]);
end

% ============================================
% End of main function - gridfit
% ============================================

% ============================================
% subfunction - parse_pv_pairs
% ============================================
function params=parse_pv_pairs(params,pv_pairs)
% parse_pv_pairs: parses sets of property value pairs, allows defaults
% usage: params=parse_pv_pairs(default_params,pv_pairs)
%
% arguments: (input)
%  default_params - structure, with one field for every potential
%             property/value pair. Each field will contain the default
%             value for that property. If no default is supplied for a
%             given property, then that field must be empty.
%
%  pv_array - cell array of property/value pairs.
%             Case is ignored when comparing properties to the list
%             of field names. Also, any unambiguous shortening of a
%             field/property name is allowed.
%
% arguments: (output)
%  params   - parameter struct that reflects any updated property/value
%             pairs in the pv_array.
%
% Example usage:
% First, set default values for the parameters. Assume we
% have four parameters that we wish to use optionally in
% the function examplefun.
%
%  - 'viscosity', which will have a default value of 1
%  - 'volume', which will default to 1
%  - 'pie' - which will have default value 3.141592653589793
%  - 'description' - a text field, left empty by default
%
% The first argument to examplefun is one which will always be
% supplied.
%
%   function examplefun(dummyarg1,varargin)
%   params.Viscosity = 1;
%   params.Volume = 1;
%   params.Pie = 3.141592653589793
%
%   params.Description = '';
%   params=parse_pv_pairs(params,varargin);
%   params
%
% Use examplefun, overriding the defaults for 'pie', 'viscosity'
% and 'description'. The 'volume' parameter is left at its default.
%
%   examplefun(rand(10),'vis',10,'pie',3,'Description','Hello world')
%
% params = 
%     Viscosity: 10
%        Volume: 1
%           Pie: 3
%   Description: 'Hello world'
%
% Note that capitalization was ignored, and the property 'viscosity'
% was truncated as supplied. Also note that the order the pairs were
% supplied was arbitrary.

npv = length(pv_pairs);
n = npv/2;

if n~=floor(n)
  error 'Property/value pairs must come in PAIRS.'
end
if n<=0
  % just return the defaults
  return
end

if ~isstruct(params)
  error 'No structure for defaults was supplied'
end

% there was at least one pv pair. process any supplied
propnames = fieldnames(params);
lpropnames = lower(propnames);
for i=1:n
  p_i = lower(pv_pairs{2*i-1});
  v_i = pv_pairs{2*i};
  
  ind = strmatch(p_i,lpropnames,'exact');
  if isempty(ind)
    ind = find(strncmp(p_i,lpropnames,length(p_i)));
    if isempty(ind)
      error(['No matching property found for: ',pv_pairs{2*i-1}])
    elseif length(ind)>1
      error(['Ambiguous property name: ',pv_pairs{2*i-1}])
    end
  end
  p_i = propnames{ind};
  
  % override the corresponding default in params
  params = setfield(params,p_i,v_i); %#ok
  
end


% ============================================
% subfunction - check_params
% ============================================
function params = check_params(params)

% check the parameters for acceptability
% smoothness == 1 by default
if isempty(params.smoothness)
  params.smoothness = 1;
else
  if (numel(params.smoothness)>2) || any(params.smoothness<=0)
    error 'Smoothness must be scalar (or length 2 vector), real, finite, and positive.'
  end
end

% interp must be one of:
% 'bicubic', 'bilinear', 'nearest', or 'triangle'
% but accept any shortening thereof.
%valid = {'bicubic', 'bilinear', 'nearest', 'triangle'};
valid = {'linear', 'nearest', 'triangle'};
if isempty(params.interp)
  params.interp = 'bilinear';
end
ind = find(strncmpi(params.interp,valid,length(params.interp)));
if (length(ind)==1)
  params.interp = valid{ind};
else
  error(['Invalid interpolation method: ',params.interp])
end

% solver must be one of:
%    'backslash', '\', 'symmlq', 'lsqr', or 'normal'
% but accept any shortening thereof.
valid = {'backslash', '\', 'symmlq', 'lsqr', 'normal'};
if isempty(params.solver)
  params.solver = '\';
end
ind = find(strncmpi(params.solver,valid,length(params.solver)));
if (length(ind)==1)
  params.solver = valid{ind};
else
  error(['Invalid solver option: ',params.solver])
end

% % extend must be one of:
% %    'never', 'warning', 'always'
% % but accept any shortening thereof.
% valid = {'never', 'warning', 'always'};
% if isempty(params.extend)
%   params.extend = 'warning';
% end
% ind = find(strncmpi(params.extend,valid,length(params.extend)));
% if (length(ind)==1)
%   params.extend = valid{ind};
% else
%   error(['Invalid extend option: ',params.extend])
% end

% % tilesize == inf by default
% if isempty(params.tilesize)
%   params.tilesize = inf;
% elseif (length(params.tilesize)>1) || (params.tilesize<3)
%   error 'Tilesize must be scalar and > 0.'
% end
% 
% % overlap == 0.20 by default
% if isempty(params.overlap)
%   params.overlap = 0.20;
% elseif (length(params.overlap)>1) || (params.overlap<0) || (params.overlap>0.5)
%   error 'Overlap must be scalar and 0 < overlap < 1.'
% end

% % ============================================
% % subfunction - tiled_gridfit
% % ============================================
% function zgrid=tiled_gridfit(x,y,z,xnodes,ynodes,params)
% % tiled_gridfit: a tiled version of gridfit, continuous across tile boundaries 
% % usage: [zgrid,xgrid,ygrid]=tiled_gridfit(x,y,z,xnodes,ynodes,params)
% %
% % Tiled_gridfit is used when the total grid is far too large
% % to model using a single call to gridfit. While gridfit may take
% % only a second or so to build a 100x100 grid, a 2000x2000 grid
% % will probably not run at all due to memory problems.
% %
% % Tiles in the grid with insufficient data (<4 points) will be
% % filled with NaNs. Avoid use of too small tiles, especially
% % if your data has holes in it that may encompass an entire tile.
% %
% % A mask may also be applied, in which case tiled_gridfit will
% % subdivide the mask into tiles. Note that any boolean mask
% % provided is assumed to be the size of the complete grid.
% %
% % Tiled_gridfit may not be fast on huge grids, but it should run
% % as long as you use a reasonable tilesize. 8-)
% 
% % Note that we have already verified all parameters in check_params
% 
% % Matrix elements in a square tile
% tilesize = params.tilesize;
% % Size of overlap in terms of matrix elements. Overlaps
% % of purely zero cause problems, so force at least two
% % elements to overlap.
% overlap = max(2,floor(tilesize*params.overlap));
% 
% % reset the tilesize for each particular tile to be inf, so
% % we will never see a recursive call to tiled_gridfit
% Tparams = params;
% Tparams.tilesize = inf;
% 
% nx = length(xnodes);
% ny = length(ynodes);
% zgrid = zeros(ny,nx);
% 
% % linear ramp for the bilinear interpolation
% rampfun = inline('(t-t(1))/(t(end)-t(1))','t');
% 
% % loop over each tile in the grid
% h = waitbar(0,'Relax and have a cup of JAVA. Its my treat.');
% warncount = 0;
% xtind = 1:min(nx,tilesize);
% while ~isempty(xtind) && (xtind(1)<=nx)
%   
%   xinterp = ones(1,length(xtind));
%   if (xtind(1) ~= 1)
%     xinterp(1:overlap) = rampfun(xnodes(xtind(1:overlap)));
%   end
%   if (xtind(end) ~= nx)
%     xinterp((end-overlap+1):end) = 1-rampfun(xnodes(xtind((end-overlap+1):end)));
%   end
%   
%   ytind = 1:min(ny,tilesize);
%   while ~isempty(ytind) && (ytind(1)<=ny)
%     % update the waitbar
%     waitbar((xtind(end)-tilesize)/nx + tilesize*ytind(end)/ny/nx)
%     
%     yinterp = ones(length(ytind),1);
%     if (ytind(1) ~= 1)
%       yinterp(1:overlap) = rampfun(ynodes(ytind(1:overlap)));
%     end
%     if (ytind(end) ~= ny)
%       yinterp((end-overlap+1):end) = 1-rampfun(ynodes(ytind((end-overlap+1):end)));
%     end
%     
%     % was a mask supplied?
%     if ~isempty(params.mask)
%       submask = params.mask(ytind,xtind);
%       Tparams.mask = submask;
%     end
%     
%     % extract data that lies in this grid tile
%     k = (x>=xnodes(xtind(1))) & (x<=xnodes(xtind(end))) & ...
%         (y>=ynodes(ytind(1))) & (y<=ynodes(ytind(end)));
%     k = find(k);
%     
%     if length(k)<4
%       if warncount == 0
%         warning('GRIDFIT:tiling','A tile was too underpopulated to model. Filled with NaNs.')
%       end
%       warncount = warncount + 1;
%       
%       % fill this part of the grid with NaNs
%       zgrid(ytind,xtind) = NaN;
%       
%     else
%       % build this tile
%       zgtile = RegularizeData3D(x(k),y(k),z(k),xnodes(xtind),ynodes(ytind),Tparams);
%       
%       % bilinear interpolation (using an outer product)
%       interp_coef = yinterp*xinterp;
%       
%       % accumulate the tile into the complete grid
%       zgrid(ytind,xtind) = zgrid(ytind,xtind) + zgtile.*interp_coef;
%       
%     end
%     
%     % step to the next tile in y
%     if ytind(end)<ny
%       ytind = ytind + tilesize - overlap;
%       % are we within overlap elements of the edge of the grid?
%       if (ytind(end)+max(3,overlap))>=ny
%         % extend this tile to the edge
%         ytind = ytind(1):ny;
%       end
%     else
%       ytind = ny+1;
%     end
%     
%   end % while loop over y
%   
%   % step to the next tile in x
%   if xtind(end)<nx
%     xtind = xtind + tilesize - overlap;
%     % are we within overlap elements of the edge of the grid?
%     if (xtind(end)+max(3,overlap))>=nx
%       % extend this tile to the edge
%       xtind = xtind(1):nx;
%     end
%   else
%     xtind = nx+1;
%   end
% 
% end % while loop over x
% 
% % close down the waitbar
% close(h)
% 
% if warncount>0
%   warning('GRIDFIT:tiling',[num2str(warncount),' tiles were underpopulated & filled with NaNs'])
% end
% 
% end

function out = binary_factorial( dims)
    
    t = repmat((1:(2^dims))'-1,1,dims);
    d = 2.^(1:dims);
    out = mod(t,d) >= (d/2);    
