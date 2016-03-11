clear all
close all

RM_L = 3; % Room Length
RM_W = 5; % Room Width
RM_H = 3; % Room Height

%NUM_TX = 1; Only 1 transmitter in this test
NUM_RX      = 50;    % Number of Receiver positions
TIME_RES    = 5e-11; % Time Resolution (s)
SPATIAL_RES = 0.25;   % Spatial Resolution (m)
MIN_BOUNCE  = 0;
MAX_BOUNCE  = 1;

myEnv = candles_classes.candlesEnv();
myEnv = myEnv.setRoomDim('l',RM_L);
myEnv = myEnv.setRoomDim('w',RM_W);
myEnv = myEnv.setRoomDim('h',RM_H);

myEnv = myEnv.addBox();
myEnv = myEnv.setBoxParam(1,'x',1.6);
myEnv = myEnv.setBoxParam(1,'y',2.4);
myEnv = myEnv.setBoxParam(1,'z',1.1);
myEnv = myEnv.setBoxParam(1,'l',0.2);
myEnv = myEnv.setBoxParam(1,'w',0.2);
myEnv = myEnv.setBoxParam(1,'h',0.2);
myEnv = myEnv.addBox();
myEnv = myEnv.setBoxParam(2,'x',1.4);
myEnv = myEnv.setBoxParam(2,'y',2.1);
myEnv = myEnv.setBoxParam(2,'z',1.1);
myEnv = myEnv.setBoxParam(2,'l',0.2);
myEnv = myEnv.setBoxParam(2,'w',0.2);
myEnv = myEnv.setBoxParam(2,'h',0.2);

myEnv = myEnv.setDelT(TIME_RES);
myEnv = myEnv.setSimSetting('del_s',SPATIAL_RES);
myEnv = myEnv.setSimSetting('min_b',MIN_BOUNCE);
myEnv = myEnv.setSimSetting('max_b',MAX_BOUNCE);

% Downward facing Tx - Center of ceiling.
myEnv = myEnv.setTxParam(1, 'x',RM_L/2);
myEnv = myEnv.setTxParam(1, 'y',RM_W/2);
myEnv = myEnv.setTxParam(1, 'z',  RM_H);
myEnv = myEnv.setTxParam(1,'az',     0);
myEnv = myEnv.setTxParam(1,'el',   270);

myEnv = myEnv.setRxParam(1, 'x',RM_L/2);
myEnv = myEnv.setRxParam(1, 'y',RM_W/2);
myEnv = myEnv.setRxParam(1, 'z',     1);
myEnv = myEnv.setRxParam(1,'az',     0);
myEnv = myEnv.setRxParam(1,'el',    90);

tic;

% Upward Facing Rxs across X - centered in Y at Z = 1
x_loc1 = ((1:NUM_RX)-1)*RM_L/(NUM_RX-1);
y_loc1 = (RM_W/2)*ones(1,NUM_RX);
[P1, H1] = myEnv.calcMotionPath(1,x_loc1,y_loc1);

% Upward Facing Rxs across Y - centered in X at Z = 1
x_loc2 = (RM_L/2)*ones(1,NUM_RX);
y_loc2 = ((1:NUM_RX)-1)*RM_W/(NUM_RX-1);
[P2, H2] = myEnv.calcMotionPath(1,x_loc2,y_loc2);

toc;

figure();
plot(x_loc1,P1);
title('Rx Power vs X')
xlabel('X Location (m)');

figure();
plot(y_loc2,P2);
title('Rx Power vs Y')
xlabel('Y Location (m)');
