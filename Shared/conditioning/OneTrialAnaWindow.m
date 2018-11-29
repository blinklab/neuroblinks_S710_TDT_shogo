function varargout = OneTrialAnaWindow(varargin)
% ONETRIALANAWINDOW MATLAB code for OneTrialAnaWindow.fig
%      ONETRIALANAWINDOW, by itself, creates a new ONETRIALANAWINDOW or raises the existing
%      singleton*.
%
%      H = ONETRIALANAWINDOW returns the handle to a new ONETRIALANAWINDOW or the handle to
%      the existing singleton*.
%
%      ONETRIALANAWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ONETRIALANAWINDOW.M with the given input arguments.
%
%      ONETRIALANAWINDOW('Property','Value',...) creates a new ONETRIALANAWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OneTrialAnaWindow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OneTrialAnaWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OneTrialAnaWindow

% Last Modified by GUIDE v2.5 07-Dec-2015 19:44:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @OneTrialAnaWindow_OpeningFcn, ...
    'gui_OutputFcn',  @OneTrialAnaWindow_OutputFcn, ...
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


% --- Executes just before OneTrialAnaWindow is made visible.
function OneTrialAnaWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OneTrialAnaWindow (see VARARGIN)

% Choose default command line output for OneTrialAnaWindow
handles.output = hObject;
handles.tnum_prev=NaN;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OneTrialAnaWindow wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OneTrialAnaWindow_OutputFcn(hObject, eventdata, handles)
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

try
t=timerfind('Name','analysisUpdateTimer');
if ~isempty(t)
    stop(t);
end
delete(t)
catch
    disp('Error in closing fig.')
end
% Hint: delete(hObject) closes the figure
delete(hObject);





% --- Executes on slider movement.
function slider_trialnum_Callback(hObject, eventdata, handles)
% hObject    handle to slider_trialnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

if strcmp(get(handles.edit_trialnum,'String'),'Trial Num')
    set(handles.edit_trialnum,'String','0');
end
t_num=round(str2double(get(handles.edit_trialnum,'String'))+get(hObject,'Value'));

trials=getappdata(0,'trials');
if isfield(trials,'eye'),
    tnum_max=length(trials.eye);
else
    tnum_max=0;
end

% set(handles.text_trialnum,'String',sprintf('Trial Viewer (1-%d)',tnum_max));

if t_num>tnum_max
    t_num=tnum_max;
elseif t_num<1
    t_num=1;
end
set(handles.edit_trialnum,'String',num2str(t_num)),
set(hObject,'Value',0),

if t_num~=handles.tnum_prev | t_num==tnum_max,
    drawOneEyelid(handles,t_num);   
end
handles.tnum_prev=t_num;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function slider_trialnum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_trialnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Value',0);


function edit_trialnum_Callback(hObject, eventdata, handles)
% hObject    handle to edit_trialnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_trialnum as text
%        str2double(get(hObject,'String')) returns contents of edit_trialnum as a double

t_num=round(str2double(get(handles.edit_trialnum,'String')));
trials=getappdata(0,'trials');
if isfield(trials,'eye'),
    tnum_max=length(trials.eye);
else
    tnum_max=0;
end
if t_num>tnum_max || t_num<1
    if t_num<1
        t_num=1;  
    else
        t_num=tnum_max;
    end
    set(handles.edit_trialnum,'String',num2str(t_num)),
end

if t_num~=handles.tnum_prev | t_num==tnum_max,
    drawOneEyelid(handles,t_num);   
end
handles.tnum_prev=t_num;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit_trialnum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_trialnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_ymax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ymax as text
%        str2double(get(hObject,'String')) returns contents of edit_ymax as a double
t_num=str2num(get(handles.edit_trialnum,'String'));
drawOneSpk(handles,t_num)


% --- Executes during object creation, after setting all properties.
function edit_ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_xmax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_xmax as text
%        str2double(get(hObject,'String')) returns contents of edit_xmax as a double
t_num=str2num(get(handles.edit_trialnum,'String'));
drawOneSpk(handles,t_num)

% --- Executes during object creation, after setting all properties.
function edit_xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton_LFP.
function pushbutton_LFP_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_LFP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ghandles=getappdata(0,'ghandles');
ghandles.onetrialLFPgui=LFPWindow;
setappdata(0,'ghandles',ghandles);

% movegui(ghandles.onetrialanagui,ghandles.pos_lfpwin)
set(ghandles.onetrialLFPgui,'units','pixels')
set(ghandles.onetrialLFPgui,'position',[ghandles.pos_lfpwin ghandles.size_lfpwin])


% --- Executes on selection change in listbox_snip.
function listbox_snip_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_snip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_snip contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_snip


% --- Executes during object creation, after setting all properties.
function listbox_snip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_snip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_get_data.
function pushbutton_get_data_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_get_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tnum=str2num(get(handles.edit_trialnum,'String'));
online_savespk_for_a_trial(tnum)
drawOneEyelid(handles,tnum)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% user difined functions %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function drawOneEyelid(handles,t_num)

trials=getappdata(0,'trials');
if ~isfield(trials,'eye'), return,  end
tnum_max=length(trials.eye);
str_tl={[sprintf('(1-%d)',tnum_max)] [trials.eye(t_num).stimtype]};

% ------- for eye -----
subplot('position',[0.06 0.19 0.90 0.46], 'Parent', handles.uipanel_behavior)
cla
plot([-1 1]*1000, [0 0],'k:'),  hold on,   plot([-1 1]*1000, [1 1],'k:'), 

set(gca,'ylim',[-0.25 1.20], 'ytick',[0:0.5:1], 'box', 'off','tickdir','out')

if isempty(trials.eye(t_num).time), return, end
xlim1=[trials.eye(t_num).time(1) trials.eye(t_num).time(end)];
plotOneEyelid(t_num);

text(xlim1*[0.38;0.62], -0.54, str_tl, 'fontsize',10)
set(gca,'xlim',xlim1,'xtick',[-400:50:1000])
set(gca,'xticklabel',{'-400' '' '-300' '' '-200' '' '-100' '' '0' '' '100' '' '200' '' ...
    '300' '' '400' '' '500' '' '600' '' '700' '' '800' '' '900' '' '1000'})
set(gca,'color',[240 240 240]/255);


% ------- for spk -----

% tnum_max=length(trials.spk);
% ylim_low=400;
% if t_num>tnum_max, 
%     ylim2=ylim_low*[1 1];
% elseif isempty(trials.spk(t_num).ylim)
%     ylim2=ylim_low*[1 1];
% else
%     ylim2=abs(trials.spk(t_num).ylim); 
% end
% ylim1=NaN*ones(tnum_max,2);
% for i=max(1,t_num-10):t_num,   if ~isempty(trials.spk(i).ylim), ylim1(i,:)=trials.spk(i).ylim;  end, end
% % ylim1(find(abs(ylim1)<ylim_low))=NaN;
% ylim2=abs(nanmedian(ylim1));  
% ylim3=ylim_low*[1 1];  ylim3(ylim2>ylim_low)=ylim2(ylim2>ylim_low); ylim3(1)=-ylim3(1);

drawOneSpk(handles,t_num)


function drawOneSpk(handles,t_num)

trials=getappdata(0,'trials');
if isfield(trials,'spk'),
    tnum_max=length(trials.spk);
else, tnum_max=0; 
end

subplot('position',[0.10 0.74 0.86 0.25], 'Parent', handles.uipanel_behavior)
cla
if t_num>tnum_max, return, end

ylim3=[-1 1]*str2num(get(handles.edit_ymax,'String'));
xlim2(2)=str2num(get(handles.edit_xmax,'String'));
xlim2(1)=-xlim2(2)/4;

plot([0 0], [-1 1]*2000, 'k:'),  hold on,   
set(gca,'color',[240 240 240]/255);

plot([1 1]*trials.eye(t_num).stimtime.st{end}, [-1 1]*2000, 'k:'), 
if isfield(trials,'spk'),
    plot(trials.spk(t_num).time,trials.spk(t_num).y,'k'), 
end

set(gca,'xlim',xlim2,'xtick',[-400:25:1000])
set(gca,'xticklabel',{'-400' '' '' '' '-300' '' '' '' '-200' '' '' '' '-100' '' '' '' '0' '' '' '' '100' '' '' '' '200' '' '' '' ...
    '300' '' '' '' '400' '' '' '' '500' '' '' '' '600' '' '' '' '700' '' '' '' '800' '' '' '' '900' '' '' '' '1000'})
set(gca,'ylim',ylim3*1.0, 'ytick',ylim3,'yticklabel',{num2str(ylim3(1)) []}, 'box', 'off','tickdir','out')
