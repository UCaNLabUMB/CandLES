classdef rx_ps < candles_classes.point_source
    %RX_PS This class extends the point source class for receivers
    %   Detailed explanation goes here
    
    %% Class Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        A   = 0.0001;   % Receiver Area (m^2)
        FOV = pi/4;     % Receiver Field of View (rad)
        n   = 1.5;      % Concentrator optics refractive index
        gc  = 4.5;      % Concentrator gain (n^2/(sin(FOV))^2)
    end
    
    %% Class Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %% Constructor
        % *****************************************************************
        % -----------------------------------------------------------------
        function obj = rx_ps(x,y,z,az,el,A,FOV,n)
            % Setup and call superclass constructor
            if nargin == 0
                % Set rxs to default to facing up
                my_args = {0.1,0.1,0,0,pi/2};
            elseif nargin == 3
                my_args = {x,y,z,0,pi/2};
            elseif nargin == 5 || nargin == 8
                my_args = {x,y,z,az,el};
            else
                error('Invalid number of arguments');
            end
            obj@candles_classes.point_source(my_args{:});
            
            % Set A, FOV, and n if given
            if nargin > 5
                obj.A   = A;    % Set Receiver Area (m^2)
                obj.FOV = FOV;  % Set Receiver Field of View (rad)
                obj.n   = n;    % Set optics refractive index
                
                % Set concentrator gain (n^2/(sin(FOV))^2)
                obj.gc  = (n/sin(FOV))^2;      
            end
        end
        
        %% Set property values
        % *****************************************************************
        % Set Receiver Area (m^2)
        % -----------------------------------------------------------------
        function obj = set_A(obj,A)
            obj.A = A;
        end
        
        % Set Receiver Field of View (rad)
        % -----------------------------------------------------------------
        function obj = set_FOV(obj,FOV)
            obj.FOV = FOV;
            
            % Set concentrator gain (n^2/(sin(FOV))^2)
            obj.gc  = (obj.n/sin(FOV))^2;      
        end         
        
        % Set optics refractive index
        % -----------------------------------------------------------------
        function obj = set_n(obj,n)
            obj.n = n;
            
            % Set concentrator gain (n^2/(sin(FOV))^2)
            obj.gc  = (n/sin(obj.FOV))^2;      
        end
        
    end
    
end

