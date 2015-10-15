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
                obj.x = 0;
                obj.y = 0;
                obj.z = 0;
                obj.length = 0.1;
                obj.width  = 0.1;
                obj.height = 0.1;
                obj.ref    = [1,1; 1,1; 1,0.5];
                
            elseif nargin == 3
                obj.x = x;
                obj.y = y;
                obj.z = z;
                obj.length = 0.1;
                obj.width  = 0.1;
                obj.height = 0.1;
                obj.ref    = [1,1; 1,1; 1,0.5];
                
            elseif nargin == 6
                obj.x = x;
                obj.y = y;
                obj.z = z;
                obj.length = l;
                obj.width  = w;
                obj.height = h;
                obj.ref    = [1,1; 1,1; 1,0.5];
                
            elseif nargin == 7;
                obj.length = l;
                obj.width  = w;
                obj.height = h;
                obj.ref    = ref; %FIXME: Error Check for ref!

            else
                error('Invalid number of arguments');
            end
        end
    end
    
end

