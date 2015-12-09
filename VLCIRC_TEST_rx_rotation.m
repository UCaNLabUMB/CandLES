clear all
close all

RM_L = 3; % Room Length
RM_W = 5; % Room Width
RM_H = 3; % Room Height

%NUM_TX = 1; Only 1 transmitter in this test
NUM_RX = 1000;
TIME_RES = 1e-10; % Time Resolution

tic;

Rm = candles_classes.room(RM_L,RM_W,RM_H);
Res.del_t = TIME_RES;

% Downward facing Tx - Center of ceiling.
Txs = candles_classes.tx_ps(RM_L/2,RM_W/2,RM_H,0,3*pi/2);

% Rx at center of room (Z=1) with various elevation angle 
Rxs(1:NUM_RX) = candles_classes.rx_ps(RM_L/2,RM_W/2,1,0,pi/2);
rotation = zeros(1,NUM_RX);
for i = 1:NUM_RX % Span 0 to 2pi (360 deg)
    rotation(i) = (i-1)*2*pi/(NUM_RX-1);
    Rxs(i) = Rxs(i).set_rotation(0,rotation(i));
end
[P1, H1] = VLCIRC(Txs, Rxs, Rm, Res);
figure();
plot(rotation*(180/pi),P1);
hold on;
%plot([Rxs(1).FOV*180/pi, Rxs(1).FOV*180/pi], [0, max(P1)])
%plot([90+Rxs(1).FOV*180/pi, 90+Rxs(1).FOV*180/pi], [0, max(P1)])
title('Rx Power vs Elevation Angle (Az = 0)')
xlabel('Rx Elevation Angle (deg)');
xlim([0, 360]);

% Rx at center of room (Z=1) with various azimuth angle 
Rxs(1:NUM_RX) = candles_classes.rx_ps(RM_L/2,RM_W/2,1,0,pi/4);
rotation = zeros(1,NUM_RX);
for i = 1:NUM_RX % Span 0 to 2pi (360 deg)
    rotation(i) = (i-1)*2*pi/(NUM_RX-1);
    Rxs(i) = Rxs(i).set_rotation(rotation(i),pi/4);
end
[P2, H2] = VLCIRC(Txs, Rxs, Rm, Res);
figure();
plot(rotation*(180/pi),P2);
title('Rx Power vs Azimuth Angle (El = 45 deg)');
xlabel('Rx Azimuth Angle (deg)');
xlim([0, 360]);

toc;