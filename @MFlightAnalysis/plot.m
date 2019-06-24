%> \author Jeffry Walker
%> @brief high level plotting function, invokes lower level plotting
%> @param[in] plots plot type name or cell of types, '?' returns possible plot types
%> \public
function plot(obj, plots, varargin)
    if nargin == 0
        error('plot types must be specified')
    end
    if ~iscell(plots)
        % list plotting options
        if strcmp(plots, '?')
            mc = metaclass(obj);
            mlist = arrayfun(@(x) x.Name, mc.MethodList, 'UniformOutput', false);
            mlist(~contains(mlist,'plot_')) = [];
            mlist = cellfun(@(x) strrep(x,'plot_',''), mlist, 'UniformOutput', false);
            fprintf('Plotting Types:\n');
            fprintf('%s\n',mlist{:});
            return
        else
            plots = {plots};
        end
    end
    for j=1:numel(plots)
        try
            if nargout == 1
                varargout{1} = feval(['plot_' lower(plots{j})], obj, varargin{:});
            else
                feval(['plot_' lower(plots{j})], obj, varargin{:});
            end
        catch ME
            rethrow(ME)
        end
    end
end