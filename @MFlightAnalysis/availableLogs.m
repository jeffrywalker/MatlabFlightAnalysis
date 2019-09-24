%> \author Jeffry Walker
%> @brief lists available logs found in log folder, sorted by log number
%> \public
function varargout = availableLogs(obj)
tmp            = arrayfun(@(x) x.name, obj.getLogList(), 'UniformOutput', false);
logNum         = obj.getLogNumber(tmp);
logDate        = obj.getLogDate(tmp);
[logNum, sidx] = sort(logNum);
logDate        = logDate(sidx);
if nargout == 1
    varargout{1} = sort(logNum);
    return
end
for j=1:numel(logNum)
    fprintf('Log: %03d\tDate: %s\n', logNum(j),...
                                   logDate{j});
end
end