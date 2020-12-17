function [roadload_force_N, roadload_power_kW, roadload_force_lbs, roadload_power_hp] = calc_roadload_abc_N(A_N, B_N, C_N, MPH, varargin)
% CALC_ROADLOAD_ABC_N  Calculate roadload force and power given roadload
% coefficients in SI units and a vector of speeds in miles per hour
%
%   Example
%       [roadload_force_N roadload_power_kW roadload_force_lbs roadload_power_hp] = 
%           calc_roadload_abc_N(A_N, B_N, C_N, MPH, varargin)
%
%   CALC_ROADLOAD_ABC_N(..., 'grade_pct', grade_pct, 'mass_kg', mass_kg) 
%   calculates roadload with the given road grade in % and vehicle mass in
%   kg

    grade_pct = parse_varargs(varargin, 'grade_pct', 0);
    mass_kg   = parse_varargs(varargin, 'mass_kg', 0);

    MPS = MPH * unit_convert.mph2mps;
    
    roadload_force_N = A_N + B_N * MPS + C_N * MPS .* MPS + sin(atan(grade_pct/100)) * mass_kg * unit_convert.g;
    roadload_power_kW = roadload_force_N .* MPS / 1000;
    
    roadload_force_lbs = roadload_force_N * unit_convert.N2lbf;
    roadload_power_hp = roadload_power_kW * unit_convert.kW2hp;
