%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> @brief Prepend prefix if field name is numeric
%> \public
function [fieldName] = sanitizeFieldName(obj, inputName)
    if isstrprop(inputName(1),'digit') % Check if first label is a digit
        fieldName = strcat(obj.alphaPrefix,inputName); % Add a alphabetic character as prefix
    else
        fieldName = inputName;
    end
end