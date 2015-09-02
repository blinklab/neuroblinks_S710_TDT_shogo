function WriteThomasDepth(obj,event)
    % Timer callback function

    % Get connection to TDT for writing
    TDT=getappdata(0,'tdt'); 
    metadata=getappdata(0,'metadata');

    % Only do something if we're recording the neuronal signal
    if TDT.GetTargetVal('ustim.RecEnable') == 0
        return
    end

    % Get file name of log
    % Search for newest file matching the pattern "EMM PositionLog*.csv"
    % fname = 'C:\shane\data\experiment logs\thomas logs\EMM PositionLog 2014-09-23-14-02.csv';
    fname = FindNewestLog(metadata.microdrive.LogFolder); 

    if isempty(fname)
        return
    end

    depths = ParseThomasLog(fname);

    if ~isempty(depths)
        % disp(depths)
        for i=1:4
            varstring = sprintf('ustim.ElectrodeDepth%d',i);
            % disp(varstring)
            TDT.SetTargetVal(varstring,depths(i)-metadata.microdrive.offsets(i));
        end
        % Trigger saving into tank
        TDT.SetTargetVal('ustim.ElectrodeDepthTrigger',1);
        pause(0.01);
        TDT.SetTargetVal('ustim.ElectrodeDepthTrigger',0);    
    end




function depths = ParseThomasLog(fname)
    % Given full path and name of Thomas recording log file, return depths for all electrodes reported on last line

    fid = fopen(fname);

    if fid < 0
        depths = [];    % Can't read file, return empty array
        return
    end

    % Seek just far enough back that we'll definitely be above the last line containing text
    fseek(fid,-200,'eof');

    currentline = fgetl(fid);
    nextline = fgetl(fid);

    % Now find the last line with text
    while ischar(nextline)
        currentline = nextline;
        nextline = fgetl(fid);
    end

    % Parse it to get depths
    % Line is formatted like this:
    % 14:02:12;100000,000;100000,000;100000,000;100000,000;100000,000;100000,000;100000,000;100000,500;
    s=strsplit(currentline,{';', ','},'CollapseDelimiters',true);
    depths = cellfun(@str2double,s(2:2:end-1));

    fclose(fid);


function newestLog = FindNewestLog(folder)
    % Given a folder to search, return the full file name of the newest log file
    d = dir(fullfile(folder,'EMM PositionLog*.csv'));

    times = [d.datenum];
    names = {d.name};

    if isempty(names)
        newestLog = '';
        return
    end

    [mx,newest] = max(times);

    newestLog = fullfile(folder,names{newest});