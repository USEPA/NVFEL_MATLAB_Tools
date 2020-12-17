classdef unit_convert
%UNIT_CONVERT - unit conversion class
	
	properties (Constant = true )
		
        g = 9.80665;                % NIST
        
		mi2mtr  = 1609.344;         % NIST
		mtr2mi  = 1 / unit_convert.mi2mtr;
		
		mph2kmh = unit_convert.mi2mtr / 1000;    % by definition
		kmh2mph = 1 / unit_convert.mph2kmh;
		
		mps2kmh = 3.6;              % by definition
		kmh2mps = 1 / unit_convert.mps2kmh;
		
		mps2mph =  3600 / unit_convert.mi2mtr;   % by definition
		mph2mps =  1 / unit_convert.mps2mph;
		
		lbm2kg = 0.453592;			% NIST
		kg2lbm = 1 / unit_convert.lbm2kg;

        hp2W = 745.6999;            % NIST
		W2hp = 1 / unit_convert.hp2W;
        
		hp2kW = unit_convert.hp2W / 1000;    % by definition
		kW2hp = 1 / unit_convert.hp2kW;
		
		kW2W = 1000;                % by definition
		W2kW = 1 / unit_convert.kW2W;
		
		lbf2N = 4.448222;           % NIST
		N2lbf = 1 / unit_convert.lbf2N;
		
		rpm2radps = pi / 30;        % by definition
		radps2rpm = 30 / pi;
		
		ton2lbm  = 2000;            % by definition
		lbm2ton  = 1 / unit_convert.ton2lbm;
		
		lit2gal = 0.2641721;        % NIST
		gal2lit = 1 / unit_convert.lit2gal;

		lit2cc = 1000;              % by definition
		cc2lit = 1 / unit_convert.lit2cc;

        gal2cc = unit_convert.gal2lit * 1000;    % by definition
		cc2gal = 1 / unit_convert.gal2cc;

		galdies2gCO2 = 10180;       % EPA LD GHG rule
		gCO22galdies = 1 / unit_convert.galdies2gCO2;
		
		galgas2gCO2 = 8887;         % EPA LD GHG rule
		gCO22galgas = 1 / unit_convert.galgas2gCO2;
		
		ftlbs2Nm = 1.355818;		% NIST
		Nm2ftlbs = 1 / unit_convert.ftlbs2Nm;
		
		MPa2kPa = 1000;             % by definition
		kPa2MPa = 1 / unit_convert.MPa2kPa;
		
		bar2kPa = 100;              % by definition
		kPa2bar = 1 / unit_convert.bar2kPa;
		
		MPa2bar = 10;               % by definition
		bar2MPa = 1 / unit_convert.MPa2bar;
		
		bar2Pa = 1e5;               % by definition
		Pa2bar = 1 / unit_convert.bar2Pa;
		
		
		psi2kPa = 6.894757;			% NIST
		kPa2psi = 1 / unit_convert.psi2kPa;
		
		psi2bar =  unit_convert.psi2kPa / 100;   % by definition
		bar2psi =  100 / unit_convert.psi2kPa;
        
        BTUplbm2Jpkg = 2326;        % NIST
        Jpkg2BTUplbm = 1 / unit_convert.BTUplbm2Jpkg;
        
		BTUplbm2MJpkg = unit_convert.BTUplbm2Jpkg / 1e6; % by definition
		MJpkg2BTUplbm = 1 / unit_convert.BTUplbm2MJpkg;
				
		in2mm = 25.4                % NIST
		mm2in = 1 / unit_convert.in2mm;
		
		in2cm = unit_convert.in2mm / 10;     % by definition
		cm2in = 1 / unit_convert.in2cm;
		
        in2m = unit_convert.in2mm / 1000;    % by definition
		m2in = 1 / unit_convert.in2m;

        water_density_nominal_gpgal_60F = 3781.8; % 0.99904 = ASTM D 4052 density of water at 60F, grams per cc, rounded
        water_density_gpgal_60F         = 0.99904 / unit_convert.cc2gal; % nominal 3781.8; % 0.99904 = ASTM D 4052 density of water at 60F, grams per cc
        water_density_gpL_60F           = 0.99904 / unit_convert.cc2lit;

        specific_gravity2density_kgpL_60F = unit_convert.water_density_gpL_60F / 1000;   % by definition
        density_kgpL2specific_gravity_60F = 1000 / unit_convert.water_density_gpL_60F;
		
	end
	
	methods(Static)
		
		function degF = degC2degF(val)
			degF = val * 1.8 + 32;      % NIST
		end
		
		function degC = degF2degC(val)
			degC = (val-32) / 1.8;      % NIST
		end
		
		
	end
	
end

