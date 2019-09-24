function plot_rcio(obj, varargin)
% common options
opt = obj.plotOptions(varargin{:});
% local options
p = inputParser;
p.KeepUnmatched = true;
addOptional(p, 'name', 'rcio');
parse(p, varargin{:});
% merge the options
warning off
opt = catstruct(opt, p.Results);
warning on

% figure to plot in
fh = nf(opt.name);
% logs index to plot
li = obj.getLogIdx(opt.logNum);

inp = obj.getMultiSignals({'RCIN',{'*'}}, 'logNum', opt.logNum);
out = obj.getMultiSignals({'RCOU',{'*'}}, 'logNum', opt.logNum);
% get time subset
iStart = find(inp.time <= opt.tStart,1, 'last');
if isfinite(opt.tStop)
    iStop  = find(inp.time >= opt.tStop,1, 'first');
else
    iStop = numel(inp.time);
end
inp = structfun(@(x) x(iStart:iStop), inp, 'UniformOutput', false);
out = structfun(@(x) x(iStart:iStop), out, 'UniformOutput', false);
% time shift
if opt.shiftToZero
    inp.time = inp.time - inp.time(1);
    out.time = out.time - out.time(1);
end

sn = {'C1','C2','C3','C4'};
dn = {'ail','elv','col','rud'};
nrow = 4;
ncol = 2;
nplt = nrow * ncol;
bidx = (nplt - (ncol-1)):nplt;
ax = [];
% inp
pmap = [1 3 5 7];
for j=1:numel(sn)
    ax(pmap(j)) = subplot(nrow, ncol, pmap(j));
    obj.cleanup(opt.clear)
    plot(inp.time, inp.(sn{j}))
    grid on
    title(sprintf('%s:inp',dn{j}))
    if j==4
        xlabel('Time (s)')
    end
end
% out
pmap = [2 4 6 8];
for j=1:numel(sn)
    ax(pmap(j)) = subplot(nrow, ncol, pmap(j));
    obj.cleanup(opt.clear)
    plot(out.time, out.(sn{j}))
    grid on
    title(sprintf('%s:out',dn{j}))
    if j==4
        xlabel('Time (s)')
    end
end
linkaxes(ax,'x')
set(ax(1), 'XLimSpec','tight')
end