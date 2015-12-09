clear all
close all

RM_L = 3; % Room Length
RM_W = 5; % Room Width
RM_H = 3; % Room Height

%NUM_TX = 1; Only 1 transmitter in this test
NUM_RX = 50;
TIME_RES = 2e-11; % Time Resolution

tic;

Rm = candles_classes.room(RM_L,RM_W,RM_H);
Res.del_t = TIME_RES;

% Downward facing Tx - Center of ceiling.
Txs = candles_classes.tx_ps(RM_L/2,RM_W/2,RM_H,0,3*pi/2);

% Upward Facing Rxs across X - centered in Y at Z = 1
Rxs(1:NUM_RX) = candles_classes.rx_ps(RM_L/2,RM_W/2,1,0,pi/2);
x_loc = zeros(1,NUM_RX);
for i = 1:NUM_RX % Span the length of the room
    x_loc(i) = (i-1)*Rm.length/(NUM_RX-1);
    Rxs(i) = Rxs(i).set_location(x_loc(i),RM_W/2,1);
end
[P1, H1] = VLCIRC(Txs, Rxs, Rm, Res);
figure();
plot(x_loc,P1);
title('Rx Power vs X')
xlabel('X Location (m)');

% Upward Facing Rxs across X - centered in Y at Z = 1
Rxs(1:NUM_RX) = candles_classes.rx_ps(RM_L/2,RM_W/2,RM_H,0,pi/2);
y_loc = zeros(1,NUM_RX);
for i = 1:NUM_RX % Span the width of the room
    y_loc(i) = (i-1)*Rm.width/(NUM_RX-1);
    Rxs(i) = Rxs(i).set_location(RM_L/2,y_loc(i),1);
end
[P2, H2] = VLCIRC(Txs, Rxs, Rm, Res);

figure();
plot(y_loc,P2);
title('Rx Power vs Y')
xlabel('Y Location (m)');


toc;