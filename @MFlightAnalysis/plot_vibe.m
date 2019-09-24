%> \author Jeffry Walker
%> \brief plots vibration data
%> \private
function plot_vibe(obj, varargin)
% common options
opt = obj.plotOptions(varargin{:});
% local options
p = inputParser;
p.KeepUnmatched = true;
addOptional(p, 'name', 'vibe');
parse(p, varargin{:});
% merge the options
opt = catstruct(opt, p.Results);

% figure to plot in
fh = nf(opt.name);
% logs index to plot
li = obj.getLogIdx(opt.logNum);
ax = [];
axName = {'X', 'Y', 'Z'};
for j=1:3
    ax(j) = subplot(3, 1, j);
    obj.cleanup(opt.clear)

    for k=1:numel(li)
        grp = obj.logs{li(k)}.log.VIBE;
        % start time range option
        [t, didx] = obj.prepareToPlot(opt, grp.TimeS, k);
        if isempty(opt.lineSpec)
            plot(t, grp.(sprintf('Vibe%s', axName{j}))(didx))
        else
            plot(t, grp.(sprintf('Vibe%s', axName{j}))(didx), opt.lineSpec{k})
        end
        hold on
    end
    if opt.grid, grid on, end
    ylabel(axName{j})
    % legend
    if opt.legend
        legend(opt.legendStr)
    end
    if j==1
        title('Vibration')
    end
end
if opt.linkX
    linkaxes(ax, 'x')
end
xlim auto
ylim auto
xlabel('t (s)')
end%fcn