%> \brief returns log indices for the requested log numbers for plotting
%> \private
function li = getLogIdx(obj, ln)
    li     = ones(size(ln));
    invalid = false(size(ln));
    for j=1:numel(ln)
        [li(j), invalid(j)] = obj.checkLogNumber(ln(j), false);
    end
    % provide warning to user
    warning('off', 'backtrace')
    if any(invalid)
        warning('invalid log numbers:')
        warning('%d\n', ln(invalid == true))
        warning('on', 'backtrace')
    end
    % remove invalid entries
    li(invalid) = [];
end