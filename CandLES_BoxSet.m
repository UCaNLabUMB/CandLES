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

% Last Modified by GUIDE v2.5 09-Oct-2015 17:52:29

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
setappdata(hObject, 'boxSetEnv', boxSetEnv);


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

% Hint: delete(hObject) closes the figure
response = questdlg('Keep updates?', '','Yes','No','Yes');
if strcmp(response,'Yes')
    % FIXME: Need to store the updated info back to mainEnv or have a save
    % option where this becomes a question "Close without save" and only
    % shows up if changes have been made and not saved yet.
    
end
% Remove the handle value of the main figure from root (handle 0) and
% delete (close) the figure
rmappdata(0, 'h_GUI_CandlesBoxSet');
delete(hObject);


function edit_RmHeight_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RmHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_RmHeight as text
%        str2double(get(hObject,'String')) returns contents of edit_RmHeight as a double

% --- Executes during object creation, after setting all properties.
function edit_RmHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RmHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
mainEnv           = getappdata(h_GUI_CandlesMain,'mainEnv');
set(hObject,'string',num2str(mainEnv.rm.height));
