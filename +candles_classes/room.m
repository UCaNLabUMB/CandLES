classdef room
    %ROOM This class defines a room within the environent
    %   Detailed explanation goes here
    
    %% Class Properties
    properties
        length      % Room length (m)
        width       % Room width (m)
        height      % Room height (m)
        ref         % Wall reflectivity array [N,S; E,W; T,B]
                    %   (North,  South)
                    %   ( East,   West)
                    %   (  Top, Bottom)
    end
    
    %% Class Methods
    methods
        %% Constructor
        function obj = room(l,w,h,ref)
            if nargin == 0
                obj.length = 4;
                obj.width  = 4;
                obj.height = 3;
                obj.ref    = [1,1; 1,1; 1,0.5];
                
            elseif nargin == 3
                obj.length = l;
                obj.width  = w;
                obj.height = h;
                obj.ref    = [1,1; 1,1; 1,0.5];
                
            elseif nargin == 4;
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

