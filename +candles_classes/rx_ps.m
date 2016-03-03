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
        %% Constructor
        % *****************************************************************
        % -----------------------------------------------------------------
        function obj = rx_ps(x,y,z,az,el,A,FOV,n)
            d_A   = 0.0001;      % Default receiver area
            d_FOV = pi/4;        % Default receiver FOV
            d_n   = 1.5;         % Default contrator refractive index
            d_pos = {0.1,0.1,0}; % Default position
            d_az  = 0;           % Default azimuth
            d_el  = pi/2;        % Default elevation

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

            % Set concentrator gain (n^2/(sin(FOV))^2)
            obj.gc  = (obj.n/sin(obj.FOV))^2;      
        end
        
        %% Set property values
        % *****************************************************************
        % Set Receiver Area (m^2)
        % -----------------------------------------------------------------
        function obj = set_A(obj,A)
            if (A > 0)
                obj.A = A;
            end
        end
        
        % Set Receiver Field of View (rad)
        % -----------------------------------------------------------------
        function obj = set_FOV(obj,FOV)
            if (FOV > 0) && (FOV <= pi/2)
                obj.FOV = FOV;
                obj = obj.set_gc();
            end
        end         
        
        % Set optics refractive index
        % -----------------------------------------------------------------
        function obj = set_n(obj,n)
            if (n > 0)
                obj.n = n;
                obj = obj.set_gc();
            end
        end

        % Set concentrator gain (n^2/(sin(FOV))^2)
        % -----------------------------------------------------------------
        function obj = set_gc(obj)
            obj.gc  = (obj.n/sin(obj.FOV))^2;   
        end
    end
    
end

