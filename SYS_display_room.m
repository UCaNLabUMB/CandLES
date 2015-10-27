%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYS_display_room.m 
%
%   Description: This is a simple matlab function to plot the room
%     described by the input values.  A 3D plot of the room size is
%     shown with all obstructions displayed as well as markers for the
%     Location of the transmitters and receivers.
%
%     disp_type values:
%           0 - Normal display
%           1 - Highlight tx(arg)
%           2 - Highlight rx(arg)
%           3 - Highlight box(arg)
%           4 - No receivers, just highlight z = arg
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SYS_display_room(my_axes, env, disp_type, arg)

  axes(my_axes);
  cla;
  if ~exist('disp_type', 'var')
      disp_type = 0;
  end
  if (disp_type == 0)
      arg       = 0;
  end
  
  %%%% Boxes %%%
  if (~isempty(env.boxes))
    plot_boxes(env.boxes, disp_type, arg);
  end

  %%% Transmitters %%%
  plot_transmitters(env.txs, disp_type, arg);

  %%%% Receivers %%%%
  plot_receivers(env.rm, env.rxs, disp_type, arg);

  %%% Display %%%
  view(3);
  grid on;
  axis equal;
  axis([0 env.rm.length 0 env.rm.width 0 env.rm.height]);
  rotate3d(my_axes, 'on');

end %END system_room()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot_boxes
%
%   Description: adds the set of boxes to the display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_boxes(boxes, disp_type, arg)
  
  box_select = 0;
  if (disp_type == 3)
      box_select = arg;
  end
  
  for i=1:length(boxes)

    if (i == box_select)
        box_lw = 1.5;
    else
        box_lw = 0.5;
    end
    
    C_x = boxes(i).x;
    C_y = boxes(i).y;
    C_z = boxes(i).z;
   
    D_x = C_x + boxes(i).length;
    D_y = C_y + boxes(i).width;
    D_z = C_z + boxes(i).height;
   
    %North
    xdata = [C_x; C_x; D_x; D_x];
    ydata = [D_y; D_y; D_y; D_y];
    zdata = [C_z; D_z; D_z; C_z];
    patch(xdata,ydata,zdata, ...
          [1-boxes(i).ref(1,1) 1-boxes(i).ref(1,1) 1],'LineWidth', box_lw);

    %South
    xdata = [C_x; C_x; D_x; D_x];
    ydata = [C_y; C_y; C_y; C_y];
    zdata = [C_z; D_z; D_z; C_z];
    patch(xdata,ydata,zdata, ...
          [1-boxes(i).ref(1,2) 1-boxes(i).ref(1,2) 1],'LineWidth', box_lw);
        
    %East
    xdata = [D_x; D_x; D_x; D_x];
    ydata = [C_y; C_y; D_y; D_y];
    zdata = [C_z; D_z; D_z; C_z];
    patch(xdata,ydata,zdata, ...
          [1-boxes(i).ref(2,2) 1-boxes(i).ref(2,2) 1],'LineWidth', box_lw);

    %West
    xdata = [C_x; C_x; C_x; C_x];
    ydata = [C_y; C_y; D_y; D_y];
    zdata = [C_z; D_z; D_z; C_z];
    patch(xdata,ydata,zdata, ...
          [1-boxes(i).ref(2,1) 1-boxes(i).ref(2,1) 1],'LineWidth', box_lw);

    %Top
    xdata = [C_x; C_x; D_x; D_x];
    ydata = [C_y; D_y; D_y; C_y];
    zdata = [D_z; D_z; D_z; D_z];
    patch(xdata,ydata,zdata, ...
          [1-boxes(i).ref(3,1) 1-boxes(i).ref(3,1) 1],'LineWidth', box_lw);
        
    %Bottom
    xdata = [C_x; C_x; D_x; D_x];
    ydata = [C_y; D_y; D_y; C_y];
    zdata = [C_z; C_z; C_z; C_z];
    patch(xdata,ydata,zdata, ...
          [1-boxes(i).ref(3,2) 1-boxes(i).ref(3,2) 1],'LineWidth', box_lw);
        
    %xdata = [C_x D_x C_x C_x C_x C_x;
    %         C_x D_x C_x C_x C_x C_x;
    %         C_x D_x D_x D_x D_x D_x;
    %         C_x D_x D_x D_x D_x D_x];
    %ydata = [C_y C_y C_y C_y C_y D_y;
    %         C_y C_y D_y D_y C_y D_y;
    %         D_y D_y D_y D_y C_y D_y;
    %         D_y D_y C_y C_y C_y D_y];
    %zdata = [C_z C_z C_z D_z C_z C_z;
    %         D_z D_z C_z D_z D_z D_z;
    %         D_z D_z C_z D_z D_z D_z;
    %         C_z C_z C_z D_z C_z C_z];
    %patch(xdata,ydata,zdata,'b');
  end
end %END plot_boxes()


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot_transmitters
%
%   Description: Adds the transmitter set to the display.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_transmitters(txs, disp_type, arg)
  %%%% Transmitters %%%
  
  tx_select = 0;
  if (disp_type == 1)
      tx_select = arg;
  end
  
  %Create color list 
  temp = colormap('lines');
  temp2 = colormap('jet');
  %White, Green, followed by colors from the lines colormap (Don't use red 
  % since it's being used for receivers)
  my_colors = [1 1 1; 0 1 0; temp(4:9,:); temp2(1:12:end,:)]; 
  
  for i=1:length(txs)
    r = 0.1; % Distance to corners and peak
    tx_color = my_colors((txs(i).net_group + 1),:);
    if (i == tx_select)
        tx_lw = 1.5;
    else
        tx_lw = 0.5;
    end
    
    az = txs(i).az;
    el = txs(i).el;
    
    %Center of Transmitter
    C_x = txs(i).x;
    C_y = txs(i).y;
    C_z = txs(i).z;

    %Place points on Axis
    D_ =  [r  0  0];
    P1_ = [0  r  r];
    P2_ = [0  r -r];
    P3_ = [0 -r -r];
    P4_ = [0 -r  r];

    %Rotate with rotation matrix
    %%% Elevation (around Y axis)
    D_p =  [(D_(1)*cos(el) - D_(3)*sin(el))   (D_(2))  (D_(1)*sin(el) + D_(3)*cos(el))];
    P1_p = [(P1_(1)*cos(el) - P1_(3)*sin(el)) (P1_(2)) (P1_(1)*sin(el) + P1_(3)*cos(el))];
    P2_p = [(P2_(1)*cos(el) - P2_(3)*sin(el)) (P2_(2)) (P2_(1)*sin(el) + P2_(3)*cos(el))];
    P3_p = [(P3_(1)*cos(el) - P3_(3)*sin(el)) (P3_(2)) (P3_(1)*sin(el) + P3_(3)*cos(el))];
    P4_p = [(P4_(1)*cos(el) - P4_(3)*sin(el)) (P4_(2)) (P4_(1)*sin(el) + P4_(3)*cos(el))];

    %%% Azimuth (around Z axis)
    D_ =  [(D_p(1)*(cos(az)) - D_p(2)*(sin(az)))   (D_p(1)*(sin(az)) + D_p(2)*(cos(az)))   (D_p(3))];
    P1_ = [(P1_p(1)*(cos(az)) - P1_p(2)*(sin(az))) (P1_p(1)*(sin(az)) + P1_p(2)*(cos(az))) (P1_p(3))];
    P2_ = [(P2_p(1)*(cos(az)) - P2_p(2)*(sin(az))) (P2_p(1)*(sin(az)) + P2_p(2)*(cos(az))) (P2_p(3))];
    P3_ = [(P3_p(1)*(cos(az)) - P3_p(2)*(sin(az))) (P3_p(1)*(sin(az)) + P3_p(2)*(cos(az))) (P3_p(3))];
    P4_ = [(P4_p(1)*(cos(az)) - P4_p(2)*(sin(az))) (P4_p(1)*(sin(az)) + P4_p(2)*(cos(az))) (P4_p(3))];

    %Shift points
    D_ =  [(D_(1) + C_x)  (D_(2) + C_y)  (D_(3) + C_z)];
    P1_ = [(P1_(1) + C_x) (P1_(2) + C_y) (P1_(3) + C_z)];
    P2_ = [(P2_(1) + C_x) (P2_(2) + C_y) (P2_(3) + C_z)];
    P3_ = [(P3_(1) + C_x) (P3_(2) + C_y) (P3_(3) + C_z)];
    P4_ = [(P4_(1) + C_x) (P4_(2) + C_y) (P4_(3) + C_z)];

    %Base
    xdata = [P1_(1); P2_(1); P3_(1); P4_(1)];
    ydata = [P1_(2); P2_(2); P3_(2); P4_(2)];
    zdata = [P1_(3); P2_(3); P3_(3); P4_(3)];
    patch(xdata,ydata,zdata, tx_color, 'LineWidth', tx_lw);
   
    %Peak
    xdata = [D_(1)  D_(1)  D_(1)  D_(1);
             P1_(1) P2_(1) P3_(1) P4_(1);
             P2_(1) P3_(1) P4_(1) P1_(1)];
    ydata = [D_(2)  D_(2)  D_(2)  D_(2);
             P1_(2) P2_(2) P3_(2) P4_(2);
             P2_(2) P3_(2) P4_(2) P1_(2)];
    zdata = [D_(3)  D_(3)  D_(3)  D_(3);
             P1_(3) P2_(3) P3_(3) P4_(3);
             P2_(3) P3_(3) P4_(3) P1_(3)];
    patch(xdata,ydata,zdata, tx_color, 'LineWidth', tx_lw);

  end

end %END plot_transmitters()


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot_receivers
%
%   Description: Adds the receiver set or the spatial plane to the display.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_receivers(room, rxs, disp_type, arg)

  if (disp_type == 4)
    %FIXME: Need to make this work
    z_plane = arg;
    xdata = [      0; room.length; room.length;          0];
    ydata = [      0;           0;  room.width; room.width];
    zdata = [z_plane;     z_plane;     z_plane;    z_plane];
    patch(xdata,ydata,zdata,'w','EdgeColor', 'r', 'FaceColor', 'none');    
  else
    rx_select = 0;
    if (disp_type == 2)
        rx_select = arg;
    end  
      
    for i=1:length(rxs)
      r = 0.1; 
      rx_color = [1 0 0];
      if (i == rx_select)
          rx_lw = 1.5;
      else
          rx_lw = 0.5;
      end
      
      az = rxs(i).az;
      el = rxs(i).el;

      %Center of Rx
      C_x = rxs(i).x;
      C_y = rxs(i).y;
      C_z = rxs(i).z;

      %Place points on Axis
      D_ =  [r  0  0];
      P1_ = [0  r  r];
      P2_ = [0  r -r];
      P3_ = [0 -r -r];
      P4_ = [0 -r  r];

      %Rotate with rotation matrix
      %%% Elevation (around Y axis)
      D_p =  [(D_(1)*cos(el) - D_(3)*sin(el))   (D_(2))  (D_(1)*sin(el) + D_(3)*cos(el))];
      P1_p = [(P1_(1)*cos(el) - P1_(3)*sin(el)) (P1_(2)) (P1_(1)*sin(el) + P1_(3)*cos(el))];
      P2_p = [(P2_(1)*cos(el) - P2_(3)*sin(el)) (P2_(2)) (P2_(1)*sin(el) + P2_(3)*cos(el))];
      P3_p = [(P3_(1)*cos(el) - P3_(3)*sin(el)) (P3_(2)) (P3_(1)*sin(el) + P3_(3)*cos(el))];
      P4_p = [(P4_(1)*cos(el) - P4_(3)*sin(el)) (P4_(2)) (P4_(1)*sin(el) + P4_(3)*cos(el))];


      %%% Azimuth (around Z axis)
      D_ =  [(D_p(1)*(cos(az)) - D_p(2)*(sin(az)))   (D_p(1)*(sin(az)) + D_p(2)*(cos(az)))   (D_p(3))];
      P1_ = [(P1_p(1)*(cos(az)) - P1_p(2)*(sin(az))) (P1_p(1)*(sin(az)) + P1_p(2)*(cos(az))) (P1_p(3))];
      P2_ = [(P2_p(1)*(cos(az)) - P2_p(2)*(sin(az))) (P2_p(1)*(sin(az)) + P2_p(2)*(cos(az))) (P2_p(3))];
      P3_ = [(P3_p(1)*(cos(az)) - P3_p(2)*(sin(az))) (P3_p(1)*(sin(az)) + P3_p(2)*(cos(az))) (P3_p(3))];
      P4_ = [(P4_p(1)*(cos(az)) - P4_p(2)*(sin(az))) (P4_p(1)*(sin(az)) + P4_p(2)*(cos(az))) (P4_p(3))];

      %Shift points
      D_ =  [(D_(1) + C_x)  (D_(2) + C_y)  (D_(3) + C_z)];
      P1_ = [(P1_(1) + C_x) (P1_(2) + C_y) (P1_(3) + C_z)];
      P2_ = [(P2_(1) + C_x) (P2_(2) + C_y) (P2_(3) + C_z)];
      P3_ = [(P3_(1) + C_x) (P3_(2) + C_y) (P3_(3) + C_z)];
      P4_ = [(P4_(1) + C_x) (P4_(2) + C_y) (P4_(3) + C_z)];
     
      %Base
      xdata = [P1_(1); P2_(1); P3_(1); P4_(1)];
      ydata = [P1_(2); P2_(2); P3_(2); P4_(2)];
      zdata = [P1_(3); P2_(3); P3_(3); P4_(3)];
      patch(xdata,ydata,zdata,rx_color,'LineWidth',rx_lw);
   
      %Peak
      xdata = [D_(1)  D_(1)  D_(1)  D_(1);
               P1_(1) P2_(1) P3_(1) P4_(1);
               P2_(1) P3_(1) P4_(1) P1_(1)];
      ydata = [D_(2)  D_(2)  D_(2)  D_(2);
               P1_(2) P2_(2) P3_(2) P4_(2);
               P2_(2) P3_(2) P4_(2) P1_(2)];
      zdata = [D_(3)  D_(3)  D_(3)  D_(3);
               P1_(3) P2_(3) P3_(3) P4_(3);
               P2_(3) P3_(3) P4_(3) P1_(3)];
         
      patch(xdata,ydata,zdata,rx_color,'LineWidth',rx_lw);   

    end
  end
  
end %END plot_receivers()
