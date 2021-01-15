classdef class_test_data
    %class_test_data
    %   Top-level universal data structure for vehicle test data or simulation data
    %   (vehicle, engine, transmission, etc)
    
    properties
        time                                            % data set time in seconds
        
        vehicle             = class_vehicle_data        % vehicle data
        accessory           = class_accessory_data      % accessory data
        engine              = class_engine_data         % engine data
        transmission        = class_transmission_data   % transmission data
        propulsion_battery  = class_battery_data;       % propulsion battery for EVs or HEVs
        emachine            = class_emachine_data;      % for electric machines (motors/generators)
    end
    
    properties ( Dependent )
    end
    
    methods
        function obj = class_test_data( time_vector )
			obj.time                    = time_vector;
            
            obj.engine.time             = time_vector;
            obj.engine.fuel.time        = time_vector;
            
            obj.vehicle.time            = time_vector;
            obj.vehicle.fuel.time       = time_vector;
            
            obj.transmission.time       = time_vector;
            
            obj.accessory.time          = time_vector;
            obj.accessory.battery.time  = time_vector;
            
            obj.propulsion_battery.time = time_vector;
            
            obj.emachine.time           = time_vector;
		end
    end
    
end

