classdef rx_ps < candles_classes.point_source
    %RX_PS This class extends the point source class for receivers
    %   Detailed explanation goes here
    
    %% Class Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        A     % Receiver Area (m^2)
        FOV   % Receiver Field of View (rad)
        n     % Concentrator optics refractive index
        gc    % Concentrator gain (n^2/(sin(FOV))^2)
    end
    
    %% Class Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %% ****************************************************************
        % -----------------------------------------------------------------
        function obj = rx_ps(x,y,z,az,el,A,FOV,n)
        % Constructor

            %Initialize the global constants in C
            global C
            if (~exist('C.VER','var') || (C.VER ~= SYS_version))
                SYS_define_constants();
            end
            
            d_pos = num2cell(C.D_RX_POS);  % Default position
            d_az  = C.D_RX_AZ;   % Default azimuth
            d_el  = C.D_RX_EL;   % Default elevation
            d_A   = C.D_RX_A;    % Default receiver area
            d_FOV = C.D_RX_FOV;  % Default receiver FOV
            d_n   = C.D_RX_N;    % Default contrator refractive index

            % Setup and call superclass constructor
            if (nargin == 0); my_args = [    d_pos(1:3), {d_az,d_el}]; end
            if (nargin == 1); my_args = [x,  d_pos(2:3), {d_az,d_el}]; end
            if (nargin == 2); my_args = [x, y, d_pos(3), {d_az,d_el}]; end
            if (nargin == 3); my_args = [       x, y, z, {d_az,d_el}]; end
            if (nargin == 4); my_args = {       x, y, z,    az, d_el}; end
            if (nargin >= 5); my_args = {       x, y, z,    az,   el}; end
            obj@candles_classes.point_source(my_args{:});
            
            % Set A (m^2), FOV (rad), and n if given
            if (exist(  'A','var'));  obj.A   = A;   else obj.A   =   d_A; end
            if (exist('FOV','var'));  obj.FOV = FOV; else obj.FOV = d_FOV; end
            if (exist(  'n','var'));  obj.n   = n;   else obj.n   =   d_n; end

            % Set concentrator gain
            obj = obj.update_gc();    
        end
        
        %% Set property values
        % *****************************************************************
        
        % -----------------------------------------------------------------
        function obj = set_A(obj,A)
        % Set Receiver Area (m^2)
            if (A > 0); obj.A = A; end
        end
        
        % -----------------------------------------------------------------
        function obj = set_FOV(obj,FOV)
        % Set Receiver Field of View (rad)
            if (FOV > 0) && (FOV <= pi/2)
                obj.FOV = FOV;
                obj = obj.update_gc();
            end
        end         
        
        % -----------------------------------------------------------------
        function obj = set_n(obj,n)
        % Set optics refractive index
            if (n > 0)
                obj.n = n;
                obj = obj.update_gc();
            end
        end

        % -----------------------------------------------------------------
        function obj = update_gc(obj)
        % Set concentrator gain (n^2/(sin(FOV))^2)
            obj.gc  = (obj.n/sin(obj.FOV))^2;   
        end
    end
    
end

