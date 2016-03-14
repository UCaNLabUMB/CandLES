classdef plane_type
    %PLANE_TYPE Defines a single plane of a box or room
    %   Detailed explanation goes here
    
    %% Class Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        x           % X position (m)
        y           % Y position (m)
        z           % Z position (m)    
        length      % Box length (m)
        width       % Box width  (m)
        height      % Box height (m)
        num_div_l   % Number of divisions (length)
        num_div_w   % Number of divisions (width)
        num_div_h   % Number of divisions (height)
        x_hat       % X direction
        y_hat       % Y direction
        z_hat       % Z direction    
        ref         % Surface reflectivity (0<=ref<=1)
    end
    
    %% Class Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %% ****************************************************************
        % -----------------------------------------------------------------
        function obj = plane_type(x,y,z,l,w,h,xh,yh,zh,ref,res)
        % Constructor
            d_pos   = [  0,   0, 0]; % Default position
            d_size  = [0.1, 0.1, 0]; % Default size
            d_dir   = [  0,   0, 1]; % Default reflection direction 
            d_ref   =             1; % Default reflectivity
            d_res   =           0.5; % Default spatial resolution (m)
            
            %FIXME: Error check invalid types (NaN, complex, etc.)
            if (exist('x','var'));   obj.x      = x;   else obj.x      =  d_pos(1); end
            if (exist('y','var'));   obj.y      = y;   else obj.y      =  d_pos(2); end
            if (exist('z','var'));   obj.z      = z;   else obj.z      =  d_pos(3); end
            if (exist('l','var'));   obj.length = l;   else obj.length = d_size(1); end
            if (exist('w','var'));   obj.width  = w;   else obj.width  = d_size(2); end
            if (exist('h','var'));   obj.height = h;   else obj.height = d_size(3); end
            if (exist('xh','var'));  obj.x_hat  = xh;  else obj.x_hat  =  d_dir(1); end
            if (exist('yh','var'));  obj.y_hat  = yh;  else obj.y_hat  =  d_dir(2); end
            if (exist('zh','var'));  obj.z_hat  = zh;  else obj.z_hat  =  d_dir(3); end
            if (exist('ref','var')); obj.ref    = ref; else obj.ref    =     d_ref; end
            if (~exist('res','var'));    res    = d_res; end
            
            obj.num_div_l = ceil(obj.length/res);
            obj.num_div_w = ceil(obj.width/res);
            obj.num_div_h = ceil(obj.height/res);
        end
    end
    
end

