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

global SPEED_OF_LIGHT 
SPEED_OF_LIGHT = 3.0e8;

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
if (Res.MAX_BOUNCE == 1)
    % Single bounce only. Only requires 1 reflector matrix.
    try
        THE_MATRIX   = zeros(NUM_ELTS,ARRAY_LEN,1);
        start_prev   = ARRAY_LEN*ones(1,NUM_ELTS);
        end_prev     = zeros(1,NUM_ELTS);
    catch
        warning('Insufficient Memory to run simulation.');
        return;
    end
% elseif (Res.MAX_BOUNCE > 1)
%     % Multiple reflections. Requires a second reflector matrices.
%     try
%         THE_MATRIX  = zeros(NUM_ELTS,ARRAY_LEN,2);
%         start_prev   = ARRAY_LEN*ones(1,NUM_ELTS);
%         end_prev     = zeros(1,NUM_ELTS);
%         start_next  = ARRAY_LEN*ones(1,NUM_ELTS);
%         end_next    = zeros(1,NUM_ELTS);            
%     catch
%         warning('Insufficient Memory to run multi-reflection simulation.');
%         return;
%     end
end
% These are essentially pointers for the previous and next matrix indices
% in the variable THE_MATRIX
prev_mat = 1; 
next_mat = 2;

%% Evaluate impulse response
% Calculate LOS response only if the 0 bounce is included
if (Res.MIN_BOUNCE == 0)
    % Pass h_t by "reference" to avoid unnecessary copy overhead.
    % Matlab uses "copy-on-write" semantics, so Txs/Rxs/Boxes are not 
    % copied since they are not modified.
    h_t = zero_bounce_power(Txs, Rxs, plane_list, h_t, Res.del_t); 
end

if (Res.MAX_BOUNCE > 0)
    % Calculate single bounce.
    [THE_MATRIX, start_prev, end_prev] = ...
        first_bounce_matrix(Txs, plane_list, Res, ...
                            THE_MATRIX, start_prev, end_prev, WAITBAR);
    [h_t, Prx] = update_Prx(Rxs, THE_MATRIX, Res, plane_list, h_t, Prx, ...
                            start_prev, end_prev, prev_mat, WAITBAR);
    
%     for bounce_no = 2:Res.MAX_BOUNCE
%         % Calculate multiple reflections.
%         THE_MATRIX(:,:,next_mat) = zeros(NUM_ELTS,ARRAY_LEN);
%         
%         start_next = ARRAY_LEN*ones(1,NUM_ELTS);
%         end_next   = zeros(1,NUM_ELTS);    
%         
%         [THE_MATRIX] = update_matrix(THE_MATRIX);
%         
%         temp_start = start_prev;
%         start_prev = start_next;
%         start_next = temp_start;
%         
%         temp_end   = end_prev;
%         end_prev   = end_next;
%         end_next   = temp_end;
%         
%         if (Res.MIN_BOUNCE <= bounce_no)
%             Prx = update_Prx(Prx);
%         end
%         
%         temp_mat = prev_mat;
%         prev_mat = next_mat;
%         next_mat = temp_mat;
%     end

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
function [H] = zero_bounce_power(Txs, Rxs, plane_list, H, del_t)
    for src_cnt = 1:length(Txs)
        for rcv_cnt = 1:length(Rxs)
            [visible, attenuation, delay] = get_atten_delay(Txs(src_cnt), ...
                                                            Rxs(rcv_cnt), ...
                                                            plane_list);
            if (visible)
                % Determine location in impulse response and update H
                i = round(1 + delay/del_t);
                if (i > size(H,2)) % Sanity check - should never get here
                    error('Delay is out of array bound'); 
                end
                H(rcv_cnt,i) = H(rcv_cnt,i) + (Txs(src_cnt).Ps)*attenuation;
            end
        end
    end
end

%% first_bounce_matrix - Calculate response from transmitters to reflectors
% -------------------------------------------------------------------------
function [THE_MATRIX, start_prev, end_prev] = first_bounce_matrix(Txs, plane_list, Res, THE_MATRIX, start_prev, end_prev, WAITBAR)
    % Initialize to call as "reference" to speedup performance
    element = candles_classes.rx_ps();
    deltas.x    = 0; deltas.y    = 0; deltas.z    = 0;
    start_pos.x = 0; start_pos.y = 0; start_pos.z = 0;
    
    if (WAITBAR); wb = waitbar(0,'First Bounce calculation...'); end
    for tx_no = 1:length(Txs)
        element_no = 0;
        for plane_no = 1:length(plane_list)
            if (WAITBAR)
                waitbar((tx_no-1)/length(Txs) + ...
                        (plane_no-1)/(length(plane_list)*length(Txs)),wb)
            end
            
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
                        
                        % Calculate attenuation & delay and add to the
                        % appropriate element in THE_MATRIX
                        [visible, attenuation, delay] = ...
                            get_atten_delay(Txs(tx_no), element, plane_list);
                        if (visible)
                            % Determine location in impulse response
                            t_i = round(1 + delay/Res.del_t);
                            THE_MATRIX(element_no,t_i) = THE_MATRIX(element_no,t_i) + ...
                                                        (Txs(tx_no).Ps * attenuation);
                            start_prev(element_no)   = min(start_prev(element_no), t_i);
                            end_prev(element_no)     = max(  end_prev(element_no), t_i);
                        end
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
                        
                        % Calculate attenuation & delay and add to the
                        % appropriate element in THE_MATRIX
                        [visible, attenuation, delay] = ...
                            get_atten_delay(Txs(tx_no), element, plane_list);
                        if (visible)
                            % Determine location in impulse response
                            t_i = round(1 + delay/Res.del_t);
                            THE_MATRIX(element_no,t_i) = THE_MATRIX(element_no,t_i) + ...
                                                        (Txs(tx_no).Ps * attenuation);
                            start_prev(element_no)   = min(start_prev(element_no), t_i);
                            end_prev(element_no)     = max(  end_prev(element_no), t_i);
                        end
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
                        
                        % Calculate attenuation & delay and add to the
                        % appropriate element in THE_MATRIX
                        [visible, attenuation, delay] = ...
                            get_atten_delay(Txs(tx_no), element, plane_list);
                        if (visible)
                            % Determine location in impulse response
                            t_i = round(1 + delay/Res.del_t);
                            THE_MATRIX(element_no,t_i) = THE_MATRIX(element_no,t_i) + ...
                                                        (Txs(tx_no).Ps * attenuation);
                            start_prev(element_no)   = min(start_prev(element_no), t_i);
                            end_prev(element_no)     = max(  end_prev(element_no), t_i);
                        end
                    end
                end
            end % End Plane Check
        end % End loop through planes
    end % End loop through sources
    if (WAITBAR); close(wb); end
end

%% update_matrix - Calculate response from reflectors to other reflectors
% -------------------------------------------------------------------------
% function [THE_MATRIX] = update_matrix(THE_MATRIX)
% 
% end

%% update_Prx - 
% -------------------------------------------------------------------------
function [h_t, Prx] = update_Prx(Rxs, THE_MATRIX, Res, plane_list, h_t, Prx, start_prev, end_prev, prev_mat, WAITBAR)
    element = candles_classes.tx_ps();
    deltas.x    = 0; deltas.y    = 0; deltas.z    = 0;
    start_pos.x = 0; start_pos.y = 0; start_pos.z = 0;
    
    if (WAITBAR); wb = waitbar(0,'Received Power Update...'); end
    for rx_no = 1:length(Rxs)
        element_no = 0;
        for plane_no = 1:length(plane_list)
            if (WAITBAR)
                waitbar((rx_no-1)/length(Rxs) + ...
                        (plane_no-1)/(length(plane_list)*length(Rxs)),wb)
            end
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
                        
                        % Get attenuation and delay from the element to rx
                        [visible, attenuation, delay] = ...
                            get_atten_delay(element, Rxs(rx_no), plane_list);
                        if (visible && (plane_list(plane_no).ref ~= 0))
                            attenuation = plane_list(plane_no).ref * attenuation;
                            t_i = round(1 + delay/Res.del_t);
                        else
                            attenuation = 0;
                            t_i = 1;
                        end
                        
                        % Update h_t for the path from the element to rx
                        for temp_count = start_prev(element_no):end_prev(element_no)
                            h_t(rx_no, temp_count + t_i) = h_t(rx_no, temp_count + t_i) + ...
                                                            attenuation*THE_MATRIX(element_no,temp_count,prev_mat);
                        end
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
                        
                        % Get attenuation and delay from the element to rx
                        [visible, attenuation, delay] = ...
                            get_atten_delay(element, Rxs(rx_no), plane_list);
                        if (visible && (plane_list(plane_no).ref ~= 0))
                            attenuation = plane_list(plane_no).ref * attenuation;
                            t_i = round(1 + delay/Res.del_t);
                        else
                            attenuation = 0;
                            t_i = 1;
                        end
                        
                        % Update h_t for the path from the element to rx
                        for temp_count = start_prev(element_no):end_prev(element_no)
                            h_t(rx_no, temp_count + t_i) = h_t(rx_no, temp_count + t_i) + ...
                                                            attenuation*THE_MATRIX(element_no,temp_count,prev_mat);
                        end
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
                        
                        % Get attenuation and delay from the element to rx
                        [visible, attenuation, delay] = ...
                            get_atten_delay(element, Rxs(rx_no), plane_list);
                        if (visible && (plane_list(plane_no).ref ~= 0))
                            attenuation = plane_list(plane_no).ref * attenuation;
                            t_i = round(1 + delay/Res.del_t);
                        else
                            attenuation = 0;
                            t_i = 1;
                        end
                        
                        % Update h_t for the path from the element to rx
                        for temp_count = start_prev(element_no):end_prev(element_no)
                            h_t(rx_no, temp_count + t_i) = h_t(rx_no, temp_count + t_i) + ...
                                                            attenuation*THE_MATRIX(element_no,temp_count,prev_mat);
                        end
                    end
                end
            end % End Plane Check
        end % End loop through planes
    end % End loop through receivers
    if (WAITBAR); close(wb); end
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
    global SPEED_OF_LIGHT

    ARRAY_LENGTH = ceil((MAX_BOUNCE+1)*sqrt(Room.length^2 + ...
                                            Room.width^2  +  ...
                                            Room.height^2) ...
                                       / (del_t*SPEED_OF_LIGHT));
end

%% get_atten_delay - Calculate the attenuation and delay from src to dest
% -------------------------------------------------------------------------
function [visible, attenuation, delay] = get_atten_delay(src, dest, plane_list)
    global SPEED_OF_LIGHT

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
        (VLCIRC_CheckVisibility(src,dest,plane_list)))
        % LOS path exists. Calculate delay and attenuation.
        visible = 1;
        delay = d/SPEED_OF_LIGHT;
        attenuation = (dest.A/d^2)* ...
                      ((src.m + 1)*(cos_phi^src.m)/(2*pi))*...
                      ((dest.gc)*cos_psi); 
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


