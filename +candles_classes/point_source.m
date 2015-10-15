classdef point_source
    %POINT_SOURCE Defines a point source location and rotation
    %   Detailed explanation goes here
    
    %% Class Properties
    properties (SetAccess = private)
        x  = 0;         % X location (m)
        y  = 0;         % Y location (m)
        z  = 0;         % Z location (m)
        az = 0;         % Azimuth Angle (rad)
        el = 0;         % Elevation Angle (rad)
        x_hat = 1;      % X value - unit vector for az, el
        y_hat = 0;      % Y value - unit vector for az, el
        z_hat = 0;      % Z value - unit vector for az, el
    end
    
    %% Class Methods
    methods
        %% Constructor
        function obj = point_source(x,y,z,az,el)
            if nargin > 0
                if nargin == 3
                    obj.x = x; % Set X location (m)
                    obj.y = y; % Set X location (m)
                    obj.z = z; % Set X location (m)
                elseif nargin == 5
                    obj.x = x; % Set X location (m)
                    obj.y = y; % Set X location (m)
                    obj.z = z; % Set X location (m)

                    obj.az = az; % Set Azimuth Angle (rad)
                    obj.el = el; % Set Elevation Angle (rad)

                    % Convert to degrees for exact calculation using sind and cosd.
                    az = (180/pi)*az;
                    el = (180/pi)*el;
                    % Calculate unit vector for az, el
                    obj.x_hat = 1*cosd(el)*cosd(az);
                    obj.y_hat = 1*cosd(el)*sind(az);
                    obj.z_hat = 1*sind(el);
                else
                    error('Invalid number of arguments');
                end
            end
        end
        
        %% Set property values
        % Set the X,Y,Z location of the point source object
        function obj = set_location(obj,x,y,z)
            obj.x = x; % Set X location (m)
            obj.y = y; % Set X location (m)
            obj.z = z; % Set X location (m)
        end
        
        % Set the rotation angles (radians)
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
        
        %% Get property values
        % get azimuth and elevation angles in radians
        function [my_az,my_el] = get_angle_rad(obj)
            my_az = obj.az;
            my_el = obj.el;
        end
        
        % get azimuth and elevation angles in degrees
        function [my_az,my_el] = get_angle_deg(obj)
            my_az = (180/pi)*obj.az;
            my_el = (180/pi)*obj.el;
        end
        
    end
    
end

