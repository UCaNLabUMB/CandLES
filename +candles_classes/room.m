classdef room
    %ROOM This class defines a room within the environent
    %   Detailed explanation goes here
    
    %% Class Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        length    % Room length (m)
        width     % Room width (m)
        height    % Room height (m)
        ref       % Wall reflectivity array [N,S; E,W; T,B]
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
            d_size = [  4,   4,     3]; % Default Size
            d_ref  = [1,1; 1,1; 1,0.5]; % Default Reflectivity
            %FIXME: Error check invalid types (NaN, complex, etc.)
            if (exist('l','var')); obj.length = l; else obj.length = d_size(1); end
            if (exist('w','var')); obj.width  = w; else obj.width  = d_size(2); end
            if (exist('h','var')); obj.height = h; else obj.height = d_size(3); end
            if (exist('ref','var') && isequal(size(ref),[3,2])) 
                % Constrain reflectivities to 0 <= ref <= 1
                obj.ref = max(min(ref,1),0);
            else
                obj.ref = d_ref;
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
                    case 'N'; obj.ref(1,1) = temp;
                    case 'S'; obj.ref(1,2) = temp;
                    case 'E'; obj.ref(2,1) = temp;
                    case 'W'; obj.ref(2,2) = temp;
                    case 'T'; obj.ref(3,1) = temp;
                    case 'B'; obj.ref(3,2) = temp;
                    otherwise
                        ERR = -3;
                end
            end
        end
        
        %% Set property values
        % *****************************************************************
        % Get the planes related to the room
        % -----------------------------------------------------------------
        function plane_list = get_planes(obj, del_s)
            plane_list = candles_classes.plane_type.empty;
            
            % North Plane
            plane_list(1) = candles_classes.plane_type(...
                                0, obj.width, 0, ...
                                obj.length, ...
                                0, ...
                                obj.height, ...
                                0,-1,0, ...
                                obj.ref(1,1), ...
                                del_s);
            % South Plane
            plane_list(2) = candles_classes.plane_type(...
                                0, 0, 0, ...
                                obj.length, ...
                                0, ...
                                obj.height, ...
                                0,1,0, ...
                                obj.ref(1,2), ...
                                del_s);
            % East Plane
            plane_list(3) = candles_classes.plane_type(...
                                obj.length, 0, 0, ...
                                0, ...
                                obj.width, ...
                                obj.height, ...
                                -1,0,0, ...
                                obj.ref(2,1), ...
                                del_s);
            % West Plane
            plane_list(4) = candles_classes.plane_type(...
                                0,0, 0, ...
                                0, ...
                                obj.width, ...
                                obj.height, ...
                                1,0,0, ...
                                obj.ref(2,2), ...
                                del_s);
            % Top Plane
            plane_list(5) = candles_classes.plane_type(...
                                0, 0, obj.height, ...
                                obj.length, ...
                                obj.width, ...
                                0, ...
                                0,0,-1, ...
                                obj.ref(3,1), ...
                                del_s);
            % Bottom Plane
            plane_list(6) = candles_classes.plane_type(...
                                0, 0, 0, ...
                                obj.length, ...
                                obj.width, ...
                                0, ...
                                0,0,1, ...
                                obj.ref(3,2), ...
                                del_s);
        end             
    end
end

