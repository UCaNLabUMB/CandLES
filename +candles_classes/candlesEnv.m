classdef candlesEnv
    %CANDLESENV CandLES environment class
    %   A candlesEnv object stores the environment variables for a CandLES
    %   GUI. This includes the room parameters and simulation parameters.
    
    %% Class Properties
    properties
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
    methods
        % Constructor - Set default values for CandLES here!
        function obj = candlesEnv()
            obj.rm  = candles_classes.room(5,4,3);
            obj.txs = candles_classes.tx_ps(2.5,2,2.5);
            obj.rxs = candles_classes.rx_ps(2.5,2,1);
            obj.boxes = candles_classes.box.empty;

            obj.del_t = 1e-10; 
        end
        
        %% Transmitter Functions
        function [obj, TX_NUM] = addTx(obj)
            TX_NUM = length(obj.txs)+1;
            obj.txs(TX_NUM) = candles_classes.tx_ps();
            % FIXME: Check room to make sure the new TX is in room
        end
        
        % ERR = 1 means there's only 1 TX left
        function [obj,ERR] = removeTx(obj, TX_NUM)
            ERR = 1;
            if (length(obj.txs) > 1)
                ERR = 0;
                obj.txs(TX_NUM) = [];
            end
        end
        
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
        function [obj, RX_NUM] = addRx(obj)
            RX_NUM = length(obj.rxs)+1;
            obj.rxs(RX_NUM) = candles_classes.rx_ps();
            % FIXME: Check room to make sure the new TX is in room
        end
        
        function [obj,ERR] = removeRx(obj, RX_NUM)
            ERR = 1;
            if (length(obj.rxs) > 1)
                ERR = 0;
                obj.rxs(RX_NUM) = [];
            end
        end
        
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
        
    end
    
end

