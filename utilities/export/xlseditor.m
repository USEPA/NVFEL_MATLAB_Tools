classdef xlseditor < handle
	%UNTITLED Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		file;
	end
	
	properties (Hidden)
		excel_obj;
		workbook_obj;
		sheet_obj;
	end
	
	properties (Dependent)
		sheet;
	end
	
	
	methods
		
		function obj = xlseditor( file, read_only )
			if isempty(regexp(file,'^(.:|\\\\|/|~)','once'))
				% path did not start with any of drive name, UNC path or '~'.
				obj.file = [pwd,filesep,file];
			else
				obj.file = file;
			end
						
			if nargin < 2
				read_only = false;
			end
			
			if  read_only && ~exist(obj.file,'file')
				error('Unable to locate input file. File creation disabled in read only mode.');
			end
			
			[~,~,ext] = fileparts(obj.file);
			
			obj.excel_obj = actxserver('Excel.Application');
			
			%set(obj.excel_obj,'Visible',0);
			
			if ~exist(obj.file,'file')
				temp_workbook = obj.excel_obj.workbook.Add;
				switch ext
					case '.xlsb' %xlExcel12
						xlFormat = 50;
					case '.xlsx' %xlOpenXMLWorkbook
						xlFormat = 51;
					case '.xlsm' %xlOpenXMLWorkbookMacroEnabled
						xlFormat = 52;
					otherwise %.xls - xlExcel8 or xlWorkbookNormal
						xlFormat = -4143;
				end
				temp_workbook.SaveAs(obj.file, xlFormat);
				temp_workbook.Close(false);
				
			end
			
			obj.workbook_obj = obj.excel_obj.Workbook.Open(obj.file, 0, read_only);
			obj.sheet_obj = obj.workbook_obj.Sheet.Item(1);
			
			% Disable popups & user confirmation dialods
			obj.excel_obj.DisplayAlerts = false;
			
		end
		
		
		function close( obj, save )
			if nargin >1 && save
				obj.workbook_obj.Save;
            end
            
            while ~ obj.workbook_obj.Saved
                pause(0.1)
                disp('P')
            end
            
			obj.workbook_obj.Close(false);
			
			delete(obj.excel_obj);
			
		end
		
		function save(obj)
			obj.workbook_obj.Save;
		end
		
		function [names] = get_sheets(obj)
			names = cell(1,obj.workbook_obj.Sheets.Count);
			for idx = 1:numel(names)
				names{idx} = obj.workbook_obj.Sheets.Item(idx).Name;
			end
			
		end
		
		
		function change_sheet(obj, sheet_name)
			obj.sheet_obj = obj.workbook_obj.Sheet.Item(sheet_name);
			invoke(obj.sheet_obj,'Activate');
		end
		
		function add_sheet(obj, sheet, location)
			% Add new worksheet
			
			% Get list of sheets
			sheet_list = obj.workbook_obj.Sheet;
			
			if nargin < 3
				% add worksheet to end
				last_sheet = sheet_list.Item(sheet_list.Count);
				new_sheet = sheet_list.Add([],last_sheet);
				
			elseif isnumeric(location) && sheet_list.Count < location - 1
				new_sheet = sheet_list.Item(sheet_list.Count);
				while sheet_list.Count <  location
					new_sheet = sheet_list.Add([],new_sheet);
				end
			elseif isnumeric(location)
				prev_sheet = sheet_list.Item(location);
				new_sheet = sheet_list.Add([],prev_sheet);
			else
				prev_sheet = sheet_list.Item(location);
				new_sheet = sheet_list.Add([],prev_sheet);
			end
			
			set(new_sheet,'Name',sheet);
			obj.sheet_obj = new_sheet;
			new_sheet.Activate;
		end
		
		function delete_sheet(obj, sheet_name)
			
			if nargin > 1
				obj.workbook_obj.Sheet.Item(sheet_name).Delete;
			else
				obj.sheet_obj.Delete;
				obj.sheet_obj = obj.workbook_obj.ActiveSheet;
			end
			
		end
		
		function [data] = read(obj, range, varargin)
            
			if nargin < 2 || isempty(range)
				xls_range = get(obj.sheet_obj,'UsedRange');
			else
				xls_range = get(obj.sheet_obj,'Range',range);
			end
			
			data = get( xls_range,'Value');
            
		end
		
% 		function [tbl] = read_table( obj, range, varargin )
% 		
%             
%             
%             name_type = parse_varargs( varargin,'VariableNames','name','char',{'name','description','none'});
% 			unit_type = parse_varargs( varargin,'VariableUnits','auto','char',{'auto','line','append','none'});
% 			descrip_comment = parse_varargs( varargin,'DescriptionComment',false ,'bool');
% 			write_rows = parse_varargs( varargin,'RowNames','line','char',{'line','none'});
% 			write_transpose = parse_varargs( varargin,'Transpose',false,'bool',{'scalar'});
% 
%     
%             
%             
%             
% 			if nargin < 2 || isempty(range)
% 				xls_range = get(obj.sheet_obj,'UsedRange');
% 			else
% 				xls_range = get(obj.sheet_obj,'Range',range);
% 			end
% 
% 			
% 			
% 			
% 			
% 		end
		
		function write_table( obj, tbl, range, varargin )
			
			name_type = parse_varargs( varargin,'VariableNames','name','char',{'name','description','none'});
			unit_type = parse_varargs( varargin,'VariableUnits','auto','char',{'auto','line','append','none'});
			descrip_comment = parse_varargs( varargin,'DescriptionComment',false ,'bool');
			write_rows = parse_varargs( varargin,'RowNames','line','char',{'line','none'});
			write_transpose = parse_varargs( varargin,'Transpose',false,'bool',{'scalar'});
			
			
			header = cell(0,width(tbl));
			
			% Handle Variable "Names" /  "Descriptions" for Column Headings
			if strcmpi( name_type, 'name')
				header(1,:) = tbl.Properties.VariableNames;
			elseif strcmpi( name_type, 'description') && isempty( tbl.Properties.VariableDescriptions)
				warning('The provided table does not contain variable descriptions, falling back to variable names.');
				header(1,:) = tbl.Properties.VariableNames;
			elseif strcmpi( name_type, 'description')
				header(1,:) = tbl.Properties.VariableDescriptions;
				missing = cellfun(@isempty, tbl.Properties.VariableDescriptions);
				if any(missing)
					warning('The provided table is missing variable descriptions for some columns, falling back to variable names.');
					header(missing) = tbl.Properties.VariableNames(missing);
				end
			end
			
			
			% Handle Variable "Units"
			if strcmpi(unit_type,'append') && ~isempty(  tbl.Properties.VariableUnits)
				has_units = ~cellfun(@isempty,  tbl.Properties.VariableUnits );
				header(1,has_units) = strcat( header(1,has_units), ' (', tbl.Properties.VariableUnits(has_units), ')');
			elseif strcmpi(unit_type,'line') && isempty( tbl.Properties.VariableUnits )
				header(2,:) = {''};
			elseif  strcmpi(unit_type,'line')
				header(2,:) = tbl.Properties.VariableUnits;
			elseif strcmpi( unit_type,'auto') && ~isempty(tbl.Properties.VariableUnits )
				header(2,:) = tbl.Properties.VariableUnits;
			end
			
			merge_cell = [header ; table2cell(tbl)];
			
			if ~isempty( tbl.Properties.RowNames) && strcmpi( write_rows,'line')
				merge_cell = [[cell(size(header,1),1);tbl.Properties.RowNames],merge_cell];
				cmnt_offset = 1;
			else
				cmnt_offset = 0;
			end
			
			
			
			if isempty(strfind(range,':'))
				% Range was partly specified or not at all. Calculate range.
				[h,w] = size(merge_cell);
				range = xlseditor.calcrange(range,h,w);
			end
			
			xls_range = get(obj.sheet_obj,'Range',range);
			
			if write_transpose
				set( xls_range,'Value',merge_cell');
			else
				set( xls_range,'Value',merge_cell);
			end
			

			
			if descrip_comment
				[head_col,head_row,range_width,range_height] = xlseditor.range2idx(range);		
				cmnt_col_idx = 1;
				cmnt_row_idx = 1;
				cmnt_tbl_idx = 1;
				cmnt_col_offset = ~write_transpose * cmnt_offset;
				cmnt_row_offset = write_transpose * cmnt_offset;
				
				while cmnt_col_idx < width(tbl) && cmnt_row_idx < height(tbl) && ...
					cmnt_col_idx < range_width - cmnt_col_offset && cmnt_row_idx < range_height - cmnt_row_offset 
					
					if ~isempty(tbl.Properties.VariableDescriptions{cmnt_tbl_idx})
						cmnt_addr = xlseditor.idx2range(head_col-1+cmnt_col_idx+cmnt_offset, head_row-1+ cmnt_row_idx*cmnt_row_offset ,1,1);
						cmnt_range = get(obj.sheet_obj,'Range',cmnt_addr);
						cmnt_range.AddComment(tbl.Properties.VariableDescriptions{cmnt_tbl_idx});
					end
					
					cmnt_tbl_idx = cmnt_tbl_idx + 1;
					cmnt_col_idx = cmnt_col_idx + ~write_transpose;
					cmnt_row_idx = cmnt_row_idx + write_transpose;
				end
			end
		end
		
		
		function write( obj, data, range, varargin)
			
			if isempty(data)
				%Nothin to do...
				return
			end
			
			if isempty(strfind(range,':'))
				% Range was partly specified or not at all. Calculate range.
				[h,w] = size(data);
				range = xlseditor.calcrange(range,h,w);
			end
			
			xls_range = get(obj.sheet_obj,'Range',range);
			
			set( xls_range,'Value',data)
			
		end
			
		
		function format( obj, range, varargin)
			
			
			
			horiz_align =parse_varargs( varargin, 'HorizAlign', '', 'char',{'General','Left','Center','Right','Fill','Justify','CenterAcrossSelection','Distributed'});
			vert_align = parse_varargs( varargin, 'VertAlign',	'', 'char', {'Top','Center','Bottom','Justify','Distributed'});
			text_orient	= parse_varargs( varargin, 'TextOrientation',	[], 'numeric',{'>=', -360,'<=',360});
			bg_color	= parse_varargs( varargin, 'Color',	[], 'numeric', {'vector','numel',3,'>=',0,'<=',1});
			
			border_style  = parse_varargs( varargin, 'LineStyle', '', 'char',{'Continuous','Dashed','DashDot','DashDotDot','Dotted','Double','None','SlantDashDot'});
			border_outer_style  = parse_varargs( varargin, 'OuterLineStyle', '', 'char',{'Continuous','Dashed','DashDot','DashDotDot','Dotted','Double','None','SlantDashDot'});
			border_color	= parse_varargs( varargin, 'BorderColor',	[], 'numeric', {'vector','numel',3,'>=',0,'<=',1});
			
			wrap_text	= parse_varargs( varargin, 'WrapText',	[], 'bool');
			merge_cell	= parse_varargs( varargin, 'MergeCells',	[], 'bool');
			
			font_name	= parse_varargs( varargin, 'Font',		'', 'char');
			font_size	= parse_varargs( varargin, 'FontSize',	[], 'numeric');
			font_color	= parse_varargs( varargin, 'FontColor',	[], 'numeric', {'vector','numel',3,'>=',0,'<=',1});
			font_bold	= parse_varargs( varargin, 'FontBold',	[], 'bool');
			font_italic	= parse_varargs( varargin, 'FontItalic',[], 'bool');
			font_strike = parse_varargs( varargin, 'FontStrikethrough',[], 'bool');
			font_super	= parse_varargs( varargin, 'FontSuperscript',[], 'bool');
			font_sub	= parse_varargs( varargin, 'FontSubscript',[], 'bool');
			
			num_format	= parse_varargs( varargin, 'NumberFormat','', 'char');
			
			row_height	= parse_varargs( varargin, 'RowHeight',	[], 'numeric');
			col_width	= parse_varargs( varargin, 'ColWidth',	[], 'numeric');
			
			autofit_cols = parse_varargs( varargin, 'AutoFitCols',0, 'toggle');
			autofit_rows = parse_varargs( varargin, 'AutoFitRows',0, 'toggle');
			freeze_pane = parse_varargs( varargin, 'FreezePane',0, 'toggle');
			
			
			
			if strcmpi(range,'all')
				obj.excel_obj.Cells.Select;
			else
				ExRange = get(obj.excel_obj.Activesheet,'Range',range);
				ExRange.Select;
			end
			
			
			if ~isempty( merge_cell )
				obj.excel_obj.Selection.MergeCells = merge_cell;
			end
			
			if ~isempty( horiz_align )
				xlseditor.set_prop( obj.excel_obj.Selection,'HorizontalAlignment', horiz_align, {'General',1;'Left',-4131;'Center',-4108;'Right',-4152;'Fill',5;'Justify',-4130;'CenterAcrossSelection',7;'Distributed',-4117} );
			end
			
			if ~isempty( vert_align )
				xlseditor.set_prop( obj.excel_obj.Selection,'VerticalAlignment', vert_align, {'Top',-4160;'Center',-4108;'Bottom',-4107;'Justify',-4130;'Distributed',-4117;});
			end
			
			if ~isempty( border_style )
				xlseditor.set_prop( obj.excel_obj.Selection.Borders,'LineStyle',border_style, {'Continuous',1;'Dashed',-4115;'DashDot',4;'DashDotDot',5;'Dotted',-4118;'Double',-4119;'None',-4142;'SlantDashDot',13} );
			end
			
			if ~isempty( border_outer_style )
				xlseditor.set_prop( obj.excel_obj.Selection.Borders.Item(7),'LineStyle',border_outer_style, {'Continuous',1;'Dashed',-4115;'DashDot',4;'DashDotDot',5;'Dotted',-4118;'Double',-4119;'None',-4142;'SlantDashDot',13} );
				xlseditor.set_prop( obj.excel_obj.Selection.Borders.Item(8),'LineStyle',border_outer_style, {'Continuous',1;'Dashed',-4115;'DashDot',4;'DashDotDot',5;'Dotted',-4118;'Double',-4119;'None',-4142;'SlantDashDot',13} );
				xlseditor.set_prop( obj.excel_obj.Selection.Borders.Item(9),'LineStyle',border_outer_style, {'Continuous',1;'Dashed',-4115;'DashDot',4;'DashDotDot',5;'Dotted',-4118;'Double',-4119;'None',-4142;'SlantDashDot',13} );
				xlseditor.set_prop( obj.excel_obj.Selection.Borders.Item(10),'LineStyle',border_outer_style, {'Continuous',1;'Dashed',-4115;'DashDot',4;'DashDotDot',5;'Dotted',-4118;'Double',-4119;'None',-4142;'SlantDashDot',13} );
			end
			
			if ~isempty( border_color )
				obj.excel_obj.Selection.Borders.Color = xlseditor.convert_color(border_color);
			end
			
			if ~isempty(bg_color )
				 obj.excel_obj.Selection.Interior.Color = xlseditor.convert_color(bg_color);
			end
			
			if ~isempty( wrap_text )
				obj.excel_obj.Selection.WrapText = wrap_text;
			end
			
			if ~isempty( text_orient )
				 obj.excel_obj.Selection.Orientation = text_orient;
			end
			
			% Set Font Options
			if ~isempty(font_name )
				obj.excel_obj.Selection.Font.Name = font_name;
			end
			
			if ~isempty(  font_size )
				obj.excel_obj.Selection.Font.Size = font_size;
			end
			
			if ~isempty( font_bold )
				obj.excel_obj.Selection.Font.Bold = font_bold;
			end
			
			if ~isempty( font_italic )
				obj.excel_obj.Selection.Font.Italic = font_italic;
			end
			
			if ~isempty( font_strike )
				obj.excel_obj.Selection.Font.Strikethrough = font_strike;
			end
			
			if ~isempty( font_super)
				obj.excel_obj.Selection.Font.Superscript = font_super;
			end
			
			if ~isempty( font_sub)
				obj.excel_obj.Selection.Font.Subscript = font_sub;
			end
			
			if ~isempty(font_color )
				obj.excel_obj.Selection.Font.Color = xlseditor.convert_color(font_color);
			end
			
			
			if ~isempty( col_width )
				obj.excel_obj.Selection.Columns.ColumnWidth = col_width;
			end
			
			if ~isempty( row_height )
				 obj.excel_obj.Selection.Rows.RowHeight = row_height;
			end
			
			if ~isempty( num_format )		
				obj.excel_obj.Selection.NumberFormat = num_format;
			end
			
			
			if freeze_pane
				obj.sheet_obj.Application.ActiveWindow.FreezePanes = true;
			end
			
			
		end
		
		
		function sheet_name = get.sheet(obj)
			sheet_name = obj.sheet_obj.name;
		end
		
	end
	
	methods (Hidden)
		
		function show_excel(obj)
			set(obj.excel_obj,'Visible',1);
		end
		
		function hide_excel(obj)
			set(obj.excel_obj,'Visible',0);
		end
		
	end
	
	methods( Hidden, Static )
		
		function [c,r] = ref2idx(addr)
			
			import matlab.io.spreadsheet.internal.columnLetter;
			import matlab.io.spreadsheet.internal.columnNumber;
			
			col_idx = isletter(addr);
			row_idx = ~col_idx;
			
			r = str2num(addr(row_idx));   % Construct last row as a string.
			c = columnNumber(addr(col_idx)); % Construct last column.
			
		end
		
		function [c,r,w,h] = range2idx(range)
			
			cor = strsplit( range,':' );
			
			if length(cor) <2
				cor{2} = cor{1};
			end
			
			
			[c,r] = xlseditor.ref2idx(cor{1});
			[c2,r2] = xlseditor.ref2idx(cor{2});
			
			w = c2-c+1;
			h = r2-r+1;
			
			if isempty([r,h])
				r = 1;
				h = inf;
			end
			
			if isempty([c,w])
				c = 1;
				w = inf;
			end
			
		end
		
		function range = idx2range( c,r,w,h )
			
			import matlab.io.spreadsheet.internal.columnLetter;
			import matlab.io.spreadsheet.internal.columnNumber;
			
			if c==1 && isinf(w)
				range = sprintf( '%d:%d', r, r+h-1);
			elseif r==1 && isinf(h)
				range = sprintf( '%s:%s', columnLetter(c), columnLetter(c+w-1));
			elseif w==1 && h==1
				range = sprintf('%s%d',columnLetter(c), r);
			else
				range = sprintf('%s%d:%s%d', columnLetter(c), r, columnLetter(c+w-1), r+h-1);
			end
			
		end
		
		function range = calcrange(corner,h,w)
			% Calculate full range, in Excel A1 notation for
			
			import matlab.io.spreadsheet.internal.columnLetter;
			import matlab.io.spreadsheet.internal.columnNumber;
			
			corner = upper(corner);
			col_idx = isletter(corner);
			row_idx = ~col_idx;
			
			% Construct first row.
			if ~any(row_idx)
				row1 = 1; % Default row.
			else
				row1 = str2double(corner(row_idx)); % from range input.
			end
			
			% Construct first column.
			if ~any(col_idx)
				col1 = 'A'; % Default column.
			else
				col1 = corner(col_idx); % from range input.
			end
			
			row2 = row1+h-1;   % Construct last row as a string.
			col2 = columnLetter(columnNumber(col1)+w-1); % Construct last column.
			range = sprintf('%s%d:%s%d',col1, row1,col2, row2);
		end
		
		function corner = getcorner( range)
			
			corner = upper(regexprep( range,':.*',''));
			col_idx = isletter(corner);
			row_idx = ~col_idx;
			
			% Construct first row.
			if ~any(row_idx)
				row1 = 1; % Default row.
			else
				row1 = str2double(corner(row_idx)); % from range input.
			end
			
			% Construct first column.
			if ~any(col_idx)
				col1 = 'A'; % Default column.
			else
				col1 = corner(col_idx); % from range input.
			end
			
			corner = sprintf('%s%d',col1, row1);
		end
		
		function xls_color = convert_color( mat_color)
			
			if isempty( mat_color )
				xls_color = [];
			else
				xls_color = [65536,256,1]*round(255*mat_color(:));
			end
			
		end
		
		function set_prop( obj, prop_str, val, enum_mapping )
			
			if nargin >= 4
				idx = strcmpi( val, enum_mapping(:,1));
				if ~any(idx)
					error('Unable to map to Excel Enumeration');
				end
				val = enum_mapping{idx,2};
			end
			
			set(obj,prop_str,val);
		end
		
	end
	
end

