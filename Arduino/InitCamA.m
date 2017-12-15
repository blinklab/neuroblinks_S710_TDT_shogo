function InitCamA(ch,recdur)

% First delete any existing image acquisition objects
% imaqreset

disp('creating video object ...')
vidobj = videoinput('gige', ch, 'Mono8');
disp('video settings ....')

metadata=getappdata(0,'metadata');
src = getselectedsource(vidobj);
% src.ExposureTimeAbs = 4900;
src.ExposureTimeAbs = metadata.cam.init_ExposureTime;
if isprop(src,'AllGainRaw')
    src.AllGainRaw=metadata.cam.init_GainRaw;
else
    src.GainRaw=metadata.cam.init_GainRaw;
end

src.PacketSize = 9014;
vidobj.LoggingMode = 'memory'; 
src.AcquisitionFrameRateAbs=200;
vidobj.FramesPerTrigger=ceil(recdur/(1000/200));

% triggerconfig(vidobj, 'hardware', 'RisingEdge', 'Line1-AcquisitionStart');
triggerconfig(vidobj, 'hardware', 'DeviceSpecific', 'DeviceSpecific');

% Different version of the camera drivers (and different versions of
% Matlab) annoyingly use different names for the property values. These are
% the possibilities that I've seen but there may be more depending on your
% configuration. 
if isprop(src,'FrameStartTriggerMode')
    src.FrameStartTriggerMode = 'On';
    src.FrameStartTriggerActivation = 'RisingEdge';
    src.FrameStartTriggerSource = 'Freerun';
else
    src.TriggerMode = 'On';
    src.TriggerActivation = 'RisingEdge';
    src.TriggerSource = 'Freerun';
end

%% Save objects to root app data
setappdata(0,'vidobj',vidobj)
setappdata(0,'src',src)

