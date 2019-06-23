%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> @brief Delete any logMsgGroups which are empty
%> Implemented by creating a new object and copying non-empty msgs
%> because once created, properties cannot be deleted
%> \public
function newlog = deleteEmptyMsgs(obj)

newlog = Ardupilog('~'); % Create a new emtpy log

propertyNames = properties(obj);
for i = 1:length(propertyNames)
    propertyName = propertyNames{i};
    if ~isa(obj.(propertyName),'LogMsgGroup') % Copy anything else except LogMsgGroups
        newlog.(propertyName) = obj.(propertyName);
    else % Check if the LogMsgGroup is emtpy
        if isempty(obj.(propertyName).LineNo) % Choosing a field which will always exist
            % Do nothing
        else
            addprop(newlog, propertyName);
            newlog.(propertyName) = obj.(propertyName);
        end
    end
end
end