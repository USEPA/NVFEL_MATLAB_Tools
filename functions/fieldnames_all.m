function [vars, var_containers] = fieldnames_all(varname_str, varargin)
% [vars, var_containers] = fieldnames_all(varname_str, varargin)
%
% Get names of all fields/subfields of varname_str and a cell array of which
% fields contain other fields
%
% Parameters:
%   varname_str (str): name of variable to get fieldnames of
%   varargin (optional keyword and name-value arguments):
%       * 'sort_fieldnames':
%           sort fieldnames alphabetically
%
% Returns:
%   tuple: string cell array of fieldnames, string cell array of fieldnames
%   that contain futher fieldnames (e.g. structs within structs)
%
% See also: fieldnames
%
% Example::
%
%     >> postproc_results
% 
%     ans = 
% 
%       struct with fields:
% 
%               performance: [1×1 struct]
%          weighted_results: [1×1 struct]
%         roadload_50mph_hp: 11.4486672205998
%
%
%     >> [vars, var_containers] = fieldnames_all('postproc_results')
% 
%     vars =
% 
%       4×1 cell array
% 
%         {'postproc_results.performance.grade_reserve_pct'        }
%         {'postproc_results.weighted_results.combined_GHG_gCO2pmi'}
%         {'postproc_results.weighted_results.load_factor_norm'    }
%         {'postproc_results.roadload_50mph_hp'                    }
% 
% 
%     var_containers =
% 
%       3×1 cell array
% 
%         {'postproc_results'                 }
%         {'postproc_results.performance'     }
%         {'postproc_results.weighted_results'}

sort_fieldnames = parse_varargs(varargin, 'sort_fieldnames', false, 'toggle');

vars = {varname_str};
var_containers = {};

var_list_idx = 1;
while var_list_idx <= length(vars)
    var_current = vars{var_list_idx};
    
    try
        field_names = evalin('caller', ['fieldnames(', var_current, ');'] );
        if sort_fieldnames
            field_names = sort(field_names);
        end
        
        add_fields = strcat(var_current , '.', field_names);
        vars = [{vars{1:var_list_idx}}, add_fields(:)', {vars{(var_list_idx+1):end}}];
        vars(var_list_idx) = []; % Remove Root from list
        var_containers{end+1} = var_current; %#ok<AGROW>
    catch
        var_list_idx = var_list_idx+1;        
    end
end

vars = vars';
var_containers = var_containers';

end

