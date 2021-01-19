function xyzt(plot_x_label, plot_y_label, plot_z_label, varargin)
% XYT(plot_x_label, plot_y_label, varargin)
%   Set plot x- and y- and z-labels, optionally set the plot title.
%
% Shortcut for setting plot labels using **xlabel**, **ylabel**, **zlabel**
% and optionally **title**
%
% Parameters:
%   plot_x_label (str): plot x-axis label string
%   plot_y_label (str): plot y-axis label string
%   plot_z_label (str): plot z-axis label string
%   varargin (optional keyword and name-value arguments):
%       * first positional vararg (string)
%           plot title string
%       * subsequent varargs
%           passed to **title** function
%       * 'no_date'
%           disable automatic date string in title
%
% Examples:
%   Set x-, y- and z-axis labels::
%
%       xyzt('Engine Speed (RPM)', 'Engine Torque (Nm)', 'Engine Efficiency (%)');
%
%   Set x-, y- and z-axis labels, omitting automatic date reference::
%
%       xyzt('Engine Speed (RPM)', 'Engine Torque (Nm)', 'Engine Efficiency (%)', 'no_date');
%
%   Set x-, y- and z-axis labels and title::
%
%       xyzt('Engine Speed (RPM)', 'Engine Torque (Nm)', 'Engine Efficiency (%)', 'Engine Efficiency Plot');
%
% Note:
%   Sets label and title Interpreters to 'none', so underscores display properly
%
% See also:
%   xlabel, ylabel, title, xyt
%

    if ~isempty(plot_x_label) || ~isempty(plot_y_label)
        xlabel_h = xlabel(plot_x_label);
        ylabel_h = ylabel(plot_y_label);
        zlabel_h = zlabel(plot_z_label);

        if (size(varargin, 2) > 0) 
            plot_title = varargin{1};
            varargin = varargin(2:end);
        else
            plot_title = [plot_z_label ' v. ' plot_x_label ' and ' plot_y_label];
        end

        no_date = parse_varargs(varargin, 'no_date', true, 'toggle');

        varargin = varargin(find(~strcmp(varargin,'no_date')));

        if no_date
            title_h = title(plot_title, varargin{:});
        else
            title_h = title([plot_title ' plotted on ' date],varargin{:});
        end

        set(xlabel_h,'Interpreter', 'none');
        set(ylabel_h,'Interpreter', 'none');
        set(zlabel_h,'Interpreter', 'none');
        set(title_h, 'Interpreter', 'none');
    else
        xlabel('');
        ylabel('');
        zlabel('');
        title('');        
    end
    
end