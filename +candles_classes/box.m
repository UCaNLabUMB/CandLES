classdef box
    %BOX This defines a box within the room
    %   Detailed explanation goes here
    
    %% Class Properties
    properties
        x           % X position (m)
        y           % Y position (m)
        z           % Z position (m)
        length      % Box length (m)
        width       % Box width (m)
        height      % Box height (m)
        ref         % Surface reflectivity array [N,S; E,W; T,B]
                    %   (North,  South)
                    %   ( East,   West)
                    %   (  Top, Bottom)
    end
    
    %% Class Methods
    methods
        %% Constructor
        function obj = box(x,y,z,l,w,h,ref)
            if nargin == 0
                obj.x      = 0;
                obj.y      = 0;
                obj.z      = 0;
                obj.length = 0.1;
                obj.width  = 0.1;
                obj.height = 0.1;
                obj.ref    = [1,1; 1,1; 1,1];
                
            elseif nargin == 3
                obj.x      = x;
                obj.y      = y;
                obj.z      = z;
                obj.length = 0.1;
                obj.width  = 0.1;
                obj.height = 0.1;
                obj.ref    = [1,1; 1,1; 1,1];
                
            elseif nargin == 6
                obj.x      = x;
                obj.y      = y;
                obj.z      = z;
                obj.length = l;
                obj.width  = w;
                obj.height = h;
                obj.ref    = [1,1; 1,1; 1,1];
                
            elseif nargin == 7;
                obj.x      = x;
                obj.y      = y;
                obj.z      = z;
                obj.length = l;
                obj.width  = w;
                obj.height = h;
                obj.ref    = max(min(ref,1),0);

            else
                error('Invalid number of arguments');
            end
        end
        
        %% Set property values
        % Set the X,Y,Z location of the box
        function obj = set_location(obj,x,y,z)
            obj.x = x; % Set X location (m)
            obj.y = y; % Set X location (m)
            obj.z = z; % Set X location (m)
        end
        % Set the X location of the box
        function obj = set_x(obj,x)
            obj.x = x; % Set X location (m)
        end
        % Set the Y location of the box
        function obj = set_y(obj,y)
            obj.y = y; % Set Y location (m)
        end
        % Set the Z location of the box
        function obj = set_z(obj,z)
            obj.z = z; % Set Z location (m)
        end
        
        % Set the length of the box
        function obj = set_length(obj,length)
            obj.length = length; % Set length (m)
        end
        % Set the width of the box
        function obj = set_width(obj,width)
            obj.width = width; % Set width (m)
        end
        % Set the height of the box
        function obj = set_height(obj,height)
            obj.height = height; % Set height (m)
        end        
        
    end
end

