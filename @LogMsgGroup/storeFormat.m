%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> \public
function [] = storeFormat(obj, type_num, type_name, data_length, format_string,...
                         field_names_string)
    if isempty(field_names_string)
        obj.fieldNameCell = {};
    else
        obj.fieldNameCell = strsplit(field_names_string,',');
    end

    % Verify that format and labels agree
    if length(format_string)~=length(obj.fieldNameCell)
        warning('incompatible data on msg type=%d/%s', type_num, type_name);
        obj = []; % Clear the instance and return %TODO this is kind of messy
        return
    end

    % For each of the fields
    for ndx = 1:length(obj.fieldNameCell)
        fieldNameStr = obj.sanitizeFieldName(obj.fieldNameCell{ndx});
        % Create a dynamic property with field name, and add to fieldInfo array
        if isempty(obj.fieldInfo)
            obj.fieldInfo = addprop(obj, fieldNameStr);
        else
            obj.fieldInfo(end+1) = addprop(obj, fieldNameStr);
        end

        % Put field format char (e.g. Q, c, b, h, etc.) into 'Description' field
        obj.fieldInfo(end).Description = format_string(ndx);
    end

    % Save FMT data into private properties (Not actually used anywhere?)
    obj.typeNumID = type_num;
    obj.name = type_name;
    obj.data_len = data_length;
    obj.format = format_string;

    % Assert that the provided message length and format agree
    obj.verifyTypeLengths();
end