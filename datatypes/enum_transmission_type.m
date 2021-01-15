classdef enum_transmission_type < Simulink.IntEnumType
% enum_transmission_type
%
% Defines an enumeration of transmission types for use with ALPHA
%

    enumeration
        no_transmission(0)  % no transmission
        automatic(1)        % automatic transmission with two-state torque converter (lock / unlock)
        automatic_3state(2) % automatic transmission with three-state torque converter (lock / unlock / controlled slip)
        manual(3)           % manual transmission
        AMT(4)              % automated manual transmission
        DCT(5)              % dual-clutch transmission
        CVT(6)              % continuously variable transmission
    end
    
end
