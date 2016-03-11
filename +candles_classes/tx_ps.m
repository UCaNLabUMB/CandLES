classdef tx_ps < candles_classes.point_source
    %TX_PS This class extends the point source class for transmitters
    %   Detailed explanation goes here
    
    %% Class Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        Ps     % Transmit Optical Power (W)
        theta  % Semiangle at half power (degrees)
        m      % Transmitter Lambertian Order

        ng     % TX network group for resource allocation
    end
    
    %% Class Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %% Constructor
        % *****************************************************************
        % -----------------------------------------------------------------
        function obj = tx_ps(x,y,z,az,el,Ps,m,ng)
            %Initialize the global constants in C
            global C
            if (~exist('C.VER','var') || (C.VER ~= SYS_version))
                SYS_define_constants();
            end
            
            d_pos = num2cell(C.D_TX_POS);  % Default position
            d_az  = C.D_TX_AZ;   % Default azimuth
            d_el  = C.D_TX_EL;   % Default elevation
            d_Ps  = C.D_TX_PS;   % Default optical power
            d_m   = C.D_TX_M;    % Default Lambertian order
            d_ng  = C.D_TX_NG;   % Default Network Group

            % Setup and call superclass constructor
            if (nargin == 0); my_args = [    d_pos(1:3), {d_az,d_el}]; end
            if (nargin == 1); my_args = [x,  d_pos(2:3), {d_az,d_el}]; end
            if (nargin == 2); my_args = [x, y, d_pos(3), {d_az,d_el}]; end
            if (nargin == 3); my_args = [       x, y, z, {d_az,d_el}]; end
            if (nargin == 4); my_args = {       x, y, z,    az, d_el}; end
            if (nargin >= 5); my_args = {       x, y, z,    az,   el}; end
            obj@candles_classes.point_source(my_args{:});
            
            % Set Tx power and Lambertian Order if given
            if (exist('Ps','var')); obj.Ps = Ps; else obj.Ps = d_Ps; end
            if (exist( 'm','var')); obj.m  =  m; else obj.m  =  d_m; end
            if (exist('ng','var')); obj.ng = ng; else obj.ng = d_ng; end
            
            % Set Tx Semiangle for the specified Lambertian Order
            obj = obj.update_theta();            
        end
        
        %% Set property values
        % *****************************************************************
        % Set Transmit Optical Power (W)
        % -----------------------------------------------------------------
        function obj = set_Ps(obj,Ps)
            Ps = max(Ps,0); % Check Bound
            obj.Ps = Ps;
        end
        
        % Set Transmitter Lambertian Order
        % -----------------------------------------------------------------
        function obj = set_m(obj,m)
            if (m > 0)
                obj.m = m;
                obj = obj.update_theta();
            end
        end        
        
        % Set Transmitter Semiangle at half power
        % -----------------------------------------------------------------
        function obj = set_theta(obj,theta)
            if (theta > 0) && (theta < 90)
                obj.theta = theta;
                obj.m = -log(2)/log(cosd(theta)); % -ln2/ln(cos(theta))
            end
        end        
        
        % Update Transmitter Semiangle at half power for the objects m
        % -----------------------------------------------------------------
        function obj = update_theta(obj)
            obj.theta = acosd(exp(-log(2)/obj.m));
        end
        
        % Set Transmitter Network Group
        % -----------------------------------------------------------------
        function obj = set_ng(obj,ng)
            ng = max(ng,0); % Check Bound
            obj.ng = ng;
        end             
    end
    
end

