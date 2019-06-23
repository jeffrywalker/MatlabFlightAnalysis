%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> \public
function [] = verifyTypeLengths(obj)
    % First, assert that the length(obj.format) == numel(obj.fieldNameCell)
    if length(obj.format) > numel(obj.fieldNameCell)
        warning([obj.name, ' format string ', obj.format,...
                 ' has more (char) elements than defined fields. ',...
                 'Only using the first ', num2str(numel(obj.fieldNameCell)),...
                 ': ', obj.format(1:numel(obj.fieldNameCell))]);
    end
    if length(obj.format) < numel(obj.fieldNameCell)
        error([obj.name, ' format string: ', obj.format, ' with length ',...
               num2str(length(obj.format)), ' does not provide (char)',...
               ' formats for all ', num2str(numel(obj.fieldNameCell)),...
               ' field names (in fieldNameCell)'])
    end

    % Next, verify that the FMT-specified message length agrees with
    % the sum of the lengths of each (char) format type. (e.g. for 'bbQQ'
    % since 'b'=int8=1byte, 'Q'=uint64=8bytes, the correct length would be
    % 1+1+8+8=18)
    length_sum = 0;
    for varType = obj.format
        length_sum = length_sum + formatLength(varType);
    end
    if (length_sum+3 ~= obj.data_len)
        warning(sprintf('Incompatible declared message type length (%d) and format length (%d) in msg %d/%s',obj.data_len, length_sum+3, obj.typeNumID, obj.name));
    end
end