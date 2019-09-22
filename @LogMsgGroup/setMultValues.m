%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> @brief Store an array containing the field value multipliers
%> \public
function [] = setMultValues(obj, MultArray)

    % Validate input
    if length(obj.fieldNameCell)~=length(MultArray)
         warning('Wrong input length');
         MultArray = MultArray(1:length(obj.fieldNameCell));
    end

    for fieldIdx=1:length(MultArray)
        fieldName = obj.sanitizeFieldName(obj.fieldNameCell{fieldIdx});
        obj.fieldMultipliers.(fieldName) = MultArray(fieldIdx);
    end
end