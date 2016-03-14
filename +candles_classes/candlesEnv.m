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
        num_groups  % Number of grouped transmitters
        Sprime      % Normalized PSD (for each group)
        lambda      % wavelengths of Sprime
        
        % Simulation Properties
        del_t       % Time resolution (sec)
        del_s       % Spatial resolution of surface (m)
        del_p       % Spatial resolution of simulated plane (m)
        min_bounce  % First reflection considered (0 for LOS)
        max_bounce  % Last reflection considered
        disp_wb     % Display waitbar when running simulations
        
    end
    
    %% Class Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %% Constructor 
        % *****************************************************************
        function obj = candlesEnv()
            %Initialize the global constants in C
            global C
            if (~exist('C.VER','var') || (C.VER ~= SYS_version))
                SYS_define_constants();
            end
            
            d_rm_size = num2cell(C.D_RM_SIZE);
            d_tx_pos  = num2cell(C.D_ENV_TX_POS);
            d_rx_pos  = num2cell(C.D_ENV_RX_POS);
            obj.rm    = candles_classes.room(d_rm_size{:});
            obj.txs   = candles_classes.tx_ps(d_tx_pos{:});
            obj.rxs   = candles_classes.rx_ps(d_rx_pos{:});
            obj.boxes = candles_classes.box.empty;
            obj.num_groups = C.D_NUM_NET_GROUPS;
            obj.lambda=C.D_LAMBDA;
            obj.Sprime(1,:) = C.D_SPRIME;

            obj.del_t        = C.D_DEL_T; 
            obj.del_s        = C.D_DEL_S;
            obj.del_p        = C.D_DEL_P;
            obj.min_bounce   = C.D_MIN_BOUNCE;
            obj.max_bounce   = C.D_MAX_BOUNCE;
            obj.disp_wb      = C.D_DISP_WAITBAR;
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
        
        % Add a specified layout of transmitters.
        % -----------------------------------------------------------------
        % Any Txs outside room boundaries gets shifted to the room edge.
        %       N_x:  Number of TXs in X direction.
        %       N_y:  Number of TXs in Y direction.
        %         d:  X and Y distance between TXs.
        %       C_x:  Center point in X direction.
        %       C_y:  Center point in Y direction.
        %   Z_plane:  Location of grid in Z dimension
        %    layout:  (1) Grid (2) Cell1 (3) Cell2
        %        ng:  Net Group
        %   replace:  (0) keep existing TXs (1) replace TXs.
        function [obj, TX_NUM] = addTxGroup(obj, N_x, N_y, d, C_x, C_y, Z_plane, layout, ng, replace)
            
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
            
            % Determine the X/Y locations and create new Txs
            TX_NUM  = length(obj.txs);
            my_grid = SYS_grid_cell_locs(C_x, C_y, N_x,N_y,d,layout);
            for new_tx_num = 1:size(my_grid,2)
                my_x = max(min(my_grid(1,new_tx_num), obj.rm.length), 0);
                my_y = max(min(my_grid(2,new_tx_num),  obj.rm.width), 0);
                my_z = max(min(              Z_plane, obj.rm.height), 0);
                
                obj.txs(TX_NUM+new_tx_num) = ...
                       candles_classes.tx_ps(my_x,my_y,my_z);
                   
                obj.txs(TX_NUM+new_tx_num) = ...
                       obj.txs(TX_NUM+new_tx_num).set_ng(ng);
            end
            
            % Set TX_NUM to the first TX in the grid
            TX_NUM = TX_NUM+1;
        end
        
        % Remove the specified transmitter
        % -----------------------------------------------------------------
        function [obj,ERR] = removeTx(obj, TX_NUM)
            global C
            
            if (length(obj.txs) > C.MIN_TX)
                ERR = C.NO_ERR;
                obj.txs(TX_NUM) = [];
            else
                ERR = C.ERR_RM_OBJ;
            end
        end
        
        % Set the parameters of the specified transmitter
        % -----------------------------------------------------------------
        function [obj,ERR] = setTxParam(obj,TX_NUM,param,temp) 
            global C
            
            ERR = C.NO_ERR;
            if (TX_NUM < 1) || (TX_NUM > length(obj.txs))
                ERR = C.ERR_INV_SELECT;
            elseif (isnan(temp)) || (~isreal(temp))
                ERR = C.ERR_INV_STRING;
            else
                switch param
                    case 'x'
                        temp = max(min(temp,obj.rm.length),0);
                        obj.txs(TX_NUM) = obj.txs(TX_NUM).set_x(temp);
                    case 'y'
                        temp = max(min(temp,obj.rm.width),0);
                        obj.txs(TX_NUM) = obj.txs(TX_NUM).set_y(temp);
                    case 'z'
                        temp = max(min(temp,obj.rm.height),0);
                        obj.txs(TX_NUM) = obj.txs(TX_NUM).set_z(temp);
                    case 'az' 
                        temp = temp*(pi/180); % Convert and set in radians
                        obj.txs(TX_NUM) = obj.txs(TX_NUM).set_az(temp);
                    case 'el' 
                        temp = temp*(pi/180); % Convert and set in radians
                        obj.txs(TX_NUM) = obj.txs(TX_NUM).set_el(temp);
                    case 'Ps'
                        obj.txs(TX_NUM) = obj.txs(TX_NUM).set_Ps(temp);
                    case 'm'
                        obj.txs(TX_NUM) = obj.txs(TX_NUM).set_m(temp);
                    case 'theta' % Set in degrees
                        obj.txs(TX_NUM) = obj.txs(TX_NUM).set_theta(temp);
                    case 'ng'
                        temp = max(min(temp,obj.num_groups),0);
                        obj.txs(TX_NUM) = obj.txs(TX_NUM).set_ng(temp);
                    otherwise
                        ERR = C.ERR_INV_PARAM;
                end
            end
        end

        % Set the parameters of all transmitters in the specified group
        % -----------------------------------------------------------------
        function [obj,ERR] = setGroupParam(obj,GROUP_NUM,param,temp) 
            global C
            
            %FIXME: Add errors from setTxParam ?
            ERR = C.NO_ERR;
            for tx_num = 1:length(obj.txs)
                if (obj.txs(tx_num).ng == GROUP_NUM)
                    obj = obj.setTxParam(tx_num,param,temp);
                end
            end
        end
        
        % Plot the normalized emission pattern of the specified Tx
        % -----------------------------------------------------------------
        function plotTxEmission(obj,TX_SELECT,my_axes) 
            my_tx = obj.txs(TX_SELECT);

            angles_deg = -90:90;
            angles_rad = angles_deg*pi/180;
            
            emission = (my_tx.m+1)*cos(angles_rad).^(my_tx.m)/(2*pi);
            emission_norm = 100*emission/max(emission);
            
            axes(my_axes); cla(my_axes,'reset');
            plot(angles_deg,emission_norm);
            axis([-90 90 0 105]);
            set(my_axes,'FontSize',8);
            title('Normalized Emission Pattern', 'FontSize',10);
            xlabel('Emission Angle (deg)', 'FontSize',9);
            ylabel('% of Peak', 'FontSize',9);
            my_axes.XTick = -90:45:90;
            my_axes.YTick = 0:50:100;
        end

        % Add a new Network Group
        % -----------------------------------------------------------------
        function [obj,ERR] = addNetGroup(obj)
            global C
            
            if obj.num_groups < C.MAX_NET_GROUPS
                obj.num_groups = obj.num_groups + 1;
                obj.Sprime(obj.num_groups,:) = C.D_SPRIME;
                ERR = C.NO_ERR;
            else
                ERR = C.ERR_MAX_NG;
            end
        end        
        
        % Remove a new Network Group
        % -----------------------------------------------------------------
        function [obj] = removeNetGroup(obj,ng)
            if (obj.num_groups > 1)
                obj.num_groups = obj.num_groups - 1;
                obj.Sprime(ng,:) = [];
                
                % Set any Txs with group = ng to 0 and update others
                for i = 1:length(obj.txs)
                    if (obj.txs(i).ng == ng)
                        obj.txs(i) = obj.txs(i).set_ng(1);
                    elseif (obj.txs(i).ng > ng)
                        obj.txs(i) = obj.txs(i).set_ng(obj.txs(i).ng - 1);
                    end
                end
            end
        end
        
        % Remove a new Network Group
        % -----------------------------------------------------------------
        function [obj] = removeUnusedNetGroups(obj)
            ng = 1;
            while ng <= obj.num_groups
                % Check if group is unused
                my_txs = obj.getGroup(ng);
                if (isempty(my_txs))
                    obj = obj.removeNetGroup(ng);
                else
                    ng = ng + 1;
                end
            end
        end
        % Get the set of transmitters belonging to group ng
        % -----------------------------------------------------------------
        function [my_txs, my_locs] = getGroup(obj,ng)
            temp = [obj.txs(:).ng];
            tx_nums = 1:length(obj.txs);
            my_locs = tx_nums(temp == ng);
            my_txs  = obj.txs(temp == ng);
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
            global C
            
            if (length(obj.rxs) > 1)
                ERR = C.NO_ERR;
                obj.rxs(RX_NUM) = [];
            else
                ERR = C.ERR_RM_OBJ;
            end
        end
        
        % Set the position of the specified receiver
        % -----------------------------------------------------------------
        function [obj,ERR] = setRxParam(obj,RX_NUM,param,temp)
            global C
            
            ERR = C.NO_ERR;
            if (RX_NUM < 1) || (RX_NUM > length(obj.rxs))
                ERR = C.ERR_INV_SELECT;
            else
                if (isnan(temp)) || (~isreal(temp))
                    ERR = C.ERR_INV_STRING;
                else
                    switch param
                        case 'x'
                            temp = max(min(temp,obj.rm.length),0);
                            obj.rxs(RX_NUM) = obj.rxs(RX_NUM).set_x(temp);
                        case 'y'
                            temp = max(min(temp,obj.rm.width),0);
                            obj.rxs(RX_NUM) = obj.rxs(RX_NUM).set_y(temp);
                        case 'z'
                            temp = max(min(temp,obj.rm.height),0);
                            obj.rxs(RX_NUM) = obj.rxs(RX_NUM).set_z(temp);
                        case 'az' 
                            temp = temp*(pi/180); % Convert and set in radians
                            obj.rxs(RX_NUM) = obj.rxs(RX_NUM).set_az(temp);
                        case 'el' 
                            temp = temp*(pi/180); % Convert and set in radians
                            obj.rxs(RX_NUM) = obj.rxs(RX_NUM).set_el(temp);
                        case 'A' 
                            temp = temp*1e-6; % Convert and set in m^2
                            obj.rxs(RX_NUM) = obj.rxs(RX_NUM).set_A(temp);
                        case 'FOV' 
                            temp = temp*(pi/180); % Convert and set in radians
                            obj.rxs(RX_NUM) = obj.rxs(RX_NUM).set_FOV(temp);
                        case 'n' 
                            obj.rxs(RX_NUM) = obj.rxs(RX_NUM).set_n(temp);
                        otherwise
                            ERR = C.ERR_INV_PARAM;
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
        function [obj,ERR] = setBoxParam(obj,BOX_NUM,param,temp)
            global C
            
            ERR = C.NO_ERR;
            if (BOX_NUM < 1) || (BOX_NUM > length(obj.boxes))
                ERR = C.ERR_INV_SELECT;
            elseif (isnan(temp)) || (~isreal(temp))
                ERR = C.ERR_INV_STRING;
            else
                switch param
                    case 'x'
                        % FIXME: Add ERR for out of range x,y,z,l,w,h
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
                    case 'l'
                        temp = max(min(temp,obj.rm.length ...
                                            - obj.boxes(BOX_NUM).x),C.MIN_BOX_DIM);
                        obj.boxes(BOX_NUM) = obj.boxes(BOX_NUM).set_length(temp);
                    case 'w'
                        temp = max(min(temp,obj.rm.width ...
                                            - obj.boxes(BOX_NUM).y),C.MIN_BOX_DIM);
                        obj.boxes(BOX_NUM) = obj.boxes(BOX_NUM).set_width(temp);
                    case 'h'
                        temp = max(min(temp,obj.rm.height ...
                                            - obj.boxes(BOX_NUM).z),C.MIN_BOX_DIM);
                        obj.boxes(BOX_NUM) = obj.boxes(BOX_NUM).set_height(temp);
                    otherwise
                        ERR = C.ERR_INV_PARAM;
                end
            end
        end

        % Set the reflectivities of the specified box
        % -----------------------------------------------------------------
        function [obj,ERR] = setBoxRef(obj,BOX_NUM,nsewtb,temp)
            global C
            
            ERR = C.NO_ERR;
            if (BOX_NUM < 1) || (BOX_NUM > length(obj.boxes))
                ERR = C.ERR_INV_SELECT;
            elseif (isnan(temp)) || (~isreal(temp))
                ERR = C.ERR_INV_STRING;
            else
                obj.boxes(BOX_NUM) = obj.boxes(BOX_NUM).set_ref(nsewtb,temp);
            end
        end
            
        %% Room Functions
        % *****************************************************************
        
        % Set the dimensions of the room
        % -----------------------------------------------------------------
        % Do not make dimensions such that objects are outside the room.
        % FIXME: For now, cap room l,w,h. For computational speed, the
        % resolution needs to be lowered when increasing room size.
        function [obj,ERR] = setRoomDim(obj,param,temp)
            global C
            
            ERR = C.NO_ERR;
            if (isnan(temp)) || (~isreal(temp))
                ERR = C.ERR_INV_STRING;
            else
                switch param
                    case 'l'
                        % FIXME: Add ERR for out of range x, y, or z
                        [x,~,~] = obj.min_room_dims();
                        temp = max(min(temp,C.MAX_ROOM_DIM),x);
                        obj.rm = obj.rm.setLength(temp);
                    case 'w'
                        [~,y,~] = obj.min_room_dims();
                        temp = max(min(temp,C.MAX_ROOM_DIM),y);
                        obj.rm = obj.rm.setWidth(temp);
                    case 'h'
                        [~,~,z] = obj.min_room_dims();
                        temp = max(min(temp,C.MAX_ROOM_DIM),z);
                        obj.rm = obj.rm.setHeight(temp);
                    otherwise
                        ERR = C.ERR_INV_PARAM;
                end
            end
        end
        
        % Set the room reflectivities
        % -----------------------------------------------------------------
        % nsewtb indicates north, south, east, west, top, or bottom wall
        function [obj,ERR] = setRoomRef(obj,nsewtb,temp)
            global C
            
            ERR = C.NO_ERR;
            if (isnan(temp)) || (~isreal(temp))
                ERR = C.ERR_INV_STRING;
            else
                obj.rm = obj.rm.setRef(nsewtb, temp);
            end
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
        
        % Set the specified simulation setting
        % -----------------------------------------------------------------
        function [obj,ERR] = setSimSetting(obj,param,temp) 
            global C
            
            ERR = C.NO_ERR;
            if (isnan(temp)) || (~isreal(temp))
                ERR = C.ERR_INV_STRING;
            else
                switch param
                    case 'del_t'
                        if (temp > 0); obj.del_t = temp; end
                    case 'del_s'
                        if (temp > 0); obj.del_s = temp; end
                    case 'del_p'
                        if (temp > 0); obj.del_p = temp; end
                    case 'min_b'
                        temp = floor(temp);
                        if (temp >= 0); obj.min_bounce = temp; end
                    case 'max_b'
                        temp = floor(temp);
                        if (temp >= 0); obj.max_bounce = temp; end
                    case 'disp'
                        if((temp == 0) || (temp == 1)) 
                            obj.disp_wb = temp;
                        end
                    otherwise
                        ERR = C.ERR_INV_PARAM;
                end
            end
        end
        
        %% Environment Simulation Functions
        % *****************************************************************
        
        % Calculate Impulse responses and Prx for Rxs in the environment
        % -----------------------------------------------------------------
        function [P_rx,h_t] = run(obj)
            Res.del_t = obj.del_t;
            Res.del_s = obj.del_s;
            Res.MIN_BOUNCE = obj.min_bounce;
            Res.MAX_BOUNCE = obj.max_bounce;
            [P_rx,h_t]     = VLCIRC(obj.txs, obj.rxs, obj.boxes, obj.rm, ...
                                    Res, obj.disp_wb);
        end
        
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
            Res.MIN_BOUNCE = obj.min_bounce;
            Res.MAX_BOUNCE = obj.max_bounce;
            [P_rx,~]       = VLCIRC(obj.txs, my_rxs, obj.boxes, obj.rm, ...
                                    Res, obj.disp_wb);
            
            
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
            Res.MIN_BOUNCE = obj.min_bounce;
            Res.MAX_BOUNCE = obj.max_bounce;
            [P, H] = VLCIRC(obj.txs, obj.rxs, obj.boxes, obj.rm, Res, obj.disp_wb);
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
            Res.MIN_BOUNCE = obj.min_bounce;
            Res.MAX_BOUNCE = obj.max_bounce;
            [P, H] = VLCIRC(obj.txs, obj.rxs, obj.boxes, obj.rm, Res, obj.disp_wb);
        end
        
        %% Environment Simulation Results - Plots
        % *****************************************************************
        
        % Plot the impulse response
        % -----------------------------------------------------------------
        function plotCommImpulse(obj,h_t,my_ax)
            t = (0:size(h_t,2)-1)*obj.del_t;
            
            axes(my_ax);
            plot(t*1e9,h_t);
            title('Normalized Impulse Response');
            xlabel('Time (ns)');
            ylabel('% of Prx');
            axis([0,max(t)*1e9,0,1]);
        end
        
        % Plot the Illumination results at a specified plane
        % -----------------------------------------------------------------
        function plotIllumPlane(obj,Illum,plane,my_ax)
            x = 0:obj.del_p:obj.rm.length;
            y = 0:obj.del_p:obj.rm.width;
            
            axes(my_ax);
            if (max(max(Illum)) > 0)
                contourf(x,y,Illum);
                xlabel('X (m)');
                ylabel('Y (m)');
                title(['Surface Illumination (Lux) at ' ...
                         num2str(plane) 'm']);
                view([0 90]);
                caxis([0 max(max(Illum))]);
                colorbar;
            else
                cla(my_ax,'reset');
                text(0.38, 0.5, sprintf('No Illumination'), 'Parent', my_ax);

            end
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
        
        % Get the error message associated with error ERR
        % -----------------------------------------------------------------
        function [msg] = getErrorMessage(~,ERR)
            global C
            
            switch ERR
                case C.NO_ERR
                    msg = '';
                case C.ERR_RM_OBJ
                    msg = 'Environment Requires at least 1 Tx and 1 Rx.';
                case C.ERR_MAX_NG
                    msg = 'Max number of network groups reached.';
                case C.ERR_INV_SELECT
                    msg = 'Invalid item selection.';
                case C.ERR_INV_STRING
                    msg = 'Invalid value entry (NaN or Complex).';
                case C.ERR_INV_PARAM
                    msg = 'Invalid parameter selection.';
                otherwise
                    msg = 'Unknown Error.';
            end                
        end
    end
    
end

