%> \param logIdx index of log
%> \param group log structure group
%> \param signal signal of interest
%
%> \return (ss) signal structure with *.signal, *.time
function varargout = getSignal(obj, logIdx, group, signal, varargin)
p = inputParser;
addOptional(p, 'asStruct', true)
addOptional(p, 'range',[])
addOptional(p, 'shiftToZero', false);
parse(p, varargin{:});
ui = p.Results;

if logIdx < 0
    logIdx = obj.getLogIdx( abs(logIdx) );
end

if ~obj.checkForSignal(logIdx, group, signal)
    error('%s.%s does not exist\n',group, signal)
end

ss.time     = obj.logs{logIdx}.log.(group).TimeS;
ss.(signal) = obj.logs{logIdx}.log.(group).(signal);

% sub select range
if ~isempty(ui.range)
    ss = structfun(@(x) x(ui.range(1):ui.range(2)), ss, 'UniformOutput', false);
end
ss.unit     = obj.logs{logIdx}.log.(group).fieldUnits.(signal);

% shift time to zero
if ui.shiftToZero
    ss.time = ss.time - ss.time(1);
end

if ui.asStruct
    varargout{1} = ss;
else
    varargout{1} = ss.(signal);
    varargout{2} = ss.time;
    varargout{3} = ss.unit;
end
end