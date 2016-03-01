classdef candlesEnv
    %CANDLESENV CandLES environment class
    %   A candlesEnv object stores the environment variables for a CandLES
    %   GUI. This includes the room parameters and simulation parameters.
    
    %% Class Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        % GUI Properties
        
        % Simulation Environment Properties
        rm          % Room under analysis
        txs         % Transmitters in the environment
        rxs         % Receivers in the environment
        boxes       % Boxes in the environment
        
        % Tx Group Properties
        Sprime      % Normalized PSD
        lambda      % wavelengths of Sprime
        
        % Simulation Properties
        del_t       % Time resolution (sec)
        del_s       % Spatial resolution of surface (m)
        del_p       % Spatial resolution of simulated plane (m)
        MIN_BOUNCE  % First reflection considered (0 for LOS)
        MAX_BOUNCE  % Last reflection considered
        DISP_WAITBAR = 1;
    end
    
    %% Class Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        % Constructor - Set default values for CandLES here!
        function obj = candlesEnv()
            obj.rm    = candles_classes.room(5,4,3);
            obj.txs   = candles_classes.tx_ps(2.5,2,2.5);
            obj.rxs   = candles_classes.rx_ps(2.5,2,1);
            obj.boxes = candles_classes.box.empty;
            
            % This is a simple base PSD... Update for LEDs to be used
            LAMBDAMIN=200; LAMBDAMAX=1100; DLAMBDA=1;
            obj.lambda=LAMBDAMIN:DLAMBDA:LAMBDAMAX;
            s1=18; m1=450; a1=1; s2=60; m2=555; a2=2.15*a1; s3=25; m3=483; a3=-0.2*a1;
            Sprime = a1/(sqrt(2*pi)*s1)*exp(-(obj.lambda-m1).^2/(2*s1^2)) + ...
                     a2/(sqrt(2*pi)*s2)*exp(-(obj.lambda-m2).^2/(2*s2^2)) + ...
                     a3/(sqrt(2*pi)*s3)*exp(-(obj.lambda-m3).^2/(2*s3^2));
            obj.Sprime=Sprime/sum(Sprime);  %Normalized PSD

            obj.del_t = 1e-10; 
            obj.del_s = 0.25;
            obj.del_p = 0.1;
            obj.MIN_BOUNCE = 0;
            obj.MAX_BOUNCE = 0;
        end
        
        %% Transmitter Functions
        % *****************************************************************
        % Add a new transmitter
        % -----------------------------------------------------------------
        function [obj, TX_NUM] = addTx(obj)
            TX_NUM = length(obj.txs)+1;
            obj.txs(TX_NUM) = candles_classes.tx_ps();
            % FIXME: Check room to make sure the new TX is in room
        end
        
        % Add a specified layout of transmitters. Anything outside the room
        % boundaries gets shifted back within the room.
        %       N_x:  Number of TXs in X direction.
        %       N_y:  Number of TXs in Y direction.
        %         d:  X and Y distance between TXs.
        %   Z_plane:  Location of grid in Z dimension
        %    layout:  (1) Grid (2) Cell1 (3) Cell2
        %   replace:  (0) keep existing TXs (1) replace TXs.
        % -----------------------------------------------------------------
        function [obj, TX_NUM] = addTxGroup(obj, N_x, N_y, d, Z_plane, layout, replace)
            
            % Error check for empty grid
            if (N_x*N_y == 0)
                TX_NUM = 1;
                return
            end
            
            % Remove other transmitters 
            if (replace)
                while (isempty(obj.txs) == 0)
                    obj.txs(1) = [];
                end
            end
            
            % Determine the X and Y locations
            TX_NUM = length(obj.txs);
            my_grid = SYS_grid_cell_locs(obj.rm.length/2, ...
                                         obj.rm.width/2, N_x,N_y,d,layout);
            for new_tx_num = 1:size(my_grid,2)
                my_x = max(min(my_grid(1,new_tx_num),obj.rm.length),0);
                my_y = max(min(my_grid(2,new_tx_num),obj.rm.width),0);
                my_z = max(min(Z_plane,obj.rm.height),0);
                
                obj.txs(TX_NUM+new_tx_num) = ...
                       candles_classes.tx_ps(my_x,my_y,my_z);
            end
            
            % Set TX_NUM to the first TX in the grid
            TX_NUM = TX_NUM+1;
        end
        
        % Remove the specified transmitter
        % -----------------------------------------------------------------
        % ERR = 1 means there's only 1 TX left
        function [obj,ERR] = removeTx(obj, TX_NUM)
            ERR = 1;
            if (length(obj.txs) > 1)
                ERR = 0;
                obj.txs(TX_NUM) = [];
            end
        end
        
        % Set the position of the specified transmitter
        % -----------------------------------------------------------------
        % ERR = -1 means invalid TX_NUM
        %     = -2 means invalid position (NaN or complex val)
        %     = -3 means invalid xyz
        function [obj,ERR] = setTxPos(obj,TX_NUM,xyz,temp)
            ERR = 0;
            if (TX_NUM < 1) || (TX_NUM > length(obj.txs))
                ERR = -1;
            else
                if (isnan(temp)) || (~isreal(temp))
                    ERR = -2;
                else
                    switch xyz
                        case 'x'
                            % FIXME: Add ERR for out of range x, y, or z
                            temp = max(min(temp,obj.rm.length),0);
                            obj.txs(TX_NUM) = obj.txs(TX_NUM).set_x(temp);
                        case 'y'
                            temp = max(min(temp,obj.rm.width),0);
                            obj.txs(TX_NUM) = obj.txs(TX_NUM).set_y(temp);
                        case 'z'
                            temp = max(min(temp,obj.rm.height),0);
                            obj.txs(TX_NUM) = obj.txs(TX_NUM).set_z(temp);
                        case 'az' % Set in degrees
                            temp = max(min(temp,360),0)*(pi/180);
                            obj.txs(TX_NUM) = obj.txs(TX_NUM).set_az(temp);
                        case 'el' % Set in degrees
                            temp = max(min(temp,360),0)*(pi/180);
                            obj.txs(TX_NUM) = obj.txs(TX_NUM).set_el(temp);
                        otherwise
                            ERR = -3;
                    end
                end
            end
        end
        
        %% Receiver Functions
        % *****************************************************************
        % Add a new receiver
        % -----------------------------------------------------------------
        function [obj, RX_NUM] = addRx(obj)
            RX_NUM = length(obj.rxs)+1;
            obj.rxs(RX_NUM) = candles_classes.rx_ps();
            % FIXME: Check room to make sure the new TX is in room
        end
        
        % Remove the specified receiver
        % -----------------------------------------------------------------
        function [obj,ERR] = removeRx(obj, RX_NUM)
            ERR = 1;
            if (length(obj.rxs) > 1)
                ERR = 0;
                obj.rxs(RX_NUM) = [];
            end
        end
        
        % Set the position of the specified receiver
        % -----------------------------------------------------------------
        % ERR = -1 means invalid RX_NUM
        %     = -2 means invalid position (NaN or complex val)
        %     = -3 means invalid xyz
        function [obj,ERR] = setRxPos(obj,RX_NUM,xyz,temp)
            ERR = 0;
            if (RX_NUM < 1) || (RX_NUM > length(obj.rxs))
                ERR = -1;
            else
                if (isnan(temp)) || (~isreal(temp))
                    ERR = -2;
                else
                    switch xyz
                        case 'x'
                            % FIXME: Add ERR for out of range x, y, or z
                            temp = max(min(temp,obj.rm.length),0);
                            obj.rxs(RX_NUM) = obj.rxs(RX_NUM).set_x(temp);
                        case 'y'
                            temp = max(min(temp,obj.rm.width),0);
                            obj.rxs(RX_NUM) = obj.rxs(RX_NUM).set_y(temp);
                        case 'z'
                            temp = max(min(temp,obj.rm.height),0);
                            obj.rxs(RX_NUM) = obj.rxs(RX_NUM).set_z(temp);
                        case 'az' % Set in degrees
                            temp = max(min(temp,360),0)*(pi/180);
                            obj.rxs(RX_NUM) = obj.rxs(RX_NUM).set_az(temp);
                        case 'el' % Set in degrees
                            temp = max(min(temp,360),0)*(pi/180);
                            obj.rxs(RX_NUM) = obj.rxs(RX_NUM).set_el(temp);
                        otherwise
                            ERR = -3;
                    end
                end
            end
        end
        
        %% Box Functions
        % *****************************************************************
        % Add a new box
        % -----------------------------------------------------------------
        function [obj, BOX_NUM] = addBox(obj)
            BOX_NUM = length(obj.boxes)+1;
            obj.boxes(BOX_NUM) = candles_classes.box();
            % FIXME: Check room to make sure the new TX is in room
        end
        
        % Remove the specified box
        % -----------------------------------------------------------------
        function [obj] = removeBox(obj, BOX_NUM)
            if (~isempty(obj.boxes))
                obj.boxes(BOX_NUM) = [];
            end
        end

        % Set the position of the specified box
        % -----------------------------------------------------------------
        % ERR = -1 means invalid BOX_NUM
        %     = -2 means invalid position (NaN or complex val)
        %     = -3 means invalid xyz
        function [obj,ERR] = setBoxPos(obj,BOX_NUM,xyz,temp)
            ERR = 0;
            if (BOX_NUM < 1) || (BOX_NUM > length(obj.boxes))
                ERR = -1;
            else
                if (isnan(temp)) || (~isreal(temp))
                    ERR = -2;
                else
                    switch xyz
                        case 'x'
                            % FIXME: Add ERR for out of range x, y, or z
                            temp = max(min(temp,obj.rm.length ...
                                                - obj.boxes(BOX_NUM).length),0);
                            obj.boxes(BOX_NUM) = obj.boxes(BOX_NUM).set_x(temp);
                        case 'y'
                            temp = max(min(temp,obj.rm.width ...
                                                - obj.boxes(BOX_NUM).width),0);
                            obj.boxes(BOX_NUM) = obj.boxes(BOX_NUM).set_y(temp);
                        case 'z'
                            temp = max(min(temp,obj.rm.height ...
                                                - obj.boxes(BOX_NUM).height),0);
                            obj.boxes(BOX_NUM) = obj.boxes(BOX_NUM).set_z(temp);
                        otherwise
                            ERR = -3;
                    end
                end
            end
        end

        % Set the dimensions of the specified box
        % -----------------------------------------------------------------
        % ERR = -1 means invalid BOX_NUM
        %     = -2 means invalid dimension (NaN or complex val)
        %     = -3 means invalid lwh
        function [obj,ERR] = setBoxDim(obj,BOX_NUM,lwh,temp)
            ERR = 0;
            if (BOX_NUM < 1) || (BOX_NUM > length(obj.boxes))
                ERR = -1;
            else
                if (isnan(temp)) || (~isreal(temp))
                    ERR = -2;
                else
                    switch lwh
                        case 'l'
                            % FIXME: Add ERR for out of range x, y, or z
                            temp = max(min(temp,obj.rm.length ...
                                                - obj.boxes(BOX_NUM).x),0.1);
                            obj.boxes(BOX_NUM) = obj.boxes(BOX_NUM).set_length(temp);
                        case 'w'
                            temp = max(min(temp,obj.rm.width ...
                                                - obj.boxes(BOX_NUM).y),0.1);
                            obj.boxes(BOX_NUM) = obj.boxes(BOX_NUM).set_width(temp);
                        case 'h'
                            temp = max(min(temp,obj.rm.height ...
                                                - obj.boxes(BOX_NUM).z),0.1);
                            obj.boxes(BOX_NUM) = obj.boxes(BOX_NUM).set_height(temp);
                        otherwise
                            ERR = -3;
                    end
                end
            end
        end

        % Set the reflectivities of the specified box
        % -----------------------------------------------------------------
        % ERR = -1 means invalid BOX_NUM
        %     = -2 means invalid ref (NaN or complex val)
        %     = -3 means invalid nsewtb
        function [obj,ERR] = setBoxRef(obj,BOX_NUM,nsewtb,ref)
            if (BOX_NUM < 1) || (BOX_NUM > length(obj.boxes))
                ERR = -1;
            else
                [obj.boxes(BOX_NUM),ERR] = obj.boxes(BOX_NUM).set_ref(nsewtb,ref);
            end
        end
            
        %% Room Functions
        % *****************************************************************
        % Set the dimensions of the room
        % -----------------------------------------------------------------
        % ERR = -2 means invalid value (NaN or complex val)
        %     = -3 means invalid xyz selection
        % Do not make dimensions such that objects are outside the room.
        % FIXME: For now, cap  room length at 10m. For computational speed, 
        % resolution needs to be lowered when increasing room size.
        function [obj,ERR] = setRoomDim(obj,xyz,temp)
            ERR = 0;
            if (isnan(temp)) || (~isreal(temp))
                ERR = -2;
            else
                switch xyz
                    case 'length'
                        % FIXME: Add ERR for out of range x, y, or z
                        [x,~,~] = obj.min_room_dims();
                        temp = max(min(temp,10),x);
                        obj.rm = obj.rm.setLength(temp);
                    case 'width'
                        [~,y,~] = obj.min_room_dims();
                        temp = max(min(temp,10),y);
                        obj.rm = obj.rm.setWidth(temp);
                    case 'height'
                        [~,~,z] = obj.min_room_dims();
                        temp = max(min(temp,10),z);
                        obj.rm = obj.rm.setHeight(temp);
                    otherwise
                        ERR = -3;
                end
            end
        end
        
        % Set the room reflectivities
        % nsewtb indicates north, south, east, west, top, or bottom wall
        % -----------------------------------------------------------------
        function [obj,ERR] = setRoomRef(obj,nsewtb,temp)
            [obj.rm,ERR] = obj.rm.setRef(nsewtb, temp);
        end
        
        % Get the maximum dimensions of boxes, txs, or rxs
        % -----------------------------------------------------------------
        function [min_x,min_y,min_z] = min_room_dims(obj)
            % Minimum bounding box for txs and rxs
            txrx_max_x = max(max([obj.txs.x]),max([obj.rxs.x]));
            txrx_max_y = max(max([obj.txs.y]),max([obj.rxs.y]));
            txrx_max_z = max(max([obj.txs.z]),max([obj.rxs.z]));

            if (isempty(obj.boxes))
                min_x = txrx_max_x;
                min_y = txrx_max_y;
                min_z = txrx_max_z;

            else
                % Minimum bounding box for boxes
                box_max_x = max(max([obj.boxes.x] + [obj.boxes.length]));
                box_max_y = max(max([obj.boxes.y] + [obj.boxes.width]));
                box_max_z = max(max([obj.boxes.z] + [obj.boxes.height]));

                % Minimum room dimensions to containt txs, rxs, and boxes
                min_x = max(txrx_max_x, box_max_x);
                min_y = max(txrx_max_y, box_max_y);
                min_z = max(txrx_max_z, box_max_z);
            end   
        end
        
        %% Environment Simulation Setting Functions
        % *****************************************************************
        % Set the time resolution
        % -----------------------------------------------------------------
        function [obj,ERR] = setDelT(obj,temp)
            ERR = 0;
            if (isnan(temp)) || (~isreal(temp))
                ERR = -2;
            else
                obj.del_t = temp;
            end
        end

        % Set the spatial resolution of the simulation surfaces
        % -----------------------------------------------------------------
        function [obj,ERR] = setDelS(obj,temp)
            ERR = 0;
            if (isnan(temp)) || (~isreal(temp))
                ERR = -2;
            else
                obj.del_s = temp;
            end
        end
        
        % Set the spatial resolution of the simulation plane
        % -----------------------------------------------------------------
        function [obj,ERR] = setDelP(obj,temp)
            ERR = 0;
            if (isnan(temp)) || (~isreal(temp))
                ERR = -2;
            else
                obj.del_p = temp;
            end
        end
        
        % Set the Min and Max number of reflections (i.e., bounces)
        % -----------------------------------------------------------------
        function [obj,ERR] = setBounces(obj,temp1,temp2)
            ERR = 0;
            if (isnan(temp1)) || (~isreal(temp1) ...
                || isnan(temp2)) || (~isreal(temp2))
                ERR = -2;
            else
                obj.MIN_BOUNCE = temp1;
                obj.MAX_BOUNCE = temp2;
            end
        end
        
        %% Environment Simulation Functions
        % *****************************************************************
        % Calculate Illumination at height Z
        % -----------------------------------------------------------------
        function [Illum, grid] = getIllum(obj,Z)
            
            % Setup X,Y locations
            x = 0:obj.del_p:obj.rm.length;
            y = 0:obj.del_p:obj.rm.width;
            N_x = length(x);
            N_y = length(y);
            
            [X, Y] = meshgrid(x, y);
            x_locs = reshape(X,1,N_x*N_y);
            y_locs = reshape(Y,1,N_x*N_y);

            temp_rx = candles_classes.rx_ps(0,0,0,0,pi/2,obj.del_p^2,pi/2,1);
            my_rxs(1:size(x_locs,2)) = temp_rx;
            for i = 1:size(x_locs,2)
                my_rxs(i) = my_rxs(i).set_x(x_locs(i));
                my_rxs(i) = my_rxs(i).set_y(y_locs(i));
                my_rxs(i) = my_rxs(i).set_z(Z);
            end
            
            Res.del_t = obj.del_t;
            Res.del_s = obj.del_s;
            Res.MIN_BOUNCE = obj.MIN_BOUNCE;
            Res.MAX_BOUNCE = obj.MAX_BOUNCE;
            [P_rx,~]       = VLCIRC(obj.txs, my_rxs, obj.boxes, obj.rm, ...
                                    Res, obj.DISP_WAITBAR);
            
            
            Irrad = P_rx./(obj.del_p)^2; 
            Irrad = reshape(Irrad,[N_y,N_x]);
            
            V = SYS_eye_sensitivity(min(obj.lambda), max(obj.lambda), 1978);
            Illum = Irrad*683*sum(obj.Sprime.*V); 
            grid = [x_locs;y_locs];
        end
        
        % Calculate rx power with receiver RX_NUM at the various positions
        % -----------------------------------------------------------------
        function [P, H] = calcMotionPath(obj,RX_NUM,x_locs,y_locs)
            obj.rxs(1:length(x_locs)) = obj.rxs(RX_NUM);
            for i = 1:length(x_locs)
                obj.rxs(i) = obj.rxs(i).set_x(x_locs(i));
                obj.rxs(i) = obj.rxs(i).set_y(y_locs(i));                
            end
                        
            Res.del_t = obj.del_t;
            Res.del_s = obj.del_s;
            Res.MIN_BOUNCE = obj.MIN_BOUNCE;
            Res.MAX_BOUNCE = obj.MAX_BOUNCE;
            [P, H] = VLCIRC(obj.txs, obj.rxs, obj.boxes, obj.rm, Res, obj.DISP_WAITBAR);
        end
        
        % Calculate rx power with receiver RX_NUM at various orientations
        % -----------------------------------------------------------------
        function [P, H] = calcRotation(obj,RX_NUM,azs,els)
            obj.rxs(1:length(azs)) = obj.rxs(RX_NUM);
            for i = 1:length(azs)
                obj.rxs(i) = obj.rxs(i).set_az(max(min(azs(i),360),0)*(pi/180));
                obj.rxs(i) = obj.rxs(i).set_el(max(min(els(i),360),0)*(pi/180));
            end
                        
            Res.del_t = obj.del_t;
            Res.del_s = obj.del_s;
            Res.MIN_BOUNCE = obj.MIN_BOUNCE;
            Res.MAX_BOUNCE = obj.MAX_BOUNCE;
            [P, H] = VLCIRC(obj.txs, obj.rxs, obj.boxes, obj.rm, Res, obj.DISP_WAITBAR);
        end
        
        %% Environment Simulation Results - Plots
        % *****************************************************************
        % Plot the Illumination results at a specified plane
        % -----------------------------------------------------------------
        function plotIllumPlane(obj,Illum,plane,my_ax)
            x = 0:obj.del_p:obj.rm.length;
            y = 0:obj.del_p:obj.rm.width;
            
            axes(my_ax);
            contourf(x,y,Illum);
            xlabel('X (m)');
            ylabel('Y (m)');
            title(['Surface Illumination (Lux) at ' ...
                     num2str(plane) 'm']);
            view([0 90]);
            caxis([0 max(max(Illum))]);
            colorbar;
        end
        
        % Plot the CDF of the Illumination results at a specified plane
        % -----------------------------------------------------------------
        function plotIllumPlaneCDF(~,Illum,plane,my_ax)
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

