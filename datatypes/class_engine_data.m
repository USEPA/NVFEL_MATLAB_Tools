classdef class_engine_data
    %class_engine_data
    %   Universal data structure for engine data
    
    properties
        time								% data set time in seconds
        
        speed_radps							% engine speed in radians / sec
        
        gross_torque_Nm						% engine gross torque (crankshaft torque plus accessory loads) in Newton-meters
        crankshaft_torque_Nm				% engine crankshaft (net) torque in Newton-meters
        
        coolant_temp_degC					% engine coolant temperature in Celsius
        oil_temp_degC						% engine oil temperature in Celsius
        
        throttle_norm						% engine throttle position, 0..1
        load_at_current_speed_norm			% engine load at current speed, 0..1
        
        fuel class_fuel_data = class_fuel_data				% engine fuel data, ``class_fuel_data`` type
		fuel_meter class_fuel_data = class_fuel_data		% engine fuel data, ``class_fuel_data`` type
		fuel_injector class_fuel_data = class_fuel_data     % engine fuel data, ``class_fuel_data`` type
        
		intake_cam_phase_deg				% intake cam measured phasing relative to parked position
		exhaust_cam_phase_deg				% exhaust cam measured phasing relative to parked position
		
        gross_power_kW						% engine gross power in kiloWatts
        crankshaft_power_kW					% engine crankshaft power in kiloWatts

		cylinder_deac_norm					% Cylinder deactivation active
		
        % ------------------ possible future properties ------------------
        % command_lambda
        % measured_lambda
        % mass_air_flow_gps
		% spark_advance_deg			%

    end
    
    properties ( Dependent )
        speed_rpm                   % engine speed in RPM
        
        accel_radps2                % engine acceleration in radians / sec^2
                
        gross_power_hp              % engine gross power in horsepower
        crankshaft_power_hp         % engine crankshaft power in horsepower
        
        gross_torque_ftlbs          % engine gross torque (crankshaft torque plus accessory loads) in foot-pounds
        crankshaft_torque_ftlbs     % engine crankshaft (net) torque in foot-pounds
        
        throttle_pct                % engine throttle position in percent
        load_at_current_speed_pct   % engine load at current speed in percent
        
        coolant_temp_degF           % engine coolant temperature in Fahrenheit
        oil_temp_degF               % engine oil temperature in Fahrenheit
        
        efficiency_norm             % engine fuel efficiency, 0..1
    end
    
    methods
        function val = get.time( obj )
            if was_provided( obj.time )
                val = obj.time;
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
        
        function val = get.gross_torque_Nm( obj )
            if was_provided( obj.gross_torque_Nm )
                val = obj.gross_torque_Nm;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.crankshaft_torque_Nm( obj )
            if was_provided( obj.crankshaft_torque_Nm )
                val = obj.crankshaft_torque_Nm;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.coolant_temp_degC( obj )
            if was_provided( obj.coolant_temp_degC )
                val = obj.coolant_temp_degC;
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
        
        function val = get.throttle_norm( obj )
            if was_provided( obj.throttle_norm )
                val = obj.throttle_norm;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.load_at_current_speed_norm( obj )
            if was_provided( obj.load_at_current_speed_norm )
                val = obj.load_at_current_speed_norm;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.gross_power_kW( obj )
            if was_provided( obj.gross_power_kW )
                val = obj.gross_power_kW;
            elseif was_provided( obj.gross_torque_Nm ) & was_provided( obj.speed_radps )
                val = obj.gross_torque_Nm .* obj.speed_radps / 1000;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.crankshaft_power_kW( obj )
            if was_provided( obj.crankshaft_power_kW )
                val = obj.crankshaft_power_kW;
            elseif was_provided( obj.crankshaft_torque_Nm ) & was_provided( obj.speed_radps )
                val = obj.crankshaft_torque_Nm .* obj.speed_radps / 1000;
            else
                val = NaN * ones(size(obj.time));
            end
        end
     
        %%
        
        function obj = set.speed_rpm( obj, val )
            obj.speed_radps = unit_convert.rpm2radps * val ;
        end
        
        function val = get.speed_rpm( obj )
            val = unit_convert.radps2rpm * obj.speed_radps;
        end
        
        function val = get.accel_radps2( obj )
            val = delta(obj.speed_radps, 1)./delta(obj.time, 1);
        end
                        
        function val = get.gross_power_hp( obj )
            val = unit_convert.kW2hp * obj.gross_power_kW;
        end
                
        function val = get.crankshaft_power_hp( obj )
            val = unit_convert.kW2hp * obj.crankshaft_power_kW;
        end
        
        function obj = set.gross_torque_ftlbs( obj, val )
            obj.gross_torque_Nm = unit_convert.ftlbs2Nm * val;
        end
        
        function val = get.gross_torque_ftlbs( obj )
            val = unit_convert.Nm2ftlbs * obj.gross_torque_Nm;
        end
        
        function obj = set.crankshaft_torque_ftlbs( obj, val )
            obj.crankshaft_torque_Nm = unit_convert.ftlbs2Nm * val;
        end
        
        function val = get.crankshaft_torque_ftlbs( obj )
            val = unit_convert.Nm2ftlbs * obj.crankshaft_torque_Nm;
        end
        
        function obj = set.throttle_pct( obj, val )
            obj.throttle_norm = val / 100 ;
        end
        
        function val = get.throttle_pct( obj )
            val = 100 * obj.throttle_norm;
        end
        
        function obj = set.load_at_current_speed_pct( obj, val )
            obj.load_at_current_speed_norm = val /100 ;
        end
        
        function val = get.load_at_current_speed_pct( obj )
            val = 100 * obj.load_at_current_speed_norm;
        end
        
        function val = get.coolant_temp_degF( obj )
            val = unit_convert.degC2degF( obj.coolant_temp_degC );
        end
        
        function obj = set.coolant_temp_degF( obj, val )
            obj.coolant_temp_degC = unit_convert.degF2degC(val);
        end
        
        function val = get.oil_temp_degF( obj )
            val = unit_convert.degC2degF( obj.oil_temp_degC );
        end
        
        function obj = set.oil_temp_degF( obj, val )
            obj.oil_temp_degC = unit_convert.degC2degF( val );
        end
        
        function val = get.efficiency_norm( obj )
            val = max(0, obj.gross_power_kW ./ (obj.fuel.flow_rate_gps * obj.fuel.energy_density_MJpkg));
        end
        
        %%
        function val = speed_radps_filt( obj, cutoff_Hz, varargin )
            % speed_radps_filt( cutoff_Hz, varargin ) returns lowpass_filter() of speed_radps
            val = lowpass_filter(obj.speed_radps, obj.time, cutoff_Hz, varargin);
        end
        
        function val = gross_torque_Nm_filt( obj, cutoff_Hz, varargin )
            % gross_torque_Nm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of gross_torque_Nm
            val = lowpass_filter(obj.gross_torque_Nm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = crankshaft_torque_Nm_filt( obj, cutoff_Hz, varargin )
            % crankshaft_torque_Nm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of crankshaft_torque_Nm
            val = lowpass_filter(obj.crankshaft_torque_Nm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = coolant_temp_degC_filt( obj, cutoff_Hz, varargin )
            % coolant_temp_degC_filt( cutoff_Hz, varargin ) returns lowpass_filter() of coolant_temp_degC
            val = lowpass_filter(obj.coolant_temp_degC, obj.time, cutoff_Hz, varargin);
        end
        
        function val = oil_temp_degC_filt( obj, cutoff_Hz, varargin )
            % oil_temp_degC_filt( cutoff_Hz, varargin ) returns lowpass_filter() of oil_temp_degC
            val = lowpass_filter(obj.oil_temp_degC, obj.time, cutoff_Hz, varargin);
        end
        
        function val = throttle_norm_filt( obj, cutoff_Hz, varargin )
            % throttle_norm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of throttle_norm
            val = lowpass_filter(obj.throttle_norm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = load_at_current_speed_norm_filt( obj, cutoff_Hz, varargin )
            % load_at_current_speed_norm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of load_at_current_speed_norm
            val = lowpass_filter(obj.load_at_current_speed_norm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = speed_rpm_filt( obj, cutoff_Hz, varargin )
            % speed_rpm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of speed_rpm
            val = lowpass_filter(obj.speed_rpm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = accel_radps2_filt( obj, cutoff_Hz, varargin )
            % accel_radps2_filt( cutoff_Hz, varargin ) returns lowpass_filter() of accel_radps2
            val = lowpass_filter(obj.accel_radps2, obj.time, cutoff_Hz, varargin);
        end
        
        function val = gross_power_kW_filt( obj, cutoff_Hz, varargin )
            % gross_power_kW_filt( cutoff_Hz, varargin ) returns lowpass_filter() of gross_power_kW
            val = lowpass_filter(obj.gross_power_kW, obj.time, cutoff_Hz, varargin);
        end
        
        function val = crankshaft_power_kW_filt( obj, cutoff_Hz, varargin )
            % crankshaft_power_kW_filt( cutoff_Hz, varargin ) returns lowpass_filter() of crankshaft_power_kW
            val = lowpass_filter(obj.crankshaft_power_kW, obj.time, cutoff_Hz, varargin);
        end
        
        function val = gross_power_hp_filt( obj, cutoff_Hz, varargin )
            % gross_power_hp_filt( cutoff_Hz, varargin ) returns lowpass_filter() of gross_power_hp
            val = lowpass_filter(obj.gross_power_hp, obj.time, cutoff_Hz, varargin);
        end
        
        function val = crankshaft_power_hp_filt( obj, cutoff_Hz, varargin )
            % crankshaft_power_hp_filt( cutoff_Hz, varargin ) returns lowpass_filter() of crankshaft_power_hp
            val = lowpass_filter(obj.crankshaft_power_hp, obj.time, cutoff_Hz, varargin);
        end
        
        function val = gross_torque_ftlbs_filt( obj, cutoff_Hz, varargin )
            % gross_torque_ftlbs_filt( cutoff_Hz, varargin ) returns lowpass_filter() of gross_torque_ftlbs
            val = lowpass_filter(obj.gross_torque_ftlbs, obj.time, cutoff_Hz, varargin);
        end
        
        function val = crankshaft_torque_ftlbs_filt( obj, cutoff_Hz, varargin )
            % crankshaft_torque_ftlbs_filt( cutoff_Hz, varargin ) returns lowpass_filter() of crankshaft_torque_ftlbs
            val = lowpass_filter(obj.crankshaft_torque_ftlbs, obj.time, cutoff_Hz, varargin);
        end
        
        function val = throttle_pct_filt( obj, cutoff_Hz, varargin )
            % throttle_pct_filt( cutoff_Hz, varargin ) returns lowpass_filter() of throttle_pct
            val = lowpass_filter(obj.throttle_pct, obj.time, cutoff_Hz, varargin);
        end
        
        function val = load_at_current_speed_pct_filt( obj, cutoff_Hz, varargin )
            % load_at_current_speed_pct_filt( cutoff_Hz, varargin ) returns lowpass_filter() of load_at_current_speed_pct
            val = lowpass_filter(obj.load_at_current_speed_pct, obj.time, cutoff_Hz, varargin);
        end
        
        function val = coolant_temp_degF_filt( obj, cutoff_Hz, varargin )
            % coolant_temp_degF_filt( cutoff_Hz, varargin ) returns lowpass_filter() of coolant_temp_degF
            val = lowpass_filter(obj.coolant_temp_degF, obj.time, cutoff_Hz, varargin);
        end
        
        function val = oil_temp_degF_filt( obj, cutoff_Hz, varargin )
            % oil_temp_degF_filt( cutoff_Hz, varargin ) returns lowpass_filter() of oil_temp_degF
            val = lowpass_filter(obj.oil_temp_degF, obj.time, cutoff_Hz, varargin);
        end
        
        function val = efficiency_norm_filt( obj, cutoff_Hz, varargin )
           % efficiency_norm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of efficiency_norm
            val = lowpass_filter(obj.efficiency_norm, obj.time, cutoff_Hz, varargin);
        end
    end
    
end

