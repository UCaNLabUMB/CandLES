function [ grid ] = SYS_grid_cell_locs( C_x, C_y, N_x, N_y, d, grid_or_cell )
%SYS_GRID_CELL_LOCS Generate X / Y locations
%   Detailed explanation goes here

    if (grid_or_cell == 1)
    %% Grid Layout
        % X Locations
        if (mod(N_x,2) == 1)
            x = (-((N_x-1)/2):((N_x-1)/2))*d;
        else
            x = (-(N_x-1):2:(N_x-1))*(d/2);
        end

        % Y Locations
        if (mod(N_y,2) == 1)
            y = (-((N_y-1)/2):((N_y-1)/2))*d;
        else
            y = (-(N_y-1):2:(N_y-1))*(d/2);
        end

        % Reshape Results
        [X, Y] = meshgrid(x, y);
        grid(1,:) = reshape(X,1,N_x*N_y) + C_x;
        grid(2,:) = reshape(Y,1,N_x*N_y) + C_y;
        
    else
    %% Cellular Layout
        d_v = sqrt(d^2 - (d/2)^2); % Y separation to maintain d between all points

        % X Locations
        if (grid_or_cell ==2)
            % Narrow / Wide layout
            N_x2 = N_x+1; 
        elseif (grid_or_cell == 3)
            % Wide / Narrow layout
            N_x2 = N_x-1;
        end
        x1 = (-(N_x-1):2:(N_x-1))*(d/2);
        x2 = (-(N_x2-1):2:(N_x2-1))*(d/2);

        % Y Locations
        if (mod(N_y,2) == 0)
            % Even Y
            grid(1,:) = repmat([x1 x2], 1, N_y/2);
            y_locs = (-(N_y-1):2:(N_y-1))*(d_v/2);
        else
            % Odd Y 
            grid(1,:) = [repmat([x1 x2], 1, (N_y-1)/2) x1];
            y_locs = (-(N_y-1):2:(N_y-1))*(d_v/2);
        end

        % FIXME: Probably a cleaner way to do this... 
        stop = 0;
        for i=1:N_y
            start = stop+1;
            stop  = start-1 + (mod(i,2))*(N_x) + (~mod(i,2))*(N_x2);
            grid(2,start:stop) = y_locs(i);
        end
        
        grid(1,:) = grid(1,:) + C_x;
        grid(2,:) = grid(2,:) + C_y;
    end
end

