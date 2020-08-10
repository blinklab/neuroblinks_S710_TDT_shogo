% Set up environment and launch app based on which version you want to use
function neuroblinks(varargin)

    % Load local configuration for these rigs
    % Should be somewhere in path but not "neuroblinks" directory or subdirectory
    neuroblinks_config
    
    % Set up defaults in case user doesn't specify all options
    device = DEFAULTDEVICE;
    rig = DEFAULTRIG;

    % Input parsing
    if nargin > 0
        for i=1:nargin
            if any(strcmpi(varargin{i},ALLOWEDDEVICES))
                device = varargin{i};
            elseif ismember(varargin{i},1:length(ALLOWEDCAMS))
                rig = varargin{i}; 
            end
        end
    end
    
    try
        switch lower(device)
            case 'tdt'
                % TDT version
                % Set up path for this session
                [basedir,mfile,ext]=fileparts(mfilename('fullpath'));
                oldpath=addpath(genpath(fullfile(basedir,'TDT')));
                addpath(genpath(fullfile(basedir,'Shared')));
                
            case 'arduino'
                
                % % Arduino version
                % % Set up path for this session
                [basedir,mfile,ext]=fileparts(mfilename('fullpath'));
                oldpath=addpath(genpath(fullfile(basedir,'Arduino')));
                addpath(genpath(fullfile(basedir,'Shared')));
                
            otherwise
                error(sprintf('Device %s not found', device))
                
        end
    catch
        error('You did not specify a valid device');
    end
    
    if strcmp(lower(device),'tdt')
        % Optional support programs to be launched automatically.
        % Add more here if you want
        button=questdlg('Do you want to launch TDT?');
        [basedir,mfile,ext]=fileparts(mfilename('fullpath'));
        if strcmpi(button,'Yes')
            %     winopen(sprintf('%s\\private\\TDTFiles\\simultaneous opto- microstim and recording.wsp',basedir));
            winopen(sprintf('%s\\TDT\\private\\TDTFiles\\TDTFiles.wsp',basedir));
            pause(7);
        end
    end
    

    % Matlab is inconsistent in how it numbers cameras so we need to explicitely search for the right one
    disp('Finding cameras...')

    % Get list of configured cameras
    foundcams = imaqhwinfo(CAMADAPTOR);
    founddeviceids = cell2mat(foundcams.DeviceIDs); 

    if isempty(founddeviceids)
        error('No cameras found')
    end
    
    %====== Getting camera ID  =====
    cam = 0;
    
    if verLessThan('matlab', '8.3') % older than 2014a
        if length(founddeviceids)>1
            cam = ALLOWEDCAMS(rig);
        else,
            cam = founddeviceids(1);
        end
    elseif verLessThan('matlab', '8.5')  % for 2014a-b
        % This code doesn't work on some versions of Matlab (this worked on 2014a)
        % so it's commented out. If you plan to use
        % more than one camera on the same computer you should uncomment it and find a way to get it working.
        for i=1:length(founddeviceids)
            vidobj = videoinput(CAMADAPTOR, founddeviceids(i), 'Mono8');
            src = getselectedsource(vidobj);
            if strcmp(src.DeviceID,ALLOWEDCAMS_2014a{rig})
                cam = i;
            end
            delete(vidobj)
        end
    else,             % 2015a or later
        if length(founddeviceids)>1
            cam = ALLOWEDCAMS(rig);
%             camlist=gigecamlist;
%             for i=1:length(founddeviceids)
%                 if strcmp(camlist.SerialNumber{founddeviceids(i)},ALLOWEDCAMS{rig})
%                     cam = founddeviceids(i);
%                 end
%             end
        else,
            cam = founddeviceids(1);
        end
    end
    
    if ~cam
        error(sprintf('The camera you specified (%d) could not be found',rig));
    end
    %================================================
    
    metadata.device=device;
    setappdata(0,'metadata',metadata);
   
    % A different "launch" function should be called depending on whether we're using TDT or Arduino
    % and will be determined by what's in the path generated above
    Launch(rig,cam)
    