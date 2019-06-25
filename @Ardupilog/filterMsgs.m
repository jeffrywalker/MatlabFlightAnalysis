%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> @brief Filter message groups in existing Ardupilog
%> \public
function newlog = filterMsgs(obj,msgFilter)

% Get the logMsgGroups names and ids
msgNames = obj.msgsContained;
msgIds = zeros(1,length(msgNames));
for i=1:length(msgNames)
    msgName = msgNames{i};
    msgIds(i) = obj.(msgName).typeNumID;
end

% Check for validity of the input msgFilter
if ~isempty(msgFilter)
    if iscellstr(msgFilter) %obj.msgFilter is a cell-array of strings
        invalid = find(ismember(msgFilter,msgNames)==0);
        for i=1:length(invalid)
            warning('Invalid element in provided message filter: %s',msgFilter{invalid(i)});
        end
    else %msgFilter is an array of msgId's
        invalid = find(ismember(msgFilter,msgIds)==0);
        for i=1:length(invalid)
            warning('Invalid element in provided message filter: %d',msgFilter(invalid(i)));
        end
    end
end

newlog = copy(obj); % Create the new log object
newlog.msgFilter = msgFilter;
deletedMsgNames = cell(1,length(msgFilter));
% Set the LineNos of any messages due for deletion to empty
for i = 1:length(msgNames)
    msgName = msgNames{i};
    msgId = newlog.(msgName).typeNumID;
    if iscellstr(newlog.msgFilter)
        if ~ismember(msgName,newlog.msgFilter)
            newlog.(msgName).LineNo = []; % Mark the message group for deletion
            deletedMsgNames{i} = msgName;
        end
    elseif isnumeric(newlog.msgFilter)
        if ~ismember(msgId,newlog.msgFilter)
            newlog.(msgName).LineNo = []; % Mark the message group for deletion
            deletedMsgNames{i} = msgName;
        end
    else
        error('msgFilter type should have passed validation by now and I shouldnt be here');
    end
end

% Update the msgsContained attribute
newlog.msgsContained = setdiff(obj.msgsContained, deletedMsgNames);

newlog = newlog.deleteEmptyMsgs();

% Update the number of actual included messages
newlog.numMsgs = 0;
newMsgNames = newlog.msgsContained;
for i = 1:length(newMsgNames)
    msgName = newMsgNames{i};
    newlog.numMsgs = newlog.numMsgs + length(newlog.(msgName).LineNo);
end

end%fcn