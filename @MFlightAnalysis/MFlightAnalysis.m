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
                tmp    = regexp(logName{j},'_','split');
                num(j) = str2double(tmp{2});
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
                tmp     = regexp(logName{j},'_','split');
                tmpDate = regexp(tmp{3},'-','split');
                date{j} = datestr(sprintf('%s-%s-%s',tmpDate{1:3}),'yyyy-mm-dd');
            end
            if length(date) == 1
                date = date{1};
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
            end
        end
    end
    methods(Access=private)
        %> @brief returns array of log files in logFolder
        %> \private
        function lfArray = getLogList(obj)
            lfArray = dir(fullfile(obj.logFolder,'*.bin'));
        end
        [logSlot, new] = checkLogNumber(obj, num, warn);
        li = getLogIdx(obj, ln);

        loadLog(obj, slot, logFile);

        % plotting
        opt = plotOptions(obj, varargin);
        plot_vibe(obj, varargin);
        plot_attrate(obj, varargin);
        plot_tune(obj, varargin);

        %> \todo implement
        %> \private
        function plot_rates(obj, varargin)
        end
        %> \todo implement
        %> \private
        function plot_states(obj, varargin)
        end
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