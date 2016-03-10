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

% Last Modified by GUIDE v2.5 08-Mar-2016 22:55:35

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
GROUP_SELECT = 1;
setappdata(hObject, 'txSetEnv', txSetEnv);
setappdata(hObject, 'TX_SELECT', TX_SELECT);
setappdata(hObject, 'GROUP_SELECT', GROUP_SELECT);
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
        
        if (txSetEnv.num_groups > 1)
            groups = 1:txSetEnv.num_groups;
            [ng, ok] = listdlg('ListString',num2str(groups'), ...
                               'SelectionMode','Single', ...
                               'ListSize',[160,60]);
        else
            ok = 1;
            ng = 1;
        end
        
        if (~isempty(ans_dlg) && ok)

            % NOTE: If changing to str2num, need to modify error check below.
            vals = [str2double(ans_dlg(1)), str2double(ans_dlg(2)), ...
                    str2double(ans_dlg(3)), str2double(ans_dlg(4)), ...
                    str2double(ans_dlg(5)), str2double(ans_dlg(6))];

            if (isnan(sum(vals)))
                warndlg('Inputs must be numeric values', ...
                        'Warning: Invalid Input');
            elseif (any(mod(vals(1:2),1)))
                warndlg('Number of TXs must be an integer value', ...
                        'Warning: Invalid Input');
            else
                replace = strcmp(questdlg('Replace existing TXs?',dlg_title,'Yes','No','Yes'),'Yes');
                [txSetEnv, TX_SELECT]  = txSetEnv.addTxGroup(vals(1), vals(2), vals(3), vals(4), ...
                                                             vals(5), vals(6), layout, ng, replace);

                setappdata(h_GUI_CandlesTxSet, 'TX_SELECT', TX_SELECT);
                setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
                set_values(); % Set the values and display room with selected TX
            end
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
    handles            = guidata(h_GUI_CandlesTxSet);
    view = get(get(handles.panel_TxGroupSelect,'SelectedObject'),'String');
    if strcmp(view,'Tx')
        TX_SELECT = get(hObject,'Value');
        setappdata(h_GUI_CandlesTxSet, 'TX_SELECT', TX_SELECT);
    elseif strcmp(view,'Group')
        GROUP_SELECT = get(hObject,'Value');
        setappdata(h_GUI_CandlesTxSet, 'GROUP_SELECT', GROUP_SELECT);
    end    
    set_values(); % Set the values and display room with selected TX

function radiobutton_tx_Callback(hObject, ~, ~)
% hObject    handle to radiobutton_tx (see GCBO)
    set_values();

function radiobutton_group_Callback(hObject, ~, ~)
% hObject    handle to radiobutton_group (see GCBO)
    set_values();    
    
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
    GROUP_SELECT       = getappdata(h_GUI_CandlesTxSet,'GROUP_SELECT');
    txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
    handles            = guidata(h_GUI_CandlesTxSet);
    temp               = str2double(get(hObject,'String'));

    view = get(get(handles.panel_TxGroupSelect,'SelectedObject'),'String');
    if strcmp(view,'Tx')
        [txSetEnv, ERR] = txSetEnv.setTxParam(TX_SELECT,param,temp);
    elseif strcmp(view,'Group')
        [txSetEnv, ERR] = txSetEnv.setGroupParam(GROUP_SELECT,param,temp);
    end    
    
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
    GROUP_SELECT       = getappdata(h_GUI_CandlesTxSet,'GROUP_SELECT');
    txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
    handles            = guidata(h_GUI_CandlesTxSet);
    temp               = get(hObject,'Value');

    view = get(get(handles.panel_TxGroupSelect,'SelectedObject'),'String');
    if strcmp(view,'Tx')
        txSetEnv = txSetEnv.setTxParam(TX_SELECT,param,temp);
    elseif strcmp(view,'Group')
        txSetEnv = txSetEnv.setGroupParam(GROUP_SELECT,param,temp);
    end       
    
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
    handles            = guidata(h_GUI_CandlesTxSet);
    
    view = get(get(handles.panel_TxGroupSelect,'SelectedObject'),'String');
    if strcmp(view,'Tx')
        tx_values_update();
    elseif strcmp(view,'Group')
        group_values_update();
    end
    

% Update the GUI values for the selected Tx
% --------------------------------------------------------------------
function tx_values_update()
    h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
    TX_SELECT          = getappdata(h_GUI_CandlesTxSet,'TX_SELECT');
    txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
    handles            = guidata(h_GUI_CandlesTxSet);

    % Display room with selected Tx ---------------------------------------
    SYS_display_room(handles.axes_room, txSetEnv, 1, TX_SELECT);
    
    % Set Tx Selection box ------------------------------------------------
    set(handles.popup_tx_select,'String',1:1:length(txSetEnv.txs), ...
                                'Value',TX_SELECT);

    % Set Group Assignment box --------------------------------------------
    set(handles.popup_group_assign,'String',1:txSetEnv.num_groups, ...
                                   'Value',txSetEnv.txs(TX_SELECT).ng, ...
                                   'Enable','on');
        
    % Set Location boxes --------------------------------------------------
    set(handles.edit_Tx_x,'string',num2str(txSetEnv.txs(TX_SELECT).x), 'Enable', 'on');
    set(handles.edit_Tx_y,'string',num2str(txSetEnv.txs(TX_SELECT).y), 'Enable', 'on');
    set(handles.edit_Tx_z,'string',num2str(txSetEnv.txs(TX_SELECT).z), 'Enable', 'on');
    set(handles.slider_Tx_x,'value',txSetEnv.txs(TX_SELECT).x, 'Enable', 'on');
    set(handles.slider_Tx_y,'value',txSetEnv.txs(TX_SELECT).y, 'Enable', 'on');
    set(handles.slider_Tx_z,'value',txSetEnv.txs(TX_SELECT).z, 'Enable', 'on');
    set(handles.slider_Tx_x,'Min',0);
    set(handles.slider_Tx_y,'Min',0);
    set(handles.slider_Tx_z,'Min',0);
    set(handles.slider_Tx_x,'Max',txSetEnv.rm.length);
    set(handles.slider_Tx_y,'Max',txSetEnv.rm.width);
    set(handles.slider_Tx_z,'Max',txSetEnv.rm.height);
    set(handles.slider_Tx_x,'SliderStep',[0.1/txSetEnv.rm.length, 1/txSetEnv.rm.length]);
    set(handles.slider_Tx_y,'SliderStep',[0.1/txSetEnv.rm.width, 1/txSetEnv.rm.width]);
    set(handles.slider_Tx_z,'SliderStep',[0.1/txSetEnv.rm.height, 1/txSetEnv.rm.height]);

    % Set Rotation boxes --------------------------------------------------
    [my_az,my_el] = txSetEnv.txs(TX_SELECT).get_angle_deg();
    set(handles.edit_Tx_az,'string',num2str(my_az), 'Enable', 'on');
    set(handles.edit_Tx_el,'string',num2str(my_el), 'Enable', 'on');
    set(handles.slider_Tx_az,'value',my_az, 'Enable', 'on');
    set(handles.slider_Tx_el,'value',my_el, 'Enable', 'on');
    set(handles.slider_Tx_az,'Min',0);
    set(handles.slider_Tx_el,'Min',0);
    set(handles.slider_Tx_az,'Max',360);
    set(handles.slider_Tx_el,'Max',360);
    set(handles.slider_Tx_az,'SliderStep',[1/360, 1/36]);
    set(handles.slider_Tx_el,'SliderStep',[1/360, 1/36]);
    
    % Set Tx Parameters ---------------------------------------------------
    set(handles.edit_Tx_Ps,   'string', num2str(txSetEnv.txs(TX_SELECT).Ps), 'Enable', 'on');
    set(handles.edit_Tx_m,    'string', num2str(txSetEnv.txs(TX_SELECT).m), 'Enable', 'on');
    set(handles.edit_Tx_theta,'string', num2str(txSetEnv.txs(TX_SELECT).theta), 'Enable', 'on');

    % Display emission pattern of selected Tx -----------------------------
    txSetEnv.plotTxEmission(TX_SELECT,handles.axes_tx);

% Update the GUI values for the selected Group
% --------------------------------------------------------------------
function group_values_update()
    h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
    GROUP_SELECT       = getappdata(h_GUI_CandlesTxSet,'GROUP_SELECT');
    txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
    handles            = guidata(h_GUI_CandlesTxSet);

    [my_txs,tx_nums] = txSetEnv.getGroup(GROUP_SELECT);
    
    % Display room with selected Tx
    SYS_display_room(handles.axes_room, txSetEnv, 1, tx_nums);    

    % Set Group Selection box (same box as Tx Select) ---------------------
    set(handles.popup_tx_select,'String',1:1:txSetEnv.num_groups);
    set(handles.popup_tx_select,'Value',GROUP_SELECT);
    
    % Set Group Assignment box --------------------------------------------
    set(handles.popup_group_assign,'String',1:txSetEnv.num_groups);
    set(handles.popup_group_assign,'Value',GROUP_SELECT);
    set(handles.popup_group_assign,'Enable','off');
    
    % Check if no Txs in group --------------------------------------------
    no_txs = isempty(my_txs);
    if (no_txs)
        disable_all_selections(handles);
        return
    end
    
    % Set Location boxes --------------------------------------------------
    check_group_edit(  [my_txs.x],   handles.edit_Tx_x, txSetEnv.txs(tx_nums(1)).x);
    check_group_slider([my_txs.x], handles.slider_Tx_x, txSetEnv.txs(tx_nums(1)).x);
    check_group_edit(  [my_txs.y],   handles.edit_Tx_y, txSetEnv.txs(tx_nums(1)).y);
    check_group_slider([my_txs.y], handles.slider_Tx_y, txSetEnv.txs(tx_nums(1)).y);
    check_group_edit(  [my_txs.z],   handles.edit_Tx_z, txSetEnv.txs(tx_nums(1)).z);
    check_group_slider([my_txs.z], handles.slider_Tx_z, txSetEnv.txs(tx_nums(1)).z);
    
    % Set Rotation boxes --------------------------------------------------
    [my_az,my_el] = txSetEnv.txs(tx_nums(1)).get_angle_deg();
    check_group_edit(  [my_txs.az],   handles.edit_Tx_az, my_az);
    check_group_slider([my_txs.az], handles.slider_Tx_az, my_az);
    check_group_edit(  [my_txs.el],   handles.edit_Tx_el, my_el);
    check_group_slider([my_txs.el], handles.slider_Tx_el, my_el);
    
    % Set Tx Parameters ---------------------------------------------------
    check_group_edit(   [my_txs.Ps],    handles.edit_Tx_Ps, txSetEnv.txs(tx_nums(1)).Ps   );
    check_group_edit(    [my_txs.m],     handles.edit_Tx_m, txSetEnv.txs(tx_nums(1)).m    );
    check_group_edit([my_txs.theta], handles.edit_Tx_theta, txSetEnv.txs(tx_nums(1)).theta);
    
    % Display emission pattern of selected Tx -----------------------------
    if (range([my_txs.m])>0)
        cla(handles.axes_tx,'reset')
        MSG = sprintf('Group has multiple\n emission patterns.');
        text(0.2, 0.5, MSG, 'Parent', handles.axes_tx);
    else
        txSetEnv.plotTxEmission(tx_nums(1),handles.axes_tx);
    end

% Check if all values are equivalent before updating edit box
% --------------------------------------------------------------------
function check_group_edit(vals,my_handle,group_value)
    if (range(vals)>0)
        set(my_handle, 'string', '--', 'Enable', 'on');
    else
        set(my_handle, 'string', num2str(group_value), 'Enable', 'on');
    end

% Check if all values are equivalent before updating slider
% --------------------------------------------------------------------
function check_group_slider(vals,my_handle,group_value)
    if (range(vals)>0)
        set(my_handle, 'value', 0, 'Enable', 'on');
    else
        set(my_handle, 'value', group_value, 'Enable', 'on');
    end
    
% Set all boxes and sliders to indicate no transmitter
% --------------------------------------------------------------------
function disable_all_selections(handles)    
    set(handles.edit_Tx_x,     'string', '--', 'Enable', 'off');
    set(handles.slider_Tx_x,    'value',    0, 'Enable', 'off');
    set(handles.edit_Tx_y,     'string', '--', 'Enable', 'off');
    set(handles.slider_Tx_y,    'value',    0, 'Enable', 'off');
    set(handles.edit_Tx_z,     'string', '--', 'Enable', 'off');
    set(handles.slider_Tx_z,    'value',    0, 'Enable', 'off');
    set(handles.edit_Tx_az,    'string', '--', 'Enable', 'off');
    set(handles.slider_Tx_az,   'value',    0, 'Enable', 'off');
    set(handles.edit_Tx_el,    'string', '--', 'Enable', 'off');
    set(handles.slider_Tx_el,   'value',    0, 'Enable', 'off');
    set(handles.edit_Tx_Ps,    'string', '--', 'Enable', 'off');
    set(handles.edit_Tx_m,     'string', '--', 'Enable', 'off');
    set(handles.edit_Tx_theta, 'string', '--', 'Enable', 'off');
    
    cla(handles.axes_tx,'reset')
    MSG = sprintf('Group has no\n transmitters.');
    text(0.28, 0.5, MSG, 'Parent', handles.axes_tx);