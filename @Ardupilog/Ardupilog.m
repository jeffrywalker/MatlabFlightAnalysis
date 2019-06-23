%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> @file Ardupilog.m
%> @details matlab class for loading ArduPilot dataflash logs. Forked from: https://github.com/Georacer/ardupilog
%
classdef Ardupilog < dynamicprops & matlab.mixin.Copyable
    properties (Access = public)
        %> name of .bin file
        fileName            
        %> path to .bin file
        filePathName        
        %> ArduPlane, ArduCopter etc
        platform            
        %> Firmware version
        version             
        %> Specific git commit
        commit              
        %> String displaying time of boot in UTC
        bootTimeUTC         
        %> A cell array with all the message names contained in the log
        msgsContained = {}; 
        %> Total number of messages of the original log
        totalLogMsgs = 0;   
        %> Storage for the msgIds/msgNames desired for parsing
        msgFilter = [];     
        %> Number of messages included in this log
        numMsgs = 0;        
    end
    properties (Access = private)
        fileID = -1;
        %> Message header as defined in ArduPilot
        header = [163 149]; 
        %> The .bin file data as a row-matrix of chars (uint8's)
        log_data = char(0); 
        %> a local copy of the FMT info, to reduce run-time
        fmt_cell = cell(0); 
        %> equivalent to cell2mat(obj.fmt_cell(:,1)), to reduce run-time
        fmt_type_mat = [];  
        FMTID = 128;
        FMTLen = 89;
        %> A cell array for reconstructing LineNo (line-number) for all entries
        valid_msgheader_cell = cell(0); 
        %> The MATLAB datenum (days since Jan 00, 0000) at APM microcontroller boot (TimeUS = 0)
        bootDatenumUTC = NaN; 

    end %properties
    
    methods
        %> @brief ARDUPILOG Ardupilot log to MATLAB converter
        %> Reads an Ardupilot .bin log and produces structure with custom containers.
        %> Message types are separated, values are timestamped.
        function obj = Ardupilog(varargin)
            % Setup argument parser
            p = inputParser;
            addOptional(p,'path',[],@(x) isstr(x)||isempty(x) );
            addOptional(p,'msgFilter',[],@(x) isnumeric(x)||iscellstr(x) );
            parse(p,varargin{:});

            % Decide on initialization method
            if strcmp(p.Results.path,'~') % We just want to create a bare Ardupilog object
                return;
            end
            
            if isempty(p.Results.path)
                % If constructor is empty, prompt user for log file
                [filename, filepathname, ~] = uigetfile('*.bin','Select binary (.bin) log-file');
            else
                % Use user-specified log file
                % Try to parse an absolute path
                [filepathname, filenameBare, extension] = fileparts(p.Results.path);
                if isempty(filepathname) % File not found
                    % Look for a relative path
                    [filepathname, filenameBare, extension] = fileparts(fullfile(pwd, p.Results.path));
                end
                filename = [filenameBare extension];
            end
            obj.fileName = filename;
            obj.filePathName = filepathname;

            obj.msgFilter = p.Results.msgFilter; % Store the message filter

            % If user pressed "cancel" then return without trying to process
            if all(obj.fileName == 0) && all(obj.filePathName == 0)
                return
            end
            
            % THE MAIN CALL: Begin reading specified log file
            readLog(obj);
            
            % Extract firmware version from MSG fields
            obj.findInfo();
            
            % Attempt to find the UTC time of boot (at boot, TimeUS = 0)
            obj.findBootTimeUTC();
            
            % Set the bootDatenumUTC for all LogMsgGroups
            % HGM: This can probably be done better after some code reorganization,
            %  but for now it works well enough. After refactoring is settled, we
            %  might set the bootDatenumUTC when we set the LineNo, or when we store
            %  the TimeUS data, whatever makes sense based on how we decide to handle
            %  message filtering.
            if ~isnan(obj.bootDatenumUTC)
                for prop = properties(obj)'
                    if isa(obj.(prop{1}), 'LogMsgGroup')
                        obj.(prop{1}).setBootDatenumUTC(obj.bootDatenumUTC);
                    end
                end
            end
            
            % Clear out the (temporary) properties
            obj.log_data = char(0);
            obj.fmt_cell = cell(0);
            obj.fmt_type_mat = [];
            obj.valid_msgheader_cell = cell(0);
        end

        function delete(obj)
            % Probably won't ever be open, but close the file just in case
            if ~isempty(fopen('all')) && any(fopen('all')==obj.fileID)
                fclose(obj.fileID);
            end
        end
        
        %> @brief Find all candidate headers within the log data
        %> Not all Indices may correspond to actual messages.
        function headerIndices = discoverHeaders(obj,msgId)
            
            if nargin<2
                msgId = [];
            end
            headerIndices = strfind(obj.log_data, [obj.header msgId]);
        end
        
    end%methods (public)
    
    methods(Access=protected)
        
        function newObj = copyElement(obj)
        % Copy function - replacement for matlab.mixin.Copyable.copy() to create object copies
        % Found from somewhere in the internet
            try
                % R2010b or newer - directly in memory (faster)
                objByteArray = getByteStreamFromArray(obj);
                newObj = getArrayFromByteStream(objByteArray);
            catch
                % R2010a or earlier - serialize via temp file (slower)
                fname = [tempname '.mat'];
                save(fname, 'obj');
                newObj = load(fname);
                newObj = newObj.obj;
                delete(fname);
            end
        end
        
    end %methods
end %classdef Ardupilog
