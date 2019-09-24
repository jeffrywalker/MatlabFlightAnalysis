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
            if ~contains(fn,'_')
                snum = fn;
            else
                tmp  = regexp(fn,'_','split');
                snum = tmp{2};
            end
            obj.num  = str2double(snum);
            % get date from bootTimeUTC
            obj.date = obj.log.bootTimeUTC;
        end
    end
end