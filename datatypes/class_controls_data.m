classdef class_controls_data
    %class_controls_data
    %
    %   Universal data structure for controls data
    
    properties
        time								% data set time in seconds
        
        charge_sustain_state
        clutch_engage_norm
        engine_on_off_state
        engine_torque_request_Nm
        motor_torque_request_Nm
        regen_flag
        torque_mode
        engine_load_level_state
     

    end
    
    
    
    methods
        function val = get.time( obj )
            if was_provided( obj.time )
                val = obj.time;
            else
                val = NaN * ones(size(obj.time));
            end
        end
        
        
        
    end
    
end

