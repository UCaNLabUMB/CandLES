classdef candlesResIllum
    %CANDLESRESILLUM Maintains and displays illumination results
    %   A candlesResIllum object stores illumination results for a CandLES
    %   environment and provides function calls to display the results.
    
    %% Class Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        RESULTS     % Store the results for each plane in RES_PLANES
        RES_PLANES  % Specify plane for each set of stored results
    end
    
    %% External Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %% ****************************************************************
        function obj = candlesResIllum()
        % Constructor 
            obj.RESULTS = [];
            obj.RES_PLANES = [];
        end
        
        % -----------------------------------------------------------------
        function TorF = results_exist(obj, plane)
        % Returns true if results have already been calculated for PLANE
            TorF = ~(isempty(obj.RES_PLANES) || ...
                     ~any(obj.RES_PLANES == plane));
        end
        
        % -----------------------------------------------------------------
        function obj = set_results(obj, temp, plane)
        % Add temp to RESULTS and update RES_PLANES
            obj.RESULTS(:,:,length(obj.RES_PLANES)+1) = temp;
            obj.RES_PLANES(length(obj.RES_PLANES)+1)  = plane;
        end
        
        % -----------------------------------------------------------------
        function display_plane(obj, x, y, plane, my_ax)
        % Display illumination results of the specified plane to my_ax
            Illum = obj.RESULTS(:,:,obj.RES_PLANES == plane);
            
            axes(my_ax);
            if (max(max(Illum)) > 0)
                contourf(x,y,Illum);
                xlabel('X (m)');
                ylabel('Y (m)');
                title(['Surface Illumination (Lux) at ' num2str(plane) 'm']);
                view([0 90]);
                caxis([0 max(max(Illum))]);
                colorbar;
            else
                cla(my_ax,'reset');
                text(0.38, 0.5, sprintf('No Illumination'), 'Parent', my_ax);
            end
        end
        
        % -----------------------------------------------------------------
        function display_cdf(obj, plane, my_ax)
        % Display cdf of results to my_ax
            Illum = obj.RESULTS(:,:,obj.RES_PLANES == plane);

            axes(my_ax);
            temp = reshape(Illum,[1,size(Illum,1)*size(Illum,2)]);
            cdfplot(temp);
%            xlabel('Illuminance (lux)');
%            ylabel('CDF');
            title(['CDF of the Surface Illumination at ' ...
                     num2str(plane) 'm']);
        end
    end
end

