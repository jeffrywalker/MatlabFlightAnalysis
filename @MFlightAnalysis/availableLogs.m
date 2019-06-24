%> \author Jeffry Walker
%> @brief lists available logs found in log folder, sorted by log number
%> \public
function availableLogs(obj)
tmp            = arrayfun(@(x) x.name, obj.getLogList(), 'UniformOutput', false);
logNum         = obj.getLogNumber(tmp);
logDate        = obj.getLogDate(tmp);
[logNum, sidx] = sort(logNum);
logDate        = logDate(sidx);
for j=1:numel(logNum)
    fprintf('Log: %d\tDate: %s\n', logNum(j),...
                                   logDate{j});
end
end