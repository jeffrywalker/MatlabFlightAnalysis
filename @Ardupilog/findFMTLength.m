%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> \public
function [] = findFMTLength(obj,allHeaderCandidates)
    for index = allHeaderCandidates
    % Try to find the length of the format message
        msgId = obj.log_data(index+2); % Get the next expected msgId
        if obj.log_data(index+3)==obj.FMTID % Check if this is the definition of the FMT message
            if msgId == obj.FMTID % Check if it matches the FMT message
                obj.FMTLen = double(obj.log_data(index+4));
                return; % Return as soon as the FMT length is found
            end
        end
    end
    warning(['Could not find the FMT message to extract its length.\n',...
             'Leaving the default %d'],obj.FMTLen);
    return;
end