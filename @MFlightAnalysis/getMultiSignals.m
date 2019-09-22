%> \param logIdx log to use
%> \param smap {group, {signals}} use '*' to get all signals in a group
%
%> \returns ss a signal struct, or sm a signal matrix
%> \note reference time is from first signal
function varargout = getMultiSignals(obj, smap, varargin)
p = inputParser;
addOptional(p, 'logIdx', 1)
addOptional(p, 'logNum', [])
addOptional(p, 'additionalExclude', {});
addOptional(p, 'defaultExclude', {'LineNo', 'TimeS', 'TimeUS', 'name',...
                                  'typeNumID', 'fieldUnits', 'fieldMultipliers',...
                                  'DatenumUTC'});
parse(p, varargin{:})
ui = p.Results;

if ~isempty(ui.logNum)
    logIdx = obj.getLogIdx(ui.logNum);
else
    logIdx = ui.logIdx;
end

% total exclude list
excludeList = horzcat(ui.defaultExclude, ui.additionalExclude);

if size(smap, 1) == 1 && size(smap,2) > 2
    smap = reshape(smap, [length(smap)/2, 2])';
end

% expand group with all signals
for j=1:size(smap,1)
    grp = smap{j,1};
    if strcmp(smap{j,2}{1},'*')
        % all
        fn = fieldnames(obj.logs{logIdx}.log.(grp));
        fn(cellfun(@(x) any(strcmp(x, excludeList)), fn)) = [];
        smap{j,2} = fn;
    end
    smap{j,2} = reshape(smap{j,2},[1 length(smap{j,2})]);
end
    
% check for unique signal names in the set
allSig = horzcat(smap{:,2});
[allSig_,ia,ic] = unique(allSig);
sic = sort(ic);
special = allSig_(sic(find(diff(sic)==0)));

% verify common time, otherwise data won't be lined up

% loop through all groups

for j=1:size(smap,1)
    grp = smap{j,1};
    sn  = smap{j,2};
    % loop through all signals
    for k=1:numel(sn)
        sig = sn{k};
        [d, t, unit] = obj.getSignal(logIdx, grp, sig, 'asStruct', false);
        if j==1 && k==1 
            % extract time
            ss.time = t;
        end
        % check if special
        sname = sig;
        if ~isempty(special) && any(strcmp(sig, special))
            sname = sprintf('%s_%s',sig, grp);
        end
        ss.(sname) = d;
        units.(sname) = unit;
    end
    
end

varargout{1} = ss;
varargout{2} = units;
end