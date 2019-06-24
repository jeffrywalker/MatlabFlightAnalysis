%> \author Jeffry Walker
%> @brief loads log files in the 'logFolder' by log number
%> @param[in] logNumbers array of integers corersponding to log numbers
%> \public
function loadLogByNumber(obj, logNumbers)
% get list of log files in the folder
lf = obj.getLogList();

% get the available log numbers 
ln = arrayfun(@(x) obj.getLogNumber(x.name), lf);

% ensure only unique log numbers exists
if (length(ln) ~= length(unique(ln)))
    error('all log numbers must be unique')
end

% loop through requested log number, load those that are found
for j=1:numel(logNumbers)
    slot = obj.checkLogNumber(logNumbers(j));
    idx  = find(ln == logNumbers(j));
    if isempty(idx)
        warning('Log Number: %d not found\n', logNumbers(j));
    else
        % load this log. assign in new slot or overwrite slot with this
        % number.
        obj.loadLog(slot, lf(idx).name)
    end
end

end

