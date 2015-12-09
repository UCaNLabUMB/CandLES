%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandLES_BoxSet - GUI for updating CandLES box settings.
%    Author: Michael Rahaim
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Suppress unnecessary warnings
%#ok<*INUSL>
%#ok<*INUSD>
%#ok<*DEFNU>
function varargout = CandLES_BoxSet(varargin)
% CANDLES_BOXSET MATLAB code for CandLES_BoxSet.fig
%      CANDLES_BOXSET, by itself, creates a new CANDLES_BOXSET or raises the existing
%      singleton*.
%
%      H = CANDLES_BOXSET returns the handle to a new CANDLES_BOXSET or the handle to
%      the existing singleton*.
%
%      CANDLES_BOXSET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CANDLES_BOXSET.M with the given input arguments.
%
%      CANDLES_BOXSET('Property','Value',...) creates a new CANDLES_BOXSET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CandLES_BoxSet_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CandLES_BoxSet_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CandLES_BoxSet

% Last Modified by GUIDE v2.5 09-Dec-2015 15:28:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CandLES_BoxSet_OpeningFcn, ...
                   'gui_OutputFcn',  @CandLES_BoxSet_OutputFcn, ...
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


% --- Executes just before CandLES_BoxSet is made visible.
function CandLES_BoxSet_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CandLES_BoxSet (see VARARGIN)

% Choose default command line output for CandLES_BoxSet
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Load images using function from CandLES.m
h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
feval(getappdata(h_GUI_CandlesMain,'fhLoadImages'),handles);

% Store the handle value for the figure in root (handle 0)
setappdata(0, 'h_GUI_CandlesBoxSet', hObject);

% Generate a temporary CandLES environment and store in the GUI handle so
% that it can be edited without modifying the main environment until saved.
mainEnv   = getappdata(h_GUI_CandlesMain,'mainEnv');
boxSetEnv  = mainEnv;
if isempty(boxSetEnv.boxes)
    BOX_SELECT = 0; % Set BOX_SELECT to 0 when no boxes exist.
else
    BOX_SELECT = 1;
end    
setappdata(hObject, 'boxSetEnv', boxSetEnv);
setappdata(hObject, 'BOX_SELECT', BOX_SELECT);
set_values(); % Set the values and display environment


% --- Outputs from this function are returned to the command line.
function varargout = CandLES_BoxSet_OutputFcn(hObject, ~, handles) 
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
h_GUI_CandlesMain   = getappdata(0,'h_GUI_CandlesMain');
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
mainEnv             = getappdata(h_GUI_CandlesMain,'mainEnv');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');

if (~isequal(mainEnv,boxSetEnv))
    response = questdlg('Keep updates?', '','Yes','No','Yes');
    if strcmp(response,'Yes')
        update_main_env();
    end
end
% Remove the handle value of the main figure from root (handle 0) and
% delete (close) the figure
rmappdata(0, 'h_GUI_CandlesBoxSet');
delete(hObject); % Close the figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% BOX MENU FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function menu_File_Callback(hObject, eventdata, handles)
% hObject    handle to menu_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_Update_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_main_env();

% --------------------------------------------------------------------
function menu_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_addBox_Callback(hObject, eventdata, handles)
% hObject    handle to menu_addBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');

my_boxes = boxSetEnv.boxes;
my_boxes(length(my_boxes)+1) = candles_classes.box();
% FIXME: Check room bounds to make sure the new box is in the room

BOX_SELECT      = length(my_boxes);
boxSetEnv.boxes = my_boxes;
setappdata(h_GUI_CandlesBoxSet, 'BOX_SELECT', BOX_SELECT);
setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
set_values(); % Set the values and display room with selected box

% --------------------------------------------------------------------
function menu_deleteBox_Callback(hObject, eventdata, handles)
% hObject    handle to menu_deleteBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');

my_boxes = boxSetEnv.boxes;
if(~isempty(my_boxes))
    my_boxes(BOX_SELECT) = [];
    BOX_SELECT = min(BOX_SELECT, length(my_boxes));
    boxSetEnv.boxes = my_boxes;
    setappdata(h_GUI_CandlesBoxSet, 'BOX_SELECT', BOX_SELECT);
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
    set_values(); % Set the values and display room with selected TX
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% BOX SELECT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function popup_box_select_Callback(hObject, eventdata, handles)
% hObject    handle to popup_box_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT           = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
if (BOX_SELECT > 0)
    BOX_SELECT = get(hObject,'Value');
    setappdata(h_GUI_CandlesBoxSet, 'BOX_SELECT', BOX_SELECT);
    set_values(); % Set the values and display room with selected TX
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% BOX LOCATION FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_box_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_box_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');

temp = str2double(get(hObject,'String'));
if (BOX_SELECT > 0) && (~isnan(temp)) && (isreal(temp))
    % FIXME: Add warning dialog boxes for out of range
    temp = max(temp, 0);
    temp = min(temp,boxSetEnv.rm.length ...
                     - boxSetEnv.boxes(BOX_SELECT).length);

    % Set the correct value in txSetEnv and save to handle
    boxSetEnv.boxes(BOX_SELECT) = boxSetEnv.boxes(BOX_SELECT).set_x(temp);
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI

function edit_box_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_box_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');

temp = str2double(get(hObject,'String'));
if (BOX_SELECT > 0) && (~isnan(temp)) && (isreal(temp))
    % FIXME: Add warning dialog boxes for out of range
    temp = max(temp, 0);
    temp = min(temp,boxSetEnv.rm.width ...
                     - boxSetEnv.boxes(BOX_SELECT).width);

    % Set the correct value in txSetEnv and save to handle
    boxSetEnv.boxes(BOX_SELECT) = boxSetEnv.boxes(BOX_SELECT).set_y(temp);
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI

function edit_box_z_Callback(hObject, eventdata, handles)
% hObject    handle to edit_box_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');

temp = str2double(get(hObject,'String'));
if (BOX_SELECT > 0) && (~isnan(temp)) && (isreal(temp))
    % FIXME: Add warning dialog boxes for out of range
    temp = max(temp, 0);
    temp = min(temp,boxSetEnv.rm.height ...
                     - boxSetEnv.boxes(BOX_SELECT).height);

    % Set the correct value in txSetEnv and save to handle
    boxSetEnv.boxes(BOX_SELECT) = boxSetEnv.boxes(BOX_SELECT).set_z(temp);
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% BOX SIZE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_box_length_Callback(hObject, eventdata, handles)
% hObject    handle to edit_box_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');

temp = str2double(get(hObject,'String'));
if (BOX_SELECT > 0) && (~isnan(temp)) && (isreal(temp))
    % FIXME: Add warning dialog boxes for out of range
    temp = max(temp, 0.1);
    temp = min(temp,boxSetEnv.rm.length ...
                     - boxSetEnv.boxes(BOX_SELECT).x);

    % Set the correct value in txSetEnv and save to handle 
    boxSetEnv.boxes(BOX_SELECT) = boxSetEnv.boxes(BOX_SELECT).set_length(temp);
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI

function edit_box_width_Callback(hObject, eventdata, handles)
% hObject    handle to edit_box_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');

temp = str2double(get(hObject,'String'));
if (BOX_SELECT > 0) && (~isnan(temp)) && (isreal(temp))
    % FIXME: Add warning dialog boxes for out of range
    temp = max(temp, 0.1);
    temp = min(temp,boxSetEnv.rm.width ...
                     - boxSetEnv.boxes(BOX_SELECT).y);

    % Set the correct value in txSetEnv and save to handle 
    boxSetEnv.boxes(BOX_SELECT) = boxSetEnv.boxes(BOX_SELECT).set_width(temp);
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI

function edit_box_height_Callback(hObject, eventdata, handles)
% hObject    handle to edit_box_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');

temp = str2double(get(hObject,'String'));
if (BOX_SELECT > 0) && (~isnan(temp)) && (isreal(temp))
    % FIXME: Add warning dialog boxes for out of range
    temp = max(temp, 0.1);
    temp = min(temp,boxSetEnv.rm.height ...
                     - boxSetEnv.boxes(BOX_SELECT).z);

    % Set the correct value in txSetEnv and save to handle 
    boxSetEnv.boxes(BOX_SELECT) = boxSetEnv.boxes(BOX_SELECT).set_height(temp);
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% BOX REFLECTION FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Box Reflections: North
% --------------------------------------------------------------------
function slider_RefNorth_Callback(hObject, eventdata, handles)
% hObject    handle to slider_RefNorth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
ref                 = get(hObject,'value'); % Get new val

if (BOX_SELECT > 0)
    % Set the correct value in boxSetEnv, update GUI and save to GUI handle
    boxSetEnv.boxes(BOX_SELECT).ref(1,1) = ref;
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI

function edit_RefNorth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RefNorth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
ref                 = str2double(get(hObject,'String'));

if (BOX_SELECT > 0) && (~isnan(ref)) && (isreal(ref))
    ref = max(ref,0);
    ref = min(ref,1);
    
    % Set the correct value in boxSetEnv, update GUI and save to GUI handle
    boxSetEnv.boxes(BOX_SELECT).ref(1,1) = ref;
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI

% Box Reflections: South
% --------------------------------------------------------------------
function slider_RefSouth_Callback(hObject, eventdata, handles)
% hObject    handle to slider_RefSouth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
ref                 = get(hObject,'value'); % Get new val
    
if (BOX_SELECT > 0)
    % Set the correct value in boxSetEnv, update GUI and save to GUI handle
    boxSetEnv.boxes(BOX_SELECT).ref(1,2) = ref;
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI

function edit_RefSouth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RefSouth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
ref                 = str2double(get(hObject,'String'));

if (BOX_SELECT > 0) && (~isnan(ref)) && (isreal(ref))
    ref = max(ref,0);
    ref = min(ref,1);
    
    % Set the correct value in boxSetEnv, update GUI and save to GUI handle
    boxSetEnv.boxes(BOX_SELECT).ref(1,2) = ref;
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI


% Box Reflections: East
% --------------------------------------------------------------------
function slider_RefEast_Callback(hObject, eventdata, handles)
% hObject    handle to slider_RefEast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
ref                 = get(hObject,'value'); % Get new val
    
if (BOX_SELECT > 0)
    % Set the correct value in boxSetEnv, update GUI and save to GUI handle
    boxSetEnv.boxes(BOX_SELECT).ref(2,1) = ref;
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI

function edit_RefEast_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RefEast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
ref                 = str2double(get(hObject,'String'));

if (BOX_SELECT > 0) && (~isnan(ref)) && (isreal(ref))
    ref = max(ref,0);
    ref = min(ref,1);
    
    % Set the correct value in boxSetEnv, update GUI and save to GUI handle
    boxSetEnv.boxes(BOX_SELECT).ref(2,1) = ref;
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI


% Box Reflections: West
% --------------------------------------------------------------------
function slider_RefWest_Callback(hObject, eventdata, handles)
% hObject    handle to slider_RefWest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
ref                 = get(hObject,'value'); % Get new val
    
if (BOX_SELECT > 0)
    % Set the correct value in boxSetEnv, update GUI and save to GUI handle
    boxSetEnv.boxes(BOX_SELECT).ref(2,2) = ref;
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI

function edit_RefWest_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RefWest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
ref                 = str2double(get(hObject,'String'));

if (BOX_SELECT > 0) && (~isnan(ref)) && (isreal(ref))
    ref = max(ref,0);
    ref = min(ref,1);
    
    % Set the correct value in boxSetEnv, update GUI and save to GUI handle
    boxSetEnv.boxes(BOX_SELECT).ref(2,2) = ref;
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI



% Box Reflections: Top
% --------------------------------------------------------------------
function slider_RefTop_Callback(hObject, eventdata, handles)
% hObject    handle to slider_RefTop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
ref                 = get(hObject,'value'); % Get new val
    
if (BOX_SELECT > 0)
    % Set the correct value in boxSetEnv, update GUI and save to GUI handle
    boxSetEnv.boxes(BOX_SELECT).ref(3,1) = ref;
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI

function edit_RefTop_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RefTop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
ref                 = str2double(get(hObject,'String'));

if (BOX_SELECT > 0) && (~isnan(ref)) && (isreal(ref))
    ref = max(ref,0);
    ref = min(ref,1);
    
    % Set the correct value in boxSetEnv, update GUI and save to GUI handle
    boxSetEnv.boxes(BOX_SELECT).ref(3,1) = ref;
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI


% Box Reflections: Bottom
% --------------------------------------------------------------------
function slider_RefBottom_Callback(hObject, eventdata, handles)
% hObject    handle to slider_RefBottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
ref                 = get(hObject,'value'); % Get new val
    
if (BOX_SELECT > 0)
    % Set the correct value in boxSetEnv, update GUI and save to GUI handle
    boxSetEnv.boxes(BOX_SELECT).ref(3,2) = ref;
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI

function edit_RefBottom_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RefBottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
ref                 = str2double(get(hObject,'String'));

if (BOX_SELECT > 0) && (~isnan(ref)) && (isreal(ref))
    ref = max(ref,0);
    ref = min(ref,1);
    
    % Set the correct value in boxSetEnv, update GUI and save to GUI handle
    boxSetEnv.boxes(BOX_SELECT).ref(3,2) = ref;
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
end
set_values(); % update GUI


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% ADDITIONAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Call the update_main function from CandLES.m
% --------------------------------------------------------------------
function update_main_env()
    h_GUI_CandlesMain    = getappdata(0,'h_GUI_CandlesMain');
    h_GUI_CandlesBoxSet  = getappdata(0,'h_GUI_CandlesBoxSet');
    boxSetEnv            = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
    feval(getappdata(h_GUI_CandlesMain,'fhUpdateMain'),boxSetEnv);
    figure(h_GUI_CandlesBoxSet); %Bring the Box GUI back to the front
    
% Set the values within the GUI
% --------------------------------------------------------------------
function set_values()
    h_GUI_CandlesBoxSet  = getappdata(0,'h_GUI_CandlesBoxSet');
    BOX_SELECT           = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
    boxSetEnv            = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
    handles              = guidata(h_GUI_CandlesBoxSet);
    
    if (BOX_SELECT > 0)
        % Display room with selected Box
        SYS_display_room(handles.axes_room, boxSetEnv, 3, BOX_SELECT);
        my_box = boxSetEnv.boxes(BOX_SELECT);

        % Set Location boxes
        set(handles.edit_box_x,      'string',       num2str(my_box.x));
        set(handles.edit_box_y,      'string',       num2str(my_box.y));
        set(handles.edit_box_z,      'string',       num2str(my_box.z));

        % Set Size boxes
        set(handles.edit_box_length, 'string',  num2str(my_box.length));
        set(handles.edit_box_width , 'string',   num2str(my_box.width));
        set(handles.edit_box_height, 'string',  num2str(my_box.height));

        % Set Box Reflectivities
        set(handles.edit_RefNorth,   'string',         my_box.ref(1,1));
        set(handles.edit_RefSouth,   'string',         my_box.ref(1,2)); 
        set(handles.edit_RefEast,    'string',         my_box.ref(2,1));
        set(handles.edit_RefWest,    'string',         my_box.ref(2,2));
        set(handles.edit_RefTop,     'string',         my_box.ref(3,1));
        set(handles.edit_RefBottom,  'string',         my_box.ref(3,2));

        set(handles.slider_RefNorth,  'value',         my_box.ref(1,1));
        set(handles.slider_RefSouth,  'value',         my_box.ref(1,2));
        set(handles.slider_RefEast,   'value',         my_box.ref(2,1));
        set(handles.slider_RefWest,   'value',         my_box.ref(2,2));
        set(handles.slider_RefTop,    'value',         my_box.ref(3,1));
        set(handles.slider_RefBottom, 'value',         my_box.ref(3,2));

        % Set Box Selection box
        set(handles.popup_box_select,'String',1:1:length(boxSetEnv.boxes));
        set(handles.popup_box_select,'Value',BOX_SELECT);
    else
        % Display room with selected Box
        SYS_display_room(handles.axes_room, boxSetEnv, 0);

        % Set Location boxes
        set(handles.edit_box_x,      'string', '--');
        set(handles.edit_box_y,      'string', '--');
        set(handles.edit_box_z,      'string', '--');

        % Set Size boxes
        set(handles.edit_box_length, 'string', '--');
        set(handles.edit_box_width , 'string', '--');
        set(handles.edit_box_height, 'string', '--');
        
        % Set box Reflectivities
        set(handles.edit_RefNorth,   'string', '--');
        set(handles.edit_RefSouth,   'string', '--');
        set(handles.edit_RefEast,    'string', '--');
        set(handles.edit_RefWest,    'string', '--');
        set(handles.edit_RefTop,     'string', '--');
        set(handles.edit_RefBottom,  'string', '--');

        set(handles.slider_RefNorth, 'value',     1);
        set(handles.slider_RefSouth, 'value',     1);
        set(handles.slider_RefEast,  'value',     1);
        set(handles.slider_RefWest,  'value',     1);
        set(handles.slider_RefTop,   'value',     1);
        set(handles.slider_RefBottom,'value',     1);        
        
        % Set Box Selection box
        set(handles.popup_box_select,'String','BOX SELECT');
        set(handles.popup_box_select,'Value',1);
    end





