classdef room
    %ROOM This class defines a room within the environent
    %   Detailed explanation goes here
    
    %% Class Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        length      % Room length (m)
        width       % Room width (m)
        height      % Room height (m)
        ref         % Wall reflectivity array [N,S; E,W; T,B]
                    %   (North,  South)
                    %   ( East,   West)
                    %   (  Top, Bottom)
    end
    
    %% Class Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %% Constructor
        % *****************************************************************
        % -----------------------------------------------------------------
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
        
        %% Set property values
        % *****************************************************************

        % Set the length of the room
        % -----------------------------------------------------------------
        function obj = setLength(obj, temp)
            obj.length = temp;
        end
        
        % Set the width of the room
        % -----------------------------------------------------------------
        function obj = setWidth(obj, temp)
            obj.width  = temp;
        end
        
        % Set the height of the room
        % -----------------------------------------------------------------
        function obj = setHeight(obj, temp)
            obj.height = temp;
        end
        
        % Set Reflectivities of the walls
        % -----------------------------------------------------------------
        % nsewtb indicates north, south, east, west, top, or bottom wall
        % ERR = -2 means invalid value (NaN or complex val)
        %     = -3 means invalid nsewtb selection
        function [obj,ERR] = setRef(obj, nsewtb, temp)
            ERR = 0;
            if (isnan(temp)) || (~isreal(temp))
                ERR = -2;
            else
                % FIXME: Add ERR for out of range reflectivity
                temp = max(min(temp,1),0);
                switch nsewtb
                    case 'N'
                        obj.ref(1,1) = temp;
                    case 'S'
                        obj.ref(1,2) = temp;
                    case 'E'
                        obj.ref(2,1) = temp;
                    case 'W'
                        obj.ref(2,2) = temp;
                    case 'T'
                        obj.ref(3,1) = temp;
                    case 'B'
                        obj.ref(3,2) = temp;
                    otherwise
                        ERR = -3;
                end
            end
        end
        
    end
    
end

