%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandLES_CommSim - GUI for showing Communications Results
%    Author: Michael Rahaim
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Suppress unnecessary warnings
%#ok<*INUSL>
%#ok<*INUSD>
%#ok<*DEFNU>
function varargout = CandLES_CommSim(varargin)
% CANDLES_COMMSIM MATLAB code for CandLES_CommSim.fig
%      CANDLES_COMMSIM, by itself, creates a new CANDLES_COMMSIM or raises the existing
%      singleton*.
%
%      H = CANDLES_COMMSIM returns the handle to a new CANDLES_COMMSIM or the handle to
%      the existing singleton*.
%
%      CANDLES_COMMSIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CANDLES_COMMSIM.M with the given input arguments.
%
%      CANDLES_COMMSIM('Property','Value',...) creates a new CANDLES_COMMSIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CandLES_CommSim_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CandLES_CommSim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CandLES_CommSim

% Last Modified by GUIDE v2.5 21-Aug-2016 21:14:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CandLES_CommSim_OpeningFcn, ...
                   'gui_OutputFcn',  @CandLES_CommSim_OutputFcn, ...
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


% --- Executes just before CandLES_CommSim is made visible.
function CandLES_CommSim_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CandLES_CommSim (see VARARGIN)

% Choose default command line output for CandLES_CommSim
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Load images using function from CandLES.m
h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
feval(getappdata(h_GUI_CandlesMain,'fhLoadImages'),handles);

% Store the handle value for the figure in root (handle 0)
setappdata(0, 'h_GUI_CandlesCommSim', hObject);

% Generate a temporary CandLES environment and store in the GUI handle so
% that it can be edited without modifying the main environment until saved.
mainEnv       = getappdata(h_GUI_CandlesMain,'mainEnv');
CommSimEnv    = mainEnv;
COMM_RES_RX   = candles_classes.candlesResCommRx();
RX_SELECT     = 0;
TX_GRP_SELECT = 1;
setappdata(hObject, 'COMM_RES_RX', COMM_RES_RX);
setappdata(hObject, 'RX_SELECT', RX_SELECT);
setappdata(hObject, 'TX_GRP_SELECT', TX_GRP_SELECT);
setappdata(hObject, 'CommSimEnv', CommSimEnv);
set_values(); % Set the values and display environment

% --- Outputs from this function are returned to the command line.
function varargout = CandLES_CommSim_OutputFcn(hObject, ~, handles) 
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
global STR 
response = questdlg(STR.MSG29, '',STR.YES,STR.NO,STR.YES);
if strcmp(response,STR.YES)
    % FIXME: Need to store the updated info back to mainEnv or have a save
    % option where this becomes a question "Close without save" and only
    % shows up if changes have been made and not saved yet.
    
    % Remove the handle value of the figure from root (handle 0) and then
    % delete (close) the figure
    rmappdata(0, 'h_GUI_CandlesCommSim');
    delete(hObject);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% EDIT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in pushbutton_GenRes.
function pushbutton_GenRes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_GenRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    h_GUI_CandlesCommSim = getappdata(0,'h_GUI_CandlesCommSim');
    CommSimEnv           = getappdata(h_GUI_CandlesCommSim,'CommSimEnv');
    COMM_RES_RX          = getappdata(h_GUI_CandlesCommSim,'COMM_RES_RX');    
    COMM_RES_RX          = CommSimEnv.run(COMM_RES_RX);
    setappdata(h_GUI_CandlesCommSim, 'COMM_RES_RX', COMM_RES_RX);
    set_values(); % Set the values and update axes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% RESULTS DISPLAY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function popup_rx_select_Callback(hObject, eventdata, handles)
% hObject    handle to popup_rx_select (see GCBO)
    h_GUI_CandlesCommSim = getappdata(0,'h_GUI_CandlesCommSim');
    RX_SELECT            = get(hObject,'Value') - 1;
    setappdata(h_GUI_CandlesCommSim, 'RX_SELECT', RX_SELECT);
    set_values(); % Set the values and update axes

% --------------------------------------------------------------------
function popup_plane_select_Callback(hObject, eventdata, handles)
% hObject    handle to popup_plane_select (see GCBO)
    set_values(); % Set the values and update axes

% --------------------------------------------------------------------
function popup_tx_group_select_Callback(hObject, eventdata, handles)
% hObject    handle to popup_tx_group_select (see GCBO)
    h_GUI_CandlesCommSim = getappdata(0,'h_GUI_CandlesCommSim');
    TX_GRP_SELECT        = get(hObject,'Value');
    setappdata(h_GUI_CandlesCommSim, 'TX_GRP_SELECT', TX_GRP_SELECT);
    set_values(); % Set the values and update axes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% ADDITIONAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Display receiver results on my_ax axes. If RX_SELECT = 0, results of all
% of the receivers are displayed.
% --------------------------------------------------------------------
function display_results_rx(COMM_RES_RX, TX_GRP_SELECT, RX_SELECT, handles, my_ax1, my_ax2)
    global STR
    
    if (~COMM_RES_RX.results_exist())
        % Display a message on the Results Axis
        cla(my_ax1,'reset')
        text(0.23, 0.5, sprintf(STR.MSG30), 'Parent', my_ax1);
        cla(my_ax2,'reset')
        text(0.23, 0.5, sprintf(STR.MSG30), 'Parent', my_ax2);
    else
        % Display the received powers or rms delay spread
        COMM_RES_RX.display_prx(TX_GRP_SELECT, my_ax1);
        
        % Display the impulse response
        COMM_RES_RX.display_h(TX_GRP_SELECT, RX_SELECT, my_ax2);
    end

% Set the values within the GUI
% --------------------------------------------------------------------
function set_values()
    global STR
    h_GUI_CandlesCommSim = getappdata(0,'h_GUI_CandlesCommSim');
    CommSimEnv           = getappdata(h_GUI_CandlesCommSim,'CommSimEnv');
    COMM_RES_RX          = getappdata(h_GUI_CandlesCommSim,'COMM_RES_RX');
    RX_SELECT            = getappdata(h_GUI_CandlesCommSim,'RX_SELECT');
    TX_GRP_SELECT        = getappdata(h_GUI_CandlesCommSim,'TX_GRP_SELECT');
    handles              = guidata(h_GUI_CandlesCommSim);
    
    % Display room with selected receiver
    if (RX_SELECT == 0)
        CommSimEnv.display_room(handles.axes_room, 2, 1:length(CommSimEnv.rxs));
    else
        CommSimEnv.display_room(handles.axes_room, 2, RX_SELECT);
    end
    
    % Display receiver results
    display_results_rx(COMM_RES_RX, TX_GRP_SELECT, RX_SELECT, ...
                       handles, handles.axes_results1, handles.axes_results2);
    
    % Display plane results
    % FIXME: Add plane results class and display functionality
    
    % Set Selection Boxes
    set(handles.popup_rx_select,'String',{STR.MSG31; 1:length(CommSimEnv.rxs)});
    set(handles.popup_rx_select,'Value',RX_SELECT+1);
    
    set(handles.popup_tx_group_select,'String',{1:CommSimEnv.num_groups});
    set(handles.popup_tx_group_select,'Value',TX_GRP_SELECT);
    
