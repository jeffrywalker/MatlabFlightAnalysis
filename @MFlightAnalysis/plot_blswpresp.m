%> \brief plots the broken loop sweep response
function plot_blswpresp(obj, varargin)
% common options
opt = obj.plotOptions(varargin{:});
% local options
p = inputParser;
p.KeepUnmatched = true;
addOptional(p, 'name', 'bl-sweep-response');
addOptional(p, 'incDes', true);
addOptional(p, 'legend', true);
addOptional(p, 'dispDeg', true);
addOptional(p, 'plotRC', true);
addOptional(p, 'swpEvent', []); % plot specific sweep event
parse(p, varargin{:});
% merge the options
warning off
opt = catstruct(opt, p.Results);
warning on

if isempty(opt.logNum)
    error('the log number ''logNum'' must be defined.')
end

% figure to plot in
fh = nf(opt.name);

% logs index to plot
li = obj.getLogIdx(opt.logNum);
[~, swpTime] = obj.getSweepIndices('logIndex', li);

% sweep signals to acquire for plotting
smap = {'SWP1',{'dlat','dlon','dped','dcol','swp','sflg'};...
        'SWP2',{'p','q','r','phi','tht','hdg','az'};...
        'SWP3',{'PD'}};
% plot groupings
pmap = {'dlat', 'p', 'phi',...
        'dlon', 'q', 'tht',...
        'dped', 'r', 'hdg',...
        'dcol', 'az', 'alt'};
% include sweep signal on active axis
%> \note this assumes the sweep axis is NOT changed during flight!
saxis     = obj.getSignal(li, 'SWP1','sax');
idx       = (mean(saxis.sax)-1) * 3 +1;
pmap{idx} = {'swp', pmap{idx}};


[dta, units] = obj.getMultiSignals(smap, 'logNum', opt.logNum);
dta.alt   = -dta.PD;
units.alt = units.PD;
tmp = {'dlat','dlon','dped','dcol','swp'};
for j=1:numel(tmp)
    units.(tmp{j}) = '%';
end

% get indices for plotting
if ~isempty(opt.swpEvent) && opt.swpEvent <= size(swpTime, 1)
    iStart = find(dta.time >= swpTime(opt.swpEvent,1), 1);
    iStop  = find(dta.time <= swpTime(opt.swpEvent,2), 1, 'last');
    % subselect this data
    dta = structfun(@(x) x(iStart:iStop), dta, 'UniformOutput', false);
    % label the active mode
    fmode = obj.getSignal(li, 'MODE','Mode');
    tSwpStart = min(dta.time(dta.sflg == 1));
    fmode = fmode.Mode( find(fmode.time <= tSwpStart, 1, 'last'));
    switch fmode
        case 0
            modeStr = 'stab';
        case 1
            modeStr = 'acro';
        case 16
            modeStr = 'phld';
        otherwise
            modeStr = '';
    end
else
    modeStr = '';
end

if opt.shiftToZero
    dta.time = dta.time - dta.time(1);
end

ax = [];
nrow = 4;
ncol = 3;
nplt = nrow * ncol;
if numel(pmap) > nplt
    error('plot grouping exceeds subplots')
end
% bottom row indices for marking time
bidx = (nplt - (ncol-1)):nplt;
for j=1:numel(pmap)
    ax(j) = subplot(nrow, ncol, j);
    obj.cleanup(opt.clear)
    if ~iscell(pmap{j})
        sigs = pmap(j);
    else
        sigs = pmap{j};
    end
    % change color order so sweep is different
    if any(contains(sigs, 'swp'))
        co = get(groot,'defaultAxesColorOrder');
        coi = 1:size(co,1);
        coi(1:2) = fliplr(coi(1:2));
        co  = co(coi,:);
        set(gca,'ColorOrder', co)
    else
        set(gca,'ColorOrder',get(groot,'defaultAxesColorOrder'))
    end
    % plot all signals in this group
    for k=1:numel(sigs)
       if opt.dispDeg && ischar(units.(sigs{k})) && contains(units.(sigs{k}), 'rad')
           kconv = 180 / pi;
           ylbl  = strrep(units.(sigs{k}),'rad','deg');
       else
           kconv = 1;
           ylbl  = units.(sigs{k});
       end
       plot(dta.time, dta.(sigs{k}) * kconv)
       hold on
       ylabel(ylbl)
       if k==1
           tmp = strrep(sigs{k},'swp',sprintf('%s:swp',modeStr));
           if contains(tmp,'swp') && numel(sigs) == 2
               tmp = sprintf('%s:%s',tmp, sigs{2});
           end
           title(tmp)
       end
    end
    grid on
    if any(j == bidx)
        xlabel('Time (s)')
    end       
    set(ax(j),'YLimSpec','tight')
end
linkaxes(ax, 'x')
set(ax(1),'XLimSpec','tight')

% plot RC IO
if opt.plotRC
    if ~isempty(opt.swpEvent)
        tStart = swpTime(opt.swpEvent,1);
        tStop  = swpTime(opt.swpEvent,2);
    else
        tStart = 0;
        tStop = inf;
    end
    obj.plot_rcio('tStart',tStart,...
                  'tStop',tStop,varargin{:})
end

end