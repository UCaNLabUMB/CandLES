function [ Prx, h_t ] = VLCIRC( Txs, Rxs, Boxes, Room, Res, WAITBAR )
%VLCIRC Calculate the received power and impulse response from Txs to Rxs
%   Txs     Array of transmitters (candles_classes.tx_ps)
%   Rxs     Array of receivers (candles_classes.rx_ps)
%   Boxes   Array of boxes (candles_classes.box)
%   Room    Room information (candles_classes.room)
%   Res     Sim resultion. Should have the following parameters:
%               Res.del_t       Time Resolution (s)
%               Res.del_s       Spatial resolution (m)
%               Res.MIN_BOUNCE  First reflection considered
%               Res.MAX_BOUNCE  First reflection considered
%
%   FIXME: Update to take a candlesEnv variable as input?
%   FIXME: Make sure the global constant variable (C) exists when running

%% Setup
% Determine the maximum number of time slots required
ARRAY_LEN = get_array_len(Room, Res.del_t, Res.MAX_BOUNCE);

% Generate planes to represent room and boxes
plane_list = get_plane_list(Room, Boxes, Res);

% Determine the total number of reflector elements
NUM_ELTS  = get_num_elts(plane_list); 

% Allocate Memory
Prx = zeros(length(Rxs),1);
h_t = zeros(length(Rxs),ARRAY_LEN);
[THE_MATRIX,M_start,M_end] = VLCIRC_allocate(NUM_ELTS,ARRAY_LEN,Res.MAX_BOUNCE);

% These are essentially pointers for the current and next matrix indices
% in the variables THE_MATRIX, mat_start, and mat_end when MAX_BOUNCE > 1
c_M = 1; % Current Matrix
n_M = 2; % Next Matrix

%% Evaluate impulse response
% Calculate LOS response only if the 0 bounce is included
if (Res.MIN_BOUNCE == 0)
    % Pass h_t by "reference" to avoid unnecessary copy overhead.
    % Matlab uses "copy-on-write" semantics, so Txs/Rxs/Boxes are not 
    % copied since they are not modified.
    h_t = zero_bounce_power(Txs, Rxs, plane_list, h_t, Res.del_t, WAITBAR); 
end

if (Res.MAX_BOUNCE > 0)
    % Calculate single bounce.
    [THE_MATRIX(:,:,c_M), M_start(c_M,:), M_end(c_M,:)] = ...
        first_bounce_matrix(Txs, plane_list, Res, THE_MATRIX(:,:,c_M), ...
                            M_start(c_M,:), M_end(c_M,:), WAITBAR);
                        
    % Update Rxs with received power from the current matrix
    if (Res.MIN_BOUNCE <= 1)
        [h_t, Prx] = update_Prx(h_t, Prx, Rxs, Res, plane_list, ...
                            THE_MATRIX(:,:,c_M), M_start(c_M,:), M_end(c_M,:), WAITBAR);
    end
    
    % Calculate multiple reflections.
    for bounce_no = 2:Res.MAX_BOUNCE
        % Clear the next matrix
        THE_MATRIX(:,:,n_M) = zeros(NUM_ELTS,ARRAY_LEN);
        M_start(n_M,:) = ARRAY_LEN*ones(1,NUM_ELTS);
        M_end(n_M,:)   = zeros(1,NUM_ELTS);    
        
        % Calculate Matrix to Matrix reflections and change c_M
        [THE_MATRIX, M_start, M_end, c_M, n_M] = ...
            update_matrix(plane_list, Res, THE_MATRIX, M_start, M_end, c_M, n_M, WAITBAR, bounce_no);
        
        % Update Rxs with received power from the current matrix
        if (Res.MIN_BOUNCE <= bounce_no)
            [h_t, Prx] = update_Prx(h_t, Prx, Rxs, Res, plane_list, ...
                            THE_MATRIX(:,:,c_M), M_start(c_M,:), M_end(c_M,:), WAITBAR);
        end
    end
end


%% Evaluate normalized impulse response and RX power
% FIXME: This is the way the code was implemented in IRSIM. Seems like it
% can be simplified, but might be necessary for the multipath calc.
total_src_power = sum([Txs.Ps]);
my_sum = sum(h_t,2)*Res.del_t;
my_betas = my_sum / (total_src_power*Res.del_t);
for rcv_cnt = 1:length(Rxs)
    if (my_sum(rcv_cnt) > 0)
        h_t(rcv_cnt,:) = h_t(rcv_cnt,:) / my_sum(rcv_cnt);
    end
end
Prx(:) = my_betas(:)*total_src_power;
h_t = h_t*Res.del_t;

end % EOF VLCIRC


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% zero_bounce_power - Calculate LOS response
% -------------------------------------------------------------------------
function [H] = zero_bounce_power(Txs, Rxs, plane_list, H, del_t, WAITBAR)
    global STR
    wb = wb_open(WAITBAR,STR.IRC_MSG2);
    
    for src_cnt = 1:length(Txs)
        wb_update(wb,(src_cnt-1)/length(Txs));
        
        for rcv_cnt = 1:length(Rxs)
            [visible, attenuation, delay] = get_atten_delay(Txs(src_cnt), ...
                                                            Rxs(rcv_cnt), ...
                                                            plane_list);
            if (visible)
                % Determine location in impulse response and update H
                t_i = get_array_loc(delay, del_t);
                H(rcv_cnt,t_i) = H(rcv_cnt,t_i) + (Txs(src_cnt).Ps)*attenuation;
            end
        end
    end
    wb_close(wb);
end

%% first_bounce_matrix - Calculate response from transmitters to reflectors
% -------------------------------------------------------------------------
function [THE_MATRIX, start_prev, end_prev] = first_bounce_matrix(Txs, plane_list, Res, THE_MATRIX, start_prev, end_prev, WAITBAR)
    global STR
    wb = wb_open(WAITBAR,STR.IRC_MSG3);

    % Initialize to call as "reference" to speedup performance
    element = candles_classes.rx_ps();
    deltas.x    = 0; deltas.y    = 0; deltas.z    = 0;
    start_pos.x = 0; start_pos.y = 0; start_pos.z = 0;
    
    for tx_no = 1:length(Txs)
        element_no = 0;
        for plane_no = 1:length(plane_list)
            wb_update(wb,(tx_no-1)/length(Txs) + ...
                        (plane_no-1)/(length(plane_list)*length(Txs)));
            
            % Determine the first element in the given plane along with the
            % corresponding deltas (difference in position for each element
            % in the plane) and the start position of the first element.
            [element, deltas, start_pos] = ...
                get_element(plane_list(plane_no),element, deltas, start_pos);
            
            %---- Z Plane ----%
            if ((deltas.x ~= 0) && (deltas.y ~= 0))     
                element = element.set_z(start_pos.z);
                element = element.set_A(deltas.x*deltas.y);
                for row = 1:plane_list(plane_no).num_div_l
                    element = element.set_x(start_pos.x + (row - 0.5)*deltas.x);
                    for col = 1:plane_list(plane_no).num_div_w
                        element = element.set_y(start_pos.y + (col - 0.5)*deltas.y);
                        element_no = element_no + 1;
                        
                        % Update impulse response for element in matrix
                        [THE_MATRIX, start_prev, end_prev] = ...
                            update_fb_impulse(THE_MATRIX, start_prev, end_prev, Res, ...
                                              plane_list, Txs, tx_no, ...
                                              element, element_no);
                    end
                end
                
            %---- Y Plane ----%
            elseif ((deltas.x ~= 0) && (deltas.z ~= 0)) 
                element = element.set_y(start_pos.y);
                element = element.set_A(deltas.x*deltas.z);
                for row = 1:plane_list(plane_no).num_div_h
                    element = element.set_z(start_pos.z + (row - 0.5)*deltas.z);
                    for col = 1:plane_list(plane_no).num_div_l
                        element = element.set_x(start_pos.x + (col - 0.5)*deltas.x);
                        element_no = element_no + 1;
                        
                        % Update impulse response for element in matrix
                        [THE_MATRIX, start_prev, end_prev] = ...
                            update_fb_impulse(THE_MATRIX, start_prev, end_prev, Res, ...
                                              plane_list, Txs, tx_no, ...
                                              element, element_no);
                    end
                end
                
            %---- X Plane ----%
            elseif ((deltas.y ~= 0) && (deltas.z ~= 0)) 
                element = element.set_x(start_pos.x);
                element = element.set_A(deltas.y*deltas.z);
                for row = 1:plane_list(plane_no).num_div_w
                    element = element.set_y(start_pos.y + (row - 0.5)*deltas.y);
                    for col = 1:plane_list(plane_no).num_div_h
                        element = element.set_z(start_pos.z + (col - 0.5)*deltas.z);
                        element_no = element_no + 1;
                        
                        % Update impulse response for element in matrix
                        [THE_MATRIX, start_prev, end_prev] = ...
                            update_fb_impulse(THE_MATRIX, start_prev, end_prev, Res, ...
                                              plane_list, Txs, tx_no, ...
                                              element, element_no);
                    end
                end
            end % End Plane Check
        end % End loop through planes
    end % End loop through sources
    wb_close(wb)
end

%% update_fb_impulse - Update matrix element's for first bounce impulse
% -------------------------------------------------------------------------
function [THE_MATRIX, start_prev, end_prev] = update_fb_impulse(THE_MATRIX, start_prev, end_prev, Res, plane_list, Txs, tx_no, element, element_no)
    % Calculate attenuation & delay and add to the
    % appropriate element in THE_MATRIX
    [visible, attenuation, delay] = get_atten_delay(Txs(tx_no), element, plane_list);
    if (visible)
        % Determine location in impulse response
        t_i = get_array_loc(delay, Res.del_t);
        THE_MATRIX(element_no,t_i) = THE_MATRIX(element_no,t_i) + ...
                                    (Txs(tx_no).Ps * attenuation);
                                
        start_prev(element_no)   = min(start_prev(element_no), t_i);
        end_prev(element_no)     = max(  end_prev(element_no), t_i);
    end

end

%% update_matrix - Calculate response from reflectors to other reflectors
% -------------------------------------------------------------------------
function [THE_MATRIX, M_start, M_end, c_M, n_M] = update_matrix(plane_list, Res, THE_MATRIX, M_start, M_end, c_M, n_M, WAITBAR, BOUNCE)
    global STR
    wb = wb_open(WAITBAR,[num2str(BOUNCE), STR.IRC_MSG4]);
    
    rx_element = candles_classes.rx_ps();
    deltas.x    = 0; deltas.y    = 0; deltas.z    = 0;
    start_pos.x = 0; start_pos.y = 0; start_pos.z = 0;
    rx_element_no = 0;
    
    for plane_no = 1:length(plane_list)
        % Determine the first element in the given plane along with the
        % corresponding deltas (difference in position for each element
        % in the plane) and the start position of the first element.
        [rx_element, deltas, start_pos] = ...
            get_element(plane_list(plane_no),rx_element, deltas, start_pos);
        
        wb_update(wb, (plane_no-1)/(length(plane_list)));
        wb_min = (plane_no-1)/(length(plane_list));
        wb_max = (plane_no)/(length(plane_list));

        %---- Z Plane ----%
        if ((deltas.x ~= 0) && (deltas.y ~= 0))  
            rx_element = rx_element.set_z(start_pos.z);
            rx_element = rx_element.set_A(deltas.x*deltas.y);
            for row = 1:plane_list(plane_no).num_div_l
                wb_update(wb, wb_min + (wb_max-wb_min)*(row-1)/plane_list(plane_no).num_div_l);

                rx_element = rx_element.set_x(start_pos.x + (row - 0.5)*deltas.x);
                for col = 1:plane_list(plane_no).num_div_w
                    rx_element = rx_element.set_y(start_pos.y + (col - 0.5)*deltas.y);
                    rx_element_no = rx_element_no + 1;
                    [THE_MATRIX, M_start, M_end] = ...
                        update_element(rx_element, rx_element_no, plane_list, Res, THE_MATRIX, M_start, M_end, c_M, n_M);
                end
            end
            
        %---- Y Plane ----%
        elseif ((deltas.x ~= 0) && (deltas.z ~= 0)) 
            rx_element = rx_element.set_y(start_pos.y);
            rx_element = rx_element.set_A(deltas.x*deltas.z);
            for row = 1:plane_list(plane_no).num_div_h
                wb_update(wb, wb_min + (wb_max-wb_min)*(row-1)/plane_list(plane_no).num_div_h);

                rx_element = rx_element.set_z(start_pos.z + (row - 0.5)*deltas.z);
                for col = 1:plane_list(plane_no).num_div_l
                    rx_element = rx_element.set_x(start_pos.x + (col - 0.5)*deltas.x);
                    rx_element_no = rx_element_no + 1;
                    [THE_MATRIX, M_start, M_end] = ...
                        update_element(rx_element, rx_element_no, plane_list, Res, THE_MATRIX, M_start, M_end, c_M, n_M);
                end
            end
            
        %---- X Plane ----%
        elseif ((deltas.y ~= 0) && (deltas.z ~= 0)) 
            rx_element = rx_element.set_x(start_pos.x);
            rx_element = rx_element.set_A(deltas.y*deltas.z);
            for row = 1:plane_list(plane_no).num_div_w
                wb_update(wb, wb_min + (wb_max-wb_min)*(row-1)/plane_list(plane_no).num_div_w);

                rx_element = rx_element.set_y(start_pos.y + (row - 0.5)*deltas.y);
                for col = 1:plane_list(plane_no).num_div_h
                    rx_element = rx_element.set_z(start_pos.z + (col - 0.5)*deltas.z);
                    rx_element_no = rx_element_no + 1;
                    [THE_MATRIX, M_start, M_end] = ...
                        update_element(rx_element, rx_element_no, plane_list, Res, THE_MATRIX, M_start, M_end, c_M, n_M);
                end
            end
        end % End if X/Y/Z plane
    end % End plane loop
    
    % Swap the pointer to the current and next matrices
    [n_M,c_M] = deal(c_M, n_M);
    wb_close(wb)
end

%% update_element - update element of next MAT power from current MAT elements.
% -------------------------------------------------------------------------
function [THE_MATRIX, M_start, M_end] = update_element(rx_element, rx_element_no, plane_list, Res, THE_MATRIX, M_start, M_end, c_M, n_M)
    tx_element = candles_classes.tx_ps();
    deltas.x    = 0; deltas.y    = 0; deltas.z    = 0;
    start_pos.x = 0; start_pos.y = 0; start_pos.z = 0;
    
    tx_element_no = 0;

    for plane_no = 1:length(plane_list)
        [tx_element, deltas, start_pos] = ...
            get_element(plane_list(plane_no),tx_element, deltas, start_pos);

        %---- Z Plane ----%
        if ((deltas.x ~= 0) && (deltas.y ~= 0))  
            tx_element = tx_element.set_z(start_pos.z);
            for row = 1:plane_list(plane_no).num_div_l
                tx_element = tx_element.set_x(start_pos.x + (row - 0.5)*deltas.x);
                for col = 1:plane_list(plane_no).num_div_w
                    tx_element = tx_element.set_y(start_pos.y + (col - 0.5)*deltas.y);
                    tx_element_no = tx_element_no + 1;
                    
                    % Update rx_element in THE_MATRIX
                    [THE_MATRIX, M_start, M_end] = ...
                        update_element_impulse(THE_MATRIX, M_start, M_end, ...
                                               c_M, n_M, Res, ...
                                               plane_list, plane_no, ...
                                               tx_element, tx_element_no, ...
                                               rx_element, rx_element_no);
                end
            end
            
        %---- Y Plane ----%
        elseif ((deltas.x ~= 0) && (deltas.z ~= 0)) 
            tx_element = tx_element.set_y(start_pos.y);
            for row = 1:plane_list(plane_no).num_div_h
                tx_element = tx_element.set_z(start_pos.z + (row - 0.5)*deltas.z);
                for col = 1:plane_list(plane_no).num_div_l
                    tx_element = tx_element.set_x(start_pos.x + (col - 0.5)*deltas.x);
                    tx_element_no = tx_element_no + 1;
                    
                    % Update rx_element in THE_MATRIX
                    [THE_MATRIX, M_start, M_end] = ...
                        update_element_impulse(THE_MATRIX, M_start, M_end, ...
                                               c_M, n_M, Res, ...
                                               plane_list, plane_no, ...
                                               tx_element, tx_element_no, ...
                                               rx_element, rx_element_no);
                end
            end
            
        %---- X Plane ----%
        elseif ((deltas.y ~= 0) && (deltas.z ~= 0)) 
            tx_element = tx_element.set_x(start_pos.x);
            for row = 1:plane_list(plane_no).num_div_w
                tx_element = tx_element.set_y(start_pos.y + (row - 0.5)*deltas.y);
                for col = 1:plane_list(plane_no).num_div_h
                    tx_element = tx_element.set_z(start_pos.z + (col - 0.5)*deltas.z);
                    tx_element_no = tx_element_no + 1;
                    
                    % Update rx_element in THE_MATRIX
                    [THE_MATRIX, M_start, M_end] = ...
                        update_element_impulse(THE_MATRIX, M_start, M_end, ...
                                               c_M, n_M, Res, ...
                                               plane_list, plane_no, ...
                                               tx_element, tx_element_no, ...
                                               rx_element, rx_element_no);
                end
            end
            
        end % End if X/Y/Z plane
    end % End plane loop
end

%% update_element_impulse - Update rx elements impulse received impulse.
% -------------------------------------------------------------------------
function [THE_MATRIX, M_start, M_end] = update_element_impulse(THE_MATRIX, M_start, M_end, c_M, n_M, Res, plane_list, plane_no, tx_element, tx_element_no, rx_element, rx_element_no)

    % Get attenuation & delay from tx_element to rx_element
    [visible, attenuation, delay] = get_atten_delay(tx_element, rx_element, plane_list);
    if (visible && (plane_list(plane_no).ref ~= 0))
        attenuation = plane_list(plane_no).ref * attenuation;
        t_i = get_array_loc(delay, Res.del_t);
    else
        attenuation = 0;
        t_i = 1; % This prevents M_start & M_end from increasing unneccessarily
    end                    

    % Update rx_element in THE_MATRIX
    start_i = M_start(c_M,tx_element_no);
    end_i   = M_end(c_M,tx_element_no);
    for temp_count = start_i:end_i
        THE_MATRIX(rx_element_no,temp_count+t_i,n_M) = ...
            THE_MATRIX(rx_element_no,temp_count+t_i,n_M) + ...
            THE_MATRIX(tx_element_no,temp_count,c_M)*attenuation;
    end                    

    % Update the range of values in the new matrix
    M_start(n_M,rx_element_no) = min(M_start(n_M,rx_element_no), start_i+t_i);
    M_end(n_M,rx_element_no)   = max(  M_end(n_M,rx_element_no),   end_i+t_i);

end

%% update_Prx - 
% -------------------------------------------------------------------------
function [h_t, Prx] = update_Prx(h_t, Prx, Rxs, Res, plane_list, THE_MATRIX, M_start, M_end, WAITBAR)
    global STR
    wb = wb_open(WAITBAR,STR.IRC_MSG5);
    
    element = candles_classes.tx_ps();
    deltas.x    = 0; deltas.y    = 0; deltas.z    = 0;
    start_pos.x = 0; start_pos.y = 0; start_pos.z = 0;
    
    for rx_no = 1:length(Rxs)
        element_no = 0;
        for plane_no = 1:length(plane_list)
            wb_update(wb, (rx_no-1)/length(Rxs) + ...
                        (plane_no-1)/(length(plane_list)*length(Rxs)));

            % Determine the first element in the given plane along with the
            % corresponding deltas (difference in position for each element
            % in the plane) and the start position of the first element.
            [element, deltas, start_pos] = ...
                get_element(plane_list(plane_no),element, deltas, start_pos);
            
            %---- Z Plane ----%
            if ((deltas.x ~= 0) && (deltas.y ~= 0))     
                element = element.set_z(start_pos.z);
                for row = 1:plane_list(plane_no).num_div_l
                    element = element.set_x(start_pos.x + (row - 0.5)*deltas.x);
                    for col = 1:plane_list(plane_no).num_div_w
                        element = element.set_y(start_pos.y + (col - 0.5)*deltas.y);
                        element_no = element_no + 1;
                        
                        % Update h_t for the path from the element to rx
                        h_t = update_rx_impulse(THE_MATRIX, M_start, M_end, h_t, Res, ...
                                                plane_list, plane_no, ...
                                                element, element_no, ...
                                                Rxs, rx_no);
                    end
                end
                
            %---- Y Plane ----%
            elseif ((deltas.x ~= 0) && (deltas.z ~= 0)) 
                element = element.set_y(start_pos.y);
                for row = 1:plane_list(plane_no).num_div_h
                    element = element.set_z(start_pos.z + (row - 0.5)*deltas.z);
                    for col = 1:plane_list(plane_no).num_div_l
                        element = element.set_x(start_pos.x + (col - 0.5)*deltas.x);
                        element_no = element_no + 1;
                        
                        % Update h_t for the path from the element to rx
                        h_t = update_rx_impulse(THE_MATRIX, M_start, M_end, h_t, Res, ...
                                                plane_list, plane_no, ...
                                                element, element_no, ...
                                                Rxs, rx_no);
                    end
                end
                
            %---- X Plane ----%
            elseif ((deltas.y ~= 0) && (deltas.z ~= 0)) 
                element = element.set_x(start_pos.x);
                for row = 1:plane_list(plane_no).num_div_w
                    element = element.set_y(start_pos.y + (row - 0.5)*deltas.y);
                    for col = 1:plane_list(plane_no).num_div_h
                        element = element.set_z(start_pos.z + (col - 0.5)*deltas.z);
                        element_no = element_no + 1;
                        
                        % Update h_t for the path from the element to rx
                        h_t = update_rx_impulse(THE_MATRIX, M_start, M_end, h_t, Res, ...
                                                plane_list, plane_no, ...
                                                element, element_no, ...
                                                Rxs, rx_no);
                    end
                end
            end % End Plane Check
        end % End loop through planes
    end % End loop through receivers
    wb_close(wb);
end

%% update_rx_impulse - Update rx impulse received impulse.
% -------------------------------------------------------------------------
function [h_t] = update_rx_impulse(THE_MATRIX, M_start, M_end, h_t, Res, plane_list, plane_no, element, element_no, Rxs, rx_no)
    % Get attenuation and delay from the element to rx
    [visible, attenuation, delay] = ...
        get_atten_delay(element, Rxs(rx_no), plane_list);
    if (visible && (plane_list(plane_no).ref ~= 0))
        attenuation = plane_list(plane_no).ref * attenuation;
        t_i = get_array_loc(delay, Res.del_t);
    else
        attenuation = 0;
        t_i = 1;
    end

    % Update h_t for the path from the element to rx
    for temp_count = M_start(element_no):M_end(element_no)
        h_t(rx_no, temp_count + t_i) = h_t(rx_no, temp_count + t_i) + ...
                                        attenuation*THE_MATRIX(element_no,temp_count);
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% SETUP FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get_plane_list - Covert the room and boxes to an array of planes
% -------------------------------------------------------------------------
function [plane_list] = get_plane_list(Room, Boxes, Res)
    plane_list = Room.get_planes(Res.del_s);
    for i=1:length(Boxes)
        plane_list = [plane_list, Boxes(i).get_planes(Res.del_s)]; %#ok<AGROW>
    end
end

%% get_num_elts - Get the total number of reflector elements from planes
% -------------------------------------------------------------------------
function [NUM_ELTS] = get_num_elts(plane_list)
    NUM_ELTS = 0;
    for i = 1:length(plane_list)
        NUM_ELTS = NUM_ELTS + ...
                     plane_list(i).num_div_l*plane_list(i).num_div_w + ...
                     plane_list(i).num_div_w*plane_list(i).num_div_h + ...
                     plane_list(i).num_div_l*plane_list(i).num_div_h;
    end
end

%% get_array_len - Get the maximum number of time slots
% -------------------------------------------------------------------------
function [ARRAY_LENGTH] = get_array_len(Room,del_t,MAX_BOUNCE)
    global C

    ARRAY_LENGTH = ceil((MAX_BOUNCE+1)*sqrt(Room.length^2 + ...
                                            Room.width^2  +  ...
                                            Room.height^2) ...
                                       / (del_t*C.SPEED_OF_LIGHT));
end

%% get_atten_delay - Calculate the attenuation and delay from src to dest
% -------------------------------------------------------------------------
function [visible, attenuation, delay] = get_atten_delay(src, dest, plane_list)
    global C

    % Calculate distance from source to destination
    d = sqrt((src.x - dest.x)^2 + (src.y - dest.y)^2 + (src.z - dest.z)^2);

    % Evaluate emission angle (phi) and acceptance angle (psi) by
    % finding the angle between the unit vector and the vector
    % pointing from Tx to Rx (for phi) or from Rx to Tx (for psi)
    cos_phi = (src.x_hat*(dest.x - src.x) + ...
               src.y_hat*(dest.y - src.y) + ...
               src.z_hat*(dest.z - src.z))/d;
    cos_psi = (dest.x_hat*(src.x - dest.x) + ...
               dest.y_hat*(src.y - dest.y) + ...
               dest.z_hat*(src.z - dest.z))/d;

    cos_FOV = cosd(dest.FOV*(180/pi));

    % Check if acceptance angle is less than FOV and if the LOS path is clear
    visible = 0; 
    attenuation = 0;
    delay = 0;
    % If cos_phi or cos_psi are less than 0, transmitter is behind the
    % receiver or the receiver is behind the transmitter.
    if ((cos_phi > 0) && (cos_psi > 0) && (cos_psi > cos_FOV) && ...
        (CheckVisibility(src,dest,plane_list)))
        % LOS path exists. Calculate delay and attenuation.
        visible = 1;
        delay = d/C.SPEED_OF_LIGHT;
        attenuation = (dest.A/d^2)* ...
                      ((src.m + 1)*(cos_phi^src.m)/(2*pi))*...
                      ((dest.gc)*cos_psi); 
    end
    
end

%% CheckVisibility - Search through planes to see if LOS path exists
% -------------------------------------------------------------------------
function [ visible ] = CheckVisibility( src, dest, plane_list )
%   Search through each of the planes in plane_list to see if the LOS
%   path is blocked between src and dest
    visible = 1;
    
    %% Define line from src to dest
    l0 = [ src.x, src.y, src.z];      % Point on the line
    l = l0 - [dest.x,dest.y,dest.z];  % vector pointing from src to dest
    
    %% Check each plane for intersection with line from src to dest
    for plane_no = 1:length(plane_list)
        
        % Get the Normal vector to plane
        n = [plane_list(plane_no).x_hat, ...
             plane_list(plane_no).y_hat, ...
             plane_list(plane_no).z_hat];
        % Get the point on the plane
        p0 = [plane_list(plane_no).x, ...
              plane_list(plane_no).y, ...
              plane_list(plane_no).z];
          
        p1 = [plane_list(plane_no).x + plane_list(plane_no).length, ...
              plane_list(plane_no).y + plane_list(plane_no).width , ...
              plane_list(plane_no).z + plane_list(plane_no).height];          
          
        % Check in line and plane are parallel 
        if (dot(l,n) ~= 0)
            % Line and plane are not Parallel
            % Calculate intersetction point
            intersect = (dot(p0-l0,n)/dot(l,n))*l + l0;
            
            % Determine if intersect is in the spectified section of plane
            %   (Points that are tangent to the section of the plane are 
            %   NOT considered as blocking the LOS)
            % -------------------------------------------------------------
            %   Check for YZ, XZ, and XY planes
            if (((p0(1) == p1(1)) && ...
                 (p0(2) < intersect(2)) && (intersect(2) < p1(2)) && ...
                 (p0(3) < intersect(3)) && (intersect(3) < p1(3))) || ...
                ((p0(1) < intersect(1)) && (intersect(1) < p1(1)) && ...
                 (p0(2) == p1(2)) && ...
                 (p0(3) < intersect(3)) && (intersect(3) < p1(3))) || ...
                ((p0(1) < intersect(1)) && (intersect(1) < p1(1)) && ...
                 (p0(2) < intersect(2)) && (intersect(2) < p1(2)) && ...
                 (p0(3) == p1(3))))
                
                % Determine if the intersection is on the line
                if ((((min(src.x,dest.x) < intersect(1)) && (intersect(1) < max(src.x,dest.x))) || (src.x == dest.x)) && ...
                    (((min(src.y,dest.y) < intersect(2)) && (intersect(2) < max(src.y,dest.y))) || (src.y == dest.y)) && ...
                    (((min(src.z,dest.z) < intersect(3)) && (intersect(3) < max(src.z,dest.z))) || (src.z == dest.z)))
                    visible = 0;
                end
            end

%         else
%             % Line and plane are parallel
%             if (dot(po-lo,n) == 0)
%                 % Line is contained in the plane
%                 % NOTE: CURRENTLY ASSUMING THAT PATH CONTAINED IN THE PLANE
%                 % IS VISIBLE. TO CHANGE THIS, SOMETHING SHOULD BE ADDED
%                 % HERE TO CHECK THAT THE PATH GOES THROUGH THE SPECIFIED
%                 % SECTION OF THE PLANE. THE ABOVE IF STATEMENTS ALSO 
%                 % DON'T CONSIDER TANGENTIAL POINTS AS BLOCKING THE PATH.
%             end
        end
    end
end

%% get_element - Specify the first element in the given plane
% -------------------------------------------------------------------------
function [element, deltas, start_pos] = get_element(plane,element, deltas, start_pos)
    if (plane.num_div_l == 0); deltas.x = 0; else deltas.x = plane.length/plane.num_div_l; end
    if (plane.num_div_w == 0); deltas.y = 0; else deltas.y = plane.width /plane.num_div_w; end
    if (plane.num_div_h == 0); deltas.z = 0; else deltas.z = plane.height/plane.num_div_h; end
    
    start_pos.x = plane.x;
    start_pos.y = plane.y;
    start_pos.z = plane.z;
    
    if (isa(element,'candles_classes.rx_ps'))
        element = element.set_n(1.0);
        element = element.set_FOV(pi/2);
    elseif(isa(element,'candles_classes.tx_ps'))
        element = element.set_m(1); % Surfaces modeled as perfec Lambertian
    end
    element = element.set_unit_vector(plane.x_hat,plane.y_hat,plane.z_hat);
    
end

%% VLCIRC_allocate - Determine location in the time array 
% -------------------------------------------------------------------------
function [THE_MATRIX,M_start,M_end] = VLCIRC_allocate(NUM_ELTS,ARRAY_LEN,MAX_BOUNCE)
    global STR
    
    if (MAX_BOUNCE == 1)
        try % Single bounce only. Only requires 1 reflector matrix.
            THE_MATRIX = zeros(NUM_ELTS,ARRAY_LEN,1);
            M_start    = ARRAY_LEN*ones(1,NUM_ELTS);
            M_end      = zeros(1,NUM_ELTS);
        catch
            warning(STR.IRC_MSG1);
            return;
        end
    elseif (MAX_BOUNCE > 1)
        try % Multiple reflections. Requires a second reflector matrices.
            THE_MATRIX = zeros(NUM_ELTS,ARRAY_LEN,2);
            M_start    = ARRAY_LEN*ones(2,NUM_ELTS);
            M_end      = zeros(2,NUM_ELTS);
        catch
            warning(STR.IRC_MSG1);
            return;
        end
    end
end


%% get_array_loc - Determine location in the time array 
% -------------------------------------------------------------------------
function [i] = get_array_loc(t, del_t)
    % Using floor rather than round so that rounding errors don't propogate
    % and cause out of range errors where a value is set beyond ARRAY_LEN.
    i = 1 + floor(t/del_t);
end

%% wb_open - check if displaying waitbars and open if so
% -------------------------------------------------------------------------
function [wb] = wb_open(WAITBAR,my_str)
    if (WAITBAR)
        wb = waitbar(0,my_str); 
    else
        wb = [];
    end
end

%% wb_update - check if wb is active and close it if so
% -------------------------------------------------------------------------
function wb_update(wb,val)
    if (~isempty(wb)); waitbar(val,wb); end
end

%% wb_close - check if wb is active and close it if so
% -------------------------------------------------------------------------
function wb_close(wb)
    if (~isempty(wb)); close(wb); end
end
