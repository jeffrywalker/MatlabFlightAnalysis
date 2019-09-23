%> \brief segments a time history by sweep and stores into sweep events
% SWP.mode.axis
% SWP.acro.roll(1)
% SWP.acro.roll(2)
% SWP.stab.roll
% SWP.phld.roll
function od = getSweepEvents(obj, varargin)
p = inputParser;
addOptional(p, 'logIdx', [])
addOptional(p, 'logNum', [])
addOptional(p, 'usrMap', {});
addOptional(p, 'defMap', {'SWP1',{'*'};...
                          'SWP2',{'*'};...
                          'SWP3',{'*'};...
                          'BARO',{'*'};...
                          'GPS',{'*'};...
                          'RCIN',{'*'};...
                          'RCOU',{'*'};...
                          'VIBE',{'*'} });
parse(p, varargin{:})
ui = p.Results;

if isempty(ui.logIdx) && isempty(ui.logNum)
    error('Must specify either logIdx or logNum')
elseif ~isempty(ui.logIdx)
    logIdx = ui.logIdx;
else
    logIdx = obj.getLogIdx(ui.logNum);
end

if isempty(logIdx) || logIdx > numel(obj.logs)
    error('invalid log requested')
end

if ~isempty(ui.usrMap)
    tmp = reshape(ui.usrMap, [length(ui.usrMap)/2, 2]);
    map = vertcat(ui.defMap, ui.usrMap);
else
    map = ui.defMap;
end

% determine common data rates
tVec = cell(size(map,1),1);
tRat = zeros(size(tVec));
for j=1:size(map,1)
    tVec{j} = obj.logs{logIdx}.log.(map{j,1}).TimeS; % ensure equal length?
    tRat(j) = floor(mean(1./diff(tVec{j}))); % group record rate
end
tRat = round(tRat / 5) * 5; % recording takes place on common intervals but 
                            % computationally may slightly differ. This
                            % excludes slower logging we dont need.
tRat(tRat > 100) = round(tRat(tRat > 100) / 100) * 100;

sweepDataRate = sprintf('f%d',tRat(1));

% group by unique rates
uRat = unique(tRat);
rName = arrayfun(@(x) sprintf('f%d',x), uRat, 'UniformOutput', false);
for j=1:numel(uRat)
   % determine which signals are at this rate
   ridx = find(tRat == uRat(j));
   if numel(ridx) > 1 && ~all(diff(cellfun(@(x) length(x), tVec(ridx)))==0)
       % record lengths
       warning('record lengths not equal for data rate: %d\n', uRat(j))
   end
   rmap = map(ridx,:); % subselect map with these rates
   [dta.(rName{j}), units.(rName{j})] = obj.getMultiSignals(rmap, 'logIdx', logIdx);
end

% get sweep indices
[swpIdx, swpTime] = obj.getSweepIndices('logIndex', logIdx);
modeSig = obj.getSignal(logIdx, 'MODE', 'Mode');
for j=1:size(swpIdx,1)
    for k=1:numel(rName)
        % get indices for this rate
        iStart = find(dta.(rName{k}).time >= swpTime(j,1), 1);
        iStop  = find(dta.(rName{k}).time <= swpTime(j,2), 1, 'last');
        sd.(rName{k}) = structfun(@(x) x(iStart:iStop), dta.(rName{k}), 'UniformOutput', false);
    end
    
    % get flight mode
    mname = getModeName(modeSig, sd.(sweepDataRate));
    % get sweep axis
    aname = getAxisName(sd.(sweepDataRate));
    % shift all times to zero
    for k=1:numel(rName)
        sd.(rName{k}).time = sd.(rName{k}).time - sd.(rName{k}).time(1);
    end
    
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
    od.(mname).(aname)(ii) = sd;
end
% add information about this flight
od.commit   = obj.logs{logIdx}.log.commit;
% store flight time in sortable format
od.fltID = obj.getFlightID('logIdx', logIdx);
% store signal units
od.units = units;
end
%==========================================================================
function modeName = getModeName(modeSig, sweepData)
    % defines.h: STAB=0, ACRO=1, PHLD=16
    tSwpStart = min(sweepData.time(sweepData.sflg == 1));
    mode = modeSig.Mode(max(find(modeSig.time < tSwpStart)));
    switch mode
        case 0
            modeName = 'stab';
        case 1
            modeName = 'acro';
        case 16
            modeName = 'phld';
        otherwise
            error('UNKNOWN MODE ACTIVE')
    end
end
function axisName = getAxisName(sweepData)
    % ROLL=1 PITCH=2 YAW=3 COL/THR=4
    switch sweepData.sax(find(sweepData.sflg == 1, 1))
        case 1 
            axisName = 'roll';
        case 2
            axisName = 'pitch';
        case 3
            axisName = 'yaw';
        case 4
            axisName = 'col';
        case 5
            axisName = 'thr';
        otherwise
            error('unknown axis value')
    end
end