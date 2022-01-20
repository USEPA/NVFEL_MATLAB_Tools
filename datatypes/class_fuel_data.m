classdef class_fuel_data
    %class_fuel_data
    %
    %   Universal data structure for fuel data
    
    properties
        time                        % data set time in seconds
        
        density_kgpL_15C            % fuel density in kg / L @ 15C
        energy_density_MJpkg        % fuel energy density in MJ / kg
        gCO2pgal                    % CO2 grams/gallon
        
        flow_rate_ccps              % fuel flow rate in cubic centimeters / sec
        flow_rate_gps               % mass fuel flow rate in grams / sec
        
        volume_cc                   % total fuel flow volume in cubic centimeters
        mass_g                      % total fuel flow mass in grams
        
        temp_degC                   % fuel temperature in degC
                		
        % ------------------ possible future properties ------------------
        % add private mass / volume booleans to help break the circle of doom...
        % make setters for the mass and flow variables and set the flags
        % then check the flags during derived value computations...
        % g -> g/s -> cc/s -> cc -> g... ad infinitum
	end
    
	properties (Hidden )
		mass_data_set = false;
		volume_data_set = false;
	end
	
    properties ( Dependent )
        energy_density_BTUplbm      % fuel energy density in BTU / lb(mass)
        
        flow_rate_galps             % fuel flow rate in gallons / sec
        
        volume_gal                  % total fuel flow volume in gallons
        volume_l                    % total fuel flow volume in liters
        
        temp_degF                   % fuel temperature in degrees Fahrenheit
    end
    
    methods
        %% constructor with fuel data        
        function obj = class_fuel_data ( fuel, time )
            if nargin >= 1
                % assign fuel properties from class_REVS_fuel or similar
                obj.density_kgpL_15C = fuel.density_kgpL_15C;
                obj.energy_density_MJpkg = fuel.energy_density_MJpkg;
                obj.gCO2pgal = fuel.gCO2pgal;
            end
            if nargin >= 2
                % assign time vector
                obj.time = time;
            end
        end
        
        %% getters for Independent properties
        
        function val = get.time( obj )
            if was_provided( obj.time )
                val = obj.time;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.density_kgpL_15C( obj )
            if was_provided( obj.density_kgpL_15C )
                val = obj.density_kgpL_15C;
            else
                val = NaN;
            end
        end
        
        function val = get.energy_density_MJpkg( obj )
            if was_provided( obj.energy_density_MJpkg )
                val = obj.energy_density_MJpkg;
            else
                val = NaN;
            end
        end
        
        function val = get.flow_rate_ccps( obj )
            if was_provided( obj.flow_rate_ccps )
                val = obj.flow_rate_ccps;
            elseif was_provided( obj.volume_cc )
                val = delta( obj.volume_cc, 1) ./ delta( obj.time, 1);
            elseif was_provided( obj.flow_rate_gps ) & was_provided( obj.density_kgpL_15C )
                val = obj.flow_rate_gps / obj.density_kgpL_15C;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.flow_rate_gps( obj )
            if was_provided( obj.flow_rate_gps )
                val = obj.flow_rate_gps;
            elseif was_provided( obj.flow_rate_ccps ) & was_provided( obj.density_kgpL_15C )
                val = obj.flow_rate_ccps * obj.density_kgpL_15C;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.volume_cc( obj )
            if was_provided( obj.volume_cc )
                val = obj.volume_cc;
            elseif was_provided( obj.mass_g ) & was_provided( obj.density_kgpL_15C )
                val = obj.mass_g / obj.density_kgpL_15C;
            elseif was_provided( obj.flow_rate_ccps )
                val = cumtrapz(obj.time, max(0, obj.flow_rate_ccps));
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.mass_g( obj )
            if was_provided( obj.mass_g )
                val = obj.mass_g;
            elseif was_provided( obj.flow_rate_gps )
                val = cumtrapz(obj.time, obj.flow_rate_gps);
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        function val = get.temp_degC( obj )
            if was_provided( obj.temp_degC )
                val = obj.temp_degC;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        %% setters/getters for Dependent properties
        
        function obj = set.energy_density_BTUplbm( obj, val )
            obj.energy_density_MJpkg = unit_convert.BTUplbm2MJpkg * val ;
        end
        
        function val = get.energy_density_BTUplbm( obj )
            val = unit_convert.MJpkg2BTUplbm * obj.energy_density_MJpkg;
        end
        
        function obj = set.flow_rate_galps( obj, val )
			obj.volume_data_set = true;
            obj.flow_rate_ccps = unit_convert.gal2cc * val ;
        end
        
        function val = get.flow_rate_galps( obj )
            val = unit_convert.cc2gal * obj.flow_rate_ccps;
        end
        
        function obj = set.volume_gal( obj, val )
			obj.volume_data_set = true;
            obj.volume_cc = unit_convert.gal2cc * val ;
        end
        
        function val = get.volume_gal( obj )
            val = unit_convert.cc2gal * obj.volume_cc;
        end

        function obj = set.volume_l( obj, val )
			obj.volume_data_set = true;
            obj.volume_cc = val * 1000;
        end

        function val = get.volume_l( obj )
            val = obj.volume_cc / 1000;
        end

        function val = get.temp_degF( obj )
            val = unit_convert.degC2degF( obj.temp_degC );
        end
        
        function obj = set.temp_degF( obj, val )
            obj.temp_degC = unit_convert.degC2degF( val );
        end
        
        %% filtering functions

         function val = flow_rate_gps_filt( obj, cutoff_Hz, varargin )
            % flow_rate_gps_filt( cutoff_Hz, varargin ) returns lowpass_filter() of flow_rate_gps
            val = lowpass_filter(obj.flow_rate_gps, obj.time, cutoff_Hz, varargin);
        end

        function val = flow_rate_ccps_filt( obj, cutoff_Hz, varargin )
            % flow_rate_ccps_filt( cutoff_Hz, varargin ) returns lowpass_filter() of flow_rate_ccps
            val = lowpass_filter(obj.flow_rate_ccps, obj.time, cutoff_Hz, varargin);
        end
        
        function val = volume_cc_filt( obj, cutoff_Hz, varargin )
            % volume_cc_filt( cutoff_Hz, varargin ) returns lowpass_filter() of volume_cc
            val = lowpass_filter(obj.volume_cc, obj.time, cutoff_Hz, varargin);
        end
        
        function val = flow_rate_galps_filt( obj, cutoff_Hz, varargin )
            % flow_rate_galps_filt( cutoff_Hz, varargin ) returns lowpass_filter() of flow_rate_galps
            val = lowpass_filter(obj.flow_rate_galps, obj.time, cutoff_Hz, varargin);
        end
        
        function val = volume_gal_filt( obj, cutoff_Hz, varargin )
            % volume_gal_filt( cutoff_Hz, varargin ) returns lowpass_filter() of volume_gal
            val = lowpass_filter(obj.volume_gal, obj.time, cutoff_Hz, varargin);
        end
        
        function val = temp_degC_filt( obj, cutoff_Hz, varargin )
            % oil_temp_degF_filt( cutoff_Hz, varargin ) returns lowpass_filter() of oil_temp_degF
            val = lowpass_filter(obj.temp_degC, obj.time, cutoff_Hz, varargin);
        end
        
        function val = temp_degF_filt( obj, cutoff_Hz, varargin )
            % oil_temp_degF_filt( cutoff_Hz, varargin ) returns lowpass_filter() of oil_temp_degF
            val = lowpass_filter(obj.temp_degF, obj.time, cutoff_Hz, varargin);
        end
    end
    
end

