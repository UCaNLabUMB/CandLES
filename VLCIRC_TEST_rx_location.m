clear all
close all

RM_L = 3; % Room Length
RM_W = 5; % Room Width
RM_H = 3; % Room Height

%NUM_TX = 1; Only 1 transmitter in this test
NUM_RX = 50;
TIME_RES = 2e-11; % Time Resolution

myEnv = candles_classes.candlesEnv();
myEnv = myEnv.setRoomDim('length',RM_L);
myEnv = myEnv.setRoomDim( 'width',RM_W);
myEnv = myEnv.setRoomDim('height',RM_H);

myEnv = myEnv.addBox();
myEnv = myEnv.setBoxPos(1,'x',1.6);
myEnv = myEnv.setBoxPos(1,'y',2.4);
myEnv = myEnv.setBoxPos(1,'z',1.1);
myEnv = myEnv.setBoxDim(1,'l',0.2);
myEnv = myEnv.setBoxDim(1,'w',0.2);
myEnv = myEnv.setBoxDim(1,'h',0.1);
myEnv = myEnv.addBox();
myEnv = myEnv.setBoxPos(2,'x',1.4);
myEnv = myEnv.setBoxPos(2,'y',2.1);
myEnv = myEnv.setBoxPos(2,'z',1.1);
myEnv = myEnv.setBoxDim(2,'l',0.2);
myEnv = myEnv.setBoxDim(2,'w',0.2);
myEnv = myEnv.setBoxDim(2,'h',0.1);

myEnv = myEnv.setDelT(TIME_RES);

% Downward facing Tx - Center of ceiling.
myEnv = myEnv.setTxPos(1, 'x',RM_L/2);
myEnv = myEnv.setTxPos(1, 'y',RM_W/2);
myEnv = myEnv.setTxPos(1, 'z',  RM_H);
myEnv = myEnv.setTxPos(1,'az',     0);
myEnv = myEnv.setTxPos(1,'el',   270);

myEnv = myEnv.setRxPos(1, 'x',RM_L/2);
myEnv = myEnv.setRxPos(1, 'y',RM_W/2);
myEnv = myEnv.setRxPos(1, 'z',     1);
myEnv = myEnv.setRxPos(1,'az',     0);
myEnv = myEnv.setRxPos(1,'el',    90);

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
