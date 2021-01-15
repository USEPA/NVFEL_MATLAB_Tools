function datagrabber(path, varargin)
% DATAGRABBER	Generic File Importer to Matlab Workspace
%
% DATAGRABBER( PATH ) extracts data contained within the file PATH to the Matlab
% workspace using the column headings as variable names after being sanitized to
% eliminate invalid variable names. DATAGRABBER automatically determines the
% location of data and column headings for variable names and delimiter.  It is capable
% of reading text files ( CSV, TAB, etc. ) or Microsoft Excel types ( XLS & XLSX )
%
% DATAGRABBER has the ability to select or exclude variables for extraction
% using the 'select' and 'exclude' parameters.  Data can also be imported to the
% matlab workspace under a different name with the 'rename' parameter.
%
% DATAGRABBER(PATH , 'PARAM', VALUE) allows for various options to be overridden
% such as specifing the line number of the column headings or the file delimiter.
%
% Parameters:
%   varargin (optional keyword and name-value arguments):
%       * 'select', column cell array of strings
%           Select column headings to import, its value must be a column 
%           cell array of strings. Wildcard * characters are supported.
%
%       * 'exclude', column cell array of strings
%           Select column headings to exclude from importation, its value
%           must be a column cell array of strings. Wildcard * characters
%           are supported.
%
%       * 'rename', 2-column cell array of strings
%           Select column headings to rename during importation, its value
%           must be a 2 column cell array of strings.  The first column being
%           the name in the file and the second being the desired output name.
%           Headings listed in the rename cellarray do not also need to be
%           selected via the ``select`` parameter.
%
%       * 'headerline', numeric
%           Line number of column headings to use for extraction.
%
%       * 'dataline', numeric
%           Line number where data for extraction begins.
%
%       * 'endline', numeric
%           Line number where data extraction ends.
%
%       * 'unitline', numeric
%           Line number where the unit strings are.
%           If specified, it retrieves unit strings and returns a structure
%           where each field is named after a data variable,
%           and its contents is the unit string. Note: if used
%           with the ``structure`` arguement, the unit structure
%           will be a field of the overall output data
%           structure (example: structname.unit.varname = 'unitstring').
%
%       * 'delimiter', str
%           Delimiter character that will be used to separate entries.
%
%       * 'sheet', numeric or string
%           Specify sheet within Excel workbook. It can be a numeric
%           specifier or a string corresponding to the name of the
%           requested worksheet.
%
%       * 'structure'
%           Import the selected data into fields of a Matlab structure
%           in the base workspace.
%
%       * 'quiet'
%           Run without printing status information to the console.
%
% Examples:
%
%   Read file, all data::
%
%       datagrabber('01-20-13_HWFE.txt');
%
%   Read file, certain columns only::
%
%       datagrabber('01-20-13_HWFE.txt', 'select', {'TimeStamp'; 'VSPD_MPH'});
%
%   Read file and rename columns::
%
%       datagrabber('01-20-13_HWFE.txt', 'rename', {'TimeStamp','time'; 'VSPD_MPH','vspeed'});
%
% Todo:
%
%	More cohesive mix between XLS and test sections
%		either an explicit expectation of output when 2 paths merge or
%		better use of sub functions to minimize duplication
%
%	Check more than 1st row for non-numeric text to avoid bad parse
%		or pull all data in as strings then convert
%
%	Better mesh between var_test, var_in, var_out
%		Handle repeated column headings
%		Don't generate new variable names when the user has specified them already
%		Don't generate new variable names when they are not being extracted
%
%	Add support for creating structures via a user provided delimiter
%	character in the headings
%

% Possible Delimiters to Search for
%				Comma   Tab		Semi-colon
delimiters =	{',',   '	',	';'};
xls_raw = {};

dlm             = parse_varargs(varargin, 'delimiter', '', 'char');
head_line       = parse_varargs(varargin, 'headerline', [],'numeric');
data_line       = parse_varargs(varargin, 'dataline', [],'numeric');
end_line        = parse_varargs(varargin, 'endline', [],'numeric');
unit_line       = parse_varargs(varargin, 'unitline', [], 'numeric');
xls_sheet       = parse_varargs(varargin, 'sheet', 1);
structure       = parse_varargs(varargin, 'structure', '', 'char');
%struct_dlm     = parse_varargs(varargin,'structdelimiter','','char');
verbose         = parse_varargs(varargin, 'quiet', true, 'toggle');
vars_select     = parse_varargs(varargin, 'select', {'*'}, 'cell');
vars_rename     = parse_varargs(varargin, 'rename', {}, 'cell', {'ncols',2});
vars_exclude    = parse_varargs(varargin, 'exclude', {}, 'cell');

% Combine renames with the selects
if ~isempty(vars_rename)
    vars_select = unique({vars_select{:} , vars_rename{:,1}})';
else
    vars_select = unique({vars_select{:}})';
end

% Generate string for Output to structure
if ~isempty(structure) && ~isvarname(regexprep(structure,'\([\d:, ]+\)$',''))
    error('The specified structure name is not a valid variable name');
end

if	~isempty(structure)
    evalin('caller',['clear ' structure]);
    structure(end+1) = '.';
end

% Convert Selects to Regular Expressions
% Sanitize the input of non-supported regex special characters
regex_special_char = '(?<!\\)([(){}<>\[\]^$.+?|])';
vars_select = regexprep(vars_select,regex_special_char,'\\$1');
vars_exclude = regexprep(vars_exclude,regex_special_char,'\\$1');
vars_select = strcat('^',strrep(vars_select,'*','.*'),'$');
vars_exclude = strcat('^',strrep(vars_exclude,'*','.*'),'$');

% Use UI get file if no file path is provided
if nargin <1 || isempty(path)
    [f, p] = uigetfile( {...
        '*.txt;*.csv;*.tab;*.log',	'Text Files (*.txt, *.csv, *.tab, *.log)'; ...
        '*.xls;*.xlsx;*.xlsm;',		'Excel Files (*.xls, *.xlsm, *.xlsx)'; ...
        '*.*',						'All Files (*.*)'}, ...
        'Select a file');
    
    if isequal(f,0) || isequal(p,0)
        return
    end
    
    path = fullfile(p,f);
    
end

% Check if Excel File & Extract Using XLSREAD
if regexpi(path,'.*\.xls[mx]?' )
    %% EXCEL HANDLING
    if (verbose)
        disp('Opening Excel File...');
    end
    try
        [~, ~, xls_raw] = xlsread(path,xls_sheet,'','basic');
        % Read var_text to Find Location of Data and Header if not defined
        if isempty(head_line) || isempty(data_line)		% Search for start of data and / or column var_text
            
            if verbose && isempty(data_line)
                disp('Finding Data...');
            end
            
            % Read Lines Until Large Number of Numerals Located
            line = 1;
            while  sum(cellfun('isclass',xls_raw(line,:),'char')) > 0.85 * length(xls_raw(line,:))
                line = line + 1;
            end
            
            % Note data line if not specified
            if isempty(data_line)
                data_line = line;
            end
            
            % If Heading Not specified locate line with the highes mean and median entries
            head_lines = xls_raw(1:(line-1), :);
            if isempty(head_line)
                if verbose
                    disp('Finding Variable Names...');
                end
                [ ~, head_line] = max( mean(cellfun('length',head_lines),2) + median(cellfun('length',head_lines),2) );
            end
            
        end
        
        if verbose
            disp('Parsing Variable Names...');
        end
        var_text = xls_raw(head_line,:);
        if verbose
            disp('Reading Data...');
        end
        data = xls_raw(data_line:end,:);
        if verbose
            disp('Reading Units...');
        end
        unit_strings = xls_raw(unit_line,:);
        
    catch
        error('Unable to read file %s',path);
    end
    
else
    %% CSV, TAB or other delimited text file
    
    try
        % Try to open file
        fid = fopen(path);
        
        % Read var_text to Find Location of Data and Header if not defined
        if isempty(head_line) || isempty(data_line)	|| isempty(unit_line) % Search for start of data and / or column var_text
            
            if verbose && isempty(data_line)
                disp('Finding Data...');
            end
            
            % Read Lines Until Large Number of Numerals Located
            head_lines{1} = fgetl(fid);
            while ~isequal(head_lines{end},-1) && sum( ismember(double(head_lines{end}), [46, 48:57]  )) <= 0.55 * length(  head_lines{end} ) % Data is more than 45 percent numeric text
                head_lines{end+1} = fgetl(fid);
            end
            
            % Note data line if not specified
            if isempty(data_line)
                data_line = length(head_lines);
            end
            
            head_lines = head_lines(1:end-1);
            
            % If Heading Not specified locate longest line with most delimiter characters
            if isempty(head_line)
                if verbose
                    disp('Finding Variable Names...');
                end
                line_len = cellfun('length',head_lines);											% Count Length of Each Line
                line_dlm = sum(ismember( double( char(head_lines)), double(char(delimiters))),2)';	% Count Number of Delimiters on Each Line
                [ ~, head_line] = max( line_len + line_dlm );
            end
            
            
            
            if strcmpi(unit_line,'none')
                unit_line = [];
            elseif isempty( unit_line)
                
                if verbose
                    disp('Finding Units...');
                end
                
                units_found = regexpi( head_lines, '(sec)|(RPM)|(rad)|(kJ)|(kW)|(bool)|(g/s)|(gps)|(Pa)|(Nm)|(hr)|(Volts)|(Amps)|(Hz)|(mph)|counts)');
                units_found = cellfun('length',units_found);
                [ ~, unit_line] = max( units_found );
                
                if unit_line == head_line
                    unit_line = [];
                end
                
            end
            
            
        end
        
        % Jump to Beginning of file
        fseek(fid, 0, 'bof');
        for line = 1:head_line
            var_line = fgetl(fid);
        end
        
        % Read Line of Variable Names
        
        
        % Search for delimiter - if not defined
        if isempty(dlm)
            if verbose
                disp('Finding Delimiter...');
            end
            dlm_count = zeros(length(delimiters),1);
            for i = 1:length(delimiters);
                dlm_count(i) = sum( var_line == delimiters{i});
            end
            [~, dlm_max] = max(dlm_count);
            dlm = delimiters{dlm_max};
        end
        
        
        % Get unit labels
        if ~isempty(unit_line) && ~strcmpi(unit_line,'none')
            fseek(fid, 0, 'bof');
            for loop = 1:unit_line
                unit_strings = fgetl(fid);
            end
            
            unit_strings = textscan(unit_strings,'%q','Delimiter',dlm);
            unit_strings = unit_strings{1};
            % 			unit_strings = strsplit(unit_strings, dlm,'CollapseDelimiters',0);
        end
        
        
        
        
        
        
        if verbose
            disp('Parsing Variable Names...');
        end
        %Parse Header into Cell Array of Strings
        var_text = textscan(var_line,'%q','Delimiter',dlm);
        var_text = var_text{1};
        
        
        %if( fid < 0 )
    catch
        error('Unable to read file %s',path);
    end
end

%Remove any Quotes & Trailing Whitespace
i = 0;
while i<size(var_text,2)
    i=i+1;
    if isnan(var_text{i})
        var_text(i)='';
        %             data(:,i)=[];
        i = i-1;
    end
end
var_text =  regexprep(var_text,'\r\n|\n|\r','');
var_text = strrep(var_text, '"','');
var_text = strtrim(var_text);

%Handle blank columns
blank_varnames = find(strcmpi(var_text,''));
if ~isempty(blank_varnames)
    for i = 1:length(blank_varnames)
        var_text{blank_varnames(i)} = sprintf('column_%d',blank_varnames(i));
        if verbose
            warning('Column %d has no header, storing to %s\n',blank_varnames(i),var_text{blank_varnames(i)});
        end
    end
end

for v = length(var_text):-1:2
    repeat = find(strcmp( var_text{v}, var_text(1:v-1)));
    if ~isempty(repeat)
        var_text{v}  = [var_text{v},'_',int2str(v)];
        for r = repeat(:)'
            var_text{r}  = [var_text{r},'_',int2str(r)];
        end
    end
end


%% Set Up Input and Output Variable Name Lists

var_in = {};
var_out = {};
units_out = {};

for k = 1:length(var_text)
    
    sl = regexp( var_text{k}, vars_select );
    ex = regexp( var_text{k}, vars_exclude );
    
    if any([sl{:}]) && ~any([ex{:}])
        var_in{end+1} =  var_text{k};
        var_out{end+1} =  var_text{k};
        
        if ~isempty(unit_line) && ~strcmpi(unit_line,'none')
            units_out{end+1} = unit_strings{k};
        end
        
        if isempty(vars_rename)
            continue;
        end
        
        match = find(strcmpi(var_text{k},  vars_rename(:,1)),1,'first');
        
        if(  ~isempty(match) )
            var_out{end} = vars_rename{match,2};
        end
    end
    
end

% Read Data From File - For Text Files - If Column wasn't requested read as string
if isempty(xls_raw)
    if verbose
        disp('Reading Data...');
    end
    % Generate Format String to Capture Data
    extract = ismember(var_text, var_in);
    
    format_str = sprintf('%i',extract);
    format_str = strrep(format_str,'0','%s');
    format_str = strrep(format_str,'1','%s');
    fseek(fid,0,'bof');
    data = textscan(fid,format_str,10,'Delimiter',dlm,'headerlines',data_line - 1,'ReturnOnError',false);
    
    for c = length(extract):-1:1
        test = data{c};
        if isempty( test )
            error('Unable to read file %s',path);
        end
        
        r = 0;
        while r < length(test) && extract(c) > 0
            r = r+1;
            entry = test{r};
            if ~isempty( entry ) && ~is_numeric_text(entry)
                extract(c) = 0;
            end
        end
    end
    
    % try to read all data
    format_str = sprintf('%i',extract);
    format_str = strrep(format_str,'0','%s');
    format_str = strrep(format_str,'1','%f');
    
    fseek(fid,0,'bof');
    
    if isempty(end_line)
        data = textscan(fid,format_str,'Delimiter',dlm,'headerlines',data_line - 1,'ReturnOnError',false, 'treatAsEmpty',{'#CATCH#'});
    else
        data = textscan(fid,format_str,end_line - data_line + 1, 'Delimiter',dlm,'headerlines',data_line - 1,'ReturnOnError',false, 'treatAsEmpty',{'#CATCH#'});
    end
    
    fclose(fid);
end

% Clean up Output Variable Name
var_out = strrep(var_out, '''','');
var_out = strrep(var_out, '"','');
var_out = strrep(var_out, ' ','_');
var_out = strrep(var_out, '(','');
var_out = strrep(var_out, ')','');
var_out = strrep(var_out, ',','');
var_out = strrep(var_out, '%','pct');
var_out = strrep(var_out, '$','');
var_out = strrep(var_out, '+','');
var_out = strrep(var_out, '-','');
var_out = strrep(var_out, '&','');
var_out = strrep(var_out, '/','_');
var_out = strrep(var_out, '\','_');
var_out = strrep(var_out, '*','');
var_out = strrep(var_out, '#','');
var_out = strrep(var_out, '@','at');
var_out = strrep(var_out, ':','_');
var_out = strrep(var_out, '[','');
var_out = strrep(var_out, ']','');
var_out = strrep(var_out, '.','_'); % might goof up structable vars...
var_out = strrep(var_out, '?','');
var_out = strrep(var_out, '!','');

% Split into Variables & Write to Workspace
if verbose
    disp('Parsing Data...');
end

for i = 1:length(var_text)
    
    [tf, idx ] = ismember(var_text{i}, var_in);
    
    if tf
        % Write to Worksapce as Variable
        if isnumeric(data{1,i})
            assignin('caller','DATAGRABBER_TEMP',cat(1,data{:,i}));
        else
            % Vertically Concatenate String Data
            %				assignin('caller','DATAGRABBER_TEMP',char(data{:,i}));  % bring in non-numerics as char vectors
            assignin('caller','DATAGRABBER_TEMP',data{:,i});        % bring in non-numerics as cell arrays of strings
        end
        
        try
            evalin('caller',[structure var_out{idx} ' = DATAGRABBER_TEMP;']);
        catch
            warning('Bad column unable to output %s, storing data to %s',[structure var_out{idx}], [structure 'column_' int2str(i) ]);
            evalin('caller',[structure 'column_' int2str(i) ' = DATAGRABBER_TEMP;']);
        end
        
    end
    
end

evalin('base','clear DATAGRABBER_TEMP;');

% return unit strings
if ~isempty(unit_line) && ~strcmpi(unit_line,'none')
    for loop = 1:length(var_out)
        units_struct.(var_out{loop}) = units_out{loop};
    end
    assignin('caller', 'units', units_struct);
    if ~isempty(structure)
        evalin('caller', [structure, 'units = units;']);
        evalin('caller', 'clear(''units'');');
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   SUB FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%%%%


% Determine if input string contains only numeric text
function [ tf ] = is_numeric_text( char_array )

num_chars = ['0123456789.+-e'];

%	tf = ~isempty(regexpi( char_array , '^([+-]?(\d+\.\d*)|(\d*\.\d+)|(\d+)e?[+-]?\d*)$','once'));
% 	tf = ~isempty(regexpi( char_array , '^[+-]?((\d+\.?\d*)|(\d*\.?\d+)|(\d+e[+-]?\d*))$','once'));
tf = ~isempty(regexpi( char_array , '^[+-]?((\d+\.?\d*)|(\d*\.?\d+))(e[+-]?\d*)*$','once'));
