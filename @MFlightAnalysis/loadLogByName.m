%> \author Jeffry Walker
%> @brief loads log file by name
%> \public
function loadLogByName(obj, logName)
    lfList = obj.getLogList();
    if ~any(arrayfun(@(x) strcmp(x.name(1:end-4), logName), lfList))
        error('%s not found in %s\n', logName, obj.logFolder);
    else
        slot = obj.checkLogNumber(obj.getLogNumber(logName));
        obj.loadLog(slot, logName)
    end
end