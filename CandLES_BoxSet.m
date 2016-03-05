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

% Last Modified by GUIDE v2.5 01-Mar-2016 22:49:22

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

% --------------------------------------------------------------------
function menu_Update_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Update (see GCBO)
    update_main_env();

% --------------------------------------------------------------------
function menu_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Edit (see GCBO)

% --------------------------------------------------------------------
function menu_addBox_Callback(hObject, eventdata, handles)
% hObject    handle to menu_addBox (see GCBO)
    h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
    boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');

    [boxSetEnv, BOX_SELECT] = boxSetEnv.addBox();

    setappdata(h_GUI_CandlesBoxSet, 'BOX_SELECT', BOX_SELECT);
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
    set_values(); % Set the values and display room with selected box

% --------------------------------------------------------------------
function menu_deleteBox_Callback(hObject, eventdata, handles)
% hObject    handle to menu_deleteBox (see GCBO)
    h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
    BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
    boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');

    boxSetEnv  = boxSetEnv.removeBox(BOX_SELECT);
    BOX_SELECT = min(BOX_SELECT, length(boxSetEnv.boxes));

    setappdata(h_GUI_CandlesBoxSet, 'BOX_SELECT', BOX_SELECT);
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
    set_values(); % Set the values and display room with selected TX

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% BOX SELECT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function popup_box_select_Callback(hObject, ~, ~)
% hObject    handle to popup_box_select (see GCBO)
    h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
    BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
    if (BOX_SELECT > 0)
        BOX_SELECT = get(hObject,'Value');
        setappdata(h_GUI_CandlesBoxSet, 'BOX_SELECT', BOX_SELECT);
        set_values(); % Set the values and display room with selected TX
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% BOX LOCATION FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function slider_box_x_Callback(hObject, ~, ~)
% hObject    handle to slider_box_x (see GCBO)
    update_pos_slider(hObject, 'x');

function edit_box_x_Callback(hObject, ~, ~)
% hObject    handle to edit_box_x (see GCBO)
    update_pos_edit(hObject, 'x');

% --------------------------------------------------------------------
function slider_box_y_Callback(hObject, ~, ~)
% hObject    handle to slider_box_y (see GCBO)
    update_pos_slider(hObject, 'y');

function edit_box_y_Callback(hObject, ~, ~)
% hObject    handle to edit_box_y (see GCBO)
    update_pos_edit(hObject, 'y');

% --------------------------------------------------------------------
function slider_box_z_Callback(hObject, ~, ~)
% hObject    handle to slider_box_z (see GCBO)
    update_pos_slider(hObject, 'z');

function edit_box_z_Callback(hObject, ~, ~)
% hObject    handle to edit_box_z (see GCBO)
    update_pos_edit(hObject, 'z');


% Update box position based on the change to the slider hObject. 
%    param = {'x', 'y', 'z'}
% --------------------------------------------------------------------
function update_pos_slider(hObject, param)
    h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
    BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
    boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
    temp                = get(hObject,'value');

    boxSetEnv = boxSetEnv.setBoxParam(BOX_SELECT,param,temp);
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
    set_values(); % update GUI
    
% Update box position based on the change to the edit hObject. 
%    param = {'x', 'y', 'z'}
% --------------------------------------------------------------------
function update_pos_edit(hObject, param)
    h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
    BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
    boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
    temp                = str2double(get(hObject,'String'));

    [boxSetEnv,ERR] = boxSetEnv.setBoxParam(BOX_SELECT,param,temp);
    % FIXME: Add warning boxes for ERR and bring to front after set_values
    if (ERR == 0)
        setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
    end
    set_values(); % update GUI
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% BOX SIZE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Box Dimensions
% --------------------------------------------------------------------
function slider_box_length_Callback(hObject, ~, ~)
% hObject    handle to slider_box_length (see GCBO)
    update_size_slider(hObject, 'l');

function edit_box_length_Callback(hObject, ~, ~)
% hObject    handle to edit_box_length (see GCBO)
    update_size_edit(hObject, 'l')

function slider_box_width_Callback(hObject, ~, ~)
% hObject    handle to slider_box_width (see GCBO)
    update_size_slider(hObject, 'w');

function edit_box_width_Callback(hObject, ~, ~)
% hObject    handle to edit_box_width (see GCBO)
    update_size_edit(hObject, 'w')

function slider_box_height_Callback(hObject, ~, ~)
% hObject    handle to slider_box_height (see GCBO)
    update_size_slider(hObject, 'h');

function edit_box_height_Callback(hObject, ~, ~)
% hObject    handle to edit_box_height (see GCBO)
    update_size_edit(hObject, 'h');

% Update box dimensions based on the change to the slider hObject. 
%    param = {'l', 'w', 'h'}
% --------------------------------------------------------------------
function update_size_slider(hObject, param)
    h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
    BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
    boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
    temp                = get(hObject,'value');

    boxSetEnv = boxSetEnv.setBoxParam(BOX_SELECT,param,temp);
    setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
    set_values(); % update GUI
    
% Update box dimensions based on the change to the edit hObject. 
%    param = {'l', 'w', 'h'}
% --------------------------------------------------------------------
function update_size_edit(hObject, param)
    h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
    BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
    boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
    temp                = str2double(get(hObject,'String'));

    [boxSetEnv,ERR] = boxSetEnv.setBoxParam(BOX_SELECT,param,temp);
    % FIXME: Add warning boxes for ERR and bring to front after set_values
    if (ERR == 0)
        setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
    end
    set_values(); % update GUI
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% BOX REFLECTION FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Box Reflections: North / South
% --------------------------------------------------------------------
function slider_RefNorth_Callback(hObject, ~, ~)
% hObject    handle to slider_RefNorth (see GCBO)
    update_ref_slider(hObject, 'ref_N');

function edit_RefNorth_Callback(hObject, ~, ~)
% hObject    handle to edit_RefNorth (see GCBO)
    update_ref_edit(hObject, 'ref_N')

function slider_RefSouth_Callback(hObject, ~, ~)
% hObject    handle to slider_RefSouth (see GCBO)
    update_ref_slider(hObject, 'ref_S');

function edit_RefSouth_Callback(hObject, ~, ~)
% hObject    handle to edit_RefSouth (see GCBO)
    update_ref_edit(hObject, 'ref_S')

% Box Reflections: East / West
% --------------------------------------------------------------------
function slider_RefEast_Callback(hObject, ~, ~)
% hObject    handle to slider_RefEast (see GCBO)
    update_ref_slider(hObject, 'ref_E');

function edit_RefEast_Callback(hObject, ~, ~)
% hObject    handle to edit_RefEast (see GCBO)
    update_ref_edit(hObject, 'ref_E')

function slider_RefWest_Callback(hObject, ~, ~)
% hObject    handle to slider_RefWest (see GCBO)
    update_ref_slider(hObject, 'ref_W');

function edit_RefWest_Callback(hObject, ~, ~)
% hObject    handle to edit_RefWest (see GCBO)
    update_ref_edit(hObject, 'ref_W')

% Box Reflections: Top / Bottom
% --------------------------------------------------------------------
function slider_RefTop_Callback(hObject, ~, ~)
% hObject    handle to slider_RefTop (see GCBO)
    update_ref_slider(hObject, 'ref_T');

function edit_RefTop_Callback(hObject, ~, ~)
% hObject    handle to edit_RefTop (see GCBO)
    update_ref_edit(hObject, 'ref_T')

function slider_RefBottom_Callback(hObject, ~, ~)
% hObject    handle to slider_RefBottom (see GCBO)
    update_ref_slider(hObject, 'ref_B');

function edit_RefBottom_Callback(hObject, ~, ~)
% hObject    handle to edit_RefBottom (see GCBO)
    update_ref_edit(hObject, 'ref_B')

% Update reflectivity values based on the change to the slider hObject. 
%    param = {'ref_N', 'ref_S', 'ref_E', 'ref_W', 'ref_T', 'ref_B'}
% --------------------------------------------------------------------
function update_ref_slider(hObject, param)
    h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
    BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
    boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
    ref                 = get(hObject,'value'); % Get new val

    [boxSetEnv,ERR] = boxSetEnv.setBoxRef(BOX_SELECT,param,ref);
    % FIXME: Add warning boxes for ERR and bring to front after set_values
    if (ERR == 0)
        setappdata(h_GUI_CandlesBoxSet, 'boxSetEnv', boxSetEnv);
    end
    set_values(); % update GUI
    
% Update reflectivity values based on the change to the edit hObject. 
%    param = {'ref_N', 'ref_S', 'ref_E', 'ref_W', 'ref_T', 'ref_B'}
% --------------------------------------------------------------------
function update_ref_edit(hObject, param)
    h_GUI_CandlesBoxSet = getappdata(0,'h_GUI_CandlesBoxSet');
    BOX_SELECT          = getappdata(h_GUI_CandlesBoxSet,'BOX_SELECT');
    boxSetEnv           = getappdata(h_GUI_CandlesBoxSet,'boxSetEnv');
    ref                 = str2double(get(hObject,'String'));

    [boxSetEnv,ERR] = boxSetEnv.setBoxRef(BOX_SELECT,param,ref);
    % FIXME: Add warning boxes for ERR and bring to front after set_values
    if (ERR == 0)
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
        max_x = boxSetEnv.rm.length - my_box.length;
        max_y = boxSetEnv.rm.width  - my_box.width;
        max_z = boxSetEnv.rm.height - my_box.height;
        max_l = boxSetEnv.rm.length - my_box.x;
        max_w = boxSetEnv.rm.width  - my_box.y;
        max_h = boxSetEnv.rm.height - my_box.z;
        
        % Note: need these checks to make sure floating point rounding 
        % errors don't cause the sliders to go out of bounds. Otherwise
        % sliders disappear (if value > max) or errors occur (if the
        % minimum slider step > 1).
        slider_x = min(max_x,my_box.x);
        slider_y = min(max_y,my_box.y);
        slider_z = min(max_z,my_box.z);
        slider_l = min(max_l,my_box.length);
        slider_w = min(max_w,my_box.width);
        slider_h = min(max_h,my_box.height);
        step_x   = [min(1,0.1/max_x), 1/max_x];
        step_y   = [min(1,0.1/max_y), 1/max_y];
        step_z   = [min(1,0.1/max_z), 1/max_z];
        step_l   = [min(1,0.1/max_l), 1/max_l];
        step_w   = [min(1,0.1/max_w), 1/max_w];
        step_h   = [min(1,0.1/max_h), 1/max_h];

        % Set Location boxes
        set(handles.edit_box_x,      'string',       num2str(my_box.x));
        set(handles.edit_box_y,      'string',       num2str(my_box.y));
        set(handles.edit_box_z,      'string',       num2str(my_box.z));

        set(handles.slider_box_x,     'value',                slider_x);
        set(handles.slider_box_y,     'value',                slider_y);
        set(handles.slider_box_z,     'value',                slider_z);
        set(handles.slider_box_x,       'Min',                       0);
        set(handles.slider_box_y,       'Min',                       0);
        set(handles.slider_box_z,       'Min',                       0);
        set(handles.slider_box_x,       'Max',                   max_x);
        set(handles.slider_box_y,       'Max',                   max_y);
        set(handles.slider_box_z,       'Max',                   max_z);
        set(handles.slider_box_x,'SliderStep',                  step_x);
        set(handles.slider_box_y,'SliderStep',                  step_y);
        set(handles.slider_box_z,'SliderStep',                  step_z);
        
        % Set Size boxes
        set(handles.edit_box_length,  'string',  num2str(my_box.length));
        set(handles.edit_box_width ,  'string',   num2str(my_box.width));
        set(handles.edit_box_height,  'string',  num2str(my_box.height));

        set(handles.slider_box_length, 'value',                slider_l);
        set(handles.slider_box_width,  'value',                slider_w);
        set(handles.slider_box_height, 'value',                slider_h);
        set(handles.slider_box_length,   'Min',                       0);
        set(handles.slider_box_width,    'Min',                       0);
        set(handles.slider_box_height,   'Min',                       0);
        set(handles.slider_box_length,   'Max',                   max_l);
        set(handles.slider_box_width,    'Max',                   max_w);
        set(handles.slider_box_height,   'Max',                   max_h);
        set(handles.slider_box_length, 'SliderStep',             step_l);
        set(handles.slider_box_width,  'SliderStep',             step_w);
        set(handles.slider_box_height, 'SliderStep',             step_h);
        
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
        
        % NOTE: Set default slider values this way to avoid errors when a
        % box is added and then removed such that Max < 1.
        X = get(handles.slider_box_x,'Max');
        Y = get(handles.slider_box_y,'Max');
        Z = get(handles.slider_box_z,'Max');
        L = get(handles.slider_box_length,'Max');
        W = get(handles.slider_box_width,'Max');
        H = get(handles.slider_box_height,'Max');

        % Set Location boxes
        set(handles.edit_box_x,      'string', '--');
        set(handles.edit_box_y,      'string', '--');
        set(handles.edit_box_z,      'string', '--');
        
        set(handles.slider_box_x,     'value',    X);
        set(handles.slider_box_y,     'value',    Y);
        set(handles.slider_box_z,     'value',    Z);
        
        % Set Size boxes
        set(handles.edit_box_length, 'string', '--');
        set(handles.edit_box_width , 'string', '--');
        set(handles.edit_box_height, 'string', '--');
        
        set(handles.slider_box_length,'value',    L);
        set(handles.slider_box_width ,'value',    W);
        set(handles.slider_box_height,'value',    H);
        
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





