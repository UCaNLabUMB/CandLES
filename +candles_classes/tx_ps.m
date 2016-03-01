classdef tx_ps < candles_classes.point_source
    %TX_PS This class extends the point source class for transmitters
    %   Detailed explanation goes here
    
    %% Class Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        Ps     % Transmit Optical Power (W)
        theta  % Semiangle at half power (degrees)
        m      % Transmitter Lambertian Order

        % FIXME - no functionality yet
        net_group = 1;  % TX group for resource allocation
    end
    
    %% Class Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %% Constructor
        % *****************************************************************
        % -----------------------------------------------------------------
        function obj = tx_ps(x,y,z,az,el,Ps,m)
            d_Ps  = 1;           % Default optical power
            d_m   = 1;           % Default Lambertian order
            d_pos = {0.1,0.1,0}; % Default position
            d_az  = 0;           % Default azimuth
            d_el  = 3*pi/2;      % Default elevation

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
            obj.theta = acosd(exp(-log(2)/obj.m));
        end
        
        %% Set property values
        % *****************************************************************
        % Set Transmit Optical Power (W)
        % -----------------------------------------------------------------
        function obj = set_Ps(obj,Ps)
            obj.Ps = Ps;
        end
        
        % Set Transmitter Lambertian Order
        % -----------------------------------------------------------------
        function obj = set_m(obj,m)
            obj.m = m;
            obj.theta = acosd(exp(-log(2)/m));
        end        
        
        % Set Transmitter Semiangle at half power
        % -----------------------------------------------------------------
        function obj = set_theta(obj,theta)
            obj.theta = theta;
            obj.m = -log(2)/log(cosd(theta)); % -ln2/ln(cos(theta))
        end        
    end
    
end

