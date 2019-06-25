%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> @brief This returns an indexed portion (a "slice") of an Ardupilog.
%> Example:
%>    log_during_cruise = Log.getSlice([t_begin_cruise, t_end_cruise], 'TimeUS')
%>  will return a smaller Ardupilog, only containing log data between
%>  TimeUS values greater than t_begin_cruise and less than t_end_cruise.
%> \public
function slice = getSlice(obj, slice_values, slice_type)
    % Check if input argument order was accidentally reversed
    if isnumeric(slice_type) && ischar(slice_values)
        error('The correct call is getSlice([value1 value2], slice_type). (It looks like the argument order may have been reversed.)')
    end

    % Copy all the properties, zero the number of messages
    slice = copy(obj);
    slice.numMsgs = 0;

    % Loop through the LogMsgGroups, slicing each one
    logProps = properties(obj);
    for i = 1:length(logProps)
        propertyName = logProps{i}; % Get the name of the property under examination
        % We are interested only in LogMsgGroup objects, skip the rest of the properties
        if ~isa(obj.(propertyName),'LogMsgGroup')
            continue;
        end

        % Slice the LogMsgGroup
        lmg_slice = slice.(propertyName).getSlice(slice_values, slice_type);
        % If the slice is not empty, add it to the Ardupilog slice
        if isempty(lmg_slice)
            delete(slice.(propertyName))
        else
            slice.(propertyName) = lmg_slice;
            slice.numMsgs = slice.numMsgs + size(slice.(propertyName).LineNo, 1);
        end
    end
end