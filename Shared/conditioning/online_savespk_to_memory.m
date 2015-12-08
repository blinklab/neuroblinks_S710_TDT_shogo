function online_savespk_to_memory(obj,event)
%  callback function by timer obj
if ~isappdata(0,'ttx'), return, end

% ---- spike data --------
metadata=getappdata(0,'metadata');
trials=getappdata(0,'trials');
TTX=getappdata(0,'ttx');

if isfield(trials,'spk'), 
    length_trials_spk=length(trials.spk);
    if length_trials_spk~=0,
        if sum(isnan(trials.spk(length_trials_spk).ts_interval)),
            for tnum=length_trials_spk:-1:1;
                if sum(isnan(trials.spk(tnum).ts_interval)),
                    length_trials_spk=tnum-1;
                elseif max(trials.spk(tnum).time)<300
                    length_trials_spk=tnum-1;
                else
                    continue,
                end
            end
        end
    end
else, length_trials_spk=0;  end

% --- reset just after starting next bloxk ---
if length_trials_spk>metadata.eye.trialnum2+1 | metadata.eye.trialnum2==1, 
    trials.spk=[]; length_trials_spk=0; setappdata(0,'trials',trials); 
end

ok=TTX.SelectBlock(metadata.TDTblockname);
if ~ok
    error('Could not select current block.')
end
    
for tnum=length_trials_spk+1:length(trials.eye);
    online_savespk_for_a_trial(tnum)
end




