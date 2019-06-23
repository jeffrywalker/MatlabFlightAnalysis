%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> @brief Store a string cell array with the unit names
%> \public
function [] = setUnitNames(obj, NamesCell)

% Validate input
if length(obj.fieldNameCell)~=length(NamesCell)
    error('Wrong input length');
end

for fieldIdx=1:length(NamesCell)
    fieldName = obj.sanitizeFieldName(obj.fieldNameCell{fieldIdx});
    obj.fieldUnits.(fieldName) = NamesCell{fieldIdx};
end
end