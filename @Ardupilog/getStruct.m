%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> @brief Create a simple struct containing the information of the log
%> without needing to include the Ardupilog class
%> \public
function dump = getStruct(obj, varargin)
%
% By default, this runs silently. To display warning
% messages, call using str=log.getStruct('verbose')
    if nargin > 1 && strcmp(varargin{1}, 'verbose')
            verbose=1;
    else
        verbose=0;
    end

    dump = struct();
    props = properties(obj)';
    % Copy all properties which are not LogMsgGroups
    for i = 1:length(props)
        propName = props{i};
        if ~isa(obj.(propName),'LogMsgGroup') % This is not a LogMsgGroup
            dump.(propName) = obj.(propName);
        elseif ~isvalid(obj.(propName))
            % This is a handle to a deleted LogMsgGroup.
            % Ignore it and do nothing.
            if verbose > 0
                disp(['Removing empty LogMsgGroup from struct: ', propName]);
            end
        else
            % This is a LogMsgGroup
            subProps = properties(obj.(propName));
            for j = 1:length(subProps)
                subPropName = subProps{j};
                dump.(propName).(subPropName) = obj.(propName).(subPropName);
            end
        end
    end
end