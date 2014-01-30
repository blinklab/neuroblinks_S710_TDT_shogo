function continuousrecord(handles)

vidobj = getappdata(0,'vidobj');
src = getappdata(0,'src');
metadata = getappdata(0,'metadata');

% Switch from memory logging to disk logging
set(vidobj, 'LoggingMode', 'disk')

% Create a VideoWriter object with the profile set to MPEG-4
ctime = etime(clock,datevec(metadata.ts(1)));
videoname=sprintf('%s\\%s_%05d.mp4',metadata.folder,metadata.TDTblockname,round(ctime));
logfile = VideoWriter(videoname, 'MPEG-4');

% Configure the video input object to use the VideoWriter object.
vidobj.DiskLogger = logfile;

% Now that the video input object is configured forlogging data to a Motion JPEG 2000 file, initiate the acquisition.
start(vidobj)

% Wait for the acquisition to finish.
wait(vidobj, 5)

% When logging large amounts of data to disk, disk writingoccasionally lags behind the acquisition. To determine whether allframes are written to disk, you can optionally use the DiskLoggerFrameCount property.
while (vidobj.FramesAcquired ~= vidobj.DiskLoggerFrameCount) 
    pause(.1)
end

% You can verify that the FramesAcquired and DiskLoggerFrameCount propertieshave identical values by using these commands and comparing the output.
vidobj.FramesAcquired
vidobj.DiskLoggerFrameCount

% When the video input object is no longer needed, deleteit and clear it from the workspace.
delete(vidobj)
clear vidobj