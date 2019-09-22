%> \brief segments a time history by sweep and stores into sweep events
% SWP.mode.axis
% SWP.acro.roll(1)
% SWP.acro.roll(2)
% SWP.stab.roll
% SWP.phld.roll
function od = getSweepEvents(obj, logIdx, varargin)
p = inputParser;
addOptional(p, 'usrMap', {});
addOptional(p, 'defMap', {'SWP1',{'*'};...
                          'SWP2',{'*'}});
parse(p, varargin{:})
ui = p.Results;

if ~isempty(ui.usrMap)
    tmp = reshape(ui.usrMap, [length(ui.usrMap)/2, 2]);
    map = vertcat(ui.defMap, ui.usrMap);
else
    map = ui.defMap;
end

% get sweep indices
swpIdx = obj.getSweepIndices('logIndex', logIdx);

% get data structure
dta = obj.getMultiSignals(logIdx, map);
for j=1:size(swpIdx,1)
    sweepData = structfun(@(x) x(swpIdx(j,1):swpIdx(j,2)), dta, 'UniformOutput', false);
   
    % get flight mode
    % defines.h: STAB=0, ACRO=1, PHLD=16
    tmp = obj.getSignal(logIdx, 'MODE', 'Mode');
    mode = tmp.Mode(max(find(tmp.time < sweepData.time(1))));
    switch mode
        case 0
            mname = 'stab';
        case 1
            mname = 'acro';
        case 16
            mname = 'phld';
        otherwise
            error('UNKNOWN MODE ACTIVE')
    end
    
    % get sweep axis
    % ROLL=1 PITCH=2 YAW=3 COL/THR=4
    switch sweepData.sAx(find(sweepData.sFlg == 1, 1))
        case 1 
            aname = 'roll';
        case 2
            aname = 'pitch';
        case 3
            aname = 'yaw';
        case 4
            aname = 'col';
        case 5
            aname = 'thr';
        otherwise
            error('unknown axis value')
    end
    sweepData.time=sweepData.time - sweepData.time(1);
    ii = 1;
    if j > 1
       fn = fieldnames(od);
       if contains(mname, fn)
           fn = fieldnames(od.(mname));
           if contains(aname, fn)
               ii = numel(od.(mname).(aname))+1;
           end
       end
    end
    od.(mname).(aname)(ii) = sweepData;
end

end