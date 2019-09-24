%> \author Jeffry Walker
%> \brief plots velocity and position in NED
%> \private
function plot_velpos(obj, varargin)
% common options
opt = obj.plotOptions(varargin{:});
% local options
p = inputParser;
p.KeepUnmatched = true;
addOptional(p, 'name', 'vel-pos');
%> \param wind [false] includes plotting of wind velocity
addOptional(p, 'wind', false);
addOptional(p, 'legend', true);
parse(p, varargin{:});
% merge the options
warning off
opt = catstruct(opt, p.Results);
warning on

% figure to plot in
fh = nf(opt.name);
% logs index to plot
li = obj.getLogIdx(opt.logNum);

pidx  = [1 3 5;
         2 4 6]';
param = {'VN','VE','VD';
         'PN','PE','PD'}';

ax = [];
% n columns
for n=1:size(pidx,2)
    % m rows
    for m=1:size(pidx,1)
        isWind = false;
        % active axes
        ax = vertcat(ax,subplot(3,2,pidx(m,n)));
        obj.cleanup(opt.clear)

        for k=1:numel(li)
            % temporary msg copy
            grp = obj.logs{li(k)}.log.NKF1;
            % get time and data indices
            [t, didx] = obj.prepareToPlot(opt, grp.TimeS, k);
            % plot parameters
            if isempty(opt.lineSpec)
                plot(t, grp.(param{m,n})(didx))
            else
                plot(t, grp.(param{m,n})(didx), opt.lineSpec{k})
            end
            if opt.wind && ( strcmp(param{m,n}, 'VN') || strcmp(param{m,n}, 'VE') )
                grp = obj.logs{li(k)}.log.NKF2;
                % get time and data indices
                [t, didx] = obj.prepareToPlot(opt, grp.TimeS, k);
                hold on
                plot(t, grp.( sprintf('VW%s', param{m,n}(end)) )(didx), '--')
                isWind = true;
            end
        end
        ylabel(sprintf('%s.%s','NKF1',param{m,n}))

        if opt.grid, grid on, end
        if opt.legend && numel(li) > 1
            legend(opt.legendStr)
        elseif opt.legend && numel(li) == 1 && opt.wind && isWind
            % legend entry for wind
            legend('av','wind')
        end

    end
    xlabel('t (s)')
end
if opt.linkX
    linkaxes(ax,'x');
end
xlim auto
ylim auto
end