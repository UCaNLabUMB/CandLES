%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandLES_Template - Template for adding new GUI pages
%    Author: Michael Rahaim
%
%    Description: This template brings (along with CandLES_Template.fig)
%    will open a CandLES GUI subpage and load the images. Open the fig file
%    in GUIDE and save as with the new page name to create a new page.
%
%    NOTE: Change "h_GUI_CandlesTemplate" in the open function and close
%    request function to represent the new page. This is the figure handle
%    that gets stored in root so that the page can be referenced by other
%    pages. You can also rename templateEnv - the candlesEnv variable
%    stored within this GUI - to something that is more representative of
%    the page.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Suppress unnecessary warnings
%#ok<*INUSL>
%#ok<*INUSD>
%#ok<*DEFNU>
function varargout = CandLES_Template(varargin)
% CANDLES_TEMPLATE MATLAB code for CandLES_Template.fig
%      CANDLES_TEMPLATE, by itself, creates a new CANDLES_TEMPLATE or raises the existing
%      singleton*.
%
%      H = CANDLES_TEMPLATE returns the handle to a new CANDLES_TEMPLATE or the handle to
%      the existing singleton*.
%
%      CANDLES_TEMPLATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CANDLES_TEMPLATE.M with the given input arguments.
%
%      CANDLES_TEMPLATE('Property','Value',...) creates a new CANDLES_TEMPLATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CandLES_Template_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CandLES_Template_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CandLES_Template

% Last Modified by GUIDE v2.5 09-Oct-2015 16:33:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CandLES_Template_OpeningFcn, ...
                   'gui_OutputFcn',  @CandLES_Template_OutputFcn, ...
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


% --- Executes just before CandLES_Template is made visible.
function CandLES_Template_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CandLES_Template (see VARARGIN)

% Choose default command line output for CandLES_Template
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Load images using function from CandLES.m
h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
feval(getappdata(h_GUI_CandlesMain,'fhLoadImages'),handles);

% Store the handle value for the figure in root (handle 0)
setappdata(0, 'h_GUI_CandlesTemplate', hObject);

% Generate a temporary CandLES environment and store in the GUI handle so
% that it can be edited without modifying the main environment until saved.
mainEnv   = getappdata(h_GUI_CandlesMain,'mainEnv');
templateEnv = mainEnv;
setappdata(hObject, 'templateEnv', templateEnv);


% --- Outputs from this function are returned to the command line.
function varargout = CandLES_Template_OutputFcn(hObject, ~, handles) 
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
response = questdlg('Close Page?', '','Yes','No','Yes');
if strcmp(response,'Yes')
    % FIXME: Need to store the updated info back to mainEnv or have a save
    % option where this becomes a question "Close without save" and only
    % shows up if changes have been made and not saved yet.
    
    % Remove the handle value of the figure from root (handle 0) and then
    % delete (close) the figure
    rmappdata(0, 'h_GUI_CandlesTemplate');
    delete(hObject);
end
