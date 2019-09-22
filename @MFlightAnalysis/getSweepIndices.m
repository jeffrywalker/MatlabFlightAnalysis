%> \brief determines start/stop indices of sweeps for the given log
function [sweepIndices, sweepTimes] = getSweepIndices(obj, varargin)
p = inputParser;
addOptional(p, 'logIndex', 1)
addOptional(p, 'minSweepDuration', 80)
addOptional(p, 'preSweepTime', 5)
addOptional(p, 'postSweepTime', 5)
parse(p, varargin{:})
ui = p.Results;

[sFlg, time] = obj.getSignal(ui.logIndex, 'SWP1', 'sflg', 'asStruct', false);
hwTime = time; % time without shift
% get minimum nbr elems for sweep duration
time      = time - time(1); % shift to zero
swpLength = find(time >= ui.minSweepDuration, 1);
preSweep  = find(time >= ui.preSweepTime, 1);
postSweep = find(time >= ui.postSweepTime, 1);

% leading edge
lei = zeros(size(sFlg));
for j=2:numel(sFlg)
    if sFlg(j) == 1 && sFlg(j-1) == 0
        lei(j) = 1;
    end
end
LE = find(lei == 1);

% trailing edge
tei = zeros(size(sFlg));
for j=1:numel(sFlg)-1
    if sFlg(j) == 1 && sFlg(j+1) == 0
        tei(j) = 1;
    end
end
TE = find(tei == 1);

% get valid sweep segments
ValidSweeps  = find((TE - LE >= swpLength)==1);
sweepIndices = zeros(numel(ValidSweeps), 2);
sweepTimes   = zeros(numel(ValidSweeps), 2);
for j=1:numel(ValidSweeps)    
    % handle pre sweep
    prevTE = max(TE(TE <= LE(ValidSweeps(j))))+1;
    if isempty(prevTE)
        prevTE = 1;
    end
    sweepIndices(j,1) = max(prevTE, max(LE(ValidSweeps(j)) - preSweep, 1));
    sweepTimes(j,1)   = hwTime(sweepIndices(j,1));
    % handle post sweep
    nextLE = min(LE(LE >= TE(ValidSweeps(j))))-1;
    if isempty(nextLE)
        nextLE = numel(sFlg);
    end
    sweepIndices(j,2) = min(nextLE, min(TE(ValidSweeps(j)) + postSweep, numel(sFlg)));
    sweepTimes(j,2)   = hwTime(sweepIndices(j,2));
end

end