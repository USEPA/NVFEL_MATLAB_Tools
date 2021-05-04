function xlsformat(filename,sheetname,ranges, varargin)

horiz_align =parse_varargs( varargin, 'HorizAlign', '', 'char',{'General','Left','Center','Right','Fill','Justify','CenterAcrossSelection','Distributed'});
vert_align = parse_varargs( varargin, 'VertAlign',	'', 'char', {'Top','Center','Bottom','Justify','Distributed'});
text_orient	= parse_varargs( varargin, 'TextOrientation',	[], 'numeric',{'>='-360,'<=',360});
bg_color	= parse_varargs( varargin, 'Color',	[], 'numeric', {'vector','numel',3,'>=',0,'<=',1});
line_style  = parse_varargs( varargin, 'LineStyle', '', 'char',{'Continuous','Dashed','DashDot','DashDotDot','Dotted','Double','None','SlantDashDot'});	

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
if isempty(regexp(filename,'^(.:|\\\\|/|~)','once'))
    % path did not start with any of drive name, UNC path or '~'.
    filename = [pwd,filesep,filename];
end

if ischar(ranges)
	ranges = cellstr(ranges);
end


%% Start Excel & Activate Sheet
Excel = actxserver('Excel.Application');
 set(Excel,'Visible',0);
% ExWorkbook = invoke(Excel, 'load', [fpath filesep file ext]);
ExWorkbook = Excel.Workbooks.Open(filename);
ExSheet = ExWorkbook.Sheets.Item(sheetname);
invoke(ExSheet,'Activate');




%% Select Range to Modify
for r = 1:numel(ranges)

	curr_range = ranges{r};
	
if strcmpi(curr_range,'all') 
	Excel.Cells.Select;
else
    ExRange = get(Excel.Activesheet,'Range',curr_range);
    ExRange.Select;
end

set_prop( Excel.Selection,'MergeCells', merge_cell);

set_prop( Excel.Selection,'HorizontalAlignment', horiz_align, {'General',1;'Left',-4131;'Center',-4108;'Right',-4152;'Fill',5;'Justify',-4130;'CenterAcrossSelection',7;'Distributed',-4117} );
set_prop( Excel.Selection,'VerticalAlignment', vert_align, {'Top',-4160;'Center',-4108;'Bottom',-4107;'Justify',-4130;'Distributed',-4117;});

set_prop( Excel.Selection.Interior,'Color', convert_color(bg_color));

set_prop( Excel.Selection.Borders,'LineStyle',line_style, {'Continuous',1;'Dashed',-4115;'DashDot',4;'DashDotDot',5;'Dotted',-4118;'Double',-4119;'None',-4142;'SlantDashDot',13} );


set_prop( Excel.Selection,'WrapText', wrap_text);
set_prop( Excel.Selection,'Orientation',text_orient);

set_prop( Excel.Selection.Font,'Name', font_name);
set_prop( Excel.Selection.Font,'Size', font_size);
set_prop( Excel.Selection.Font,'Bold', font_bold);
set_prop( Excel.Selection.Font,'Italic', font_italic);
set_prop( Excel.Selection.Font,'Strikethrough', font_strike);
set_prop( Excel.Selection.Font,'Superscript', font_super);
set_prop( Excel.Selection.Font,'Subscript', font_sub);
set_prop( Excel.Selection.Font,'Color', convert_color(font_color));		

set_prop( Excel.Selection.Columns,'ColumnWidth', col_width);	
set_prop( Excel.Selection.Rows,'RowHeight', row_height);	


set_prop( Excel.Selection,'NumberFormat', num_format);		


if autofit_cols
	Excel.Selection.Columns.AutoFit;
end

if autofit_rows
	Excel.Selection.Rows.AutoFit;
end

end

invoke(ExWorkbook, 'Save');
invoke(Excel, 'Quit');
delete(Excel);

end

function h_color = convert_color( m_color)
if isempty( m_color )
	h_color = [];
else
	h_color = [65536,256,1]*round(255*m_color(:));
end
	
end

function set_prop( obj, prop_str, val, enum_mapping )

if isempty(val)
	return;
end

if nargin >= 4
	idx = strcmpi( val, enum_mapping(:,1));
	if ~any(idx)
		error('Unable to map to Excel Enumeration');
	end
	val = enum_mapping{idx,2};
end

set(obj,prop_str,val);

end

