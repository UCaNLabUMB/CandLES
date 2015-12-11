classdef box
    %BOX This defines a box within the room
    %   Detailed explanation goes here
    
    %% Class Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %% Constructor
        % *****************************************************************
        % -----------------------------------------------------------------
        function obj = box(x,y,z,l,w,h,ref)
            d_pos  = [  0,   0,   0]; % Default Position
            d_size = [0.1, 0.1, 0.1]; % Default Size
            d_ref  = [1,1; 1,1; 1,1]; % Default Reflectivity
            %FIXME: Error check invalid types (NaN, complex, etc.)
            if (exist('x','var')); obj.x      = x; else obj.x      =  d_pos(1); end
            if (exist('y','var')); obj.y      = y; else obj.y      =  d_pos(2); end
            if (exist('z','var')); obj.z      = z; else obj.z      =  d_pos(3); end
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
        % Set the X,Y,Z location of the box
        % -----------------------------------------------------------------
        function obj = set_location(obj,x,y,z)
            obj.x = x; % Set X location (m)
            obj.y = y; % Set X location (m)
            obj.z = z; % Set X location (m)
        end
        
        % Set the X location of the box
        % -----------------------------------------------------------------
        function obj = set_x(obj,x)
            obj.x = x; % Set X location (m)
        end
        
        % Set the Y location of the box
        % -----------------------------------------------------------------
        function obj = set_y(obj,y)
            obj.y = y; % Set Y location (m)
        end
        
        % Set the Z location of the box
        % -----------------------------------------------------------------
        function obj = set_z(obj,z)
            obj.z = z; % Set Z location (m)
        end
        
        % Set the length of the box
        % -----------------------------------------------------------------
        function obj = set_length(obj,length)
            obj.length = length; % Set length (m)
        end
        
        % Set the width of the box
        % -----------------------------------------------------------------
        function obj = set_width(obj,width)
            obj.width = width; % Set width (m)
        end
        
        % Set the height of the box
        % -----------------------------------------------------------------
        function obj = set_height(obj,height)
            obj.height = height; % Set height (m)
        end        
        
        % Set the height of the box
        % -----------------------------------------------------------------
        function [obj,ERR] = set_ref(obj,nsewtb,ref)
            ERR = 0;
            if (isnan(ref)) || (~isreal(ref))
                ERR = -2;
            else
                % FIXME: Add ERR for out of range reflectivity
                ref = max(min(ref,1),0);
                switch nsewtb
                    case 'N'; obj.ref(1,1) = ref;
                    case 'S'; obj.ref(1,2) = ref;
                    case 'E'; obj.ref(2,1) = ref;
                    case 'W'; obj.ref(2,2) = ref;
                    case 'T'; obj.ref(3,1) = ref;
                    case 'B'; obj.ref(3,2) = ref;
                    otherwise
                        ERR = -3;
                end
            end
        end
        
        %% Set property values
        % *****************************************************************
        % Get the planes related to this box
        % -----------------------------------------------------------------
        function plane_list = get_planes(obj)
            plane_list = candles_classes.plane_type.empty;
            
            % North Plane
            plane_list(1) = candles_classes.plane_type(...
                                obj.x, ...
                                obj.y + obj.width, ...
                                obj.z, ...
                                obj.length, ...
                                0, ...
                                obj.height, ...
                                0,1,0, ...
                                obj.ref(1,1) ...
                                );
            % South Plane
            plane_list(2) = candles_classes.plane_type(...
                                obj.x, ...
                                obj.y, ...
                                obj.z, ...
                                obj.length, ...
                                0, ...
                                obj.height, ...
                                0,-1,0, ...
                                obj.ref(1,2) ...
                                );
            % East Plane
            plane_list(3) = candles_classes.plane_type(...
                                obj.x + obj.length, ...
                                obj.y, ...
                                obj.z, ...
                                0, ...
                                obj.width, ...
                                obj.height, ...
                                1,0,0, ...
                                obj.ref(2,1) ...
                                );
            % West Plane
            plane_list(4) = candles_classes.plane_type(...
                                obj.x, ...
                                obj.y, ...
                                obj.z, ...
                                0, ...
                                obj.width, ...
                                obj.height, ...
                                -1,0,0, ...
                                obj.ref(2,2) ...
                                );
            % Top Plane
            plane_list(5) = candles_classes.plane_type(...
                                obj.x, ...
                                obj.y, ...
                                obj.z + obj.height, ...
                                obj.length, ...
                                obj.width, ...
                                0, ...
                                0,0,1, ...
                                obj.ref(3,1) ...
                                );
            % Bottom Plane
            plane_list(6) = candles_classes.plane_type(...
                                obj.x, ...
                                obj.y, ...
                                obj.z, ...
                                obj.length, ...
                                obj.width, ...
                                0, ...
                                0,0,-1, ...
                                obj.ref(3,2) ...
                                );
        end             
    end
end

