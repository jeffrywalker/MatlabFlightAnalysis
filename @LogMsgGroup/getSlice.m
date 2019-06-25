%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> @brief This returns an indexed portion (a "slice") of a LogMsgGroup
%> Example:
%>    cruise_gps_msgs = GPS.getSlice([t_begin_cruise, t_end_cruise], 'TimeUS')
%>  will return a smaller LogMsgGroup than GPS, only containing data
%>  between TimeUS values greater than t_begin_cruise and less than
%>  t_end_cruise.
%> \public
function [slice, remainder] = getSlice(obj, slice_values, slice_type)

    if isprop(obj, slice_type)
        % Find indices corresponding to slice_values, from slice_type
        switch slice_type
          case 'LineNo'
            start_ndx = find(obj.LineNo >= slice_values(1),1,'first');
            end_ndx = find(obj.LineNo <= slice_values(2),1,'last');
          case 'TimeS'
            start_ndx = find(obj.TimeS >= slice_values(1),1,'first');
            end_ndx = find(obj.TimeS <= slice_values(2),1,'last');
          otherwise
            error(['Unsupported slice type: ', slice_type]);
        end
        slice_ndx = [start_ndx:1:end_ndx];
    else
        slice_ndx = [];
    end

    % If the slice is not valid, return an empty LogMsgGroup
    % HGM TODO: We need to improve this validity-checking. For instance, what if the slice_ndx is negative? That's not valid
    if isempty(slice_ndx)
        slice = LogMsgGroup.empty();
        return
    end
    % End HGM TODO

    % Create the slice as a new LogMsgGroup
    field_names_string = strjoin(obj.fieldNameCell,',');
    slice = LogMsgGroup(obj.typeNumID, obj.name, obj.data_len, obj.format, field_names_string);
    % For each data field, copy the slice of data, identified by slice_ndx
    for field_name = slice.fieldNameCell
        % HGM: The following is valid for 1-dim and 2-dim fields.
        % - Should we extend to n-dim fields?
        % - If yes, is there a standard way to do this?
        % -- one approach: Could build string_statement from ndims() and repeating ',:' ndims()-1 times, then calling with eval(string_statement)
        % -- MATLAB, or the community, might already have this solved
        slice.(field_name{1}) = obj.(field_name{1})(slice_ndx,:);
    end
    % Copy also the LineNo slice and set the bootDatenum
    slice.setLineNo(obj.LineNo(slice_ndx));
    slice.setBootDatenumUTC(obj.bootDatenumUTC);
end