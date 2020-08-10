function InitCam(ch,recdur)
% First delete any existing image acquisition objects
neuroblinks_config
imaqreset

disp('creating video object ...')
% vidobj = videoinput('gentl', ch, 'Mono8');
vidobj = videoinput(CAMADAPTOR, ch, 'Mono8');
disp('video settings ....')

metadata=getappdata(0,'metadata');

src = getselectedsource(vidobj);

src.StreamBytesPerSecond = 90000000;
src.ExposureTimeAbs = metadata.cam.init_ExposureTime;

% Different version of the camera drivers (and different versions of
% Matlab) annoyingly use different names for the property values. These are
% the possibilities that I've seen but there may be more depending on your
% configuration. 
% Set gain based on how bright the image appears. However, it's more important to
% set up the IR light and camera aperature properly. Gain is just
% multiplying the pixel values and can be done after the video has been
% acquired if needed. 
if isprop(src,'AllGainRaw')
    src.AllGainRaw=metadata.cam.init_GainRaw;
else
    src.GainRaw=metadata.cam.init_GainRaw;
end

% src.NetworkPacketSize = '9014';
if strcmpi(CAMADAPTOR,'gige'),
    src.PacketSize = 8228;
%     src.PacketSize = 2000;
    src.PacketDelay = 2000;		% Calculated based on frame rate and image size using Mathworks helper function
end

vidobj.LoggingMode = 'memory'; 
vidobj.FramesPerTrigger=1;

% vidobj.LoggingMode = 'memory'; 
% vidobj.FramesPerTrigger=1;
% src.AcquisitionFrameRateAbs=200;

%for 2010b
% triggerconfig(vidobj,'Hardware','RisingEdge','externalTrigger')
% triggerconfig(vidobj, 'hardware', 'risingEdge', 'externalTrigger');
% triggerconfig(vidobj, 'hardware', 'RisingEdge', 'Line1-FrameStart');

triggerconfig(vidobj, 'hardware', 'DeviceSpecific', 'DeviceSpecific');

% Different version of the camera drivers (and different versions of
% Matlab) annoyingly use different names for the property values. These are
% the possibilities that I've seen but there may be more depending on your
% configuration. 
if isprop(src,'FrameStartTriggerMode')
    src.FrameStartTriggerMode = 'On';
    src.FrameStartTriggerActivation = 'LevelHigh';
    src.FrameStartTriggerSource = 'Freerun';
else
    src.TriggerMode = 'On';
    src.TriggerActivation = 'LevelHigh'; % RisingEdge,
    src.TriggerSource = 'Freerun';  % FixedRate
%     src.TriggerSelector = 'FrameStart';
end

src.AcquisitionFrameRateAbs=200;

%% Save objects to root app data

setappdata(0,'vidobj',vidobj)
setappdata(0,'src',src)

