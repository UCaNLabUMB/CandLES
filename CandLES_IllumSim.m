%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandLES_IllumSim - GUI for showing Illumination results
%    Author: Michael Rahaim
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Suppress unnecessary warnings
%#ok<*INUSL>
%#ok<*INUSD>
%#ok<*DEFNU>
function varargout = CandLES_IllumSim(varargin)
% CANDLES_ILLUMSIM MATLAB code for CandLES_IllumSim.fig
%      CANDLES_ILLUMSIM, by itself, creates a new CANDLES_ILLUMSIM or raises the existing
%      singleton*.
%
%      H = CANDLES_ILLUMSIM returns the handle to a new CANDLES_ILLUMSIM or the handle to
%      the existing singleton*.
%
%      CANDLES_ILLUMSIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CANDLES_ILLUMSIM.M with the given input arguments.
%
%      CANDLES_ILLUMSIM('Property','Value',...) creates a new CANDLES_ILLUMSIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CandLES_IllumSim_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CandLES_IllumSim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CandLES_IllumSim

% Last Modified by GUIDE v2.5 29-Feb-2016 21:58:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CandLES_IllumSim_OpeningFcn, ...
                   'gui_OutputFcn',  @CandLES_IllumSim_OutputFcn, ...
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


% --- Executes just before CandLES_IllumSim is made visible.
function CandLES_IllumSim_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CandLES_IllumSim (see VARARGIN)

% Choose default command line output for CandLES_IllumSim
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Load images using function from CandLES.m
h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
feval(getappdata(h_GUI_CandlesMain,'fhLoadImages'),handles);

% Store the handle value for the figure in root (handle 0)
setappdata(0, 'h_GUI_CandlesIllumSim', hObject);

% Generate a temporary CandLES environment and store in the GUI handle so
% that it can be edited without modifying the main environment until saved.
mainEnv      = getappdata(h_GUI_CandlesMain,'mainEnv');
IllumSimEnv  = mainEnv;
PLANE_SELECT = min(1,mainEnv.rm.height);
ILLUM_RES    = candles_classes.candlesResIllum();
setappdata(hObject, 'IllumSimEnv', IllumSimEnv);
setappdata(hObject, 'PLANE_SELECT', PLANE_SELECT);
setappdata(hObject, 'ILLUM_RES', ILLUM_RES);
set_values(); % Set the values and display environment


% --- Outputs from this function are returned to the command line.
function varargout = CandLES_IllumSim_OutputFcn(hObject, ~, handles) 
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
    % FIXME: Need to add option to save results and add a variable to
    % indicate if the most recent results have been saved.
    
    % Remove the handle value of the figure from root (handle 0) and then
    % delete (close) the figure
    rmappdata(0, 'h_GUI_CandlesIllumSim');
    delete(hObject);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% EDIT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function edit_Plane_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Plane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesIllumSim = getappdata(0,'h_GUI_CandlesIllumSim');
IllumSimEnv           = getappdata(h_GUI_CandlesIllumSim,'IllumSimEnv');
PLANE_SELECT = max(min(str2double(get(hObject,'String')),IllumSimEnv.rm.height),0);
setappdata(h_GUI_CandlesIllumSim, 'PLANE_SELECT', PLANE_SELECT);
set_values(); % Set the values and display room with selected TX

% --------------------------------------------------------------------
function slider_Plane_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Plane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesIllumSim = getappdata(0,'h_GUI_CandlesIllumSim');
IllumSimEnv           = getappdata(h_GUI_CandlesIllumSim,'IllumSimEnv');
PLANE_SELECT = max(min(get(hObject,'Value'),IllumSimEnv.rm.height),0);
setappdata(h_GUI_CandlesIllumSim, 'PLANE_SELECT', PLANE_SELECT);
set_values(); % Set the values and display room with selected TX


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% RESULTS DISPLAY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function pushbutton_GenRes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_GenRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesIllumSim = getappdata(0,'h_GUI_CandlesIllumSim');
IllumSimEnv           = getappdata(h_GUI_CandlesIllumSim,'IllumSimEnv');
PLANE_SELECT          = getappdata(h_GUI_CandlesIllumSim,'PLANE_SELECT');
ILLUM_RES             = getappdata(h_GUI_CandlesIllumSim,'ILLUM_RES');

% Calculate the results if not already stored
if (~ILLUM_RES.results_exist(PLANE_SELECT))
    temp = IllumSimEnv.getIllum(PLANE_SELECT);
    ILLUM_RES = ILLUM_RES.set_results(temp, PLANE_SELECT);
end

setappdata(h_GUI_CandlesIllumSim, 'ILLUM_RES', ILLUM_RES);
set_values(); % Set the values and display room with selected TX


% --------------------------------------------------------------------
function radiobutton_results_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_cdf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_values()


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% ADDITIONAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the values within the GUI
% --------------------------------------------------------------------
function set_values()
    global STR
    h_GUI_CandlesIllumSim = getappdata(0,'h_GUI_CandlesIllumSim');
    IllumSimEnv           = getappdata(h_GUI_CandlesIllumSim,'IllumSimEnv');
    PLANE_SELECT          = getappdata(h_GUI_CandlesIllumSim,'PLANE_SELECT');
    ILLUM_RES             = getappdata(h_GUI_CandlesIllumSim,'ILLUM_RES');
    handles               = guidata(h_GUI_CandlesIllumSim);
    
    % Display room with selected Plane
    IllumSimEnv.display_room(handles.axes_room, 4, PLANE_SELECT);
    
    % Display results
    res_view = get(get(handles.panel_display,'SelectedObject'),'String');
    if (~ILLUM_RES.results_exist(PLANE_SELECT))
        % Display a message on the Results Axis
        cla(handles.axes_results,'reset')
        text(0.23, 0.5, sprintf(STR.MSG30), 'Parent', handles.axes_results);
    else
        if(strcmp(res_view,'Spatial Plane'))
            x = 0:IllumSimEnv.del_p:IllumSimEnv.rm.length;
            y = 0:IllumSimEnv.del_p:IllumSimEnv.rm.width;
            ILLUM_RES.display_plane(x, y, PLANE_SELECT, handles.axes_results);
        elseif(strcmp(res_view,'CDF'))
            ILLUM_RES.display_cdf(PLANE_SELECT, handles.axes_results);
        end
    end
    
    % Set Selection Boxes
    set(handles.edit_Plane,'String',num2str(PLANE_SELECT));
    set(handles.slider_Plane,'Value',PLANE_SELECT);
    set(handles.slider_Plane,'Min',0);
    set(handles.slider_Plane,'Max',IllumSimEnv.rm.height);
    set(handles.slider_Plane,'SliderStep',[0.1/IllumSimEnv.rm.height, ...
                                             1/IllumSimEnv.rm.height]);
    







