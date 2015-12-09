classdef tx_ps < candles_classes.point_source
    %TX_PS This class extends the point source class for transmitters
    %   Detailed explanation goes here
    
    %% Class Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        Ps = 1;         % Transmit Optical Power (W)
        m  = 1;         % Transmitter Lambertian Order

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
            % Setup and call superclass constructor
            if nargin == 0
                % Set txs to default to facing down
                my_args = {0.1,0.1,0,0,3*pi/2};
            elseif nargin == 3
                my_args = {x,y,z,0,3*pi/2};
            elseif nargin == 5 || nargin == 7
                my_args = {x,y,z,az,el};
            else
                error('Invalid number of arguments');
            end
            obj@candles_classes.point_source(my_args{:});
            
            % Set Tx power and Lambertian Order if given
            if nargin > 5
                obj.Ps = Ps;    % Set Transmit Optical Power (W)
                obj.m = m;      % Set Transmitter Lambertian Order
            end
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
        end        
    end
    
end

