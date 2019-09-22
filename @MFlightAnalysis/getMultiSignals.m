%> \param logIdx log to use
%> \param smap {group, {signals}} use '*' to get all signals in a group
%
%> \returns ss a signal struct, or sm a signal matrix
%> \note reference time is from first signal
function varargout = getMultiSignals(obj, logIdx, smap, varargin)
p = inputParser;
addOptional(p, 'additionalExclude', {});
addOptional(p, 'defaultExclude', {'LineNo', 'TimeS', 'TimeUS', 'name',...
                                  'typeNumID', 'fieldUnits', 'fieldMultipliers',...
                                  'DatenumUTC'});
parse(p, varargin{:})
ui = p.Results;

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
special = cell(numel(allSig) - numel(allSig_));
ii = 1;
for j=1:numel(special)
    while(true)
        if numel(find(ic == ic(ii))) > 1
            special{j} = allSig{ic(ii)};
            break
        else
            ii = ii+1;
        end
    end
end

% loop through all groups
for j=1:size(smap,1)
    grp = smap{j,1};
    sn  = smap{j,2};
    % loop through all signals
    for k=1:numel(sn)
        sig = sn{k};
        [d, t] = obj.getSignal(logIdx, grp, sig, 'asStruct', false);
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
    end
    
end

varargout{1} = ss;

end