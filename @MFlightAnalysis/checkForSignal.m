%> \brief checks if the group/signal combination exist for the given log
%
%> \param logIndex selected log index
%> \param group
%> \param signal
%> \return (exist) true if signal exist
function exist = checkForSignal(obj, logIndex, group, signal)
exist = false;
if any(cellfun(@(x) strcmp(x, group), fieldnames(obj.logs{logIndex}.log)))
    % log group exist
    if any(cellfun(@(x) strcmp(x, signal), fieldnames(obj.logs{logIndex}.log.(group))))
        % signal exist
        exist = true;
    end
end

end