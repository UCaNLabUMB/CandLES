%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandLES - Communication and Lighting Environment Simulator
%    Author: Michael Rahaim
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Suppress unnecessary warnings
%#ok<*INUSL>
%#ok<*INUSD>
%#ok<*DEFNU>
function varargout = CandLES(varargin)
% CANDLES MATLAB code for CandLES.fig
%      CANDLES, by itself, creates a new CANDLES or raises the existing
%      singleton*.
%
%      H = CANDLES returns the handle to a new CANDLES or the handle to
%      the existing singleton*.
%
%      CANDLES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CANDLES.M with the given input arguments.
%
%      CANDLES('Property','Value',...) creates a new CANDLES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CandLES_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CandLES_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CandLES

% Last Modified by GUIDE v2.5 26-Feb-2016 15:11:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CandLES_OpeningFcn, ...
                   'gui_OutputFcn',  @CandLES_OutputFcn, ...
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


% --- Executes just before CandLES is made visible.
function CandLES_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CandLES (see VARARGIN)

% Choose default command line output for CandLES
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Load GUI images (logos)
load_images(handles);

% Store the handle value for the main figure in root (handle 0)
setappdata(0, 'h_GUI_CandlesMain', hObject);

% Generate default environment, store in the GUI handle, and setup GUI
mainEnv = candles_classes.candlesEnv();
setappdata(hObject, 'mainEnv', mainEnv);
set_values();

% Store functions to be called externally
setappdata(hObject,  'fhLoadImages', @load_images);
setappdata(hObject,   'fhSetValues', @set_values );
setappdata(hObject,  'fhUpdateMain', @update_main);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles) 
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

response = questdlg('Are you sure you want to exit?', '','Yes','No','Yes');
if strcmp(response,'Yes')
    % Remove the handle value of the main figure from root (handle 0) and
    % delete (close) the figure
    rmappdata(0, 'h_GUI_CandlesMain');
    delete(hObject);
end

% --- Outputs from this function are returned to the command line.
function varargout = CandLES_OutputFcn(hObject, eventdata, handles)  
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% MENU CALLBACKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Menu ----------------------------------------------------------
% --------------------------------------------------------------------
function menu_Save_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Save (see GCBO)
    h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
    mainEnv           = getappdata(h_GUI_CandlesMain,'mainEnv'); %#ok<NASGU>

    [FileName, PathName] = uiputfile('*.mat');
    if FileName ~= 0
        save([PathName FileName], 'mainEnv');
    end

function menu_Load_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Load (see GCBO)
    [FileName, PathName] = uigetfile('*.mat');
    if FileName ~= 0
        load([PathName FileName])
        % FIXME: Should validate the content of the loaded mainEnv
        if exist('mainEnv','var')
            h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
            setappdata(h_GUI_CandlesMain, 'mainEnv', mainEnv);
            set_values();
        else
            warndlg('Invalid .mat file. CandLES Environment does not exist');
        end
    end

function menu_Clear_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Clear (see GCBO)
    response = questdlg('Clear the current configuration?', ...
                        'Clear Configuration', 'Yes', 'No', 'Yes');
    % NOTE: Apparently questdlg alway returns the default when 'Enter' is
    % pressed, even if you tab to a different selection. (Spacebar works)
    if strcmp(response,'Yes')
        mainEnv = candles_classes.candlesEnv();
        h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
        setappdata(h_GUI_CandlesMain, 'mainEnv', mainEnv);
        set_values();
    end

function menu_Print_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Print (see GCBO)
    % FIXME: Add Print feature
    helpdlg('This feature has not yet been added.');

% Edit Menu ----------------------------------------------------------
% --------------------------------------------------------------------
function menu_TxSet_Callback(hObject, eventdata, handles)
% hObject    handle to menu_TxSet (see GCBO)
    CandLES_TxSet();

function menu_RxSet_Callback(hObject, eventdata, handles)
% hObject    handle to menu_RxSet (see GCBO)
    CandLES_RxSet();

function menu_BoxSet_Callback(hObject, eventdata, handles)
% hObject    handle to menu_BoxSet (see GCBO)
    CandLES_BoxSet();

function menu_SimSet_Callback(hObject, eventdata, handles)
% hObject    handle to menu_SimSet (see GCBO)
    CandLES_SimSet();

% Results Menu -------------------------------------------------------   
% --------------------------------------------------------------------
function menu_IllumSim_Callback(hObject, eventdata, handles)
% hObject    handle to menu_IllumSim (see GCBO)
    CandLES_IllumSim();

function menu_CommSim_Callback(hObject, eventdata, handles)
% hObject    handle to menu_CommSim (see GCBO)
    CandLES_CommSim();

% Help Menu ----------------------------------------------------------    
% --------------------------------------------------------------------
function menu_About_Callback(hObject, eventdata, handles)
% hObject    handle to menu_About (see GCBO)
helpdlg(['CandLES is a simulation tool for indoor optical wireless ' ...
         'communication systems. The software was developed at Boston '...
         'University as part of the NSF funded Smart Lighting '...
         'Engineering Research Center. '], 'About CandLES');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROOM SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in pushbutton_disp_room.
function pushbutton_disp_room_Callback(~, ~, ~)
    h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
    mainEnv           = getappdata(h_GUI_CandlesMain,'mainEnv');
    figure();
    SYS_display_room(axes(), mainEnv)


% Room Size ----------------------------------------------------------
% --------------------------------------------------------------------
function edit_RmLength_Callback(hObject, ~, ~)
% hObject    handle to edit_RmLength (see GCBO)
    update_size_edit(hObject, 'l');
    
function edit_RmWidth_Callback(hObject, ~, ~)
% hObject    handle to edit_RmWidth (see GCBO)
    update_size_edit(hObject, 'w');

function edit_RmHeight_Callback(hObject, ~, ~)
% hObject    handle to edit_RmHeight (see GCBO)
    update_size_edit(hObject, 'h');

% Update room size based on the change to the edit hObject. 
%    param = {'l', 'w', 'h'}
function update_size_edit(hObject, param)
    h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
    mainEnv           = getappdata(h_GUI_CandlesMain,'mainEnv');
    temp              = str2double(get(hObject,'String'));

    [mainEnv, ERR] = mainEnv.setRoomDim(param,temp);
    % FIXME: Add warning boxes for ERR and bring to front after set_values
    if (ERR == 0)
        setappdata(h_GUI_CandlesMain, 'mainEnv', mainEnv);
    end
    set_values();


% Room Reflections ---------------------------------------------------
% --------------------------------------------------------------------
function slider_RefNorth_Callback(hObject, ~, ~)
% hObject    handle to slider_RefNorth (see GCBO)
    update_ref_slider(hObject, 'N');

function edit_RefNorth_Callback(hObject, ~, ~)
% hObject    handle to edit_RefNorth (see GCBO)
    update_ref_edit(hObject, 'N');

function slider_RefSouth_Callback(hObject, ~, ~)
% hObject    handle to slider_RefSouth (see GCBO)
    update_ref_slider(hObject, 'S');

function edit_RefSouth_Callback(hObject, ~, ~)
% hObject    handle to edit_RefSouth (see GCBO)
    update_ref_edit(hObject, 'S');

function slider_RefEast_Callback(hObject, ~, ~)
% hObject    handle to slider_RefEast (see GCBO)
    update_ref_slider(hObject, 'E');

function edit_RefEast_Callback(hObject, ~, ~)
% hObject    handle to edit_RefEast (see GCBO)
    update_ref_edit(hObject, 'E');

function slider_RefWest_Callback(hObject, ~, ~)
% hObject    handle to slider_RefWest (see GCBO)
    update_ref_slider(hObject, 'W');

function edit_RefWest_Callback(hObject, ~, ~)
% hObject    handle to edit_RefWest (see GCBO)
    update_ref_edit(hObject, 'W');

function slider_RefTop_Callback(hObject, ~, ~)
% hObject    handle to slider_RefTop (see GCBO)
    update_ref_slider(hObject, 'T');

function edit_RefTop_Callback(hObject, ~, ~)
% hObject    handle to edit_RefTop (see GCBO)
    update_ref_edit(hObject, 'T');

function slider_RefBottom_Callback(hObject, ~, ~)
% hObject    handle to slider_RefBottom (see GCBO)
    update_ref_slider(hObject, 'B');

function edit_RefBottom_Callback(hObject, ~, ~)
% hObject    handle to edit_RefBottom (see GCBO)
    update_ref_edit(hObject, 'B');

% Update reflectivity values based on the change to the slider hObject. 
%    param = {'N', 'S', 'E', 'W', 'T', 'B'}
function update_ref_slider(hObject, param)
    h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
    mainEnv           = getappdata(h_GUI_CandlesMain,'mainEnv');
    temp              = get(hObject,'value'); % Get new value

    mainEnv = mainEnv.setRoomRef(param,temp);
    setappdata(h_GUI_CandlesMain, 'mainEnv', mainEnv);
    set_values();
    
% Update reflectivity values based on the change to the edit hObject. 
%    param = {'N', 'S', 'E', 'W', 'T', 'B'}
function update_ref_edit(hObject, param)
    h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
    mainEnv           = getappdata(h_GUI_CandlesMain,'mainEnv');
    temp              = str2double(get(hObject,'String'));

    [mainEnv, ERR] = mainEnv.setRoomRef(param,temp);
    % FIXME: Add warning boxes for ERR and bring to front after set_values
    if (ERR == 0)
        setappdata(h_GUI_CandlesMain, 'mainEnv', mainEnv);
    end
    set_values();

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% ADDITIONAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load Images
% --------------------------------------------------------------------
function load_images(guiHandle)
    axes(guiHandle.logo_NSF);
    image(importdata('GUI_Images/pic_NSF_logo.bmp')); axis off;
    axes(guiHandle.logo_BU);
    image(importdata('GUI_Images/pic_BU_logo.bmp')); axis off;
    axes(guiHandle.logo_SL);
    image(importdata('GUI_Images/pic_SL_logo.bmp')); axis off;

% Update the main GUI with the CandLES environment newEnv
% --------------------------------------------------------------------
function update_main(newEnv)
    h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
    mainEnv = newEnv; %FIXME: Add error check here?

    setappdata(h_GUI_CandlesMain, 'mainEnv', mainEnv);
    set_values();
    
% Set the values within the GUI
% --------------------------------------------------------------------
function set_values()
    h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
    mainEnv           = getappdata(h_GUI_CandlesMain,'mainEnv');
    handles           = guidata(h_GUI_CandlesMain);
    
    SYS_display_room(handles.axes_room, mainEnv)
    
    % Room Settings
    set(handles.edit_RmLength,'string', num2str(mainEnv.rm.length));
    set(handles.edit_RmWidth, 'string',  num2str(mainEnv.rm.width));
    set(handles.edit_RmHeight,'string', num2str(mainEnv.rm.height));

    set(handles.edit_RefNorth, 'string', mainEnv.rm.ref(1,1));
    set(handles.edit_RefSouth, 'string', mainEnv.rm.ref(1,2)); 
    set(handles.edit_RefEast,  'string', mainEnv.rm.ref(2,1));
    set(handles.edit_RefWest,  'string', mainEnv.rm.ref(2,2));
    set(handles.edit_RefTop,   'string', mainEnv.rm.ref(3,1));
    set(handles.edit_RefBottom,'string', mainEnv.rm.ref(3,2));
    
    set(handles.slider_RefNorth, 'value', mainEnv.rm.ref(1,1));
    set(handles.slider_RefSouth, 'value', mainEnv.rm.ref(1,2));
    set(handles.slider_RefEast,  'value', mainEnv.rm.ref(2,1));
    set(handles.slider_RefWest,  'value', mainEnv.rm.ref(2,2));
    set(handles.slider_RefTop,   'value', mainEnv.rm.ref(3,1));
    set(handles.slider_RefBottom,'value', mainEnv.rm.ref(3,2));





