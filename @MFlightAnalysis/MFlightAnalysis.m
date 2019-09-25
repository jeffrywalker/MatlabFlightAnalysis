%> @author Jeffry Walker
%> @brief provides analysis tools for plotting ArduPilot dataflash logs
classdef MFlightAnalysis < handle
    properties
        %> folder where log files are stored
        logFolder
        %> container of loaded log data
        logs@cell = {};
    end

    methods
        %> @brief class constructor, handles setting initial default options
        %> \param logFolder directory where log files are stored
        function obj = MFlightAnalysis(logFolder)
            if nargin == 0
                logFolder = uigetdir(pwd);
            end
            obj.logFolder = logFolder;
        end

        %> @brief removes the specified logs
        %> \todo implement removal by log number
        %> \todo impelemtn removal by log date
        %> \public
        function removeLog(obj, varargin)
        end
        
        % externally defined
        [sweepIndices, sweepTimes] = getSweepIndices(obj, varargin);
        varargout = getSignal(obj, logIdx, group, signal, varargin);
        exist = checkForSignal(obj, logIndex, group, signal);
        varargout = getMultiSignals(obj, logIdx, smap, varargin);
        od = getSweepEvents(obj, varargin);
        
        %> \brief single parameter plotting in active window
        function plotSignal(obj, logNum, grp, sig)
           li  = obj.getLogIdx(logNum);
           tmp = obj.getSignal( li, grp, sig);
           plot(tmp.time, tmp.(sig))
        end
        %
        function varargout = loadedLogs(obj)
            if nargout == 1
                varargout{1} = cellfun(@(x) x.num, obj.logs);
            else
                cellfun(@(x) fprintf('Log: %d\n',x.num), obj.logs);
            end
        end
        function fltID = getFlightID(obj, varargin)
            p = inputParser;
            addOptional(p, 'logNum', [])
            addOptional(p, 'logidx', [])
            parse(p, varargin{:})
            ui = p.Results;
            if ~isempty(ui.logNum)
                li = obj.getLogIdx(ui.logNum);
            else
                li = ui.logIdx;
            end
            fltID = datestr(obj.logs{li}.log.bootTimeUTC,'YYYYmmDDHHMMSS');
        end
        li = getLogIdx(obj, ln);
    end

    methods(Static)
        %> @brief helper function to extract the log number
        %> @param[out] num numeric integer of log number
        %> @param[in] logName log file name string
        function num = getLogNumber(logName)
            if ~iscell(logName)
                logName = {logName};
            end
            num = zeros(numel(logName),1);
            for j=1:numel(logName)
                [~,name] = fileparts(logName{j});
                if contains(name,'_')
                    tmp    = regexp(name,'_','split');
                    snum   = tmp{2};
                else
                    snum = name;
                end
                num(j) = str2double(snum);
            end
        end

        %> @brief helper function to extract the log date
        %> @param[out] num string of log date yyyy-mm-dd
        %> @param[in] logName log file name string
        function date = getLogDate(logName)
            if ~iscell(logName)
                logName = {logName};
            end
            date = cell(numel(logName),1);
            for j=1:numel(logName)
                if contains(logName{j},'_')
                    tmp     = regexp(logName{j},'_','split');
                    tmpDate = regexp(tmp{3},'-','split');
                    date{j} = datestr(sprintf('%s-%s-%s',tmpDate{1:3}),'yyyy-mm-dd');
                else
                    date{j} = 'UNK';
                end
            end
        end
    end
    
    methods(Access=private, Static)
        %> \brief get generic plotting information
        %> \param opt plot options
        %> \param[in] t data time vector
        %> \param iter iterator value for plot requests with multiple logs
        %> \param[out] t time vector for plotting
        %> \param[out] didx data index, i.e. t[out] = t[in](didx)
        function [t, didx] = prepareToPlot(opt, t, iter)
            didx = intersect(find(t >= opt.tStart(iter)), find( t <= opt.tStop(iter)));
            t = t(didx);
            % shift to zero
            if opt.shiftToZero
                t = t - t(1);
            end
        end
        %> \brief cleans up axes and legends
        %> \param clear true/false whether to cleanup or not
        function cleanup(clear)
            if clear
                cla
                delete(findobj(gcf,'Type','Legend','Axes',gca));
                set(gca,'XLimMode','auto')
                set(gca,'YLimMode','auto')
            end
        end
    end
    methods(Access=private)
        %> @brief returns array of log files in logFolder
        %> \private
        function lfArray = getLogList(obj)
            lfArray = dir(fullfile(obj.logFolder,'*.bin'));
            lfArray = vertcat(lfArray, dir(fullfile(obj.logFolder,'*.BIN')));
        end
        [logSlot, new] = checkLogNumber(obj, num, warn);
        

        loadLog(obj, slot, logFile);

        % plotting
        opt = plotOptions(obj, varargin);
        plot_vibe(obj, varargin);
        plot_attrate(obj, varargin);
        plot_tune(obj, varargin);
        plot_velpos(obj, varargin);
        plot_blswpresp(obj, varargin);
        plot_rcio(obj, varargin);
    end
    %% Hide Handle Stuff
    methods(Hidden)
        function addlistener(obj, property, eventname, callback)
            addlistener@addlistener(obj, property, eventname, callback)
        end
        function findobj(obj,varargin)
            findobj@findobj(obj,varargin{:})
        end
        function notify(obj, eventname, data)
            notify@notify(obj, eventname, data)
        end
    end
end%class