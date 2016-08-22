classdef candlesResCommRx
    %CANDLESRESCOMMRX Maintain & display communs results for a set of rxs.
    %   A candlesResComm object stores communication results for a CandLES
    %   environment and provides function calls to display the results.
    
    %% Class Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        prx   % Store the received power for each receiver
        h     % Store the impulse response for each receiver
        del_t % The actual time resolution represented in h
    end
    
    %% External Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %% ****************************************************************
        function obj = candlesResCommRx()
        % Constructor 
            obj.prx   = [];
            obj.h     = [];
            obj.del_t = [];
        end
        
        % -----------------------------------------------------------------
        function TorF = results_exist(obj)
        % Returns true if results have been calculated for the set of rxs
            TorF = ~isempty(obj.prx);
        end
        
        % -----------------------------------------------------------------
        function obj = set_results(obj, prx, h, del_t)
        % Set prx and h
            obj.prx   = prx;
            obj.h     = h;
            obj.del_t = del_t;
        end
        
        % -----------------------------------------------------------------
        function display_prx(obj, TX_GRP_SELECT, my_ax)
            my_prx = obj.prx(TX_GRP_SELECT,:);
            axes(my_ax);
            bar(my_prx);
            title('Received Optical Power');
            xlabel('Receiver');
            ylabel('Power (W)');
        end
            
        % -----------------------------------------------------------------
        function display_h(obj, TX_GRP_SELECT, RX_SELECT, my_ax)
        % Display impulse response to my_ax
            if (RX_SELECT == 0)
                h_t = reshape(obj.h(TX_GRP_SELECT,:,:),size(obj.h,2),size(obj.h,3));
            else
                h_t = reshape(obj.h(TX_GRP_SELECT,RX_SELECT,:),1,size(obj.h,3));
            end
            
            t = (0:size(h_t,2)-1)*obj.del_t;
            
            axes(my_ax);
            plot(t*1e9,h_t);
            title('Normalized Impulse Response');
            xlabel('Time (ns)');
            ylabel('% of Prx');
            axis([0,max(t)*1e9,0,1]);
        end
    end
end

