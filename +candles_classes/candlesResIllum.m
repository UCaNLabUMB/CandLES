classdef candlesResIllum
    %CANDLESRESILLUM Maintains and displays illumination results
    %   A candlesResIllum object stores illumination results for a CandLES
    %   environment and provides function calls to display the results.
    
    %% Class Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        RESULTS     % Store the results for each plane in RES_PLANES
        RES_PLANES  % Specify plane for each set of stored results
        GRID        % The actual X,Y locations relating to RESULTS
    end
    
    %% External Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %% ****************************************************************
        function obj = candlesResIllum()
        % Constructor 
            obj.RESULTS    = [];
            obj.RES_PLANES = [];
            obj.GRID       = [];
        end
        
        % -----------------------------------------------------------------
        function TorF = results_exist(obj, plane)
        % Returns true if results have already been calculated for PLANE
            TorF = ~(isempty(obj.RES_PLANES) || ...
                     ~any(obj.RES_PLANES == plane));
        end
        
        % -----------------------------------------------------------------
        function obj = set_grid(obj, grid)
            obj.GRID = grid;
        end
        
        % -----------------------------------------------------------------
        function obj = set_results(obj, temp, plane)
        % Add temp to RESULTS and update RES_PLANES
            obj.RESULTS(:,:,length(obj.RES_PLANES)+1) = temp;
            obj.RES_PLANES(length(obj.RES_PLANES)+1)  = plane;
        end
        
        % -----------------------------------------------------------------
        function display_plane(obj, plane, scale_for_maximum, my_ax)
        % Display illumination results of the specified plane to my_ax
            axes(my_ax);
            cla(my_ax,'reset');

            Illum = obj.RESULTS(:,:,obj.RES_PLANES == plane);
            if (max(max(Illum)) > 0)
                if (isempty(obj.GRID))
                    contourf(Illum);
                else
                    x = unique(obj.GRID(1,:));
                    y = unique(obj.GRID(2,:));
                    contourf(x,y,Illum);
                    xlabel('X (m)');
                    ylabel('Y (m)');
                end
                title(['Surface Illumination (Lux) at ' num2str(plane) 'm']);
                view([0 90]);
                if (scale_for_maximum)
                    caxis([0 max(max(max(obj.RESULTS)))]);
                else
                    caxis([0 max(max(Illum))]);
                end
                colorbar;
            else
                cla(my_ax,'reset');
                text(0.38, 0.5, sprintf('No Illumination'), 'Parent', my_ax);
            end
        end
        
        % -----------------------------------------------------------------
        function display_video(obj, scale_for_maximum)
        % Display a video of the available results with each frame showing
        % results of a different plane.
            my_fig = figure();
            my_ax  = axes();
            if isempty(obj.RESULTS)
                cla(my_ax,'reset');
                text(0.27, 0.5, sprintf('Results have not been generated.'), 'Parent', my_ax);
            else
                % Use this to display results video in sorted order of planes
                [~,frame_order] = sort(obj.RES_PLANES); 
                % Generate Video
                F(length(obj.RES_PLANES)) = struct('cdata',[],'colormap',[]);
                for my_frame = 1:length(obj.RES_PLANES)
                    obj.display_plane(obj.RES_PLANES(frame_order(my_frame)), scale_for_maximum, my_ax);
                    F(my_frame) = getframe(gcf);
                end
                
                % Save movie
                YorN = questdlg('Would you like to save the movie?','Save Movie','Yes','No','Yes');
                if (strcmp(YorN,'Yes'))
                    [FileName, PathName] = uiputfile('*.avi');
                    if (FileName ~= 0)
                        v = VideoWriter([PathName FileName]);
                        v.FrameRate = 8;
                        open(v);
                        for my_frame = 1:length(F)
                            writeVideo(v,F(my_frame));
                        end
                        close(v);
                    end                    
                end
                
                %Play Movie in my_fig
                movie(my_fig,F,1);
            end
        end

        % -----------------------------------------------------------------
        function display_cdf(obj, plane, scale_for_maximum, cdf_all, my_ax)
        % Display cdf of results to my_ax
            axes(my_ax);
            cla(my_ax,'reset');

            if (cdf_all)
                % Use this to display results in sorted order of planes
                [~,plane_order] = sort(obj.RES_PLANES); 
                for my_plane = 1:length(obj.RES_PLANES)
                    Illum = obj.RESULTS(:,:,plane_order(my_plane));
                    temp = reshape(Illum,[1,size(Illum,1)*size(Illum,2)]);
                    cdfplot(temp);
                    hold on
                end
                title('CDF of the Surface Illumination at Z m');
            else
                Illum = obj.RESULTS(:,:,obj.RES_PLANES == plane);
                temp = reshape(Illum,[1,size(Illum,1)*size(Illum,2)]);
                cdfplot(temp);
                title(['CDF of the Surface Illumination at ' ...
                         num2str(plane) 'm']);
            end
            xlabel('x (lux)');

            if (scale_for_maximum || cdf_all)
                xlim([0, max(max(max(obj.RESULTS)))]);
            else
                xlim([0, max(max(max(Illum)),1)]);
            end
        end
    end
end

