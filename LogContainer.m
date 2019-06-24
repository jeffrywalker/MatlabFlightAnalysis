%> \author Jeffry Walker
%> @brief type container for multiple logs
classdef LogContainer
    properties
        %> loaded log data
        log Ardupilog
        %> log number
        num
        %> date yyy-mm-dd
        date
    end
    methods
        function obj = LogContainer(logFilePath)
            obj.log  = Ardupilog(logFilePath);
            % extract info from file name
            [~, fn]  = fileparts(logFilePath);
            tmp      = regexp(fn,'_','split');
            obj.num  = str2double(tmp{2});
            tmpDate  = regexp(tmp{3},'-','split');
            obj.date = datestr(sprintf('%s-%s-%s',tmpDate{1:3}),'yyyy-mm-dd');
        end
    end
end