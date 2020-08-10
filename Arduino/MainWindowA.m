function varargout = MainWindowA(varargin)
% MAINWINDOWA M-file for MainWindowA.fig
%      MAINWINDOWA, by itself, creates a new MAINWINDOWA or raises the existing
%      singleton*.
%
%      H = MAINWINDOWA returns the handle to a new MAINWINDOWA or the handle to
%      the existing singleton*.
%
%      MAINWINDOWA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINWINDOWA.M with the given input arguments.
%
%      MAINWINDOWA('Property','Value',...) creates a new MAINWINDOWA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainWindowA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainWindowA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainWindowA

% Last Modified by GUIDE v2.5 01-Jan-2016 18:25:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainWindowA_OpeningFcn, ...
                   'gui_OutputFcn',  @MainWindowA_OutputFcn, ...
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


% --- Executes just before MainWindowA is made visible.
function MainWindowA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% varargin   command line arguments to MainWindowA (see VARARGIN)

% Choose default command line output for MainWindowA
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MainWindowA wait for user response (see UIRESUME)
% uiwait(handles.CamFig);
src=getappdata(0,'src');
metadata=getappdata(0,'metadata');
metadata.date=date;
metadata.TDTblockname='TempBlk';
metadata.ts=[datenum(clock) 0]; % two element vector containing datenum at beginning of session and offset of current trial (in seconds) from beginning
metadata.folder=pwd; % For now use current folder as base; will want to change this later

% metadata.cam.fps=src.AcquisitionFrameRateAbs; %in frames per second
metadata.cam.fps=200; %in frames per second
metadata.cam.thresh=0.125;
metadata.cam.trialnum=1;
metadata.eye.trialnum1=1;  %  for conditioning
metadata.eye.trialnum2=1;

typestring=get(handles.popupmenu_stimtype,'String');
metadata.stim.type=typestring{get(handles.popupmenu_stimtype,'Value')};

metadata.cam.time(1)=str2double(get(handles.edit_pretime,'String'));
metadata.cam.time(3)=metadata.cam.recdurA-metadata.cam.time(1);
metadata.cam.calib_offset=0;
metadata.cam.calib_scale=1;

trials.stimnum=0;
trials.savematadata=0;

setappdata(0,'metadata',metadata);
setappdata(0,'trials',trials);

% Open parameter dialog
% h=ParamsWindow;
% waitfor(h);

pushbutton_StartStopPreview_Callback(handles.pushbutton_StartStopPreview, [], handles)
pause(0.2)
pushbutton_StartStopPreview_Callback(handles.pushbutton_StartStopPreview, [], handles)

% --- init table ----
if isappdata(0,'paramtable')
    paramtable=getappdata(0,'paramtable');
    set(handles.uitable_params,'Data',paramtable.data);
end

% --- Executes on button press in pushbutton_StartStopPreview.
function pushbutton_StartStopPreview_Callback(hObject, eventdata, handles)
vidobj=getappdata(0,'vidobj');
metadata=getappdata(0,'metadata');
metadata.cam.roi = vidobj.ROIposition;

if strcmp(get(handles.pushbutton_StartStopPreview,'String'),'Start Preview')
    % Camera is off. Change button string and start camera.
    set(handles.pushbutton_StartStopPreview,'String','Stop Preview')
    handles.pwin=image(zeros(480,640),'Parent',handles.cameraAx);
    preview(vidobj,handles.pwin);
else
    % Camera is on. Stop camera and change button string.
    set(handles.pushbutton_StartStopPreview,'String','Start Preview')
    closepreview(vidobj);
end
setappdata(0,'metadata',metadata);
guidata(hObject,handles)


function pushbutton_quit_Callback(hObject, eventdata, handles)
vidobj=getappdata(0,'vidobj');
ghandles=getappdata(0,'ghandles');
metadata=getappdata(0,'metadata');
arduino=getappdata(0,'arduino');

button=questdlg('Are you sure you want to quit?','Quit?');
if ~strcmpi(button,'Yes')
    return
end

try
    fclose(arduino);
    delete(arduino);
    delete(vidobj);
    rmappdata(0,'src');
    rmappdata(0,'vidobj');
catch err
    warning(err.identifier,'Problem cleaning up objects. You may need to do it manually.')
end
delete(handles.CamFig)
button=questdlg('Do you want to compress the videos from this session?');
if strcmpi(button,'Yes')
    makeCompressedVideos(metadata.folder);
end

% --- Outputs from this function are returned to the command line.
function varargout = MainWindowA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;


function CamFig_KeyPressFcn(hObject, eventdata, handles)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
switch eventdata.Character
    case '`'
        pushbutton_stim_Callback(hObject, eventdata, handles);
    otherwise
        return
end


function pushbutton_setROI_Callback(hObject, eventdata, handles)
vidobj=getappdata(0,'vidobj');metadata=getappdata(0,'metadata');
if isfield(metadata.cam,'winpos')
    winpos=metadata.cam.winpos;
else
    winpos=[0 0 640 480];
end
h=imellipse(handles.cameraAx,winpos);
fcn = makeConstrainToRectFcn('imellipse',get(handles.cameraAx,'XLim'),get(handles.cameraAx,'YLim'));
setPositionConstraintFcn(h,fcn);

% metadata.cam.winpos=round(wait(h));
XY=round(wait(h));  % only use for imellipse
metadata.cam.winpos=getPosition(h);
metadata.cam.mask=createMask(h);

wholeframe=getsnapshot(vidobj);
binframe=im2bw(wholeframe,metadata.cam.thresh);
eyeframe=binframe.*metadata.cam.mask;
metadata.cam.pixelpeak=sum(sum(eyeframe));

xmin=metadata.cam.winpos(1);
ymin=metadata.cam.winpos(2);
width=metadata.cam.winpos(3);
height=metadata.cam.winpos(4);

% Save indices that delineate border of ROI
handles.x1=ceil(metadata.cam.winpos(1));
handles.x2=floor(metadata.cam.winpos(1)+metadata.cam.winpos(3));
handles.y1=ceil(metadata.cam.winpos(2));
handles.y2=floor(metadata.cam.winpos(2)+metadata.cam.winpos(4));

hp=findobj(handles.cameraAx,'Tag','roipatch');
delete(hp)

delete(h);
handles.roipatch=patch(XY(:,1),XY(:,2),'g','FaceColor','none','EdgeColor','g','Tag','roipatch');

setappdata(0,'metadata',metadata);
guidata(hObject,handles)


function pushbutton_CalbEye_Callback(hObject, eventdata, handles)
refreshPermsA(handles);

metadata=getappdata(0,'metadata'); 
metadata.stim.type='Puff';  setappdata(0,'metadata',metadata);

sendto_arduino();

metadata=getappdata(0,'metadata'); 
vidobj=getappdata(0,'vidobj');
vidobj.TriggerRepeat = 0;
vidobj.StopFcn=@CalbEye;   % this will be executed after timer stop 
flushdata(vidobj);         % Remove any data from buffer before triggering
start(vidobj)

metadata.ts(2)=etime(clock,datevec(metadata.ts(1)));
% --- trigger via arduino --
arduino=getappdata(0,'arduino');
fwrite(arduino,1,'int8');

setappdata(0,'metadata',metadata);


function checkbox_record_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.checkbox_record,'BackgroundColor',[0 1 0]); % green
else
    set(handles.checkbox_record,'BackgroundColor',[1 0 0]); % red
end


function pushbutton_instantreplay_Callback(hObject, eventdata, handles)
instantReplay(getappdata(0,'lastdata'),getappdata(0,'lastmetadata'));


function toggle_continuous_Callback(hObject, eventdata, handles)
if get(hObject,'Value'),
    set(hObject,'String','Continuous: ON')
else
    set(hObject,'String','Continuous: OFF')
end


function pushbutton_stim_Callback(hObject, eventdata, handles)
TriggerArduino(handles)

function togglebutton_stream_Callback(hObject, eventdata, handles)
stream(handles)

function pushbutton_params_Callback(hObject, eventdata, handles)
ParamsWindow


function pushbutton_oneana_Callback(hObject, eventdata, handles)
ghandles=getappdata(0,'ghandles');
ghandles.onetrialanagui=OneTrialAnaWindow;
setappdata(0,'ghandles',ghandles);

set(ghandles.onetrialanagui,'units','pixels')
set(ghandles.onetrialanagui,'position',[ghandles.pos_oneanawin ghandles.size_oneanawin])


function uipanel_TDTMode_SelectionChangeFcn(hObject, eventdata, handles)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'togglebutton_TDTRecord'
        dlgans = inputdlg({'Enter Block name'},'Recording');
        if isempty(dlgans) 
            ok=0;
        elseif isempty(dlgans{1})
            ok=0;
        else
            ok=1;  block=dlgans{1};
            set(handles.checkbox_save_metadata,'Value',0);
        end
    case 'togglebutton_TDTPreview'
        button=questdlg('Are you sure you want to quit recording?','Yes','No');
        if ~strcmpi(button,'Yes')
            ok=0;
        else
            block='TempBlk';     ok=1;
        end
    otherwise
        warndlg('There is something wrong with the mode selection callback','Mode Select Problem!')
        return
end

if ok
    set(eventdata.NewValue,'Value',1);
    set(eventdata.OldValue,'Value',0);
    set(handles.uipanel_TDTMode,'SelectedObject',eventdata.NewValue);
else
    set(eventdata.NewValue,'Value',0);
    set(eventdata.OldValue,'Value',1);
    set(handles.uipanel_TDTMode,'SelectedObject',eventdata.OldValue);
    return
end
ResetCamTrials()
set(handles.edit_TDTBlockName,'String',block);
metadata=getappdata(0,'metadata');
metadata.TDTblockname=block;
setappdata(0,'metadata',metadata);


function pushbutton_opentable_Callback(hObject, eventdata, handles)
paramtable.data=get(handles.uitable_params,'Data');
paramtable.randomize=get(handles.checkbox_random,'Value');
% paramtable.tonefreq=str2num(get(handles.edit_tone,'String'));
% if length(paramtable.tonefreq)<2, paramtable.tonefreq(2)=0; end
setappdata(0,'paramtable',paramtable);

ghandles=getappdata(0,'ghandles');
trialtablegui=TrialTable;
movegui(trialtablegui,[ghandles.pos_mainwin(1)+ghandles.size_mainwin(1)+20 200])



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% user defined functions %%%%%%%%%%%%%%%%%

function refreshPermsA(handles)
metadata=getappdata(0,'metadata');
trials=getappdata(0,'trials');

trials.savematadata=get(handles.checkbox_save_metadata,'Value');
val=get(handles.popupmenu_stimtype,'Value');
str=get(handles.popupmenu_stimtype,'String');
metadata.stim.type=str{val};

metadata.stim.c.csdur=0;
metadata.stim.c.csnum=0;
metadata.stim.c.isi=0;
metadata.stim.c.usdur=0;
metadata.stim.c.cstone=[0 0];

metadata.stim.p.puffdur=str2double(get(handles.edit_puffdur,'String'));
metadata.stim.p.puffdelay=0;

switch lower(metadata.stim.type)
    case 'none'
        metadata.stim.totaltime=0;
    case 'puff'
        metadata.stim.totaltime=metadata.stim.p.puffdur;
    case 'conditioning'
        trialvars=readTrialTable(metadata.eye.trialnum1);
        metadata.stim.c.csdur=trialvars(1);
        metadata.stim.c.csnum=trialvars(2);
        metadata.stim.c.isi=trialvars(3);
        metadata.stim.c.usdur=trialvars(4);
        metadata.stim.c.cstone=str2num(get(handles.edit_tone,'String'))*1000;
        if length(metadata.stim.c.cstone)<2, metadata.stim.c.cstone(2)=0; end
        metadata.stim.totaltime=metadata.stim.c.isi+metadata.stim.c.usdur;
    otherwise
        metadata.stim.totaltime=0;
        warning('Unknown stimulation mode set.');
end
metadata.stim.c.ITI=str2double(get(handles.edit_ITI,'String'));

metadata.cam.time(1)=str2double(get(handles.edit_pretime,'String'));
metadata.cam.time(2)=metadata.stim.totaltime;
metadata.cam.time(3)=metadata.cam.recdurA-sum(metadata.cam.time(1:2));

setappdata(0,'metadata',metadata);
setappdata(0,'trials',trials);


function sendto_arduino()
metadata=getappdata(0,'metadata');
datatoarduino=zeros(1,8);

datatoarduino(3)=metadata.cam.time(1);
if strcmpi(metadata.stim.type, 'puff')
    datatoarduino(6)=metadata.stim.p.puffdur;
elseif  strcmpi(metadata.stim.type, 'conditioning')
    datatoarduino(4)=metadata.stim.c.csnum;
    datatoarduino(5)=metadata.stim.c.csdur;
    datatoarduino(6)=metadata.stim.c.usdur;
    datatoarduino(7)=metadata.stim.c.isi;
    if ismember(metadata.stim.c.csnum,[5 6]),
        datatoarduino(8)=metadata.stim.c.cstone(metadata.stim.c.csnum-4)/1000; % kHz
    end
end

% ---- send data to arduino ----
arduino=getappdata(0,'arduino');
for i=3:length(datatoarduino),
    fwrite(arduino,i,'int8');                  % header
    fwrite(arduino,datatoarduino(i),'int16');  % data
    if mod(i,4)==0,
        pause(0.010);
    end
end


function TriggerArduino(handles)
refreshPermsA(handles)
sendto_arduino()

metadata=getappdata(0,'metadata');
vidobj=getappdata(0,'vidobj');
vidobj.TriggerRepeat = 0;

% if get(handles.checkbox_record,'Value') == 1  
%     vidobj.StopFcn=@savetrial;
%     incrementStimTrial()
% else
%     vidobj.StopFcn=@nosavetrial;  
% end
vidobj.StopFcn=@endOfTrial;
flushdata(vidobj); % Remove any data from buffer before triggering
start(vidobj)
metadata.ts(2)=etime(clock,datevec(metadata.ts(1)));

% --- trigger via arduino --
arduino=getappdata(0,'arduino');
fwrite(arduino,1,'int8');

% ---- write status bar ----
trials=getappdata(0,'trials');
set(handles.text_status,'String',sprintf('Total trials: %d\nStim trials: %d',metadata.cam.trialnum-1,trials.stimnum));
if strcmpi(metadata.stim.type,'conditioning')
    trialvars=readTrialTable(metadata.eye.trialnum1+1);
    csdur=trialvars(1);
    csnum=trialvars(2);
    isi=trialvars(3);
    usdur=trialvars(4);
    cstone=str2num(get(handles.edit_tone,'String'));
    if length(cstone)<2, cstone(2)=0; end
    
    str2=[];
    if ismember(csnum,[5 6]), 
        str2=[' (' num2str(cstone(csnum-4)) ' Hz)'];
    end
        
    str1=sprintf('Next:  No %d,  CS ch %d%s,  ISI %d,  US %d',metadata.eye.trialnum1+1, csnum, str2, isi, usdur);
    set(handles.text_disp_cond,'String',str1)
end
setappdata(0,'metadata',metadata);

function incrementStimTrial()
trials=getappdata(0,'trials');
trials.stimnum=trials.stimnum+1;
setappdata(0,'trials',trials);

function stream(handles)
ghandles=getappdata(0,'ghandles'); 
metadata=getappdata(0,'metadata');
vidobj=getappdata(0,'vidobj');
updaterate=0.017;   % ~67 Hz
t1=clock; pause(0.1);
t0=clock;
etime2=round(1000*etime(clock,t1)/1000);

eyedata=NaN*ones(500,2);  
plt_range=-2100;

% set(0,'currentfigure',ghandles.maingui)
% set(ghandles.maingui,'CurrentAxes',handles.axes_eye)
% set(gca,'color',[240 240 240]/255,'YAxisLocation','right');

if get(handles.togglebutton_stream,'Value')
    set(0,'currentfigure',ghandles.maingui)
    set(ghandles.maingui,'CurrentAxes',handles.axes_eye)
    cla
    pl1=plot([plt_range 0],[1 1]*0,'k-'); hold on
    tx1=text(plt_range(1)+100,0.9,'10');
    set(gca,'color',[240 240 240]/255,'YAxisLocation','right');
    set(gca,'xlim',[plt_range 0],'ylim',[-0.1 1.1])
    set(gca,'xtick',[-3000:500:0],'box','off')
    set(gca,'ytick',[0:0.5:1],'yticklabel',{'0' '' '1'})
end

try
    while get(handles.togglebutton_stream,'Value') == 1
        t2=clock;
        
        % --- eye trace ---
        wholeframe=getsnapshot(vidobj);
        roi=wholeframe.*uint8(metadata.cam.mask);
        eyelidpos=sum(roi(:)>=256*metadata.cam.thresh);
        
        % --- eye trace buffer ---
        etime0=round(1000*etime(clock,t0));
        eyedata(1:end-1,:)=eyedata(2:end,:);
        eyedata(end,1)=etime0;
        eyedata(end,2)=(eyelidpos-metadata.cam.calib_offset)/metadata.cam.calib_scale; % eyelid pos
        
        set(pl1,'XData',eyedata(:,1)-etime0,'YData',eyedata(:,2))
        %         set(0,'currentfigure',ghandles.maingui)
        %         set(ghandles.maingui,'CurrentAxes',handles.axes_eye)
        %         plot(eyedata(:,1)-etime0,eyedata(:,2),'k')
        %         set(gca,'xlim',[plt_range 0],'ylim',[-0.1 1.1])
        
        etime1=round(1000*etime(clock,t1)/1000);
        iti1=str2double(get(handles.edit_ITI,'String'));
        if etime1~=etime2,
            set(tx1,'String',num2str(iti1-etime1));
            etime2=etime1;
        end
        % --- Trigger ----
        if get(handles.toggle_continuous,'Value') == 1
            if etime1>=iti1,
                eyeok=checkeye(handles,eyedata);
                if eyeok
                    TriggerArduino(handles)
                    t1=clock;
                end
            end
        end
        
        t=round(1000*etime(clock,t2))/1000;
        % -- pause in the left time -----
        d=updaterate-t;
        if d>0
            pause(d)        %   java.lang.Thread.sleep(d*1000);     %     drawnow
        else
            disp(sprintf('%s: Unable to sustain requested stream rate! Loop required %f seconds.',datestr(now,'HH:MM:SS'),t))
        end
    end
catch
    try % If it's a dropped frame, see if we can recover
        handles.pwin=image(zeros(480,640),'Parent',handles.cameraAx);
        pause(0.5) 
        closepreview(vidobj);
        pause(0.2) 
        preview(vidobj,handles.pwin);
        stream(handles)
        disp('Caught camera error')
    catch
        disp('Aborted eye streaming.')
        set(handles.togglebutton_stream,'Value',0);
        return
    end
end

function eyeok=checkeye(handles,eyedata)
eyethrok = (eyedata(end,2)<str2double(get(handles.edit_eyethr,'String')));
eyedata(:,1)=eyedata(:,1)-eyedata(end,1);  
recenteye=eyedata(eyedata(:,1)>-1000*str2double(get(handles.edit_stabletime,'String')),2);
eyestableok = ((max(recenteye)-min(recenteye))<str2double(get(handles.edit_stableeye,'String')));
eyeok = eyethrok && eyestableok;


%%%%%%%%%% end of user functions %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







% --- Executes on button press in checkbox_random.
function checkbox_random_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_random (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_random


function edit_tone_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_tone as text
%        str2double(get(hObject,'String')) returns contents of edit_tone as a double


% --- Executes during object creation, after setting all properties.
function edit_tone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_stimtype.
function popupmenu_stimtype_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_stimtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_stimtype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_stimtype


% --- Executes during object creation, after setting all properties.
function popupmenu_stimtype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_stimtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_pretime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pretime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_pretime as text
%        str2double(get(hObject,'String')) returns contents of edit_pretime as a double


% --- Executes during object creation, after setting all properties.
function edit_pretime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pretime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in togglebutton_tgframerate.
function togglebutton_tgframerate_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_tgframerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of togglebutton_tgframerate





% --- Executes on button press in checkbox_save_metadata.
function checkbox_save_metadata_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_save_metadata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_save_metadata


function edit_ITI_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ITI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_ITI as text
%        str2double(get(hObject,'String')) returns contents of edit_ITI as a double


% --- Executes during object creation, after setting all properties.
function edit_ITI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ITI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_puffdur_Callback(hObject, eventdata, handles)
% hObject    handle to edit_puffdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_puffdur as text
%        str2double(get(hObject,'String')) returns contents of edit_puffdur as a double


% --- Executes during object creation, after setting all properties.
function edit_puffdur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_puffdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_TDTBlockName_Callback(hObject, eventdata, handles)
% hObject    handle to edit_TDTBlockName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_TDTBlockName as text
%        str2double(get(hObject,'String')) returns contents of edit_TDTBlockName as a double


% --- Executes during object creation, after setting all properties.
function edit_TDTBlockName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_TDTBlockName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_stabletime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stabletime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_stabletime as text
%        str2double(get(hObject,'String')) returns contents of edit_stabletime as a double


% --- Executes during object creation, after setting all properties.
function edit_stabletime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stabletime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_stableeye_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stableeye (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_stableeye as text
%        str2double(get(hObject,'String')) returns contents of edit_stableeye as a double


% --- Executes during object creation, after setting all properties.
function edit_stableeye_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stableeye (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_eyethr_Callback(hObject, eventdata, handles)
% hObject    handle to edit_eyethr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_eyethr as text
%        str2double(get(hObject,'String')) returns contents of edit_eyethr as a double


% --- Executes during object creation, after setting all properties.
function edit_eyethr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_eyethr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_loadparams.
function pushbutton_loadparams_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadparams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

paramtable = getappdata(0,'paramtable');

[paramfile,paramfilepath,filteridx] = uigetfile('*.csv');

if paramfile & filteridx == 1 % The filterindex thing is a hack to make sure it's a csv file
    paramtable.data=csvread(fullfile(paramfilepath,paramfile));
    set(handles.uitable_params,'Data',paramtable.data);
    setappdata(0,'paramtable',paramtable);
end
