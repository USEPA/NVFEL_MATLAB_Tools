function [filt_val] = lowpass_filter(val, time, cutoff_hz, varargin)
% [filt_val] = LOWPASS_FILTER(val, time, cutoff_hz, varargin)
%
% Perform a low-pass filter at ``cutoff_hz`` of ``val`` over ``time``.
%
% Parameters:
%   val (numeric): value to be filtered
%   time (numeric): time vector of ``val``
%   cutoff_hz (numeric): cutoff frequency of low-pass filter in Hz
%   varargin (optional keyword and name-value arguments):
%     * 'do_plots': enable plots of raw and filtered value
%     * 'time_align_disable': disable time-alignment of filtered and raw
%       value
%
% Returns:
%   vector of filtered value
%
% See also:
%   time_aligner
%

    do_plots            = parse_varargs(varargin, 'do_plots', false, 'toggle');
    time_align_disable  = parse_varargs(varargin, 'time_align_disable', false, 'toggle');
    
    was_column = iscolumn(val);
    
    if was_column
        val = val';
    end
    if iscolumn(time)
        time = time';
    end
    
    filt_val = zeros(1, length(val));
    filt_val(1) = val(1);
    for i=2:length(val)
        filt_val(i) = val(i) + (filt_val(i-1) - val(i))/(1 + (time(i)-time(i-1))*2*pi*cutoff_hz);
    end
    
    if ~time_align_disable
        cmp_idx = 1:min(length(time),max(100, length(time) * 0.1));
		ref_idx = cmp_idx(1:ceil(length(cmp_idx)*0.75));		
		offset_time = time_aligner(time(ref_idx), val(ref_idx), time(cmp_idx), filt_val(cmp_idx) );

		filt_val = interp1(time , filt_val, time - offset_time, 'linear', filt_val(end));
    end
    
    if do_plots
        fplothg(time, val);
        plothg(time, filt_val, 'r.-');
    end
    
    if was_column
        filt_val = filt_val';
    end
end
