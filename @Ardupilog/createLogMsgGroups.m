%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> \public
function [] = createLogMsgGroups(obj,data)
    for i=1:size(data,1)
        % Process FMT message to create a new dynamic property
        msgData = data(i,:);

        newType = double(msgData(1));
        newLen = double(msgData(2)); % Note: this is header+ID+dataLen = length(header)+1+dataLen.

        newName = char(trimTail(msgData(3:6)));
        newFmt = char(trimTail(msgData(7:22)));
        newLabels = char(trimTail(msgData(23:86)));

        % Instantiate LogMsgGroup class named newName, process FMT data
        new_msg_group = LogMsgGroup(newType, newName, newLen, newFmt, newLabels);
        if isempty(new_msg_group)
            warning('Msg group %d/%s could not be created', newType, newName);
        else
            obj.msgsContained{end+1} = newName;
            addprop(obj, newName);
            obj.(newName) = new_msg_group;
        end

        % Add to obj.fmt_cell and obj.fmt_type_mat (for increased speed)
        obj.fmt_cell = [obj.fmt_cell; {newType, newName, newLen}];
        obj.fmt_type_mat = [obj.fmt_type_mat; newType];

    end
    % msgName needs to be FMT
    fmt_ndx = find(obj.fmt_type_mat == 128);
    FMTName = obj.fmt_cell{fmt_ndx, 2};
    % Store msgData correctly in that LogMsgGroup
    obj.(FMTName).storeData(data);
end