classdef class_emachine_data
    %class_emachine_data
    %   Universal data structure for emachine (electric motor/generator) data
    
    properties
        
        time                    % dataset time in seconds
        
        current_A               % emachine electrical current in Amps
        voltage_V               % emachine electrical potential in Volts
        
        torque_Nm               % emachine shaft torque in Newton-meters
        speed_radps             % emachine shaft speed in radians/sec
        
        mechanical_power_kW     % output shaft power in kiloWatts
        electrical_power_kW     % battery terminal power in kiloWatts
        efficiency_norm         % emachine efficiency 0..1
        
    end
    
    properties ( Dependent )
        
        speed_rpm   % emachine shaft speed in rpm
        
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
        
        function val = get.current_A( obj )
            if was_provided( obj.current_A )
                val = obj.current_A;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.voltage_V( obj )
            if was_provided( obj.voltage_V )
                val = obj.voltage_V;
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
        
        function val = get.mechanical_power_kW( obj )
            if was_provided( obj.mechanical_power_kW )
                val = obj.mechanical_power_kW;
            elseif was_provided( obj.torque_Nm ) && was_provided( obj.speed_radps )
                val = obj.torque_Nm .* obj.speed_radps / 1000;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.electrical_power_kW( obj )
            if was_provided( obj.electrical_power_kW )
                val = obj.electrical_power_kW;
            elseif was_provided( obj.voltage_V ) && was_provided( obj.current_A )
                val = obj.voltage_V .* obj.current_A / 1000;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.efficiency_norm( obj )
            if was_provided( obj.efficiency_norm )
                val = obj.efficiency_norm;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        %% setters/getters for Dependent properties
        
        function obj = set.speed_rpm( obj, val )
            obj.speed_radps = unit_convert.rpm2radps * val ;
        end
        
        function val = get.speed_rpm( obj )
            val = unit_convert.radps2rpm * obj.speed_radps;
        end
        
        %% filtering functions
        function val = current_A_filt( obj, cutoff_Hz, varargin )
            % current_A_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of current_A
            val = lowpass_filter(obj.current_A, obj.time, cutoff_Hz, varargin);
        end
        
        function val = voltage_V_filt( obj, cutoff_Hz, varargin )
            % voltage_V_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of voltage_V
            val = lowpass_filter(obj.voltage_V, obj.time, cutoff_Hz, varargin);
        end
        
        function val = torque_Nm_filt( obj, cutoff_Hz, varargin )
            % torque_Nm_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of torque_Nm
            val = lowpass_filter(obj.torque_Nm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = speed_radps_filt( obj, cutoff_Hz, varargin )
            % speed_radps_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of speed_radps
            val = lowpass_filter(obj.speed_radps, obj.time, cutoff_Hz, varargin);
        end
        
        function val = mechanical_power_kW_filt( obj, cutoff_Hz, varargin )
            % mechanical_power_kW_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of mechanical_power_kW
            val = lowpass_filter(obj.mechanical_power_kW, obj.time, cutoff_Hz, varargin);
        end
        
        function val = electrical_power_kW_filt( obj, cutoff_Hz, varargin )
            % electrical_power_kW_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of electrical_power_kW
            val = lowpass_filter(obj.electrical_power_kW, obj.time, cutoff_Hz, varargin);
        end
        
        function val = efficiency_norm_filt( obj, cutoff_Hz, varargin )
            % efficiency_norm_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of efficiency_norm
            val = lowpass_filter(obj.efficiency_norm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = speed_rpm_filt( obj, cutoff_Hz, varargin )
            % speed_rpm_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of speed_rpm
            val = lowpass_filter(obj.speed_rpm, obj.time, cutoff_Hz, varargin);
        end
    end
    
end

