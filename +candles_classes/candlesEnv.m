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
    
    %% External Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %% ****************************************************************
        function obj = candlesEnv()
        % Constructor 

            %Initialize the global constants in C
            global C
            SYS_define_constants();
            
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
        
        % -----------------------------------------------------------------
        function [obj, TX_NUM] = addTx(obj)
        % Add a new transmitter
            TX_NUM = length(obj.txs)+1;
            obj.txs(TX_NUM) = candles_classes.tx_ps();
            % FIXME: Check room to make sure the new TX is in room
        end
        
        % -----------------------------------------------------------------
        function [obj, TX_NUM] = addTxGroup(obj, N_x, N_y, d, C_x, C_y, Z_plane, layout, ng, replace)
        % Add a specified layout of transmitters.
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
        
        % -----------------------------------------------------------------
        function [obj,ERR] = removeTx(obj, TX_NUM)
        % Remove the specified transmitter
            global C
            
            if (length(obj.txs) > C.MIN_TX)
                ERR = C.NO_ERR;
                obj.txs(TX_NUM) = [];
            else
                ERR = C.ERR_RM_OBJ;
            end
        end
        
        % -----------------------------------------------------------------
        function [obj,ERR] = setTxParam(obj,TX_NUM,param,temp) 
        % Set the parameters of the specified transmitter
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

        % -----------------------------------------------------------------
        function [obj,ERR] = setGroupParam(obj,GROUP_NUM,param,temp) 
        % Set the parameters of all transmitters in the specified group
            global C
            
            %FIXME: Add errors from setTxParam ?
            ERR = C.NO_ERR;
            for tx_num = 1:length(obj.txs)
                if (obj.txs(tx_num).ng == GROUP_NUM)
                    obj = obj.setTxParam(tx_num,param,temp);
                end
            end
        end
        
        % -----------------------------------------------------------------
        function plotTxEmission(obj,TX_SELECT,my_axes) 
        % Plot the normalized emission pattern of the specified Tx
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

        
        % -----------------------------------------------------------------
        function plotNetGroupSPD(obj,GROUP_SELECT,my_axes)         
            SPD = 100*obj.Sprime(GROUP_SELECT,:)./max(obj.Sprime(GROUP_SELECT,:));
            
            min_lam = 380;
            max_lam = 780;
            
            axes(my_axes); cla(my_axes,'reset');
            plot(obj.lambda,SPD);
            axis([min_lam max_lam 0 105]);
            title('Normalized Spectral Power Distribution', 'FontSize',10);
            xlabel('Wavelength (nm)', 'FontSize',9);
            ylabel('% of Max', 'FontSize',9);            
            my_axes.XTick = min_lam:100:max_lam;
            my_axes.YTick = 0:50:100;
        end
        
        % -----------------------------------------------------------------
        function [obj,ERR] = addNetGroup(obj)
        % Add a new Network Group
            global C
            
            if obj.num_groups < C.MAX_NET_GROUPS
                obj.num_groups = obj.num_groups + 1;
                obj.Sprime(obj.num_groups,:) = C.D_SPRIME;
                ERR = C.NO_ERR;
            else
                ERR = C.ERR_MAX_NG;
            end
        end        
        
        % -----------------------------------------------------------------
        function [obj] = removeNetGroup(obj,ng)
        % Remove a new Network Group
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
        
        % -----------------------------------------------------------------
        function [obj] = removeUnusedNetGroups(obj)
        % Remove all Network Groups without an associated Tx
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
        
        % -----------------------------------------------------------------
        function [obj] = setNetGroupSPD(obj, ng, SPD)
        % Update the Spectral Power Distribution of the Network Group (ng)
            % Verify that the Network Group exists
            if ((ng > 0) && (ng <= obj.num_groups))
                % Verify appropriate length SPD
                if (length(SPD) == length(obj.lambda))
                    obj.Sprime(ng,:) = SPD;
                end
            end
        end
        
        % -----------------------------------------------------------------
        function [my_txs, my_locs] = getGroup(obj,ng)
        % Get the set of transmitters belonging to group ng
            temp = [obj.txs(:).ng];
            tx_nums = 1:length(obj.txs);
            my_locs = tx_nums(temp == ng);
            my_txs  = obj.txs(temp == ng);
        end
        
        %% Receiver Functions
        % *****************************************************************
        
        % -----------------------------------------------------------------
        function [obj, RX_NUM] = addRx(obj)
        % Add a new receiver
            RX_NUM = length(obj.rxs)+1;
            obj.rxs(RX_NUM) = candles_classes.rx_ps();
            % FIXME: Check room to make sure the new TX is in room
        end
        
        % -----------------------------------------------------------------
        function [obj,ERR] = removeRx(obj, RX_NUM)
        % Remove the specified receiver
            global C
            
            if (length(obj.rxs) > 1)
                ERR = C.NO_ERR;
                obj.rxs(RX_NUM) = [];
            else
                ERR = C.ERR_RM_OBJ;
            end
        end
        
        % -----------------------------------------------------------------
        function [obj,ERR] = setRxParam(obj,RX_NUM,param,temp)
        % Set the position of the specified receiver
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
        
        % -----------------------------------------------------------------
        function [obj, BOX_NUM] = addBox(obj)
        % Add a new box
            BOX_NUM = length(obj.boxes)+1;
            obj.boxes(BOX_NUM) = candles_classes.box();
            % FIXME: Check room to make sure the new TX is in room
        end
        
        % -----------------------------------------------------------------
        function [obj] = removeBox(obj, BOX_NUM)
        % Remove the specified box
            if (~isempty(obj.boxes))
                obj.boxes(BOX_NUM) = [];
            end
        end

        % -----------------------------------------------------------------
        function [obj,ERR] = setBoxParam(obj,BOX_NUM,param,temp)
        % Set the position of the specified box
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

        % -----------------------------------------------------------------
        function [obj,ERR] = setBoxRef(obj,BOX_NUM,nsewtb,temp)
        % Set the reflectivities of the specified box
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
        
        % -----------------------------------------------------------------
        function [obj,ERR] = setRoomDim(obj,param,temp)
        % Set the dimensions of the room
        % Do not make dimensions such that objects are outside the room.
        % FIXME: For now, cap room l,w,h. For computational speed, the
        % resolution needs to be lowered when increasing room size.
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
        
        % -----------------------------------------------------------------
        function [obj,ERR] = setRoomRef(obj,nsewtb,temp)
        % Set the room reflectivities
        % nsewtb indicates north, south, east, west, top, or bottom wall
            global C
            
            ERR = C.NO_ERR;
            if (isnan(temp)) || (~isreal(temp))
                ERR = C.ERR_INV_STRING;
            else
                obj.rm = obj.rm.setRef(nsewtb, temp);
            end
        end
        
        % -----------------------------------------------------------------
        function [min_x,min_y,min_z] = min_room_dims(obj)
        % Get the maximum dimensions of boxes, txs, or rxs
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
        
        % -----------------------------------------------------------------
        function [obj,ERR] = setSimSetting(obj,param,temp) 
        % Set the specified simulation setting
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
        
        % -----------------------------------------------------------------
        function [P_rx,h_t] = run(obj)
        % Calculate Impulse responses and Prx for Rxs in the environment
            for ng = 1:obj.num_groups
                [my_txs, ~] = obj.getGroup(ng);
                [P,h] = VLCIRC(my_txs, obj.rxs, obj.boxes, obj.rm, ...
                                    obj.getRes(), obj.disp_wb);
                % FIXME: Should allocate before, but ARRAYLEN (i.e., h2) is
                % calculated in the VLCIRC function at the moment.
                if (~exist('P_rx','var'))
                    P_rx = zeros(obj.num_groups,length(obj.rxs));
                    h_t  = zeros(obj.num_groups,length(obj.rxs),size(h,2));
                end
                P_rx(ng,:)  = P;
                h_t(ng,:,:) = h;
            end
        end
        
        % -----------------------------------------------------------------
        function [Illum, grid] = getIllum(obj,Z)
        % Calculate Illumination at height Z
            
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
            
            [P_rx,~] = VLCIRC(obj.txs, my_rxs, obj.boxes, obj.rm, ...
                              obj.getRes(), obj.disp_wb);
            
            
            Irrad = P_rx./(obj.del_p)^2; 
            Irrad = reshape(Irrad,[N_y,N_x]);
            
            V = SYS_eye_sensitivity(min(obj.lambda), max(obj.lambda), 1978);
            Illum = Irrad*683*sum(obj.Sprime(1,:).*V); 
            % FIXME: Update illum conversion for each group
            grid = [x_locs;y_locs];
        end
        
        % -----------------------------------------------------------------
        function [P, H] = calcMotionPath(obj,RX_NUM,x_locs,y_locs)
        % Calculate rx power with receiver RX_NUM at the various positions
            obj.rxs(1:length(x_locs)) = obj.rxs(RX_NUM);
            for i = 1:length(x_locs)
                obj.rxs(i) = obj.rxs(i).set_x(x_locs(i));
                obj.rxs(i) = obj.rxs(i).set_y(y_locs(i));                
            end
                        
            [P, H] = VLCIRC(obj.txs, obj.rxs, obj.boxes, obj.rm, obj.getRes(), obj.disp_wb);
        end
        
        % -----------------------------------------------------------------
        function [P, H] = calcRotation(obj,RX_NUM,azs,els)
        % Calculate rx power with receiver RX_NUM at various orientations
            obj.rxs(1:length(azs)) = obj.rxs(RX_NUM);
            for i = 1:length(azs)
                obj.rxs(i) = obj.rxs(i).set_az(max(min(azs(i),360),0)*(pi/180));
                obj.rxs(i) = obj.rxs(i).set_el(max(min(els(i),360),0)*(pi/180));
            end
                        
            [P, H] = VLCIRC(obj.txs, obj.rxs, obj.boxes, obj.rm, obj.getRes(), obj.disp_wb);
        end
        
        % -----------------------------------------------------------------
        function [Res] = getRes(obj)
        % Get the resolution information in a structure called Res
            Res.del_t      = obj.del_t;
            Res.del_s      = obj.del_s;
            Res.MIN_BOUNCE = obj.min_bounce;
            Res.MAX_BOUNCE = obj.max_bounce;
        end
        
        %% Display Functions
        % *****************************************************************
        
        % -----------------------------------------------------------------
        function plotCommImpulse(obj,h_t,my_ax)
        % Plot the impulse response
            t = (0:size(h_t,2)-1)*obj.del_t;
            
            axes(my_ax);
            plot(t*1e9,h_t);
            title('Normalized Impulse Response');
            xlabel('Time (ns)');
            ylabel('% of Prx');
            axis([0,max(t)*1e9,0,1]);
        end
        
        % -----------------------------------------------------------------
        function plotIllumPlane(obj,Illum,plane,my_ax)
        % Plot the Illumination results at a specified plane
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
        
        % -----------------------------------------------------------------
        function plotIllumPlaneCDF(~,Illum,plane,my_ax)
        % Plot the CDF of the Illumination results at a specified plane
            axes(my_ax);
            temp = reshape(Illum,[1,size(Illum,1)*size(Illum,2)]);
            cdfplot(temp);
%            xlabel('Illuminance (lux)');
%            ylabel('CDF');
            title(['CDF of the Surface Illumination at ' ...
                     num2str(plane) 'm']);
        end        
        
        % -----------------------------------------------------------------
        function [msg] = getErrorMessage(~,ERR)
        % Get the error message associated with error ERR
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
    
        % -----------------------------------------------------------------
        function display_room(obj, my_axes, disp_type, arg)
        % Plot the environment room/txs/rxs/boxes in my_axes.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Description: This is a simple matlab function to plot the room
        % described by the input values.  A 3D plot of the room size is
        % shown with all obstructions displayed as well as markers for the
        % Location of the transmitters and receivers.
        %
        %     disp_type values:
        %           0 - Normal display
        %           1 - Highlight tx(arg), arg may be a list 
        %           2 - Highlight rx(arg)
        %           3 - Highlight box(arg)
        %           4 - No receivers, just highlight z = arg
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Setup the Axis
            axes(my_axes);
            cla(my_axes,'reset');
            if (~exist('disp_type', 'var')); disp_type = 0; end
            if (disp_type == 0); arg = 0; end

            % Plot the contents of the room
            display_boxes(obj, disp_type, arg);
            display_transmitters(obj, disp_type, arg);
            display_receivers(obj, disp_type, arg);

            % Display
            view(3);
            grid on;
            axis equal;
            axis([0 obj.rm.length 0 obj.rm.width 0 obj.rm.height]);
            rotate3d(my_axes, 'on');
        end
    end
    
    
    %% Internal methods (protected)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = protected)
        
        % -----------------------------------------------------------------
        function display_boxes(obj, disp_type, arg)
        % Adds the set of boxes to the display.
            % Don't do anything if boxes is empty
            if (isempty(obj.boxes)); return; end
        
            box_select = 0;
            if (disp_type == 3); box_select = arg; end

            for i=1:length(obj.boxes)

                box_lw = 0.5;
                if (i == box_select); box_lw = 1.5; end

                C_x = obj.boxes(i).x;
                C_y = obj.boxes(i).y;
                C_z = obj.boxes(i).z;

                D_x = C_x + obj.boxes(i).length;
                D_y = C_y + obj.boxes(i).width;
                D_z = C_z + obj.boxes(i).height;

                %North
                xdata = [C_x; C_x; D_x; D_x];
                ydata = [D_y; D_y; D_y; D_y];
                zdata = [C_z; D_z; D_z; C_z];
                patch(xdata,ydata,zdata, ...
                    [1-obj.boxes(i).ref(1,1) 1-obj.boxes(i).ref(1,1) 1],'LineWidth', box_lw);

                %South
                xdata = [C_x; C_x; D_x; D_x];
                ydata = [C_y; C_y; C_y; C_y];
                zdata = [C_z; D_z; D_z; C_z];
                patch(xdata,ydata,zdata, ...
                    [1-obj.boxes(i).ref(1,2) 1-obj.boxes(i).ref(1,2) 1],'LineWidth', box_lw);

                %East
                xdata = [D_x; D_x; D_x; D_x];
                ydata = [C_y; C_y; D_y; D_y];
                zdata = [C_z; D_z; D_z; C_z];
                patch(xdata,ydata,zdata, ...
                    [1-obj.boxes(i).ref(2,1) 1-obj.boxes(i).ref(2,1) 1],'LineWidth', box_lw);

                %West
                xdata = [C_x; C_x; C_x; C_x];
                ydata = [C_y; C_y; D_y; D_y];
                zdata = [C_z; D_z; D_z; C_z];
                patch(xdata,ydata,zdata, ...
                    [1-obj.boxes(i).ref(2,2) 1-obj.boxes(i).ref(2,2) 1],'LineWidth', box_lw);

                %Top
                xdata = [C_x; C_x; D_x; D_x];
                ydata = [C_y; D_y; D_y; C_y];
                zdata = [D_z; D_z; D_z; D_z];
                patch(xdata,ydata,zdata, ...
                    [1-obj.boxes(i).ref(3,1) 1-obj.boxes(i).ref(3,1) 1],'LineWidth', box_lw);

                %Bottom
                xdata = [C_x; C_x; D_x; D_x];
                ydata = [C_y; D_y; D_y; C_y];
                zdata = [C_z; C_z; C_z; C_z];
                patch(xdata,ydata,zdata, ...
                    [1-obj.boxes(i).ref(3,2) 1-obj.boxes(i).ref(3,2) 1],'LineWidth', box_lw);
            end
        end
        
        % -----------------------------------------------------------------
        function display_transmitters(obj, disp_type, arg)
        % Adds the transmitter set to the display.
            tx_select = 0;
            if (disp_type == 1); tx_select = arg; end

            %Create color list 
            temp = colormap('lines');
            temp2 = colormap('jet');
            %White, Green, followed by colors from the lines colormap.
            % (Don't use red since it's being used for receivers)
            my_colors = [1 1 1; 0 1 0; temp(4:9,:); temp2(1:12:end,:)]; 

            for i=1:length(obj.txs)
                r = 0.1; % Distance to corners and peak
                tx_color = my_colors((obj.txs(i).ng + 1),:);
                
                tx_lw = 0.5;
                if (any(i == tx_select)); tx_lw = 1.5; end

                % Center of Transmitter
                C_x = obj.txs(i).x;
                C_y = obj.txs(i).y;
                C_z = obj.txs(i).z;

                % Place points on Axis
                D_ =  [r  0  0];
                P1_ = [0  r  r];
                P2_ = [0  r -r];
                P3_ = [0 -r -r];
                P4_ = [0 -r  r];

                % Rotate with rotation matrix
                az = obj.txs(i).az;
                el = obj.txs(i).el;

                %%% Elevation (around Y axis)
                D_p =  [(D_(1)*cos(el) - D_(3)*sin(el))   (D_(2))  (D_(1)*sin(el) + D_(3)*cos(el))];
                P1_p = [(P1_(1)*cos(el) - P1_(3)*sin(el)) (P1_(2)) (P1_(1)*sin(el) + P1_(3)*cos(el))];
                P2_p = [(P2_(1)*cos(el) - P2_(3)*sin(el)) (P2_(2)) (P2_(1)*sin(el) + P2_(3)*cos(el))];
                P3_p = [(P3_(1)*cos(el) - P3_(3)*sin(el)) (P3_(2)) (P3_(1)*sin(el) + P3_(3)*cos(el))];
                P4_p = [(P4_(1)*cos(el) - P4_(3)*sin(el)) (P4_(2)) (P4_(1)*sin(el) + P4_(3)*cos(el))];

                %%% Azimuth (around Z axis)
                D_ =  [(D_p(1)*(cos(az)) - D_p(2)*(sin(az)))   (D_p(1)*(sin(az)) + D_p(2)*(cos(az)))   (D_p(3))];
                P1_ = [(P1_p(1)*(cos(az)) - P1_p(2)*(sin(az))) (P1_p(1)*(sin(az)) + P1_p(2)*(cos(az))) (P1_p(3))];
                P2_ = [(P2_p(1)*(cos(az)) - P2_p(2)*(sin(az))) (P2_p(1)*(sin(az)) + P2_p(2)*(cos(az))) (P2_p(3))];
                P3_ = [(P3_p(1)*(cos(az)) - P3_p(2)*(sin(az))) (P3_p(1)*(sin(az)) + P3_p(2)*(cos(az))) (P3_p(3))];
                P4_ = [(P4_p(1)*(cos(az)) - P4_p(2)*(sin(az))) (P4_p(1)*(sin(az)) + P4_p(2)*(cos(az))) (P4_p(3))];

                %Shift points
                D_ =  [(D_(1) + C_x)  (D_(2) + C_y)  (D_(3) + C_z)];
                P1_ = [(P1_(1) + C_x) (P1_(2) + C_y) (P1_(3) + C_z)];
                P2_ = [(P2_(1) + C_x) (P2_(2) + C_y) (P2_(3) + C_z)];
                P3_ = [(P3_(1) + C_x) (P3_(2) + C_y) (P3_(3) + C_z)];
                P4_ = [(P4_(1) + C_x) (P4_(2) + C_y) (P4_(3) + C_z)];

                %Base
                xdata = [P1_(1); P2_(1); P3_(1); P4_(1)];
                ydata = [P1_(2); P2_(2); P3_(2); P4_(2)];
                zdata = [P1_(3); P2_(3); P3_(3); P4_(3)];
                patch(xdata,ydata,zdata, tx_color, 'LineWidth', tx_lw);

                %Peak
                xdata = [D_(1)  D_(1)  D_(1)  D_(1);
                         P1_(1) P2_(1) P3_(1) P4_(1);
                         P2_(1) P3_(1) P4_(1) P1_(1)];
                ydata = [D_(2)  D_(2)  D_(2)  D_(2);
                         P1_(2) P2_(2) P3_(2) P4_(2);
                         P2_(2) P3_(2) P4_(2) P1_(2)];
                zdata = [D_(3)  D_(3)  D_(3)  D_(3);
                         P1_(3) P2_(3) P3_(3) P4_(3);
                         P2_(3) P3_(3) P4_(3) P1_(3)];
                patch(xdata,ydata,zdata, tx_color, 'LineWidth', tx_lw);

                % DEBUG: Show the unit vector from Tx
                %     xdata = [C_x; C_x; C_x+0.5*txs(i).x_hat; C_x+0.5*txs(i).x_hat];
                %     ydata = [C_y; C_y; C_y+0.5*txs(i).y_hat; C_y+0.5*txs(i).y_hat];
                %     zdata = [C_z; C_z; C_z+0.5*txs(i).z_hat; C_z+0.5*txs(i).z_hat];    
                %     patch(xdata,ydata,zdata, 'k');
            end
        end

        % -----------------------------------------------------------------
        function display_receivers(obj, disp_type, arg)
        % Adds the receiver set or the spatial plane to the display.
            if (disp_type == 4)
                %FIXME: Need to make this work
                z_plane = arg;
                xdata = [      0; obj.rm.length; obj.rm.length;            0];
                ydata = [      0;             0;  obj.rm.width; obj.rm.width];
                zdata = [z_plane;       z_plane;       z_plane;      z_plane];
                patch(xdata,ydata,zdata,'w','EdgeColor', 'r', 'FaceColor', 'none');    
            else
                rx_select = 0;
                if (disp_type == 2); rx_select = arg; end  

                for i=1:length(obj.rxs)
                    r = 0.1; 
                    rx_color = [1 0 0];
                    
                    rx_lw = 0.5;
                    if (i == rx_select); rx_lw = 1.5; end

                    %Center of Rx
                    C_x = obj.rxs(i).x;
                    C_y = obj.rxs(i).y;
                    C_z = obj.rxs(i).z;

                    %Place points on Axis
                    D_ =  [r  0  0];
                    P1_ = [0  r  r];
                    P2_ = [0  r -r];
                    P3_ = [0 -r -r];
                    P4_ = [0 -r  r];

                    %Rotate with rotation matrix
                    az = obj.rxs(i).az;
                    el = obj.rxs(i).el;

                    %%% Elevation (around Y axis)
                    D_p =  [(D_(1)*cos(el) - D_(3)*sin(el))   (D_(2))  (D_(1)*sin(el) + D_(3)*cos(el))];
                    P1_p = [(P1_(1)*cos(el) - P1_(3)*sin(el)) (P1_(2)) (P1_(1)*sin(el) + P1_(3)*cos(el))];
                    P2_p = [(P2_(1)*cos(el) - P2_(3)*sin(el)) (P2_(2)) (P2_(1)*sin(el) + P2_(3)*cos(el))];
                    P3_p = [(P3_(1)*cos(el) - P3_(3)*sin(el)) (P3_(2)) (P3_(1)*sin(el) + P3_(3)*cos(el))];
                    P4_p = [(P4_(1)*cos(el) - P4_(3)*sin(el)) (P4_(2)) (P4_(1)*sin(el) + P4_(3)*cos(el))];


                    %%% Azimuth (around Z axis)
                    D_ =  [(D_p(1)*(cos(az)) - D_p(2)*(sin(az)))   (D_p(1)*(sin(az)) + D_p(2)*(cos(az)))   (D_p(3))];
                    P1_ = [(P1_p(1)*(cos(az)) - P1_p(2)*(sin(az))) (P1_p(1)*(sin(az)) + P1_p(2)*(cos(az))) (P1_p(3))];
                    P2_ = [(P2_p(1)*(cos(az)) - P2_p(2)*(sin(az))) (P2_p(1)*(sin(az)) + P2_p(2)*(cos(az))) (P2_p(3))];
                    P3_ = [(P3_p(1)*(cos(az)) - P3_p(2)*(sin(az))) (P3_p(1)*(sin(az)) + P3_p(2)*(cos(az))) (P3_p(3))];
                    P4_ = [(P4_p(1)*(cos(az)) - P4_p(2)*(sin(az))) (P4_p(1)*(sin(az)) + P4_p(2)*(cos(az))) (P4_p(3))];

                    %Shift points
                    D_ =  [(D_(1) + C_x)  (D_(2) + C_y)  (D_(3) + C_z)];
                    P1_ = [(P1_(1) + C_x) (P1_(2) + C_y) (P1_(3) + C_z)];
                    P2_ = [(P2_(1) + C_x) (P2_(2) + C_y) (P2_(3) + C_z)];
                    P3_ = [(P3_(1) + C_x) (P3_(2) + C_y) (P3_(3) + C_z)];
                    P4_ = [(P4_(1) + C_x) (P4_(2) + C_y) (P4_(3) + C_z)];

                    %Base
                    xdata = [P1_(1); P2_(1); P3_(1); P4_(1)];
                    ydata = [P1_(2); P2_(2); P3_(2); P4_(2)];
                    zdata = [P1_(3); P2_(3); P3_(3); P4_(3)];
                    patch(xdata,ydata,zdata,rx_color,'LineWidth',rx_lw);

                    %Peak
                    xdata = [D_(1)  D_(1)  D_(1)  D_(1);
                             P1_(1) P2_(1) P3_(1) P4_(1);
                             P2_(1) P3_(1) P4_(1) P1_(1)];
                    ydata = [D_(2)  D_(2)  D_(2)  D_(2);
                             P1_(2) P2_(2) P3_(2) P4_(2);
                             P2_(2) P3_(2) P4_(2) P1_(2)];
                    zdata = [D_(3)  D_(3)  D_(3)  D_(3);
                             P1_(3) P2_(3) P3_(3) P4_(3);
                             P2_(3) P3_(3) P4_(3) P1_(3)];
                    patch(xdata,ydata,zdata,rx_color,'LineWidth',rx_lw);   

                    % DEBUG: Show the unit vector from Rx
                    %     xdata = [C_x; C_x; C_x+0.5*rxs(i).x_hat; C_x+0.5*rxs(i).x_hat];
                    %     ydata = [C_y; C_y; C_y+0.5*rxs(i).y_hat; C_y+0.5*rxs(i).y_hat];
                    %     zdata = [C_z; C_z; C_z+0.5*rxs(i).z_hat; C_z+0.5*rxs(i).z_hat];    
                    %     patch(xdata,ydata,zdata, 'k');
                end
            end
        end
        
    end
end
