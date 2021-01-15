classdef class_accessory_data
    %class_accessory_data
    %   Universal data structure for accessory load data
    
    properties
        time                        % data set time in seconds
        
        alternator_A                % alternator current in Amps
        alternator_V                % alternator voltage in Volts
        alternator_electrical_kW    % alternator electrical power in kiloWatts
        
        alternator_speed_radps      % alternator speed in radians / sec
        alternator_torque_Nm        % alternator torque in Newton-meters
        alternator_mechanical_kW    % alternator mechanical power in kiloWatts
        
        battery = class_battery_data;   % holds starter/accessory battery data
                
        torque_Nm                   % mechanical accessory torque in Nm
        speed_radps                 % mechanical accessory speed in radians / sec
        mechanical_kW               % mechanical accessory power in kiloWatts
        
        DCDC_input_A                % DC-DC converter input current in Amps
        DCDC_input_V                % DC-DC converter input voltage in Volts
        DCDC_input_kW               % DC-DC converter input power in kiloWatts
        
        DCDC_output_A               % DC-DC converter output current in Amps
        DCDC_output_V               % DC-DC converter outtput voltage in Volts
        DCDC_output_kW              % DC-DC converter output power in kiloWatts
    end
    
    properties ( Dependent )
        torque_ftlbs                % mechanical accessory torque in foot-pounds
        speed_rpm                   % mechanical accessory speed in RPM
        mechanical_hp               % mechanical accessory power in horsepower
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
        
        function val = get.alternator_A( obj )
            if was_provided( obj.alternator_A )
                val = obj.alternator_A;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.alternator_V( obj )
            if was_provided( obj.alternator_V )
                val = obj.alternator_V;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.alternator_electrical_kW( obj )
            if was_provided( obj.alternator_electrical_kW )
                val = obj.alternator_electrical_kW;
            elseif was_provided( obj.alternator_A ) & was_provided( obj.alternator_V )
                val = (obj.alternator_A .* obj.alternator_V)/1000;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.alternator_speed_radps( obj )
            if was_provided( obj.alternator_speed_radps )
                val = obj.alternator_speed_radps;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.alternator_torque_Nm( obj )
            if was_provided( obj.alternator_torque_Nm )
                val = obj.alternator_torque_Nm;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.alternator_mechanical_kW( obj )
            if was_provided( obj.alternator_mechanical_kW )
                val = obj.alternator_mechanical_kW;
            elseif was_provided( obj.alternator_speed_radps ) & was_provided( obj.alternator_torque_Nm )
                val = (obj.alternator_speed_radps .* obj.alternator_torque_Nm)/1000;
            else
                val = NaN * ones(size(obj.time));
            end
        end
                
        function val = get.torque_Nm( obj )
            if was_provided( obj.torque_Nm )
                val = obj.torque_Nm;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.speed_radps( obj )
            if was_provided( obj.speed_radps )
                val = obj.speed_radps;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.mechanical_kW( obj )
            if was_provided( obj.mechanical_kW )
                val = obj.mechanical_kW;
            elseif was_provided( obj.torque_Nm ) & was_provided( obj.speed_radps )
                val = (obj.torque_Nm .* obj.speed_radps)/1000;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.DCDC_input_A( obj )
            if was_provided( obj.DCDC_input_A )
                val = obj.DCDC_input_A;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.DCDC_input_V( obj )
            if was_provided( obj.DCDC_input_V )
                val = obj.DCDC_input_V;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.DCDC_input_kW( obj )
            if was_provided( obj.DCDC_input_kW )
                val = obj.DCDC_input_kW;
            elseif was_provided( obj.DCDC_input_A ) & was_provided( obj.DCDC_input_V )
                val = (obj.DCDC_input_A .* obj.DCDC_input_V)/1000;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.DCDC_output_A( obj )
            if was_provided( obj.DCDC_output_A )
                val = obj.DCDC_output_A;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.DCDC_output_V( obj )
            if was_provided( obj.DCDC_output_V )
                val = obj.DCDC_output_V;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.DCDC_output_kW( obj )
            if was_provided( obj.DCDC_output_kW )
                val = obj.DCDC_output_kW;
            elseif was_provided( obj.DCDC_output_A ) & was_provided( obj.DCDC_output_V )
                val = (obj.DCDC_output_A .* obj.DCDC_output_V)/1000;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        %% setters/getters for Dependent properties
        
        function obj = set.torque_ftlbs( obj, val )
            obj.torque_Nm = unit_convert.ftlbs2Nm * val ;
        end
        
        function val = get.torque_ftlbs( obj )
            val = unit_convert.Nm2ftlbs * obj.torque_Nm;
        end
        
        function obj = set.speed_rpm( obj, val )
            obj.speed_radps = unit_convert.rpm2radps * val ;
        end
        
        function val = get.speed_rpm( obj )
            val = unit_convert.radps2rpm * obj.speed_radps;
        end
        
        function obj = set.mechanical_hp( obj, val )
            obj.mechanical_kW = unit_convert.hp2kW * val ;
        end
        
        function val = get.mechanical_hp( obj )
            val = unit_convert.kW2hp * obj.mechanical_kW;
        end
        %% filtering functions
        
        function val = alternator_A_filt( obj, cutoff_Hz, varargin )
            % alternator_A_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of alternator_A
            val = lowpass_filter(obj.alternator_A, obj.time, cutoff_Hz, varargin);
        end
        
        function val = alternator_V_filt( obj, cutoff_Hz, varargin )
            % alternator_V_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of alternator_V
            val = lowpass_filter(obj.alternator_V, obj.time, cutoff_Hz, varargin);
        end
        
        function val = alternator_electrical_kW_filt( obj, cutoff_Hz, varargin )
            % alternator_electrical_kW_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of alternator_electrical_kW
            val = lowpass_filter(obj.alternator_electrical_kW, obj.time, cutoff_Hz, varargin);
        end
        
        function val = alternator_speed_radps_filt( obj, cutoff_Hz, varargin )
            % alternator_speed_radps_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of alternator_speed_radps
            val = lowpass_filter(obj.alternator_speed_radps, obj.time, cutoff_Hz, varargin);
        end
        
        function val = alternator_torque_Nm_filt( obj, cutoff_Hz, varargin )
            % alternator_torque_Nm_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of alternator_torque_Nm
            val = lowpass_filter(obj.alternator_torque_Nm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = alternator_mechanical_kW_filt( obj, cutoff_Hz, varargin )
            % alternator_mechanical_kW_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of alternator_mechanical_kW
            val = lowpass_filter(obj.alternator_mechanical_kW, obj.time, cutoff_Hz, varargin);
        end
                
        function val = torque_Nm_filt( obj, cutoff_Hz, varargin )
            % torque_Nm_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of torque_Nm
            val = lowpass_filter(obj.torque_Nm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = speed_radps_filt( obj, cutoff_Hz, varargin )
            % speed_radps_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of speed_radps
            val = lowpass_filter(obj.speed_radps, obj.time, cutoff_Hz, varargin);
        end
        
        function val = mechanical_kW_filt( obj, cutoff_Hz, varargin )
            % mechanical_kW_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of mechanical_kW
            val = lowpass_filter(obj.mechanical_kW, obj.time, cutoff_Hz, varargin);
        end
        
        function val = DCDC_input_A_filt( obj, cutoff_Hz, varargin )
            % DCDC_input_A_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of DCDC_input_A
            val = lowpass_filter(obj.DCDC_input_A, obj.time, cutoff_Hz, varargin);
        end
        
        function val = DCDC_input_V_filt( obj, cutoff_Hz, varargin )
            % DCDC_input_V_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of DCDC_input_V
            val = lowpass_filter(obj.DCDC_input_V, obj.time, cutoff_Hz, varargin);
        end
        
        function val = DCDC_input_kW_filt( obj, cutoff_Hz, varargin )
            % DCDC_input_kW_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of DCDC_input_kW
            val = lowpass_filter(obj.DCDC_input_kW, obj.time, cutoff_Hz, varargin);
        end
        
        function val = DCDC_output_A_filt( obj, cutoff_Hz, varargin )
            % DCDC_output_A_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of DCDC_output_A
            val = lowpass_filter(obj.DCDC_output_A, obj.time, cutoff_Hz, varargin);
        end
        
        function val = DCDC_output_V_filt( obj, cutoff_Hz, varargin )
            % DCDC_output_V_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of DCDC_output_V
            val = lowpass_filter(obj.DCDC_output_V, obj.time, cutoff_Hz, varargin);
        end
        
        function val = DCDC_output_kW_filt( obj, cutoff_Hz, varargin )
            % DCDC_output_kW_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of DCDC_output_kW
            val = lowpass_filter(obj.DCDC_output_kW, obj.time, cutoff_Hz, varargin);
        end
        
        function val = torque_ftlbs_filt( obj, cutoff_Hz, varargin )
            % torque_ftlbs_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of torque_ftlbs
            val = lowpass_filter(obj.torque_ftlbs, obj.time, cutoff_Hz, varargin);
        end
        
        function val = speed_rpm_filt( obj, cutoff_Hz, varargin )
            % speed_rpm_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of speed_rpm
            val = lowpass_filter(obj.speed_rpm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = mechanical_hp_filt( obj, cutoff_Hz, varargin )
            % mechanical_hp_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of mechanical_hp
            val = lowpass_filter(obj.mechanical_hp, obj.time, cutoff_Hz, varargin);
        end
    end
    
end

