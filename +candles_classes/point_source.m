classdef point_source
    %POINT_SOURCE Defines a point source location and rotation
    %   Detailed explanation goes here
    
    %% Class Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        x       % X location (m)
        y       % Y location (m)
        z       % Z location (m)
        az      % Azimuth Angle (rad)
        el      % Elevation Angle (rad)
        x_hat   % X value - unit vector for az, el
        y_hat   % Y value - unit vector for az, el
        z_hat   % Z value - unit vector for az, el
    end
    
    %% Class Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %% ****************************************************************
        % -----------------------------------------------------------------
        function obj = point_source(x,y,z,az,el)
        % Constructor
        
            %Initialize the global constants in C
            global C
            if (~exist('C.VER','var') || (C.VER ~= SYS_version))
                SYS_define_constants();
            end
            
            d_pos = C.D_PS_POS; % Default Position
            d_or  = C.D_PS_OR;  % Default Orientation (az, el)
            %FIXME: Error check invalid types (NaN, complex, etc.)
            if (exist('x','var'));  obj.x  = x;  else obj.x  = d_pos(1); end
            if (exist('y','var'));  obj.y  = y;  else obj.y  = d_pos(2); end
            if (exist('z','var'));  obj.z  = z;  else obj.z  = d_pos(3); end
            if (exist('az','var')); obj.az = az; else obj.az =  d_or(1); end
            if (exist('el','var')); obj.el = el; else obj.el =  d_or(2); end
            
            % Set the unit vector for the given az/el
            obj = obj.update_unit_vector();
        end
        
        %% Set property values
        % *****************************************************************
        
        % -----------------------------------------------------------------
        function obj = set_location(obj,x,y,z)
        % Set the X,Y,Z location of the point source object
            obj.x = x; % Set X location (m)
            obj.y = y; % Set X location (m)
            obj.z = z; % Set X location (m)
        end
        
        % -----------------------------------------------------------------
        function obj = set_x(obj,x)
        % Set the X location of the point source object
            obj.x = x; % Set X location (m)
        end
        
        % -----------------------------------------------------------------
        function obj = set_y(obj,y)
        % Set the Y location of the point source object
            obj.y = y; % Set Y location (m)
        end
        
        % -----------------------------------------------------------------
        function obj = set_z(obj,z)
        % Set the Z location of the point source object
            obj.z = z; % Set Z location (m)
        end
        
        % -----------------------------------------------------------------
        function obj = set_rotation(obj,az,el)
        % Set the rotation angles (radians)
            obj.az = az; % Set Azimuth Angle (rad)
            obj.el = el; % Set Elevation Angle (rad)
            
            % Set the unit vector for the given az/el
            obj = obj.update_unit_vector();
        end
        
        % -----------------------------------------------------------------
        function obj = set_unit_vector(obj,x,y,z)
        % Set the unit vector and associated rotation angles (radians)
            % Calculate unit vector
            obj.x_hat = x/sqrt(x^2 + y^2 + z^2);
            obj.y_hat = y/sqrt(x^2 + y^2 + z^2);
            obj.z_hat = z/sqrt(x^2 + y^2 + z^2);
            
            obj.el = asin(obj.z_hat);
            obj.az = atan2(obj.y_hat,obj.x_hat);
            
            % Check to put az and el between 0 and 2pi for consistency
            if(obj.el < 0); obj.el = obj.el + 2*pi; end
            if(obj.az < 0); obj.az = obj.az + 2*pi; end

        end
        
        % -----------------------------------------------------------------
        function obj = update_unit_vector(obj)
        % Update the unit vector for the objects rotation angles
            % Convert to degrees for exact calculation using sind and cosd.
            my_az = (180/pi)*obj.az;
            my_el = (180/pi)*obj.el;
            % Calculate unit vector for az, el
            obj.x_hat = 1*cosd(my_el)*cosd(my_az);
            obj.y_hat = 1*cosd(my_el)*sind(my_az);
            obj.z_hat = 1*sind(my_el);
        end
        
        % -----------------------------------------------------------------
        function obj = set_az(obj,az)
        % Set the azimuth of the point source object (radians)
            az = max(min(az,2*pi),0); % Confirm 0 <= az <= 2pi
            obj.az = az; % Set Azimuth Angle (rad)
            
            % Convert to degrees for exact calculation using sind and cosd.
            my_az = (180/pi)*az;
            my_el = (180/pi)*obj.el;
            
            % Calculate unit vector for az, el
            obj.x_hat = 1*cosd(my_el)*cosd(my_az);
            obj.y_hat = 1*cosd(my_el)*sind(my_az);
            obj.z_hat = 1*sind(my_el);
        end
        
        % -----------------------------------------------------------------
        function obj = set_el(obj,el)
        % Set the elevation of the point source object (radians)
            el = max(min(el,2*pi),0); % Confirm 0 <= el <= 2pi
            obj.el = el; % Set Elevation Angle (rad)
            
            % Convert to degrees for exact calculation using sind and cosd.
            my_el = (180/pi)*el;
            my_az = (180/pi)*obj.az;

            % Calculate unit vector for az, el
            obj.x_hat = 1*cosd(my_el)*cosd(my_az);
            obj.y_hat = 1*cosd(my_el)*sind(my_az);
            obj.z_hat = 1*sind(my_el);
        end
        
        %% Get property values
        % *****************************************************************
        
        % -----------------------------------------------------------------
        function [my_az,my_el] = get_angle_rad(obj)
        % get azimuth and elevation angles in radians
            my_az = obj.az;
            my_el = obj.el;
        end
        
        % -----------------------------------------------------------------
        function [my_az,my_el] = get_angle_deg(obj)
        % get azimuth and elevation angles in degrees
            my_az = (180/pi)*obj.az;
            my_el = (180/pi)*obj.el;
        end
        
    end
    
end

