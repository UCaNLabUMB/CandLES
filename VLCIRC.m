function [ Prx, h_t ] = VLCIRC( Txs, Rxs, Boxes, Room, Res )
%VLCIRC Summary of this function goes here
%   Detailed explanation goes here

MIN_BOUNCE = 0;
MAX_BOUNCE = 0;

global SPEED_OF_LIGHT 
SPEED_OF_LIGHT = 3.0e8;

%% Setup
ARRAY_LEN = ceil((MAX_BOUNCE+1)*sqrt(Room.length^2 + ...
                                     Room.width^2  + ...
                                     Room.height^2) ...
                                  / (Res.del_t*SPEED_OF_LIGHT));

% Allocate Memory
Prx = zeros(length(Rxs),1);
h_t = zeros(length(Rxs),ARRAY_LEN);

% Generate planes to represent room and boxes
plane_list = Room.get_planes();
for i=1:length(Boxes)
    plane_list = [plane_list, Boxes(i).get_planes()]; %#ok<AGROW>
end

%% Evaluate LOS
% Pass h_t by "reference" to avoid unnecessary copy overhead.
% Matlab uses "copy-on-write" semantics, so Txs/Rxs/Boxes are not copied
% since they are not modified.
h_t = zero_bounce_power(Txs, Rxs, plane_list, h_t, Res.del_t); 


%% Evaluate normalized impulse response and RX power
% This is the way the code was implemented in IRSIM... seems like it
% can be simplified, but might be necessary for the multipath calc.
total_power = sum([Txs.Ps]);
my_sum = sum(h_t,2)*Res.del_t;
my_betas = my_sum / (total_power*Res.del_t);
for rcv_cnt = 1:length(Rxs)
    if (my_sum(rcv_cnt) > 0)
        h_t(rcv_cnt,:) = h_t(rcv_cnt,:) / my_sum(rcv_cnt);
    end
end
Prx(:) = my_betas(:)*total_power;
h_t = h_t*Res.del_t;

end % EOF VLCIRC



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% zero_bounce_power - Calculate LOS response
function [H] = zero_bounce_power(Txs, Rxs, plane_list, H, del_t)

    global SPEED_OF_LIGHT
    
    for src_cnt = 1:length(Txs)
        for rcv_cnt = 1:length(Rxs)
            d = sqrt((Txs(src_cnt).x - Rxs(rcv_cnt).x)^2 + ...
                     (Txs(src_cnt).y - Rxs(rcv_cnt).y)^2 + ...
                     (Txs(src_cnt).z - Rxs(rcv_cnt).z)^2);
            
            % Evaluate emission angle (phi) and acceptance angle (psi) by
            % finding the angle between the unit vector and the vector
            % pointing from Tx to Rx (for phi) or from Rx to Tx (for psi)
            cos_phi = (Txs(src_cnt).x_hat*(Rxs(rcv_cnt).x - Txs(src_cnt).x) + ...
                       Txs(src_cnt).y_hat*(Rxs(rcv_cnt).y - Txs(src_cnt).y) + ...
                       Txs(src_cnt).z_hat*(Rxs(rcv_cnt).z - Txs(src_cnt).z))/d;
            cos_psi = (Rxs(rcv_cnt).x_hat*(Txs(src_cnt).x - Rxs(rcv_cnt).x) + ...
                       Rxs(rcv_cnt).y_hat*(Txs(src_cnt).y - Rxs(rcv_cnt).y) + ...
                       Rxs(rcv_cnt).z_hat*(Txs(src_cnt).z - Rxs(rcv_cnt).z))/d;
            
            cos_FOV = cosd(Rxs(rcv_cnt).FOV*(180/pi));
                   
            % Check if acceptance angle is less than FOV and if the LOS path is clear
            if ((cos_psi > cos_FOV) && (VLCIRC_CheckVisibility(Txs(src_cnt),Rxs(rcv_cnt),plane_list)))
                % Calculate attenuation
                attenuation = ...
                    (Rxs(rcv_cnt).A/d^2)*...
                    ((Txs(src_cnt).m + 1)*(cos_phi^Txs(src_cnt).m)/(2*pi))*...
                    ((Rxs(rcv_cnt).gc)*cos_psi); 

                % Calculate delay and location in impulse response
                delay = d/SPEED_OF_LIGHT;
                i = round(1 + delay/del_t);

                % Update H
                if (i > size(H,2)) % Sanity check - should never get here
                    error('Delay is out of array bound'); 
                end
                H(rcv_cnt,i) = H(rcv_cnt,i) + (Txs(src_cnt).Ps)*attenuation;
            end
        end
    end

end
