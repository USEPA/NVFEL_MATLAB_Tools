classdef class_vehicle_data
    %class_vehicle_data
    %   Universal data structure for vehicle data
    
    properties
        time                        % data set time in seconds
        
        tire_rolling_radius_m       % tire rolling radius in meters
        %        tire_temp_degC              % tire temperature in degrees Celsius
        
        drive_cycle_speed_mps       % target drive cycle speed in meters / sec
        drive_cycle_phase           % target drive cycle phase / "bag"
        drive_cycle_time            % target drive cycle time in seconds
        
        dyno_speed_mps              % dyno speed in meters / sec
        dyno_distance_m             % dyno distance in meters        
        dyno_load_cell_N            % dyno load cell force in Newtons
        dyno_tractive_force_N       % dyno tractive force in Newtons
        
        final_drive_ratio           % final drive ratio
        
        speed_mps                   % vehicle speed in meters / sec
        distance_m                  % vehicle distance travelled in meters
        grade_pct                   % vehicle grade in percent
        
        accel_pedal_norm            % 'gas'/accelerator pedal position, 0..1
        brake_pedal_norm            % brake pedal position, 0..1
        brake_pedal_bool            % brake pedal on/off (on = true)
        PRNDL                       % PRNDL position
        
        wheel_torque_Nm             % torque at the wheels in Newton-meters
        
        halfshaft_torque_Nm         % halfshaft torque in Newton-meters
        DS_halfshaft_torque_Nm      % driver-side halfshaft torque in Newton-meters
        PS_halfshaft_torque_Nm      % passenger-side halfshaft torque in Newton-meters
        
        fuel = class_fuel_data      % vehicle fuel data
        
        halfshaft_power_kW          % halfshaft power in kiloWatts
        wheel_power_kW              % power at the wheels in kiloWatts

        fuel_economy_mpg            % fuel economy in miles per gallon
        
        mass_static_kg              % ETW or static mass in kilograms
        mass_dynamic_kg             % static mass plus equivalent inertia mass in kilograms
        
        mass_curb_kg                % aka curb "weight" in kilograms
        mass_gvw_kg                 % aka gross vehicle "weight" in kilograms
        mass_glider_kg              % mass of rolling chassis, no driveline, in kilograms
        
        coastdown_target_A_N     = 0;      % coastdown target A/F0 term in Newtons
        coastdown_target_B_Npms  = 0;      % coastdown target B/F1 term in Newtons per meter / second
        coastdown_target_C_Npms2 = 0;      % coastdown target C/F2 term in Newtons per (meter / second)^2

        coastdown_adjust_A_N     = 0;      % coastdown adjust A/F0 term in Newtons
        coastdown_adjust_B_Npms  = 0;      % coastdown adjust B/F1 term in Newtons per meter / second
        coastdown_adjust_C_Npms2 = 0;      % coastdown adjust C/F2 term in Newtons per (meter / second)^2
        
        frontal_area_m2             % vehicle frontal area
        aerodynamic_drag_coeff      % aerodynamic coefficient of drag
        rolling_resistance_coeff    % tire rolling resistance coefficient
        
        % ------------------ possible future properties ------------------

    end
    
    properties ( Dependent )
        drive_cycle_speed_mph       % target drive cycle speed in miles / hour
        
        dyno_speed_mph              % dyno speed in miles / hour
        dyno_load_cell_lbf          % dyno load cell force in pounds (force)
        dyno_tractive_force_lbf     % dyno tractive force in pounds (force)
        
        speed_mph                   % vehicle speed in miles/hour
        distance_mi                 % vehicle distance travelled in miles
        dyno_distance_mi            % dyno distance travelled in miles
        
        speed_kmh                   % vehicle speed in kilometers/hour
        distance_km                 % vehicle distance travelled in kilometers
        
        accel_pedal_pct             % 'gas'/accelerator pedal position in percent
        accel_pedal_bool            % 'gas'/accelerator pedal pedal on/off (on = true)
        
        brake_pedal_pct             % brake pedal position in percent
%         brake_pedal_bool            % brake pedal on/off (on = true)
        
        wheel_speed_radps           % wheel speed in radians/sec
        wheel_speed_rpm             % wheel speed in RPM
        
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
        
        function val = get.tire_rolling_radius_m( obj )
            if was_provided( obj.tire_rolling_radius_m )
                val = obj.tire_rolling_radius_m;
            else
                val = NaN;
            end
        end
        
        function val = get.drive_cycle_speed_mps( obj )
            if was_provided( obj.drive_cycle_speed_mps )
                val = obj.drive_cycle_speed_mps;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.drive_cycle_phase( obj )
            if was_provided( obj.drive_cycle_phase )
                val = obj.drive_cycle_phase;
            else
                val = NaN * ones(size(obj.time));
            end
        end

        function val = get.drive_cycle_time( obj )
            if was_provided( obj.drive_cycle_time )
                val = obj.drive_cycle_time;
            else
                val = obj.time;
            end
        end
        
        function val = get.dyno_speed_mps( obj )
            if was_provided( obj.dyno_speed_mps )
                val = obj.dyno_speed_mps;
            else
                val = NaN * ones(size(obj.time));
            end
        end

        function val = get.dyno_distance_m( obj )
            if was_provided( obj.dyno_distance_m )
                val = obj.dyno_distance_m;
            elseif was_provided( obj.dyno_speed_mps )
                val = cumtrapz(obj.time, obj.dyno_speed_mps);
            else
                val = NaN * ones(size(obj.time));
            end
        end

        function val = get.grade_pct( obj )
            if was_provided( obj.grade_pct )
                val = obj.grade_pct;
            else
                val = NaN * ones(size(obj.time));
            end
        end

        function val = get.dyno_load_cell_N( obj )
            if was_provided( obj.dyno_load_cell_N )
                val = obj.dyno_load_cell_N;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.dyno_tractive_force_N( obj )
            if was_provided( obj.dyno_tractive_force_N )
                val = obj.dyno_tractive_force_N;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.final_drive_ratio( obj )
            if was_provided( obj.final_drive_ratio )
                val = obj.final_drive_ratio;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.speed_mps( obj )
            if was_provided( obj.speed_mps )
                val = obj.speed_mps;
            elseif was_provided( obj.dyno_speed_mps )
                val = obj.dyno_speed_mps;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.distance_m( obj )
            if was_provided( obj.distance_m )
                val = obj.distance_m;
            elseif was_provided( obj.speed_mps)
                val = cumtrapz( obj.time, obj.speed_mps );
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.accel_pedal_norm( obj )
            if was_provided( obj.accel_pedal_norm )
                val = obj.accel_pedal_norm;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.brake_pedal_norm( obj )
            if was_provided( obj.brake_pedal_norm )
                val = obj.brake_pedal_norm;
            else
                val = NaN * ones(size(obj.time));
            end
        end

        function val = get.PRNDL( obj )
            if was_provided( obj.PRNDL )
                val = obj.PRNDL;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.halfshaft_torque_Nm( obj )
            if was_provided( obj.halfshaft_torque_Nm )
                val = obj.halfshaft_torque_Nm;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.wheel_torque_Nm( obj )
            if was_provided( obj.wheel_torque_Nm )
                val = obj.wheel_torque_Nm;
            elseif was_provided( obj.halfshaft_torque_Nm )
                val = obj.halfshaft_torque_Nm;
            elseif was_provided( obj.dyno_tractive_force_N ) & was_provided( obj.tire_rolling_radius_m )
                val = obj.dyno_tractive_force_N * obj.tire_rolling_radius_m;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.DS_halfshaft_torque_Nm( obj )
            if was_provided( obj.DS_halfshaft_torque_Nm )
                val = obj.DS_halfshaft_torque_Nm;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.PS_halfshaft_torque_Nm( obj )
            if was_provided( obj.PS_halfshaft_torque_Nm )
                val = obj.PS_halfshaft_torque_Nm;
            else
                val = NaN * ones(size(obj.time));
            end
        end
          
        function val = get.halfshaft_power_kW( obj )
            if was_provided( obj.halfshaft_power_kW )
                val = obj.halfshaft_power_kW;
            elseif was_provided( obj.halfshaft_torque_Nm ) & was_provided( obj.wheel_speed_radps )
                val = obj.halfshaft_torque_Nm .* obj.wheel_speed_radps / 1000;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.wheel_power_kW( obj )
            if was_provided( obj.wheel_power_kW )
                val = obj.wheel_power_kW;
            elseif was_provided( obj.wheel_torque_Nm ) & was_provided( obj.wheel_speed_radps )
                val = obj.wheel_torque_Nm .* obj.wheel_speed_radps / 1000;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.fuel_economy_mpg( obj )
            if was_provided( obj.fuel_economy_mpg )
                val = obj.fuel_economy_mpg;
            elseif was_provided( obj.dyno_distance_mi ) & was_provided( obj.fuel.volume_gal )
                val = obj.dyno_distance_mi ./ obj.fuel.volume_gal;                
            elseif was_provided( obj.distance_mi ) & was_provided( obj.fuel.volume_gal )
                val = obj.distance_mi ./ obj.fuel.volume_gal;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.brake_pedal_bool( obj )
            if was_provided( obj.brake_pedal_bool )
                val = obj.brake_pedal_bool;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        
        
        %% setters/getters for Dependent properties
        function obj = set.drive_cycle_speed_mph( obj, val )
            obj.drive_cycle_speed_mps = unit_convert.mph2mps * val ;
        end
        
        function val = get.drive_cycle_speed_mph( obj )
            val = unit_convert.mps2mph * obj.drive_cycle_speed_mps;
        end
        
        function obj = set.dyno_speed_mph( obj, val )
            obj.dyno_speed_mps = unit_convert.mph2mps * val ;
        end
        
        function val = get.dyno_speed_mph( obj )
            val = unit_convert.mps2mph * obj.dyno_speed_mps;
        end
        
        function obj = set.dyno_load_cell_lbf( obj, val )
            obj.dyno_load_cell_N = unit_convert.lbf2N * val ;
        end
        
        function val = get.dyno_load_cell_lbf( obj )
            val = unit_convert.N2lbf * obj.dyno_load_cell_N;
        end
        
        function obj = set.dyno_tractive_force_lbf( obj, val )
            obj.dyno_tractive_force_N = unit_convert.lbf2N * val ;
        end
        
        function val = get.dyno_tractive_force_lbf( obj )
            val = unit_convert.N2lbf * obj.dyno_tractive_force_N;
        end
        
        function obj = set.speed_mph( obj, val )
            obj.speed_mps = unit_convert.mph2mps * val ;
        end
        
        function val = get.speed_mph( obj )
            val = unit_convert.mps2mph * obj.speed_mps;
        end
        
        function obj = set.distance_mi( obj, val )
            obj.distance_m = unit_convert.mi2mtr * val ;
        end
        
        function val = get.distance_mi( obj )
            val = unit_convert.mtr2mi * obj.distance_m;
        end

        function obj = set.dyno_distance_mi( obj, val )
            obj.dyno_distance_m = unit_convert.mi2mtr * val ;
        end
        
        function val = get.dyno_distance_mi( obj )
            val = unit_convert.mtr2mi * obj.dyno_distance_m;
        end
        
        function obj = set.speed_kmh( obj, val )
            obj.speed_mps = unit_convert.kmh2mps * val ;
        end
        
        function val = get.speed_kmh( obj )
            val = unit_convert.mps2kmh * obj.speed_mps;
        end
        
        function obj = set.distance_km( obj, val )
            obj.distance_m = val * 1000;
        end
        
        function val = get.distance_km( obj )
            val = obj.distance_m / 1000;
        end
        
        function obj = set.accel_pedal_pct( obj, val )
            obj.accel_pedal_norm = val / 100 ;
        end
        
        function val = get.accel_pedal_pct( obj )
            val = obj.accel_pedal_norm * 100;
        end
        
        function obj = set.accel_pedal_bool( obj, val )
            obj.accel_pedal_norm = (val ~= 0);
        end
        
        function val = get.accel_pedal_bool( obj )
            val = (obj.accel_pedal_norm ~= 0);
        end
        
        function obj = set.brake_pedal_pct( obj, val )
            obj.brake_pedal_norm = val / 100 ;
        end
        
        function val = get.brake_pedal_pct( obj )
            val = obj.brake_pedal_norm * 100;
        end
        
%         function obj = set.brake_pedal_bool( obj, val )
%             obj.brake_pedal_norm = (val ~= 0);
%         end
%         
%         function val = get.brake_pedal_bool( obj )
%             val = (obj.brake_pedal_norm ~= 0);
%         end
        
        function obj = set.wheel_speed_radps( obj, val )
            obj.speed_mps = val * obj.tire_rolling_radius_m;
        end
        
        function val = get.wheel_speed_radps( obj )
            val = obj.speed_mps / obj.tire_rolling_radius_m;
        end
        
        function obj = set.wheel_speed_rpm( obj, val )
            obj.wheel_speed_radps = unit_convert.rpm2radps * val ;
        end
        
        function val = get.wheel_speed_rpm( obj )
            val = unit_convert.radps2rpm * obj.wheel_speed_radps;
        end
        
        %% filtering functions
        function val = speed_mps_filt( obj, cutoff_Hz, varargin )
            % speed_mps_filt( cutoff_Hz, varargin ) returns lowpass_filter() of speed_mps
            val = lowpass_filter(obj.speed_mps, obj.time, cutoff_Hz, varargin);
        end
        
        function val = distance_m_filt( obj, cutoff_Hz, varargin )
            % distance_m_filt( cutoff_Hz, varargin ) returns lowpass_filter() of distance_m
            val = lowpass_filter(obj.distance_m, obj.time, cutoff_Hz, varargin);
        end

        function val = grade_pct_filt( obj, cutoff_Hz, varargin )
            % grade_pct_filt( cutoff_Hz, varargin ) returns lowpass_filter() of grade_pct
            val = lowpass_filter(obj.grade_pct, obj.time, cutoff_Hz, varargin);
        end

        function val = accel_pedal_norm_filt( obj, cutoff_Hz, varargin )
            % accel_pedal_norm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of accel_pedal_norm
            val = lowpass_filter(obj.accel_pedal_norm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = brake_pedal_norm_filt( obj, cutoff_Hz, varargin )
            % brake_pedal_norm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of brake_pedal_norm
            val = lowpass_filter(obj.brake_pedal_norm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = halfshaft_torque_Nm_filt( obj, cutoff_Hz, varargin )
            % halfshaft_torque_Nm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of halfshaft_torque_Nm
            val = lowpass_filter(obj.halfshaft_torque_Nm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = DS_halfshaft_torque_Nm_filt( obj, cutoff_Hz, varargin )
            % DS_halfshaft_torque_Nm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of DS_halfshaft_torque_Nm
            val = lowpass_filter(obj.DS_halfshaft_torque_Nm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = PS_halfshaft_torque_Nm_filt( obj, cutoff_Hz, varargin )
            % PS_halfshaft_torque_Nm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of PS_halfshaft_torque_Nm
            val = lowpass_filter(obj.PS_halfshaft_torque_Nm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = speed_mph_filt( obj, cutoff_Hz, varargin )
            % speed_mph_filt( cutoff_Hz, varargin ) returns lowpass_filter() of speed_mph
            val = lowpass_filter(obj.speed_mph, obj.time, cutoff_Hz, varargin);
        end
        
        function val = distance_mi_filt( obj, cutoff_Hz, varargin )
            % distance_mi_filt( cutoff_Hz, varargin ) returns lowpass_filter() of distance_mi
            val = lowpass_filter(obj.distance_mi, obj.time, cutoff_Hz, varargin);
        end
        
        function val = speed_kmh_filt( obj, cutoff_Hz, varargin )
            % speed_kmh_filt( cutoff_Hz, varargin ) returns lowpass_filter() of speed_kmh
            val = lowpass_filter(obj.speed_kmh, obj.time, cutoff_Hz, varargin);
        end
        
        function val = distance_km_filt( obj, cutoff_Hz, varargin )
            % distance_km_filt( cutoff_Hz, varargin ) returns lowpass_filter() of distance_km
            val = lowpass_filter(obj.distance_km, obj.time, cutoff_Hz, varargin);
        end
        
        function val = accel_pedal_pct_filt( obj, cutoff_Hz, varargin )
            % accel_pedal_pct_filt( cutoff_Hz, varargin ) returns lowpass_filter() of accel_pedal_pct
            val = lowpass_filter(obj.accel_pedal_pct, obj.time, cutoff_Hz, varargin);
        end
        
        function val = accel_pedal_bool_filt( obj, cutoff_Hz, varargin )
            % accel_pedal_bool_filt( cutoff_Hz, varargin ) returns lowpass_filter() of accel_pedal_bool
            val = lowpass_filter(obj.accel_pedal_bool, obj.time, cutoff_Hz, varargin);
        end
        
        function val = brake_pedal_pct_filt( obj, cutoff_Hz, varargin )
            % brake_pedal_pct_filt( cutoff_Hz, varargin ) returns lowpass_filter() of brake_pedal_pct
            val = lowpass_filter(obj.brake_pedal_pct, obj.time, cutoff_Hz, varargin);
        end
        
        function val = brake_pedal_bool_filt( obj, cutoff_Hz, varargin )
            % brake_pedal_bool_filt( cutoff_Hz, varargin ) returns lowpass_filter() of brake_pedal_bool
            val = lowpass_filter(obj.brake_pedal_bool, obj.time, cutoff_Hz, varargin);
        end
        
        function val = wheel_speed_radps_filt( obj, cutoff_Hz, varargin )
            % wheel_speed_radps_filt( cutoff_Hz, varargin ) returns lowpass_filter() of wheel_speed_radps
            val = lowpass_filter(obj.wheel_speed_radps, obj.time, cutoff_Hz, varargin);
        end
        
        function val = wheel_speed_rpm_filt( obj, cutoff_Hz, varargin )
            % wheel_speed_rpm_filt( cutoff_Hz, varargin ) returns lowpass_filter() of wheel_speed_rpm
            val = lowpass_filter(obj.wheel_speed_rpm, obj.time, cutoff_Hz, varargin);
        end
        
        function val = halfshaft_power_kW_filt( obj, cutoff_Hz, varargin )
            % halfshaft_power_kW_filt( cutoff_Hz, varargin ) returns lowpass_filter() of halfshaft_power_kW
            val = lowpass_filter(obj.halfshaft_power_kW, obj.time, cutoff_Hz, varargin);
        end
        
        function val = wheel_power_kW_filt( obj, cutoff_Hz, varargin )
            % wheel_power_kW_filt( cutoff_Hz, varargin ) returns lowpass_filter() of wheel_power_kW
            val = lowpass_filter(obj.wheel_power_kW, obj.time, cutoff_Hz, varargin);
        end
        
    end
    
end

