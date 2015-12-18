function [ visible ] = VLCIRC_CheckVisibility( src, dest, plane_list )
%VLCIRC_CHECKVISIBILITY Search through planes to see if LOS path exists
%   Search through each of the planes in plane_list to see if the LOS
%   path is blocked between src and dest
    
    visible = 1;
    
    %% Define line from src to dest
    l0 = [ src.x, src.y, src.z];      % Point on the line
    l = l0 - [dest.x,dest.y,dest.z];  % vector pointing from src to dest
    
    %% Check each plane for intersection with line from src to dest
    for plane_no = 1:length(plane_list)
        
        % Get the Normal vector to plane
        n = [plane_list(plane_no).x_hat, ...
             plane_list(plane_no).y_hat, ...
             plane_list(plane_no).z_hat];
        % Get the point on the plane
        p0 = [plane_list(plane_no).x, ...
              plane_list(plane_no).y, ...
              plane_list(plane_no).z];
          
        p1 = [plane_list(plane_no).x + plane_list(plane_no).length, ...
              plane_list(plane_no).y + plane_list(plane_no).width , ...
              plane_list(plane_no).z + plane_list(plane_no).height];          
          
        % Check in line and plane are parallel 
        if (dot(l,n) ~= 0)
            % Line and plane are not Parallel
            % Calculate intersetction point
            intersect = (dot(p0-l0,n)/dot(l,n))*l + l0;
            
            % Determine if intersect is in the spectified section of plane
            %   (Points that are tangent to the section of the plane are 
            %   NOT considered as blocking the LOS)
            % -------------------------------------------------------------
            %   Check for YZ, XZ, and XY planes
            if (((p0(1) == p1(1)) && ...
                 (p0(2) < intersect(2)) && (intersect(2) < p1(2)) && ...
                 (p0(3) < intersect(3)) && (intersect(3) < p1(3))) || ...
                ((p0(1) < intersect(1)) && (intersect(1) < p1(1)) && ...
                 (p0(2) == p1(2)) && ...
                 (p0(3) < intersect(3)) && (intersect(3) < p1(3))) || ...
                ((p0(1) < intersect(1)) && (intersect(1) < p1(1)) && ...
                 (p0(2) < intersect(2)) && (intersect(2) < p1(2)) && ...
                 (p0(3) == p1(3))))
                
                % Determine if the intersection is on the line
                if ((((min(src.x,dest.x) < intersect(1)) && (intersect(1) < max(src.x,dest.x))) || (src.x == dest.x)) && ...
                    (((min(src.y,dest.y) < intersect(2)) && (intersect(2) < max(src.y,dest.y))) || (src.y == dest.y)) && ...
                    (((min(src.z,dest.z) < intersect(3)) && (intersect(3) < max(src.z,dest.z))) || (src.z == dest.z)))
                    visible = 0;
                end
            end

%         else
%             % Line and plane are parallel
%             if (dot(po-lo,n) == 0)
%                 % Line is contained in the plane
%                 % NOTE: CURRENTLY ASSUMING THAT PATH CONTAINED IN THE PLANE
%                 % IS VISIBLE. TO CHANGE THIS, SOMETHING SHOULD BE ADDED
%                 % HERE TO CHECK THAT THE PATH GOES THROUGH THE SPECIFIED
%                 % SECTION OF THE PLANE. THE ABOVE IF STATEMENTS ALSO 
%                 % DON'T CONSIDER TANGENTIAL POINTS AS BLOCKING THE PATH.
%             end
        end
    end
end

