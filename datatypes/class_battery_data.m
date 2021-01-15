classdef class_battery_data
    %class_battery_data
    %   Universal data structure for battery data
    
    properties
        
        time                        % data set time in seconds
                
        terminal_current_A          % battery terminal current in Amps
        terminal_voltage_V          % battery terminal voltage in Volts
        terminal_power_kW           % battery terminal power in kiloWatts
        state_of_charge_norm        % battery state of charge, 0..1
        
    end
    
    properties ( Dependent )
        terminal_coulombs_Ah        % battery terminal Amp-hours
        terminal_energy_kWh         % battery terminal energy in kiloWatt-hours
        terminal_energy_Wh          % battery terminal energy in Watt-hours
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
                
        function val = get.terminal_current_A( obj )
            if was_provided( obj.terminal_current_A )
                val = obj.terminal_current_A;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.terminal_voltage_V( obj )
            if was_provided( obj.terminal_voltage_V )
                val = obj.terminal_voltage_V;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.terminal_power_kW( obj )
            if was_provided( obj.terminal_power_kW )
                val = obj.terminal_power_kW;
            elseif was_provided( obj.terminal_current_A ) & was_provided( obj.terminal_voltage_V )
                val = (obj.terminal_current_A .* obj.terminal_voltage_V)/1000;
            else
                val = NaN * ones(size(obj.time));
            end
        end

        function val = get.state_of_charge_norm( obj )
            if was_provided( obj.state_of_charge_norm )
                val = obj.state_of_charge_norm;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        %% setters/getters for Dependent properties
        function val = get.terminal_coulombs_Ah( obj )
            Amps = obj.terminal_current_A;
            Amps(isnan(Amps)) = 0;
            val = cumtrapz(obj.time / 3600, Amps);
        end

        function val = get.terminal_energy_kWh( obj )
            kW = obj.terminal_power_kW;
            kW(isnan(kW)) = 0;
            val = cumtrapz(obj.time / 3600, kW);
        end
        
        function val = get.terminal_energy_Wh( obj )
            kW = obj.terminal_power_kW;
            kW(isnan(kW)) = 0;
            val = cumtrapz(obj.time / 3600, kW * 1000);
        end
        
        %% filtering functions
                
        function val = terminal_current_A_filt( obj, cutoff_Hz, varargin )
            % terminal_current_A_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of terminal_current_A
            val = lowpass_filter(obj.terminal_current_A, obj.time, cutoff_Hz, varargin);
        end
        
        function val = terminal_voltage_V_filt( obj, cutoff_Hz, varargin )
            % terminal_voltage_V_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of terminal_voltage_V
            val = lowpass_filter(obj.terminal_voltage_V, obj.time, cutoff_Hz, varargin);
        end
        
        function val = terminal_power_kW_filt( obj, cutoff_Hz, varargin )
            % terminal_power_kW_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of terminal_power_kW
            val = lowpass_filter(obj.terminal_power_kW, obj.time, cutoff_Hz, varargin);
        end

        function val = state_of_charge_norm_filt( obj, cutoff_Hz, varargin )
            % state_of_charge_norm_filt( obj, cutoff_Hz, varargin ) returns lowpass_filter() of state_of_charge_norm
            val = lowpass_filter(obj.state_of_charge_norm, obj.time, cutoff_Hz, varargin);
        end
        
    end
    
end

