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
        %% ****************************************************************
        function obj = box(x,y,z,l,w,h,ref)
        % Constructor
            
            %Initialize the global constants in C
            global C
            SYS_define_constants();
            
            d_pos  = C.D_BOX_POS;  % Default Position
            d_size = C.D_BOX_SIZE; % Default Size
            d_ref  = C.D_BOX_REF;  % Default Reflectivity
            %FIXME: Error check invalid types (NaN, complex, etc.)
            if (exist('x','var')); obj.x      = x; else obj.x      =  d_pos(1); end
            if (exist('y','var')); obj.y      = y; else obj.y      =  d_pos(2); end
            if (exist('z','var')); obj.z      = z; else obj.z      =  d_pos(3); end
            if (exist('l','var')); obj.length = l; else obj.length = d_size(1); end
            if (exist('w','var')); obj.width  = w; else obj.width  = d_size(2); end
            if (exist('h','var')); obj.height = h; else obj.height = d_size(3); end
            if (exist('ref','var') && isequal(size(ref),[3,2])) 
                % Constrain reflectivities to 0 <= ref <= 1
                obj.ref = max(min(ref,C.MAX_REF),0);
            else
                obj.ref = d_ref;
            end
        end
        
        %% Set property values
        % *****************************************************************
        
        % -----------------------------------------------------------------
        function obj = set_location(obj,x,y,z)
        % Set the X,Y,Z location of the box
            obj.x = x; % Set X location (m)
            obj.y = y; % Set X location (m)
            obj.z = z; % Set X location (m)
        end
        
        % -----------------------------------------------------------------
        function obj = set_x(obj,x)
        % Set the X location of the box
            obj.x = x; % Set X location (m)
        end
        
        % -----------------------------------------------------------------
        function obj = set_y(obj,y)
        % Set the Y location of the box
            obj.y = y; % Set Y location (m)
        end
        
        % -----------------------------------------------------------------
        function obj = set_z(obj,z)
        % Set the Z location of the box
            obj.z = z; % Set Z location (m)
        end
        
        % -----------------------------------------------------------------
        function obj = set_length(obj,length)
        % Set the length of the box
            global C
            if (length >= C.MIN_BOX_DIM); obj.length = length; end % Set length (m)
        end
        
        % -----------------------------------------------------------------
        function obj = set_width(obj,width)
        % Set the width of the box
            global C
            if (width >= C.MIN_BOX_DIM); obj.width = width; end    % Set width (m)
        end
        
        % -----------------------------------------------------------------
        function obj = set_height(obj,height)
        % Set the height of the box
            global C
            if (height >= C.MIN_BOX_DIM); obj.height = height; end % Set height (m)
        end        
        
        % -----------------------------------------------------------------
        function obj = set_ref(obj,nsewtb,ref)
        % Set the Reflectivity of box surfaces
            global C

            ref = max(min(ref,C.MAX_REF),0);
            switch nsewtb
                case 'ref_N'; obj.ref(1,1) = ref;
                case 'ref_S'; obj.ref(1,2) = ref;
                case 'ref_E'; obj.ref(2,1) = ref;
                case 'ref_W'; obj.ref(2,2) = ref;
                case 'ref_T'; obj.ref(3,1) = ref;
                case 'ref_B'; obj.ref(3,2) = ref;
            end
        end
        
        %% Get property values
        % *****************************************************************
        
        % -----------------------------------------------------------------
        function plane_list = get_planes(obj,del_s)
        % Get the planes related to this box
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
                                obj.ref(1,1), ...
                                del_s);
            % South Plane
            plane_list(2) = candles_classes.plane_type(...
                                obj.x, ...
                                obj.y, ...
                                obj.z, ...
                                obj.length, ...
                                0, ...
                                obj.height, ...
                                0,-1,0, ...
                                obj.ref(1,2), ...
                                del_s);
            % East Plane
            plane_list(3) = candles_classes.plane_type(...
                                obj.x + obj.length, ...
                                obj.y, ...
                                obj.z, ...
                                0, ...
                                obj.width, ...
                                obj.height, ...
                                1,0,0, ...
                                obj.ref(2,1), ...
                                del_s);
            % West Plane
            plane_list(4) = candles_classes.plane_type(...
                                obj.x, ...
                                obj.y, ...
                                obj.z, ...
                                0, ...
                                obj.width, ...
                                obj.height, ...
                                -1,0,0, ...
                                obj.ref(2,2), ...
                                del_s);
            % Top Plane
            plane_list(5) = candles_classes.plane_type(...
                                obj.x, ...
                                obj.y, ...
                                obj.z + obj.height, ...
                                obj.length, ...
                                obj.width, ...
                                0, ...
                                0,0,1, ...
                                obj.ref(3,1), ...
                                del_s);
            % Bottom Plane
            plane_list(6) = candles_classes.plane_type(...
                                obj.x, ...
                                obj.y, ...
                                obj.z, ...
                                obj.length, ...
                                obj.width, ...
                                0, ...
                                0,0,-1, ...
                                obj.ref(3,2), ...
                                del_s);
        end             
    end
end

