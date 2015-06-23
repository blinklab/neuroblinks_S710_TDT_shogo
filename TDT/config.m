%%%% This is configuration file for each user. %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% basedir='D:\shane\matlab\neuroblinks v 1.1';
tank='optoelectrophys'; % The tank should be registered using TankMon

% Specific to using Thomas Drive
metadata.microdrive.LogFolder = 'C:\shane\data\experiment logs\thomas logs';
% Need to make this something that can be changed online but I don't have time now
metadata.microdrive.offsets = [0,0,0,0,0,0,0];

% If Neuroblinks is launched from the root directory of the mouse, make a new directory for the session, otherwise leave that up to the user
cwd=regexp(pwd,'\\','split');
if regexp(cwd{end},'[A-Z]\d\d\d')  % Will match anything of the form LDDD, where L is single uppercase letter and DDD is a seq of 3 digits
    mkdir(datestr(now,'yymmdd'))
    cd(datestr(now,'yymmdd'))
end

% ------ Letter for mouse -----
path1=pwd;   ind1=find(path1=='\');   metadata.mouse=path1(ind1(end-1)+1:ind1(end)-1);
% metadata.mouse='Sxxx';  % for Shane
% metadata.mouse='T';     % for shogo


%%% Set up user environment %%%

% -- specify the location of bottomleft corner of MainWindow & AnalysisWindow  --
ghandles.pos_mainwin=[8,450];     ghandles.size_mainwin=[840 720]; 
ghandles.pos_anawin=[470 50];     ghandles.size_anawin=[1030 840]; 
ghandles.pos_oneanawin=[8,48];    ghandles.size_oneanawin=[840,364];   
ghandles.pos_lfpwin=[470 50];    ghandles.size_lfpwin=[600 380];

% ------ Initial value of the conditioning table ----

% Search for per-mouse config file and load it if it exists, otherwise default to the paramtable below

mousedir=regexp(pwd,['[A-Za-z]:\\.*\\', metadata.mouse],'once','match');
condfile=fullfile(mousedir,'condparams.csv');

if exist(condfile)
	paramtable.data=csvread(condfile);
else
	paramtable.data=...
    [9,  500,1,200, 20,1,1;...
     1,  500,1,200, 0, 1,0;...
     9,  500,2,400, 20,2,1;...
     1,  500,2,400, 0, 2,0;...
     9,  500,1,200, 20,3,1;...
     1,  500,1,200, 0, 3,0;...
     9,  500,2,400, 20,4,1;...
     1,  500,2,400, 0, 4,0;...
     zeros(2,7)];
 end
 
% paramtable.data=zeros(10,7);
%  paramtable.data=...
%     [50, 500,1,200, 20, 1,1;...
%      50, 500,2,400, 20, 1,0;...
%      zeros(8,7)];

% Optional support programs to be launched automatically.
% Comment out the ones you don't use or add new ones.
% If you comment out the TDT line you must have OpenWorkbench already running when you start Neuroblinks
button=questdlg('Do you want to launch TDT?');
if strcmpi(button,'Yes')
    winopen(sprintf('%s\\TDT\\private\\TDTFiles\\simultaneous opto- microstim and recording.wsp',basedir));
    pause(5);
end
% winopen('C:\Program Files (x86)\DinoCapture 2.0\DinoCapture.exe');
% winopen('C:\Program Files\Sublime Text 2\sublime_text.exe');

