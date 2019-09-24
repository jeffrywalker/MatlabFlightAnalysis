%> \author Jeffry Walker
%> \brief plots ch6 tuning value below att-rate plots
%> \private
function plot_tune(obj, varargin)

% common options
opt = obj.plotOptions(varargin{:});
% local options
p = inputParser;
p.KeepUnmatched = true;
addOptional(p, 'name', 'tune');
addOptional(p, 'incDes', true);
addOptional(p, 'legend', true);
addOptional(p, 'legendStr', {'resp','des'});
parse(p, varargin{:});
% merge the options
warning off
opt = catstruct(opt, p.Results);
warning on

% figure to plot in
fh = nf(opt.name);
% logs index to plot
li = obj.getLogIdx(opt.logNum);

% ensure tuning data is present
if any(arrayfun(@(x) length(obj.logs{x}.log.PTUN.TimeS) == 0, li))
    error('no tuning data present in requested log')
end

pidx  = [1 3 5;
         2 4 6]';
msg = {'RATE','ATT'};
param = {'R','P','Y';
         'Roll','Pitch','Yaw'}';
aerol = {'p', 'q', 'r';
         '$\phi$', '$\theta$', '$\psi$'}';
ax = [];
% n columns
for n=1:size(pidx,2)
    % m rows
    for m=1:size(pidx,1)
        % active axes
        ax = vertcat(ax,subplot(4,2,pidx(m,n)));
        obj.cleanup(opt.clear)

        % configure desired parameter name
        if n==1
            tmp = sprintf('%sDes',param{m,n});
        else
            tmp = sprintf('Des%s',param{m,n});
        end
        for k=1:numel(li)
            % temporary msg copy
            grp = obj.logs{li(k)}.log.(msg{n});
            % get time and data indices
            [t, didx] = obj.prepareToPlot(opt, grp.TimeS, k);
            % plot parameters
            if isempty(opt.lineSpec)
                plot(t, grp.(param{m,n})(didx))
            else
                plot(t, grp.(param{m,n})(didx), opt.lineSpec{k})
            end
            if opt.incDes
                hold on
                plot(t, grp.(tmp)(didx), '--')
            end
        end
        if opt.aeroLabel
            ylabel(aerol{m,n},'Interpreter','latex')
        else
            ylabel(sprintf('%s.%s',msg{n},param{m,n}))
        end
        if opt.grid, grid on, end
        if opt.legend
            legend(opt.legendStr)
        end

    end
    xlabel('t (s)')
end
% add tuning value
ax = vertcat(ax, subplot(4,2,[7 8]));
[t, didx] = obj.prepareToPlot(opt, obj.logs{li(k)}.log.PTUN.TimeS, k);
plot(t, obj.logs{li(k)}.log.PTUN.TunLo(didx) * 1e-3,'r--',...
     t, obj.logs{li(k)}.log.PTUN.TunHi(didx) * 1e-3,'r--',...
     t, obj.logs{li(k)}.log.PTUN.TunVal(didx),'b')
grid on

if opt.linkX
    linkaxes(ax,'x');
end
xlim auto
ylim auto

end