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

% Last Modified by GUIDE v2.5 23-Oct-2015 13:59:14

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

% Hint: delete(hObject) closes the figure
response = questdlg('Keep updates?', '','Yes','No','Yes');
if strcmp(response,'Yes')
    % FIXME: Need to store the updated info back to mainEnv or have a save
    % option where this becomes a question "Close without save" and only
    % shows up if changes have been made and not saved yet.
    
end
% Remove the handle value of the main figure from root (handle 0) and
% delete (close) the figure
rmappdata(0, 'h_GUI_CandlesRxSet');
delete(hObject);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% RX MENU FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function menu_File_Callback(hObject, eventdata, handles)
% hObject    handle to menu_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_addRx_Callback(hObject, eventdata, handles)
% hObject    handle to menu_addRx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesRxSet = getappdata(0,'h_GUI_CandlesRxSet');
rxSetEnv           = getappdata(h_GUI_CandlesRxSet,'rxSetEnv');

[rxSetEnv, RX_SELECT]  = rxSetEnv.addRx();

setappdata(h_GUI_CandlesRxSet, 'RX_SELECT', RX_SELECT);
setappdata(h_GUI_CandlesRxSet, 'rxSetEnv', rxSetEnv);
set_values(); % Set the values and display room with selected RX

% --------------------------------------------------------------------
function menu_deleteRx_Callback(hObject, eventdata, handles)
% hObject    handle to menu_deleteRx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
function popup_rx_select_Callback(hObject, eventdata, handles)
% hObject    handle to popup_rx_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesRxSet = getappdata(0,'h_GUI_CandlesRxSet');
RX_SELECT = get(hObject,'Value');
setappdata(h_GUI_CandlesRxSet, 'RX_SELECT', RX_SELECT);
set_values(); % Set the values and display room with selected RX


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% RX LOCATION FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_Rx_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Rx_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesRxSet = getappdata(0,'h_GUI_CandlesRxSet');
RX_SELECT          = getappdata(h_GUI_CandlesRxSet,'RX_SELECT');
rxSetEnv           = getappdata(h_GUI_CandlesRxSet,'rxSetEnv');
temp               = str2double(get(hObject,'String'));

[rxSetEnv, ERR] = rxSetEnv.setRxPos(RX_SELECT,'x',temp);
% FIXME: Add warning boxes for ERR and bring to front after set_values
if (ERR == 0)
    setappdata(h_GUI_CandlesRxSet, 'rxSetEnv', rxSetEnv);
end
set_values();

function edit_Rx_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Rx_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesRxSet = getappdata(0,'h_GUI_CandlesRxSet');
RX_SELECT          = getappdata(h_GUI_CandlesRxSet,'RX_SELECT');
rxSetEnv           = getappdata(h_GUI_CandlesRxSet,'rxSetEnv');
temp               = str2double(get(hObject,'String'));

[rxSetEnv, ERR] = rxSetEnv.setRxPos(RX_SELECT,'y',temp);
% FIXME: Add warning boxes for ERR and bring to front after set_values
if (ERR == 0)
    setappdata(h_GUI_CandlesRxSet, 'rxSetEnv', rxSetEnv);
end
set_values();

function edit_Rx_z_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Rx_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesRxSet = getappdata(0,'h_GUI_CandlesRxSet');
RX_SELECT          = getappdata(h_GUI_CandlesRxSet,'RX_SELECT');
rxSetEnv           = getappdata(h_GUI_CandlesRxSet,'rxSetEnv');
temp               = str2double(get(hObject,'String'));

[rxSetEnv, ERR] = rxSetEnv.setRxPos(RX_SELECT,'z',temp);
% FIXME: Add warning boxes for ERR and bring to front after set_values
if (ERR == 0)
    setappdata(h_GUI_CandlesRxSet, 'rxSetEnv', rxSetEnv);
end
set_values();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% RX ROTATION FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_Rx_az_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Rx_az (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesRxSet = getappdata(0,'h_GUI_CandlesRxSet');
RX_SELECT          = getappdata(h_GUI_CandlesRxSet,'RX_SELECT');
rxSetEnv           = getappdata(h_GUI_CandlesRxSet,'rxSetEnv');
temp               = str2double(get(hObject,'String'));

[rxSetEnv, ERR] = rxSetEnv.setRxPos(RX_SELECT,'az',temp);
% FIXME: Add warning boxes for ERR and bring to front after set_values
if (ERR == 0)
    setappdata(h_GUI_CandlesRxSet, 'rxSetEnv', rxSetEnv);
end
set_values();

function edit_Rx_el_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Rx_el (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesRxSet = getappdata(0,'h_GUI_CandlesRxSet');
RX_SELECT          = getappdata(h_GUI_CandlesRxSet,'RX_SELECT');
rxSetEnv           = getappdata(h_GUI_CandlesRxSet,'rxSetEnv');
temp               = str2double(get(hObject,'String'));

[rxSetEnv, ERR] = rxSetEnv.setRxPos(RX_SELECT,'el',temp);
% FIXME: Add warning boxes for ERR and bring to front after set_values
if (ERR == 0)
    setappdata(h_GUI_CandlesRxSet, 'rxSetEnv', rxSetEnv);
end
set_values();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% ADDITIONAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

    % Set Rotation boxes
    [my_az,my_el] = rxSetEnv.rxs(RX_SELECT).get_angle_deg();
    set(handles.edit_Rx_az,'string',num2str(my_az));
    set(handles.edit_Rx_el,'string',num2str(my_el));

    % Set Rx Selection box
    set(handles.popup_rx_select,'String',1:1:length(rxSetEnv.rxs));
    set(handles.popup_rx_select,'Value',RX_SELECT);

