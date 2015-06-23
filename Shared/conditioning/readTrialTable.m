function trialvars=readTrialTable(current_tr)
% Return current row from trial table, which is stored in the app data for the root figure

trialtable=getappdata(0,'trialtable');
% ghandles=getappdata(0,'ghandles');
% handles=guidata(ghandles.maingui);


[m,n]=size(trialtable);

% This is a hack and should be moved somewhere more appropriate later
% Turns off the "continuous" button if we've reached the end of the table in case we want to limit the number of trials done
% if mod(current_tr,m) == 0 && current_tr > 0
%     % disp(sprintf('Current trial: %d, size of table: %d',current_tr,m))
%     disp(sprintf('\nEnd of Trial Table reached: Automatically disabled continuous mode\n'))
%     if get(handles.toggle_continuous,'Value') == 1
%         set(handles.toggle_continuous,'Value',0)
%         set(handles.toggle_continuous,'String','Continuous: OFF')
%     end
% end

current_tr=mod(current_tr-1,m)+1;	% Cycle through the table again if we've reached the end
% if current_tr == 0
% 	current_tr=m;	% Need this additional step b/c mod(x,{x,2x,3x,..})==0, which happens when we reach the last item in the table
% end


trialvars=trialtable(current_tr,:);