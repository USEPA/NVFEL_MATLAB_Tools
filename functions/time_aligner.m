function [ best_offset_time, offset_time, comparison_error] = ...
    time_aligner( reference_time, reference_data, comparison_time, comparison_data, varargin )
% [best_offset_time, offset_time, comparison_error] = time_aligner( reference_time, reference_data, comparison_time, comparison_data, varargin )
%
% Find the time offset that best time-aligns comparison data with reference
% data.
%
% Note:
%   Comparison timespan needs to be longer than reference timespan.  If the
%   reference and the comparison data have the same timespan, use the
%   'reference_xxx' varargins to shorten the reference timespan.
%
% Parameters:
%   reference_time (numeric): time vector of ``reference_data``
%   reference_data (numeric): reference data to time-align
%       ``comparison_data`` with
%   comparison_time (numeric): time vector of ``comparison_data``
%   comparison_data (numeric): data to time-align to ``reference_data``
%   varargin (optional keyword and name-value arguments):
%       * 'reference_window', numeric
%           2-element vector to define the start and end times of the 
%           reference window, format [start_time, end_time], by default
%           the entire ``reference_time`` timespan is used unless
%           overridden
%
%       * 'reference_start', numeric
%           define reference window start time
%
%       * 'reference_end', numeric
%           define reference window end time
%
%       * 'comparison_window', numeric
%           2-element vector to define the start and end times of the 
%           comparison window, format [start_time, end_time], by default
%           the entire ``comparison_time`` timespan is used unless
%           overridden
%
%       * 'comparison_start', numeric
%           define comparison window start time
%
%       * 'comparison_end', numeric
%           define comparison window end time
% 
%       * 'offset_interval', numeric
%           time alignment accuracy, default is the lesser of 0.1 and
%           one-fifth of the median of ``comparison_time`` delta-t
%
%   Returns:
%       tuple: best offset time (to be added to ``comparison_time`` to
%       perform alignment), offset times and comparison errors at those
%       times
%

reference_window_time = parse_varargs(varargin, 'reference_window',[reference_time(1), reference_time(end)] ,'numeric');
reference_start_time = reference_window_time(1);
reference_end_time = reference_window_time(end);
reference_start_time = parse_varargs(varargin, 'reference_start', reference_start_time,'numeric');
reference_end_time = parse_varargs(varargin, 'reference_end', reference_end_time,'numeric');

comparison_window_time = parse_varargs(varargin, 'comparison_window',[comparison_time(1), comparison_time(end)] ,'numeric');
comparison_start_time = comparison_window_time(1);
comparison_end_time = comparison_window_time(end);
comparison_start_time = parse_varargs(varargin, 'comparison_start', comparison_start_time,'numeric');
comparison_end_time = parse_varargs(varargin, 'comparison_end', comparison_end_time,'numeric');

offset_interval = parse_varargs(varargin, 'offset_interval', min(0.1, median(diff(comparison_time))/5), 'numeric');

%% new stuff
reference_data = interp1(reference_time, reference_data, reference_start_time : offset_interval : reference_end_time);
reference_time = reference_start_time : offset_interval : reference_end_time;
reference_length = length(reference_data);

comparison_data = interp1(comparison_time, comparison_data, comparison_start_time : offset_interval : comparison_end_time);
comparison_time = comparison_start_time : offset_interval : comparison_end_time;
comparison_length = length(comparison_data);

if reference_length >= comparison_length
    error('Comparison window needs to be longer than reference window');
end

%%
comparison_error    = zeros(1, comparison_length-reference_length);
offset_time         = zeros(1, comparison_length-reference_length);

for i = 1:(comparison_length - reference_length)
    comparison_start_index  = i;
    comparison_end_index    = comparison_start_index + reference_length - 1;

    data_difference = abs(reference_data - comparison_data(comparison_start_index:comparison_end_index));
    
    data_difference(isnan(data_difference)) = 0;
    comparison_error(i) = sum(data_difference);
    offset_time(i)      = comparison_time(comparison_start_index) - reference_start_time;
end

[~, min_error_index] = min(comparison_error);
best_offset_time = -offset_time(min_error_index);
offset_time = offset_time;

end
