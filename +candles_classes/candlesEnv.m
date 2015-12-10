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
        
        % Simulation Properties
        del_t
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

            obj.del_t = 1e-10; 
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
        
    end
    
end

