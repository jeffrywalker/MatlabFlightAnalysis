%> \author Jeffry Walker
%> @brief loads log by specified date
%> @param[in] date input possible formats 'yyyy-mm-dd', 'mm-dd', 'dd',
%>  (or) a cell array of the previous options {'yyyy-mm-dd','yyyy-mm-dd'}
%>  (or) simply 'today', 'yesterday'
%>  (or) array of numeric days for this month
%> \public
function loadLogByDate(obj, date)

% handle array of days
if isnumeric(date)
    date = arrayfun(@(x) num2str(x), date, 'UniformOutput', false);
end

% handle non-cell date input
if ~iscell(date)
    if strcmp(date, 'today') || strcmp(date, 'yesterday')
        date = {datestr(datetime(date), 'yyyy-mm-dd')};
    else
        date = {date};
    end
end

% ensure all dates have proper format and can be converted
today  = datestr(datetime('today'), 'yyyy-mm-dd');
tParts = regexp(today, '-', 'split');
for j=1:numel(date)
    parts = regexp(date{j}, '-', 'split');
    if numel(parts) == 1
        date{j} = datestr(sprintf('%s-%s', tParts{2}, parts{1}), 'yyyy-mm-dd');
    elseif numel(parts) == 2
        date{j} = datestr(sprintf('%s-%s', parts{1:2}), 'yyyy-mm-dd');
    elseif numel(parts) == 3
        date{j} = datestr(sprintf('%s-%s-%s', parts{1:3}), 'yyyy-mm-dd');
    else
        error('invalid format: %s\n', date{j})
    end
end

% loop over all dates now that we know they are in a valid format
lf = arrayfun(@(x) x.name, obj.getLogList(), 'UniformOutput', false);
% available dates
lfDates = obj.getLogDate(lf); 
% get indices that match the request
matches = cellfun(@(x) find(strcmp(x, lfDates) == 1), date, 'UniformOutput', false);
% remove null entries
matches(cellfun(@isempty, matches)) = [];
if isempty(matches)
    error('no files found to load')
end
% concatenate all into a list
filesToLoad = {};
for j=1:numel(matches)
    filesToLoad = vertcat(filesToLoad, lf(matches{j}));
end
% load all
for j=1:numel(filesToLoad)
    slot = obj.checkLogNumber(obj.getLogNumber(filesToLoad{j}));
    obj.loadLog(slot, filesToLoad{j})
end
end