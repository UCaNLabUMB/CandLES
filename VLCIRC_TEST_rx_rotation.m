clear all
close all

RM_L = 3; % Room Length
RM_W = 5; % Room Width
RM_H = 3; % Room Height

%NUM_TX = 1; Only 1 transmitter in this test
NUM_RX = 361;
TIME_RES = 1e-10; % Time Resolution

myEnv = candles_classes.candlesEnv();
myEnv = myEnv.setRoomDim('length',RM_L);
myEnv = myEnv.setRoomDim( 'width',RM_W);
myEnv = myEnv.setRoomDim('height',RM_H);

myEnv = myEnv.setDelT(TIME_RES);

% Downward facing Tx - Center of ceiling.
myEnv = myEnv.setTxPos(1, 'x',RM_L/2);
myEnv = myEnv.setTxPos(1, 'y',RM_W/2);
myEnv = myEnv.setTxPos(1, 'z',  RM_H);
myEnv = myEnv.setTxPos(1,'az',     0);
myEnv = myEnv.setTxPos(1,'el',   270);

% Rx at center of room (Z=1) with various elevation angle 
myEnv = myEnv.setRxPos(1, 'x',RM_L/2);
myEnv = myEnv.setRxPos(1, 'y',RM_W/2);
myEnv = myEnv.setRxPos(1, 'z',     1);
myEnv = myEnv.setRxPos(1,'az',     0);
myEnv = myEnv.setRxPos(1,'el',    90);

tic;

% Upward Facing Rxs across X - centered in Y at Z = 1
azs1 = zeros(1,NUM_RX);
els1 = (0:(NUM_RX-1))*360/(NUM_RX-1);
[P1, H1] = myEnv.calcRotation(1,azs1,els1);

% Upward Facing Rxs across Y - centered in X at Z = 1
azs2 = (0:(NUM_RX-1))*360/(NUM_RX-1);
els2 = 45*ones(1,NUM_RX);
[P2, H2] = myEnv.calcRotation(1,azs2,els2);

toc;

figure();
plot(els1,P1);
title('Rx Power vs Elevation Angle (Az = 0)')
xlabel('Rx Elevation Angle (deg)');
xlim([0, 360]);

figure();
plot(azs2,P2);
title('Rx Power vs Azimuth Angle (El = 45 deg)');
xlabel('Rx Azimuth Angle (deg)');
xlim([0, 360]);

