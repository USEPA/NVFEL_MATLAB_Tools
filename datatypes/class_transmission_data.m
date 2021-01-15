classdef class_transmission_data
    %class_transmission_data
    %
    %   Universal data structure for transmission data
    
    properties
        time                        % data set time in seconds
        
        type                        % transmission type
        
        gear_ratios                 % vector of forward gear ratios 1..MAX_GEAR
        
        current_gear_number         % current / last gear number
        commanded_gear_number       % commanded gear number
        
        current_gear_ratio          % current / last gear ratio
        commanded_gear_ratio        % commanded gear ratio

        current_CVT_ratio           % current CVT ratio
        commanded_CVT_ratio         % commanded CVT ratio
        
        input_speed_radps           % transmission (pre-laumch-device) input speed in radians/sec
        slip_speed_radps            % launch device slip speed in radians/sec
        desired_slip_speed_radps    % launch device desired slip speed in radians/sec
        
        gearbox_input_speed_radps   % post-launch-device gearbox input speed in radians/sec
        gearbox_input_torque_Nm     % post-launch-device gearbox input torque in Newton-meters
        
        gearbox_output_speed_radps  % gearbox output speed in radians/sec
        
        output_torque_Nm            % transmission output torque in Newton-meters
        
        oil_temp_degC               % engine oil temperature in Celsius
        
        line_pressure_bar           % transmission line pressure in bar
        
        launch_device_lockup_norm   % = 1 if launch device is considered locked, 0 = unlocked
        
        % ------------------ possible future properties ------------------
        % speed_ratio
        % torque_ratio?
    end
    
    properties ( Dependent )
        input_speed_rpm             % transmission input speed in RPM
        slip_speed_rpm              % launch device slip speed in RPM
        
        gearbox_input_speed_rpm     % gearbox input speed in RPM
        gearbox_input_torque_ftlbs  % post-launch-device gearbox input torque in foot-pounds

        gearbox_output_speed_rpm    % gearbox output speed in RPM
        
        output_torque_ftlbs         % transmission output torque in foot-pounds

        oil_temp_degF               % engine oil temperature in Fahrenheit
        
        line_pressure_psi           % transmission line pressure in psi
    end
    
    methods
        %% getters for Independent properties
        
        function val = get.time( obj )
            if was_provided( obj.time )
                val = obj.time;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.type( obj )
            if was_provided( obj.type )
                val = obj.type;
            else
                val = enum_transmission_type.no_transmission;
            end
        end
        
        function val = get.current_gear_ratio( obj )
            if obj.type == enum_transmission_type.CVT
                val = obj.current_CVT_ratio;
            elseif was_provided(obj.current_gear_ratio)
                val = obj.current_gear_ratio;
            else
                val = reshape(obj.gear_ratios(obj.current_gear_number+1), size(obj.time));
            end
        end
        
        function val = get.commanded_gear_ratio( obj )
            if obj.type == enum_transmission_type.CVT
                val = obj.commanded_CVT_ratio;
            elseif was_provided(obj.commanded_gear_ratio)
                val = obj.commanded_gear_ratio;
            else
                val = reshape(obj.gear_ratios(obj.commanded_gear_number+1), size(obj.time));
            end
        end
        
        function val = get.gear_ratios( obj )
            if was_provided( obj.gear_ratios )
                val = obj.gear_ratios;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.current_gear_number( obj )
            if was_provided( obj.current_gear_number )
                val = obj.current_gear_number;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.commanded_gear_number( obj )
            if was_provided( obj.commanded_gear_number )
                val = obj.commanded_gear_number;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.current_CVT_ratio( obj )
            if was_provided( obj.current_CVT_ratio )
                val = obj.current_CVT_ratio;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.commanded_CVT_ratio( obj )
            if was_provided( obj.commanded_CVT_ratio )
                val = obj.commanded_CVT_ratio;
            else
                val = NaN * ones(size(obj.time));
            end
        end

        function val = get.input_speed_radps( obj )
            if was_provided( obj.input_speed_radps )
                val = obj.input_speed_radps;
            else
                val = NaN * ones(size(obj.time));
            end
        end

        function val = get.slip_speed_radps( obj )
            if was_provided( obj.slip_speed_radps )
                val = obj.slip_speed_radps;
            elseif was_provided( obj.input_speed_radps) & was_provided( obj.gearbox_input_speed_radps )
                val = obj.input_speed_radps - obj.gearbox_input_speed_radps;
            else
                val = NaN * ones(size(obj.time));
            end
        end

        function val = get.desired_slip_speed_radps( obj )
            if was_provided( obj.desired_slip_speed_radps )
                val = obj.desired_slip_speed_radps;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.gearbox_input_speed_radps( obj )
            if was_provided( obj.gearbox_input_speed_radps )
                val = obj.gearbox_input_speed_radps;
            elseif was_provided( obj.gearbox_output_speed_radps ) & was_provided( obj.current_gear_ratio )
                val = obj.gearbox_output_speed_radps .* obj.current_gear_ratio;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.gearbox_output_speed_radps( obj )
            if was_provided( obj.gearbox_output_speed_radps )
                val = obj.gearbox_output_speed_radps;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.output_torque_Nm( obj )
            if was_provided( obj.output_torque_Nm )
                val = obj.output_torque_Nm;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.oil_temp_degC( obj )
            if was_provided( obj.oil_temp_degC )
                val = obj.oil_temp_degC;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.line_pressure_bar( obj )
            if was_provided( obj.line_pressure_bar )
                val = obj.line_pressure_bar;
            else
                val = NaN * ones(size(obj.time));
            end
        end
                
        function val = get.launch_device_lockup_norm( obj )
            if was_provided( obj.launch_device_lockup_norm )
                val = obj.launch_device_lockup_norm;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        %% setters/getters for Dependent properties

        function obj = set.input_speed_rpm( obj, val )
            obj.input_speed_radps = unit_convert.rpm2radps * val ;
        end
        
        function val = get.input_speed_rpm( obj )
            val = unit_convert.radps2rpm * obj.input_speed_radps;
        end

        function obj = set.slip_speed_rpm( obj, val )
            obj.slip_speed_radps = unit_convert.rpm2radps * val ;
        end
        
        function val = get.slip_speed_rpm( obj )
            val = unit_convert.radps2rpm * obj.slip_speed_radps;
        end
        
        function obj = set.gearbox_input_speed_rpm( obj, val )
            obj.gearbox_input_speed_radps = unit_convert.rpm2radps * val ;
        end
        
        function val = get.gearbox_input_speed_rpm( obj )
            val = unit_convert.radps2rpm * obj.gearbox_input_speed_radps;
        end
        
        function obj = set.gearbox_output_speed_rpm( obj, val )
            obj.gearbox_output_speed_radps = unit_convert.rpm2radps * val ;
        end
        
        function val = get.gearbox_output_speed_rpm( obj )
            val = unit_convert.radps2rpm * obj.gearbox_output_speed_radps;
        end

        function val = set.gearbox_input_torque_ftlbs( obj, val )
            obj.gearbox_input_torque_Nm = unit_convert.ftlbs2Nm * val;
        end

        function val = set.output_torque_ftlbs( obj, val )
            obj.output_torque_Nm = unit_convert.ftlbs2Nm * val;
        end

        function val = get.gearbox_input_torque_ftlbs( obj )
            val = unit_convert.Nm2ftlbs * obj.gearbox_input_torque_Nm;
        end

        function val = get.output_torque_ftlbs( obj )
            val = unit_convert.Nm2ftlbs * obj.output_torque_Nm;
        end
        
        function val = get.oil_temp_degF( obj )
            val = unit_convert.degC2degF( obj.oil_temp_degC );
        end
        
        function obj = set.oil_temp_degF( obj, val )
            obj.oil_temp_degC = unit_convert.degC2degF( val );
        end
        
        function obj = set.line_pressure_psi( obj, val )
            obj.line_pressure_bar = unit_convert.psi2bar * val ;
        end
        
        function val = get.line_pressure_psi( obj )
            val = unit_convert.bar2psi * obj.line_pressure_bar;
        end
        %% filtering functions
        
        function val = current_gear_number_filt( obj, cutoff_Hz, varargin )
            % current_gear_number_filt( cutoff_Hz, varargin ) returns lowpass_filter() of current_gear_number
            val = lowpass_filter(obj.current_gear_number, obj.time, cutoff_Hz, varargin);
        end
        
        function val = commanded_gear_number_filt( obj, cutoff_Hz, varargin )
            % commanded_gear_number_filt( cutoff_Hz, varargin ) returns lowpass_filter() of commanded_gear_number
            val = lowpass_filter(obj.commanded_gear_number, obj.time, cutoff_Hz, varargin);
        end
        
        function val = current_CVT_ratio_filt( obj, cutoff_Hz, varargin )
            % current_CVT_ratio_filt( cutoff_Hz, varargin ) returns lowpass_filter() of current_CVT_ratio
            val = lowpass_filter(obj.current_CVT_ratio, obj.time, cutoff_Hz, varargin);
        end
        
        function val = commanded_CVT_ratio_filt( obj, cutoff_Hz, varargin )
            % commanded_CVT_ratio_filt( cutoff_Hz, varargin ) returns lowpass_filter() of commanded_CVT_ratio
            val = lowpass_filter(obj.commanded_CVT_ratio, obj.time, cutoff_Hz, varargin);
        end
        
        function val = input_speed_radps_filt( obj, cutoff_Hz, varargin )
            % input_speed_radps_filt( cutoff_Hz, varargin ) returns lowpass_filter() of input_speed_radps
            val = lowpass_filter(obj.input_speed_radps, obj.time, cutoff_Hz, varargin);
        end

        function val = slip_speed_radps_filt( obj, cutoff_Hz, varargin )
         % slip_speed_radps_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of slip_speed_radps
            val = lowpass_filter(obj.slip_speed_radps, obj.time, cutoff_Hz, varargin);
        end        
        
        function val = gearbox_output_speed_radps_filt( obj, cutoff_Hz, varargin )
            % gearbox_output_speed_radps_filt( cutoff_Hz, varargin ) returns lowpass_filter() of gearbox_output_speed_radps
            val = lowpass_filter(obj.gearbox_output_speed_radps, obj.time, cutoff_Hz, varargin);
        end

        function val = gearbox_input_torque_Nm_filt( obj, cutoff_Hz, varargin )
            % output_torque_Nm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of output_torque_Nm
            val = lowpass_filter(obj.gearbox_input_torque_Nm, obj.time, cutoff_Hz, varargin);
        end

        function val = output_torque_Nm_filt( obj, cutoff_Hz, varargin )
            % output_torque_Nm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of output_torque_Nm
            val = lowpass_filter(obj.output_torque_Nm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = oil_temp_degC_filt( obj, cutoff_Hz, varargin )
            % oil_temp_degC_filt( cutoff_Hz, varargin ) returns lowpass_filter() of oil_temp_degC
            val = lowpass_filter(obj.oil_temp_degC, obj.time, cutoff_Hz, varargin);
        end
        
        function val = current_gear_ratio_filt( obj, cutoff_Hz, varargin )
            % current_gear_ratio_filt( cutoff_Hz, varargin ) returns lowpass_filter() of current_gear_ratio
            val = lowpass_filter(obj.current_gear_ratio, obj.time, cutoff_Hz, varargin);
        end
        
        function val = commanded_gear_ratio_filt( obj, cutoff_Hz, varargin )
            % commanded_gear_ratio_filt( cutoff_Hz, varargin ) returns lowpass_filter() of commanded_gear_ratio
            val = lowpass_filter(obj.commanded_gear_ratio, obj.time, cutoff_Hz, varargin);
        end
        
        function val = input_speed_rpm_filt( obj, cutoff_Hz, varargin )
            % input_speed_rpm_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of input_speed_rpm
            val = lowpass_filter(obj.input_speed_rpm, obj.time, cutoff_Hz, varargin);
        end

        function val = slip_speed_rpm_filt( obj, cutoff_Hz, varargin )
         % slip_speed_rpm_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of slip_speed_rpm
            val = lowpass_filter(obj.slip_speed_rpm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = gearbox_input_speed_rpm_filt( obj, cutoff_Hz, varargin )
            % gearbox_input_speed_rpm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of gearbox_input_speed_rpm
            val = lowpass_filter(obj.gearbox_input_speed_rpm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = gearbox_output_speed_rpm_filt( obj, cutoff_Hz, varargin )
            % gearbox_output_speed_rpm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of gearbox_output_speed_rpm
            val = lowpass_filter(obj.gearbox_output_speed_rpm, obj.time, cutoff_Hz, varargin);
        end

        function val = gearbox_input_torque_ftlbs_filt( obj, cutoff_Hz, varargin )
            % output_torque_ftlbs_filt( cutoff_Hz, varargin ) returns lowpass_filter() of output_torque_ftlbs
            val = lowpass_filter(obj.gearbox_input_torque_ftlbs, obj.time, cutoff_Hz, varargin);
        end
        
        function val = output_torque_ftlbs_filt( obj, cutoff_Hz, varargin )
            % output_torque_ftlbs_filt( cutoff_Hz, varargin ) returns lowpass_filter() of output_torque_ftlbs
            val = lowpass_filter(obj.output_torque_ftlbs, obj.time, cutoff_Hz, varargin);
        end
        
        function val = oil_temp_degF_filt( obj, cutoff_Hz, varargin )
            % oil_temp_degF_filt( cutoff_Hz, varargin ) returns lowpass_filter() of oil_temp_degF
            val = lowpass_filter(obj.oil_temp_degF, obj.time, cutoff_Hz, varargin);
        end
        
    end
    
end

