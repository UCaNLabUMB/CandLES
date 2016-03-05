%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandLES_RxSet - GUI for updating CandLES Receiver settings.
%    Author: Michael Rahaim
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Suppress unnecessary warnings
%#ok<*INUSL>
%#ok<*INUSD>
%#ok<*DEFNU>
function varargout = CandLES_RxSet(varargin)
% CANDLES_RXSET MATLAB code for CandLES_RxSet.fig
%      CANDLES_RXSET, by itself, creates a new CANDLES_RXSET or raises the existing
%      singleton*.
%
%      H = CANDLES_RXSET returns the handle to a new CANDLES_RXSET or the handle to
%      the existing singleton*.
%
%      CANDLES_RXSET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CANDLES_RXSET.M with the given input arguments.
%
%      CANDLES_RXSET('Property','Value',...) creates a new CANDLES_RXSET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CandLES_RxSet_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CandLES_RxSet_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CandLES_RxSet

% Last Modified by GUIDE v2.5 02-Mar-2016 23:17:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CandLES_RxSet_OpeningFcn, ...
                   'gui_OutputFcn',  @CandLES_RxSet_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CandLES_RxSet is made visible.
function CandLES_RxSet_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CandLES_RxSet (see VARARGIN)

% Choose default command line output for CandLES_RxSet
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Load images using function from CandLES.m
h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
feval(getappdata(h_GUI_CandlesMain,'fhLoadImages'),handles);

% Store the handle value for the figure in root (handle 0)
setappdata(0, 'h_GUI_CandlesRxSet', hObject);

% Generate a temporary CandLES environment and store in the GUI handle so
% that it can be edited without modifying the main environment until saved.
mainEnv   = getappdata(h_GUI_CandlesMain,'mainEnv');
rxSetEnv  = mainEnv;
RX_SELECT = 1;
setappdata(hObject, 'rxSetEnv', rxSetEnv);
setappdata(hObject, 'RX_SELECT', RX_SELECT);
set_values(); % Set the values and display environment


% --- Outputs from this function are returned to the command line.
function varargout = CandLES_RxSet_OutputFcn(hObject, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesMain  = getappdata(0,'h_GUI_CandlesMain');
h_GUI_CandlesRxSet = getappdata(0,'h_GUI_CandlesRxSet');
mainEnv            = getappdata(h_GUI_CandlesMain,'mainEnv');
rxSetEnv           = getappdata(h_GUI_CandlesRxSet,'rxSetEnv');

if (~isequal(mainEnv,rxSetEnv))
    response = questdlg('Keep updates?', '','Yes','No','Yes');
    if strcmp(response,'Yes')
        update_main_env();
    end
end
% Remove the handle value of the main figure from root (handle 0) and
% delete (close) the figure
rmappdata(0, 'h_GUI_CandlesRxSet');
delete(hObject); % Close the figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% RX MENU FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function menu_Update_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Update (see GCBO)
    update_main_env();

% --------------------------------------------------------------------
function menu_addRx_Callback(hObject, eventdata, handles)
% hObject    handle to menu_addRx (see GCBO)
    h_GUI_CandlesRxSet = getappdata(0,'h_GUI_CandlesRxSet');
    rxSetEnv           = getappdata(h_GUI_CandlesRxSet,'rxSetEnv');

    [rxSetEnv, RX_SELECT]  = rxSetEnv.addRx();

    setappdata(h_GUI_CandlesRxSet, 'RX_SELECT', RX_SELECT);
    setappdata(h_GUI_CandlesRxSet, 'rxSetEnv', rxSetEnv);
    set_values(); % Set the values and display room with selected RX

% --------------------------------------------------------------------
function menu_deleteRx_Callback(hObject, eventdata, handles)
% hObject    handle to menu_deleteRx (see GCBO)
    h_GUI_CandlesRxSet = getappdata(0,'h_GUI_CandlesRxSet');
    RX_SELECT          = getappdata(h_GUI_CandlesRxSet,'RX_SELECT');
    rxSetEnv           = getappdata(h_GUI_CandlesRxSet,'rxSetEnv');

    [rxSetEnv, ERR]  = rxSetEnv.removeRx(RX_SELECT);
    RX_SELECT = min(RX_SELECT, length(rxSetEnv.rxs));
    if(ERR == 1)
        errordlg('CandLES environment must contain a Rx.','Rx Delete');
    else
        % NOTE: Do this in the else statement so that the error box doesn't 
        % get hidden when the GUI is updated in set_values()
        setappdata(h_GUI_CandlesRxSet, 'RX_SELECT', RX_SELECT);
        setappdata(h_GUI_CandlesRxSet, 'rxSetEnv', rxSetEnv);
        set_values(); % Set the values and display room with selected RX
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% RX SELECT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function popup_rx_select_Callback(hObject, ~, ~)
% hObject    handle to popup_rx_select (see GCBO)
    h_GUI_CandlesRxSet = getappdata(0,'h_GUI_CandlesRxSet');
    RX_SELECT = get(hObject,'Value');
    setappdata(h_GUI_CandlesRxSet, 'RX_SELECT', RX_SELECT);
    set_values(); % Set the values and display room with selected RX


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% RX LOCATION FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_Rx_x_Callback(hObject, ~, ~)
% hObject    handle to edit_Rx_x (see GCBO)
    update_edit(hObject, 'x');

function slider_Rx_x_Callback(hObject, ~, ~)
% hObject    handle to slider_Rx_x (see GCBO)
    update_slider(hObject, 'x');

function edit_Rx_y_Callback(hObject, ~, ~)
% hObject    handle to edit_Rx_y (see GCBO)
    update_edit(hObject, 'y');

function slider_Rx_y_Callback(hObject, ~, ~)
% hObject    handle to slider_Rx_y (see GCBO)
    update_slider(hObject, 'y');

function edit_Rx_z_Callback(hObject, ~, ~)
% hObject    handle to edit_Rx_z (see GCBO)
    update_edit(hObject, 'z');

function slider_Rx_z_Callback(hObject, ~, ~)
% hObject    handle to slider_Rx_z (see GCBO)
    update_slider(hObject, 'z');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% RX ROTATION FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_Rx_az_Callback(hObject, ~, ~)
% hObject    handle to edit_Rx_az (see GCBO)
    update_edit(hObject, 'az');

function slider_Rx_az_Callback(hObject, ~, ~)
% hObject    handle to slider_Rx_az (see GCBO)
    update_slider(hObject, 'az');

function edit_Rx_el_Callback(hObject, ~, ~)
% hObject    handle to edit_Rx_el (see GCBO)
    update_edit(hObject, 'el');

function slider_Rx_el_Callback(hObject, ~, ~)
% hObject    handle to slider_Rx_el (see GCBO)
    update_slider(hObject, 'el');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% TX PARAMETER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Edit callback for photosensor area (mm^2)
function edit_Rx_A_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Rx_A (see GCBO)
    update_edit(hObject, 'A');

% Edit callback for Field of View (degrees)
function edit_Rx_FOV_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Rx_FOV (see GCBO)
    update_edit(hObject, 'FOV');

% Edit callback for Refractive Index
function edit_Rx_n_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Rx_n (see GCBO)
    update_edit(hObject, 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% ADDITIONAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update values based on the change to the edit box hObject. 
%    param = {'x', 'y', 'z', 'az', 'el'}
% --------------------------------------------------------------------
function update_edit(hObject, param)
    h_GUI_CandlesRxSet = getappdata(0,'h_GUI_CandlesRxSet');
    RX_SELECT          = getappdata(h_GUI_CandlesRxSet,'RX_SELECT');
    rxSetEnv           = getappdata(h_GUI_CandlesRxSet,'rxSetEnv');
    temp               = str2double(get(hObject,'String'));

    [rxSetEnv, ERR] = rxSetEnv.setRxParam(RX_SELECT,param,temp);
    % FIXME: Add warning boxes for ERR and bring to front after set_values
    if (ERR == 0)
        setappdata(h_GUI_CandlesRxSet, 'rxSetEnv', rxSetEnv);
    end
    set_values();

% Update values based on the change to the slider hObject. 
%    param = {'x', 'y', 'z', 'az', 'el'}
% --------------------------------------------------------------------
function update_slider(hObject, param)
    h_GUI_CandlesRxSet = getappdata(0,'h_GUI_CandlesRxSet');
    RX_SELECT          = getappdata(h_GUI_CandlesRxSet,'RX_SELECT');
    rxSetEnv           = getappdata(h_GUI_CandlesRxSet,'rxSetEnv');
    temp               = get(hObject,'Value');

    rxSetEnv = rxSetEnv.setRxParam(RX_SELECT,param,temp);
    setappdata(h_GUI_CandlesRxSet, 'rxSetEnv', rxSetEnv);
    set_values();

% Call the update_main function from CandLES.m
% --------------------------------------------------------------------
function update_main_env()
    h_GUI_CandlesMain  = getappdata(0,'h_GUI_CandlesMain');
    h_GUI_CandlesRxSet = getappdata(0,'h_GUI_CandlesRxSet');
    rxSetEnv           = getappdata(h_GUI_CandlesRxSet,'rxSetEnv');
    feval(getappdata(h_GUI_CandlesMain,'fhUpdateMain'),rxSetEnv);
    figure(h_GUI_CandlesRxSet); %Bring the RX GUI back to the front
    
% Set the values within the GUI
% --------------------------------------------------------------------
function set_values()
    h_GUI_CandlesRxSet = getappdata(0,'h_GUI_CandlesRxSet');
    RX_SELECT          = getappdata(h_GUI_CandlesRxSet,'RX_SELECT');
    rxSetEnv           = getappdata(h_GUI_CandlesRxSet,'rxSetEnv');
    handles            = guidata(h_GUI_CandlesRxSet);
    
    % Display room with selected Rx
    SYS_display_room(handles.axes_room, rxSetEnv, 2, RX_SELECT);
    
    % Set Location boxes
    set(handles.edit_Rx_x,'string',num2str(rxSetEnv.rxs(RX_SELECT).x));
    set(handles.edit_Rx_y,'string',num2str(rxSetEnv.rxs(RX_SELECT).y));
    set(handles.edit_Rx_z,'string',num2str(rxSetEnv.rxs(RX_SELECT).z));
    set(handles.slider_Rx_x,'value',rxSetEnv.rxs(RX_SELECT).x);
    set(handles.slider_Rx_y,'value',rxSetEnv.rxs(RX_SELECT).y);
    set(handles.slider_Rx_z,'value',rxSetEnv.rxs(RX_SELECT).z);
    set(handles.slider_Rx_x,'Min',0);
    set(handles.slider_Rx_y,'Min',0);
    set(handles.slider_Rx_z,'Min',0);
    set(handles.slider_Rx_x,'Max',rxSetEnv.rm.length);
    set(handles.slider_Rx_y,'Max',rxSetEnv.rm.width);
    set(handles.slider_Rx_z,'Max',rxSetEnv.rm.height);
    set(handles.slider_Rx_x,'SliderStep',[0.1/rxSetEnv.rm.length, 1/rxSetEnv.rm.length]);
    set(handles.slider_Rx_y,'SliderStep',[0.1/rxSetEnv.rm.width, 1/rxSetEnv.rm.width]);
    set(handles.slider_Rx_z,'SliderStep',[0.1/rxSetEnv.rm.height, 1/rxSetEnv.rm.height]);

    % Set Rotation boxes
    [my_az,my_el] = rxSetEnv.rxs(RX_SELECT).get_angle_deg();
    set(handles.edit_Rx_az,'string',num2str(my_az));
    set(handles.edit_Rx_el,'string',num2str(my_el));
    set(handles.slider_Rx_az,'value',my_az);
    set(handles.slider_Rx_el,'value',my_el);
    set(handles.slider_Rx_az,'Min',0);
    set(handles.slider_Rx_el,'Min',0);
    set(handles.slider_Rx_az,'Max',360);
    set(handles.slider_Rx_el,'Max',360);
    set(handles.slider_Rx_az,'SliderStep',[1/360, 1/36]);
    set(handles.slider_Rx_el,'SliderStep',[1/360, 1/36]);

    % Set Rx Selection box
    set(handles.popup_rx_select,'String',1:1:length(rxSetEnv.rxs));
    set(handles.popup_rx_select,'Value',RX_SELECT);

    % Set Rx Parameters
    set(handles.edit_Rx_A,   'string', rxSetEnv.rxs(RX_SELECT).A*10^6);
    set(handles.edit_Rx_FOV, 'string', rxSetEnv.rxs(RX_SELECT).FOV*180/pi);
    set(handles.edit_Rx_n,   'string', rxSetEnv.rxs(RX_SELECT).n);
    set(handles.edit_Rx_gc,  'string', rxSetEnv.rxs(RX_SELECT).gc);

