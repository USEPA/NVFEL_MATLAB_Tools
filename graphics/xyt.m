function xyt(plot_x_label, plot_y_label, varargin)
% function XYT(plot_x_label, plot_y_label, varargin)
%   Set plot x- and y-labels, optionally set the plot title.
%
% Shortcut for setting plot labels using **xlabel** and **ylabel**, and
% optionally **title**
%
% Parameters:
%   plot_x_label (str): plot x-axis label string
%   plot_y_label (str): plot y-axis label string
%   varargin (optional keyword and name-value arguments):
%       * first positional argument: plot title string
%       * subsequent varargs: passed to **title** function
%       * 'no_date': disables automatic date string in title
%
% Examples:
%   Set x- and y-axis labels::
%
%       xyt('time (secs)', 'Engine Speed (RPM)');
%
%   Set x- and y-axis labels, omitting automatic date reference::
%
%       xyt('time (secs)', 'Engine Speed (RPM)', 'no_date');
%
%   Set x- and y-axis labels and title::
%
%       xyt('time (secs)', 'Engine Speed (RPM)', 'Engine Speed v. Time');
%
%   Set x- and y-axis labels and title, omitting automatic date reference::
%
%       xyt('time (secs)', 'Engine Speed (RPM)', 'Engine Speed v. Time', 'no_date');
%
%   Set x- and y-axis labels and title, with optional title font size setting::
%
%       xyt('time (secs)', 'Engine Speed (RPM)', 'Engine Speed v. Time', 'FontSize', 12);
%
% Note:
%   Sets label and title Interpreters to 'none', so underscores display properly
%
% See also:
%   xlabel, ylabel, title
%

    if ~isempty(plot_x_label) || ~isempty(plot_y_label)
        xlabel_h = xlabel(plot_x_label);
        ylabel_h = ylabel(plot_y_label);
        if (size(varargin,2) > 0) 
            plot_title = varargin{1};
            varargin = varargin(2:end);
        else
            plot_title = [plot_y_label ' v. ' plot_x_label];
        end

        no_date = parse_varargs(varargin, 'no_date', true, 'toggle');

        varargin = varargin(find(~strcmp(varargin,'no_date')));

        if no_date
            title_h = title(plot_title, varargin{:});
        else
            title_h = title([plot_title ' plotted on ' date],varargin{:});
        end

        set(xlabel_h,'Interpreter','none');
        set(ylabel_h,'Interpreter','none');
        set(title_h,'Interpreter','none');
    else
        xlabel('');
        ylabel('');
        title('');        
    end
    
end