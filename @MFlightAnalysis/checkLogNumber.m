%> @brief checks to see if a log with this number has been loaded
%> @param[out] logSlot position to store this data
%> \param[in] warn print warning if exists
%> \param[out] new [true] if new slot location
%> \private
function [logSlot, new] = checkLogNumber(obj, num, warn)
    if nargin < 3
        warn = true;
    end
    new = true;
    % check to see if this log is loaded
    if ~isempty(obj.logs)
        logSlot = find(cellfun(@(x) x.num == num, obj.logs) == 1, 1);
        if ~isempty(logSlot)
            new = false;
            if (warn)
                warning('off','backtrace')
                warning(['Log Number: %d has already been loaded.',...
                         ' It will be overwritten.'], num);
                warning('on','backtrace')
            end
        else
            % new location
            logSlot = numel(obj.logs) + 1;
        end
    else
        logSlot = 1;
    end
end