%> @brief attempts to load log, reports back error msg with filename
%> \private
function loadLog(obj, slot, logFile)
   try
       if ~contains(logFile, '.bin')
           logFile = [logFile, '.bin'];
       end
       obj.logs{slot} = LogContainer(fullfile(obj.logFolder, logFile));
       fprintf('Loaded Log: %d, Date: %s\n', obj.getLogNumber(logFile), ...
                                             obj.getLogDate(logFile));
   catch ME
       warning('off','backtrace')
       warning('Failed to load log file: %s\n',logFile);
       warning('on','backtrace')
       rethrow(ME)
   end
end