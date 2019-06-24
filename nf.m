%> \author Jeffry Walker
%> @brief get figure handle to new figure window (or one with this name)
function fh = nf(name)
    fh = findobj('Name', name);
    if isempty(fh)
        fh = figure('Name', name);
    else
        figure(fh);
    end
end