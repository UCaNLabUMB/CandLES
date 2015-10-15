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
    end
    
end

