%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandLES_TxSet - GUI for updating CandLES Transmitter settings.
%    Author: Michael Rahaim
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Suppress unnecessary warnings
%#ok<*INUSL>
%#ok<*INUSD>
%#ok<*DEFNU>
function varargout = CandLES_TxSet(varargin)
% CANDLES_TXSET MATLAB code for CandLES_TxSet.fig
%      CANDLES_TXSET, by itself, creates a new CANDLES_TXSET or raises the existing
%      singleton*.
%
%      H = CANDLES_TXSET returns the handle to a new CANDLES_TXSET or the handle to
%      the existing singleton*.
%
%      CANDLES_TXSET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CANDLES_TXSET.M with the given input arguments.
%
%      CANDLES_TXSET('Property','Value',...) creates a new CANDLES_TXSET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CandLES_TxSet_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CandLES_TxSet_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CandLES_TxSet

% Last Modified by GUIDE v2.5 07-Mar-2016 22:39:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CandLES_TxSet_OpeningFcn, ...
                   'gui_OutputFcn',  @CandLES_TxSet_OutputFcn, ...
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


% --- Executes just before CandLES_TxSet is made visible.
function CandLES_TxSet_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CandLES_TxSet (see VARARGIN)

% Choose default command line output for CandLES_TxSet
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Load images using function from CandLES.m
h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
feval(getappdata(h_GUI_CandlesMain,'fhLoadImages'),handles);

% Store the handle value for the figure in root (handle 0)
setappdata(0, 'h_GUI_CandlesTxSet', hObject);

% Generate a temporary CandLES environment and store in the GUI handle so
% that it can be edited without modifying the main environment until saved.
mainEnv   = getappdata(h_GUI_CandlesMain,'mainEnv');
txSetEnv  = mainEnv;
TX_SELECT = 1;
setappdata(hObject, 'txSetEnv', txSetEnv);
setappdata(hObject, 'TX_SELECT', TX_SELECT);
set_values(); % Set the values and display environment


% --- Outputs from this function are returned to the command line.
function varargout = CandLES_TxSet_OutputFcn(hObject, ~, handles) 
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
h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
mainEnv            = getappdata(h_GUI_CandlesMain,'mainEnv');
txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');

if (~isequal(mainEnv,txSetEnv))
    response = questdlg('Keep updates?', '','Yes','No','Yes');
    if strcmp(response,'Yes')
        update_main_env();
    end
end
% Remove the handle value of the main figure from root (handle 0) and
% delete (close) the figure
rmappdata(0, 'h_GUI_CandlesTxSet');
delete(hObject); % Close the figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% TX MENU FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function menu_Update_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Update (see GCBO)
    update_main_env();

% --------------------------------------------------------------------
function menu_addTx_Callback(hObject, eventdata, handles)
% hObject    handle to menu_addTx (see GCBO)
    h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
    txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');

    [txSetEnv, TX_SELECT]  = txSetEnv.addTx();

    setappdata(h_GUI_CandlesTxSet, 'TX_SELECT', TX_SELECT);
    setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
    set_values(); % Set the values and display room with selected TX

% --------------------------------------------------------------------
function menu_addTxLayout_Callback(hObject, eventdata, handles)
% hObject    handle to menu_addTxLayout (see GCBO)
    h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
    txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');

    dlg_title    = 'Tx Layout Settings';

    % NOTE: Grid layout = 1. Cell layout 1 = 2. Cell layout 2 = 3.
    layout = listdlg('ListString',{'Grid Layout', ...
                                   'Cell Layout 1', ...
                                   'Cell Layout 2'}, ...
                     'SelectionMode','single',...
                     'Name',dlg_title, ...
                     'ListSize',[160 60]);

    if (~isempty(layout))
        num_lines    = 1;
        prompt       = {'Number of TXs in X dimension:', ...
                        'Number of TXs in Y dimension:', ...
                        'Distance between TXs (m):', ...
                        'Center in X dimension (m):', ...
                        'Center in Y dimension (m):', ...
                        'Z Plane (m):'};
        default_vals = {'2','2','1',num2str(txSetEnv.rm.length/2), ...
                                    num2str(txSetEnv.rm.width/2), ...
                                    num2str(txSetEnv.rm.height)};

        ans_dlg = inputdlg(prompt,dlg_title,num_lines,default_vals);

        % NOTE: If changing to str2num, need to modify error check below.
        vals = [str2double(ans_dlg(1)), ...
                str2double(ans_dlg(2)), ...
                str2double(ans_dlg(3)), ...
                str2double(ans_dlg(4)), ...
                str2double(ans_dlg(5)), ...
                str2double(ans_dlg(6))];

        if (isnan(sum(vals)))
            warndlg('Inputs must be numeric values', ...
                    'Warning: Invalid Input');
        elseif (any(mod(vals(1:2),1)))
            warndlg('Number of TXs must be an integer value', ...
                    'Warning: Invalid Input');
        else
            replace = strcmp(questdlg('Replace existing TXs?',dlg_title,'Yes','No','Yes'),'Yes');
            [txSetEnv, TX_SELECT]  = txSetEnv.addTxGroup(vals(1), vals(2), vals(3), vals(4), ...
                                                         vals(5), vals(6), layout, replace);

            setappdata(h_GUI_CandlesTxSet, 'TX_SELECT', TX_SELECT);
            setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
            set_values(); % Set the values and display room with selected TX
        end
    end


% --------------------------------------------------------------------
function menu_deleteTx_Callback(hObject, eventdata, handles)
% hObject    handle to menu_deleteTx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
    TX_SELECT          = getappdata(h_GUI_CandlesTxSet,'TX_SELECT');
    txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');

    [txSetEnv, ERR]  = txSetEnv.removeTx(TX_SELECT);
    TX_SELECT = min(TX_SELECT, length(txSetEnv.txs));
    if(ERR == 1)
        errordlg('CandLES environment must contain a Tx.','Tx Delete');
    else
        % NOTE: Do this in the else statement so that the error box doesn't 
        % get hidden when the GUI is updated in set_values()
        setappdata(h_GUI_CandlesTxSet, 'TX_SELECT', TX_SELECT);
        setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
        set_values(); % Set the values and display room with selected TX
    end

    
% --------------------------------------------------------------------
function menu_addTxGroup_Callback(hObject, eventdata, handles)
% hObject    handle to menu_addTxGroup (see GCBO)
    h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
    txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
    txSetEnv           = txSetEnv.addNetGroup();

    h = msgbox('New Tx Group Added Successfully');
    uiwait(h);
    
    setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
    set_values(); % Set the values and display room with selected TX

% --------------------------------------------------------------------
function menu_removeTxGroup_Callback(hObject, eventdata, handles)
% hObject    handle to menu_removeTxGroup (see GCBO)
    h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
    txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
    
    groups = 1:txSetEnv.num_groups;
    ng = listdlg('ListString',num2str(groups'), ...
                     'SelectionMode','single',...
                     'Name','Select Group to Remove', ...
                     'ListSize',[160 60]);

    if (~isempty(ng))
        txSetEnv           = txSetEnv.removeNetGroup(ng);
    end
    
    setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
    set_values(); % Set the values and display room with selected TX
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% TX SELECT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function popup_tx_select_Callback(hObject, ~, ~)
% hObject    handle to popup_tx_select (see GCBO)
    h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
    TX_SELECT = get(hObject,'Value');
    setappdata(h_GUI_CandlesTxSet, 'TX_SELECT', TX_SELECT);
    set_values(); % Set the values and display room with selected TX


function popup_group_assign_Callback(hObject, ~, ~)
% hObject    handle to popup_group_assign (see GCBO)
    h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
    TX_SELECT          = getappdata(h_GUI_CandlesTxSet,'TX_SELECT');
    txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
    
    txSetEnv           = txSetEnv.setTxParam(TX_SELECT,'ng',get(hObject,'Value'));
    
    setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
    set_values(); % Set the values and display room with selected TX

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% TX LOCATION FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_Tx_x_Callback(hObject, ~, ~)
% hObject    handle to edit_Tx_x (see GCBO)
    update_edit(hObject, 'x');

function slider_Tx_x_Callback(hObject, ~, ~)
% hObject    handle to slider_Tx_x (see GCBO)
    update_slider(hObject, 'x');

function edit_Tx_y_Callback(hObject, ~, ~)
% hObject    handle to edit_Tx_y (see GCBO)
    update_edit(hObject, 'y');

function slider_Tx_y_Callback(hObject, ~, ~)
% hObject    handle to slider_Tx_y (see GCBO)
    update_slider(hObject, 'y');

function edit_Tx_z_Callback(hObject, ~, ~)
% hObject    handle to edit_Tx_z (see GCBO)
    update_edit(hObject, 'z');

function slider_Tx_z_Callback(hObject, ~, ~)
% hObject    handle to slider_Tx_z (see GCBO)
    update_slider(hObject, 'z');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% TX ROTATION FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_Tx_az_Callback(hObject, ~, ~)
% hObject    handle to edit_Tx_az (see GCBO)
    update_edit(hObject, 'az');

function slider_Tx_az_Callback(hObject, ~, ~)
% hObject    handle to slider_Tx_az (see GCBO)
    update_slider(hObject, 'az');

function edit_Tx_el_Callback(hObject, ~, ~)
% hObject    handle to edit_Tx_el (see GCBO)
    update_edit(hObject, 'el');

function slider_Tx_el_Callback(hObject, ~, ~)
% hObject    handle to slider_Tx_el (see GCBO)
    update_slider(hObject, 'el');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% TX PARAMETER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Edit callback for average transmit power (Optical Watts)
function edit_Tx_Ps_Callback(hObject, ~, ~)
% hObject    handle to edit_Tx_Ps (see GCBO)
    update_edit(hObject, 'Ps');
    
% Edit callback for Lambertian Order
function edit_Tx_m_Callback(hObject, ~, ~)
% hObject    handle to edit_Tx_m (see GCBO)
    update_edit(hObject, 'm');

function edit_Tx_theta_Callback(hObject, ~, ~)
% hObject    handle to edit_Tx_theta (see GCBO)
    update_edit(hObject, 'theta');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% ADDITIONAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update values based on the change to the edit box hObject. 
%    param = {'x', 'y', 'z', 'az', 'el', 'Ps', 'm', 'theta'}
% --------------------------------------------------------------------
function update_edit(hObject, param)
    h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
    TX_SELECT          = getappdata(h_GUI_CandlesTxSet,'TX_SELECT');
    txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
    temp               = str2double(get(hObject,'String'));

    [txSetEnv, ERR] = txSetEnv.setTxParam(TX_SELECT,param,temp);
    % FIXME: Add warning boxes for ERR and bring to front after set_values
    if (ERR == 0)
        setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
    end
    set_values();

% Update values based on the change to the slider hObject. 
%    param = {'x', 'y', 'z', 'az', 'el', 'Ps', 'm', 'theta'}
% --------------------------------------------------------------------
function update_slider(hObject, param)
    h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
    TX_SELECT          = getappdata(h_GUI_CandlesTxSet,'TX_SELECT');
    txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
    temp               = get(hObject,'Value');

    txSetEnv = txSetEnv.setTxParam(TX_SELECT,param,temp);
    setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
    set_values();

% Call the update_main function from CandLES.m
% --------------------------------------------------------------------
function update_main_env()
    h_GUI_CandlesMain  = getappdata(0,'h_GUI_CandlesMain');
    h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
    txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
    feval(getappdata(h_GUI_CandlesMain,'fhUpdateMain'),txSetEnv);
    figure(h_GUI_CandlesTxSet); %Bring the TX GUI back to the front

    
% Set the values within the GUI
% --------------------------------------------------------------------
function set_values()
    h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
    TX_SELECT          = getappdata(h_GUI_CandlesTxSet,'TX_SELECT');
    txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
    handles            = guidata(h_GUI_CandlesTxSet);
    
    % Display room with selected Tx
    SYS_display_room(handles.axes_room, txSetEnv, 1, TX_SELECT);
    
    % Display emission pattern of selected Tx
    txSetEnv.plotTxEmission(TX_SELECT,handles.axes_tx);
    
    % Set Location boxes
    set(handles.edit_Tx_x,'string',num2str(txSetEnv.txs(TX_SELECT).x));
    set(handles.edit_Tx_y,'string',num2str(txSetEnv.txs(TX_SELECT).y));
    set(handles.edit_Tx_z,'string',num2str(txSetEnv.txs(TX_SELECT).z));
    set(handles.slider_Tx_x,'value',txSetEnv.txs(TX_SELECT).x);
    set(handles.slider_Tx_y,'value',txSetEnv.txs(TX_SELECT).y);
    set(handles.slider_Tx_z,'value',txSetEnv.txs(TX_SELECT).z);
    set(handles.slider_Tx_x,'Min',0);
    set(handles.slider_Tx_y,'Min',0);
    set(handles.slider_Tx_z,'Min',0);
    set(handles.slider_Tx_x,'Max',txSetEnv.rm.length);
    set(handles.slider_Tx_y,'Max',txSetEnv.rm.width);
    set(handles.slider_Tx_z,'Max',txSetEnv.rm.height);
    set(handles.slider_Tx_x,'SliderStep',[0.1/txSetEnv.rm.length, 1/txSetEnv.rm.length]);
    set(handles.slider_Tx_y,'SliderStep',[0.1/txSetEnv.rm.width, 1/txSetEnv.rm.width]);
    set(handles.slider_Tx_z,'SliderStep',[0.1/txSetEnv.rm.height, 1/txSetEnv.rm.height]);

    % Set Rotation boxes
    [my_az,my_el] = txSetEnv.txs(TX_SELECT).get_angle_deg();
    set(handles.edit_Tx_az,'string',num2str(my_az));
    set(handles.edit_Tx_el,'string',num2str(my_el));
    set(handles.slider_Tx_az,'value',my_az);
    set(handles.slider_Tx_el,'value',my_el);
    set(handles.slider_Tx_az,'Min',0);
    set(handles.slider_Tx_el,'Min',0);
    set(handles.slider_Tx_az,'Max',360);
    set(handles.slider_Tx_el,'Max',360);
    set(handles.slider_Tx_az,'SliderStep',[1/360, 1/36]);
    set(handles.slider_Tx_el,'SliderStep',[1/360, 1/36]);
    
    % Set Tx Selection box
    set(handles.popup_tx_select,'String',1:1:length(txSetEnv.txs));
    set(handles.popup_tx_select,'Value',TX_SELECT);

    % Set Group Assignment box
    set(handles.popup_group_assign,'String',1:txSetEnv.num_groups);
    set(handles.popup_group_assign,'Value',txSetEnv.txs(TX_SELECT).ng);
    
    % Set Tx Parameters
    set(handles.edit_Tx_Ps,   'string', num2str(txSetEnv.txs(TX_SELECT).Ps));
    set(handles.edit_Tx_m,    'string', num2str(txSetEnv.txs(TX_SELECT).m));
    set(handles.edit_Tx_theta,'string', num2str(txSetEnv.txs(TX_SELECT).theta));

    
  
    


