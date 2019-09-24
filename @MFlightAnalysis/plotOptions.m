%> \author Jeffry Walker
%> @brief general plot options avaialable in all plotting functions
%> \private
function opt = plotOptions(obj, varargin)
    p = inputParser;
    p.KeepUnmatched = true;
    %> \param logNum log numbers to plot, defaults to first loaded log
    addOptional(p, 'logNum', [])
    %> \param legend [false] display legend. defaults to true if numel(logNum) > 1
    addOptional(p, 'legend', [])
    %> \param legendStr defaults to log numbers
    addOptional(p, 'legendStr', {})
    %> \param tStart time to start plotting data (absolute recording time), default 0
    addOptional(p, 'tStart', [])
    %> \param tStop time to stop plotting data (absolute recording time), default inf
    addOptional(p, 'tStop', [])
    %> \param tShift amount to shift time axis
    addOptional(p, 'tShift', [])
    %> \param shiftToZero [true] plot axis shifted to start at zero
    addOptional(p, 'shiftToZero', true)
    %> \param lineSpec defaults to matlab spec, otherwise if cell array applied per log number
    addOptional(p, 'lineSpec', {})
    %> \param plotWindow ['byName']/'new'/'gcf' what window to plot in. byName plots in the window with this name
    addOptional(p, 'plotWindow', 'byName')
    %> \param clear [true] clear the axes before plotting
    addOptional(p, 'clear', true)
    %> \param linkX [true] link x-axis
    addOptional(p, 'linkX', true)
    %> \param grid [true]
    addOptional(p, 'grid', true)
    %> \param aeroLabel user aerospace nomenclature to label
    addOptional(p, 'aeroLabel', true);
    parse(p, varargin{:})
    opt = p.Results;
    % establish defaults in order to run
    if isempty(opt.logNum) && numel(obj.logs) >= 1
        opt.logNum = obj.logs{1}.num;
    elseif ~isnumeric(opt.logNum) && strcmp(opt.logNum,'all')
       opt.logNum = cellfun(@(x) x.num, obj.logs);
    end

    if numel(opt.logNum) > 1 && isempty(opt.legend)
        opt.legend = true;
    else
        opt.legend = false;
    end
    % default legend string
    if isempty(opt.legendStr)
        % set legend string to be log numbers
        opt.legendStr = arrayfun(@(x) sprintf('log-%d', x), opt.logNum, 'UniformOutput', false);
    end
    % default to no shift
    if isempty(opt.tShift)
        opt.tShift = zeros(size(opt.logNum));
    end
    % default to all time
    if isempty(opt.tStart)
        opt.tStart = zeros(size(opt.logNum));
    elseif numel(opt.tStart) ~= numel(opt.logNum)
        opt.tStart = repmat(opt.tStart, [1 numel(opt.logNum)]);
    end
    if isempty(opt.tStop)
        opt.tStop = inf(size(opt.logNum));
    elseif numel(opt.tStop) ~= numel(opt.logNum)
        opt.tStop = repmat(opt.tStop, [1 numel(opt.logNum)]);
    end

end