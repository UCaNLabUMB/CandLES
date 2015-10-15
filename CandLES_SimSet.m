%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandLES_SimSet - GUI for updating CandLES simulation settings.
%    Author: Michael Rahaim
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Suppress unnecessary warnings
%#ok<*INUSL>
%#ok<*INUSD>
%#ok<*DEFNU>
function varargout = CandLES_SimSet(varargin)
% CANDLES_SIMSET MATLAB code for CandLES_SimSet.fig
%      CANDLES_SIMSET, by itself, creates a new CANDLES_SIMSET or raises the existing
%      singleton*.
%
%      H = CANDLES_SIMSET returns the handle to a new CANDLES_SIMSET or the handle to
%      the existing singleton*.
%
%      CANDLES_SIMSET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CANDLES_SIMSET.M with the given input arguments.
%
%      CANDLES_SIMSET('Property','Value',...) creates a new CANDLES_SIMSET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CandLES_SimSet_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CandLES_SimSet_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CandLES_SimSet

% Last Modified by GUIDE v2.5 08-Oct-2015 12:21:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CandLES_SimSet_OpeningFcn, ...
                   'gui_OutputFcn',  @CandLES_SimSet_OutputFcn, ...
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


% --- Executes just before CandLES_SimSet is made visible.
function CandLES_SimSet_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CandLES_SimSet (see VARARGIN)

% Choose default command line output for CandLES_SimSet
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Load images using function from CandLES.m
h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
feval(getappdata(h_GUI_CandlesMain,'fhLoadImages'),handles);

% Store the handle value for the figure in root (handle 0)
setappdata(0, 'h_GUI_CandlesSimSet', hObject);

% Generate a temporary CandLES environment and store in the GUI handle so
% that it can be edited without modifying the main environment until saved.
mainEnv   = getappdata(h_GUI_CandlesMain,'mainEnv');
simSetEnv = mainEnv;
setappdata(hObject, 'simSetEnv', simSetEnv);


% --- Outputs from this function are returned to the command line.
function varargout = CandLES_SimSet_OutputFcn(hObject, ~, handles) 
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
rmappdata(0, 'h_GUI_CandlesSimSet');
delete(hObject);


function edit_del_t_Callback(hObject, ~, handles)
% hObject    handle to edit_del_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_del_t as text
%        str2double(get(hObject,'String')) returns contents of edit_del_t as a double


% --- Executes during object creation, after setting all properties.
function edit_del_t_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_del_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
mainEnv           = getappdata(h_GUI_CandlesMain,'mainEnv');
set(hObject,'string',num2str(mainEnv.del_t));
