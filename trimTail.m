%> @brief Remove any trailing space (zero-chars)
%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
function string = trimTail(string)
    % Test if string is all zeroes
    if ~any(string)
        string = [];
        return;
    end
    while string(end)==0
        string(end) = [];
    end
end