function [roadload_force_N, roadload_power_kW, roadload_force_lbs, roadload_power_hp] = calc_roadload_abc_N(A_N, B_N, C_N, MPH, varargin)
% [roadload_force_N, roadload_power_kW, roadload_force_lbs, roadload_power_hp] = calc_roadload_abc_N(A_N, B_N, C_N, MPH, varargin)
%
% CALC_ROADLOAD_ABC_N  Calculate roadload force and power given roadload
% coefficients in SI units and a vector of speeds in miles per hour
%
% Parameters:
%   A_N: 'A'/'F0' roadload coefficient, SI units
%   B_N: 'B'/'F1' roadload coefficient, SI units
%   C_N: 'C'/'F2' roadload coefficient, SI units
%   MPH: 
%       vector of vehicle speeds at which to calculate rooadload, in miles per hour
%   varargin (optional keyword and name-value arguments):
%       * 'grade_pct': road grade in percent
%       * 'mass_kg': vehicle mass in kg, for use with ``grade_pct``
%
% Returns:
%   Roadload force and power in SI and SAE units at the given vehicle
%   speeds
%
% Example:
%   Calculate roadload horsepower at 50 mph:
%   
%   ::
%
%       [~,~,~, postproc_results.roadload_50mph_hp] = 
%           calc_roadload_abc_N(vehicle.coastdown_target_A_N, vehicle.coastdown_target_B_Npms, vehicle.coastdown_target_C_Npms2,  50);
%

grade_pct = parse_varargs(varargin, 'grade_pct', 0);
mass_kg   = parse_varargs(varargin, 'mass_kg', 0);

MPS = MPH * unit_convert.mph2mps;

roadload_force_N = A_N + B_N * MPS + C_N * MPS .* MPS + sin(atan(grade_pct/100)) * mass_kg * unit_convert.g;
roadload_power_kW = roadload_force_N .* MPS / 1000;

roadload_force_lbs = roadload_force_N * unit_convert.N2lbf;
roadload_power_hp = roadload_power_kW * unit_convert.kW2hp;
