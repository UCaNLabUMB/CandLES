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
        %% Constructor
        % *****************************************************************
        % -----------------------------------------------------------------
        function obj = point_source(x,y,z,az,el)
            d_pos = [0, 0, 0]; % Default Position
            d_or  = [0, 0];    % Default Orientation (az, el)
            %FIXME: Error check invalid types (NaN, complex, etc.)
            if (exist('x','var'));  obj.x  = x;  else obj.x  = d_pos(1); end
            if (exist('y','var'));  obj.y  = y;  else obj.y  = d_pos(2); end
            if (exist('z','var'));  obj.z  = z;  else obj.z  = d_pos(3); end
            if (exist('az','var')); obj.az = az; else obj.az =  d_or(1); end
            if (exist('el','var')); obj.el = el; else obj.el =  d_or(2); end
            
            % Convert to degrees for exact calculation using sind and cosd.
            temp_az = (180/pi)*obj.az;
            temp_el = (180/pi)*obj.el;
            % Calculate unit vector for az, el
            obj.x_hat = 1*cosd(temp_el)*cosd(temp_az);
            obj.y_hat = 1*cosd(temp_el)*sind(temp_az);
            obj.z_hat = 1*sind(temp_el);
        end
        
        %% Set property values
        % *****************************************************************
        % Set the X,Y,Z location of the point source object
        % -----------------------------------------------------------------
        function obj = set_location(obj,x,y,z)
            obj.x = x; % Set X location (m)
            obj.y = y; % Set X location (m)
            obj.z = z; % Set X location (m)
        end
        
        % Set the X location of the point source object
        % -----------------------------------------------------------------
        function obj = set_x(obj,x)
            obj.x = x; % Set X location (m)
        end
        
        % Set the Y location of the point source object
        % -----------------------------------------------------------------
        function obj = set_y(obj,y)
            obj.y = y; % Set Y location (m)
        end
        
        % Set the Z location of the point source object
        % -----------------------------------------------------------------
        function obj = set_z(obj,z)
            obj.z = z; % Set Z location (m)
        end
        
        % Set the rotation angles (radians)
        % -----------------------------------------------------------------
        function obj = set_rotation(obj,az,el)
            obj.az = az; % Set Azimuth Angle (rad)
            obj.el = el; % Set Elevation Angle (rad)
            
            % Convert to degrees for exact calculation using sind and cosd.
            az = (180/pi)*az;
            el = (180/pi)*el;
            % Calculate unit vector for az, el
            obj.x_hat = 1*cosd(el)*cosd(az);
            obj.y_hat = 1*cosd(el)*sind(az);
            obj.z_hat = 1*sind(el);
        end
        
        % Set the azimuth of the point source object
        % -----------------------------------------------------------------
        function obj = set_az(obj,az)
            obj.az = az; % Set Azimuth Angle (rad)
            
            % Convert to degrees for exact calculation using sind and cosd.
            az = (180/pi)*az;
            % Calculate unit vector for az, el
            obj.x_hat = 1*cosd(obj.el)*cosd(az);
            obj.y_hat = 1*cosd(obj.el)*sind(az);
            obj.z_hat = 1*sind(obj.el);
        end
        
        % Set the azimuth of the point source object
        % -----------------------------------------------------------------
        function obj = set_el(obj,el)
            obj.el = el; % Set Elevation Angle (rad)
            
            % Convert to degrees for exact calculation using sind and cosd.
            el = (180/pi)*el;
            % Calculate unit vector for az, el
            obj.x_hat = 1*cosd(el)*cosd(obj.az);
            obj.y_hat = 1*cosd(el)*sind(obj.az);
            obj.z_hat = 1*sind(el);
        end
        
        %% Get property values
        % *****************************************************************
        % get azimuth and elevation angles in radians
        % -----------------------------------------------------------------
        function [my_az,my_el] = get_angle_rad(obj)
            my_az = obj.az;
            my_el = obj.el;
        end
        
        % get azimuth and elevation angles in degrees
        % -----------------------------------------------------------------
        function [my_az,my_el] = get_angle_deg(obj)
            my_az = (180/pi)*obj.az;
            my_el = (180/pi)*obj.el;
        end
        
    end
    
end

