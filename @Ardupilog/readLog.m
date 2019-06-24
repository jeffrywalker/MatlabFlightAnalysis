%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> @brief Open file, read all data, close file,
%> Find message headers, find FMT messages, create LogMsgGroup for each FMT msg,
%> Count number of headers = number of messages, process data
%> \public
function [] = readLog(obj)

    % Open a file at [filePathName filesep fileName]
    [obj.fileID, errmsg] = fopen([obj.filePathName, filesep, obj.fileName], 'r');
    if ~isempty(errmsg) || obj.fileID==-1
        error(errmsg);
    end

    % Define the read-size (inf=read whole file) and read the logfile
    readsize = inf; % Block size to read before performing a count
    obj.log_data = fread(obj.fileID, [1, readsize], '*uchar'); % Read the datafile entirely

    % Close the file
    if fclose(obj.fileID) == 0
        obj.fileID = -1;
    else
        warn('File not closed successfully')
    end
    
    % Discover the locations of all the messages
    allHeaderCandidates = obj.discoverHeaders([]);
    
    % Find the FMT message legnth
    obj.findFMTLength(allHeaderCandidates);
    
    % Read the FMT messages
    data = obj.isolateMsgData(obj.FMTID,obj.FMTLen,allHeaderCandidates);
    obj.createLogMsgGroups(data');
    
    % Check for validity of the input msgFilter
    if ~isempty(obj.msgFilter)
        if iscellstr(obj.msgFilter) %obj.msgFilter is a cell-array of strings
            invalid = find(ismember(obj.msgFilter,obj.fmt_cell(:,2))==0);
            for i=1:length(invalid)
                warning('Invalid element in provided message filter: %s',obj.msgFilter{invalid(i)});
            end
        else %msgFilter is an array of msgId's
            invalid = find(ismember(obj.msgFilter,cell2mat(obj.fmt_cell(:,1)))==0);
            for i=1:length(invalid)
                warning('Invalid element in provided message filter: %d',obj.msgFilter(invalid(i)));
            end                    
        end
    end
    
    % Iterate over all the discovered msgs
    for i=1:length(obj.fmt_cell)
        msgId = obj.fmt_cell{i,1};
        msgName = obj.fmt_cell{i,2};
        if msgId==obj.FMTID % Skip re-searching for FMT messages
            continue;
        end

        msgLen = obj.fmt_cell{i,3};
        data = obj.isolateMsgData(msgId,msgLen,allHeaderCandidates);

        % Check against the message filters
        if ~isempty(obj.msgFilter) 
            if iscellstr(obj.msgFilter)
                if ~ismember(msgName,obj.msgFilter)
                    continue;
                end
            elseif isnumeric(obj.msgFilter)
                if ~ismember(msgId,obj.msgFilter)
                    continue;
                end
            else
                error('Unexpected comparison result');
            end
        end
        
        % If message not filtered, store it
        obj.(msgName).storeData(data');
    end
    
    % If available, parse unit formatting messages
    availableFields = fieldnames(obj);
    if (ismember('UNIT', availableFields) && ismember('MULT', availableFields) && ismember('FMTU', availableFields))
        obj.buildMsgUnitFormats();
    end
    
    % Construct the LineNo for the whole log
    LineNo_ndx_vec = sort(vertcat(obj.valid_msgheader_cell{:,2}));
    LineNo_vec = [1:length(LineNo_ndx_vec)]';
    % Record the total number of log messages
    obj.totalLogMsgs = LineNo_vec(end);
    % Iterate over all the messages
    for i = 1:size(obj.valid_msgheader_cell,1)
        % Find msgName from msgId in 1st column
        msgId = obj.valid_msgheader_cell{i,1};
        row_in_fmt_cell = vertcat(obj.fmt_cell{:,1})==msgId;
        msgName = obj.fmt_cell{row_in_fmt_cell,2};
        
        % Check if this message was meant to be filtered
        if iscellstr(obj.msgFilter)
            if ~isempty(obj.msgFilter) && ~ismember(msgName,obj.msgFilter)
                continue;
            end
        elseif isnumeric(obj.msgFilter)
            if ~isempty(obj.msgFilter) && ~ismember(msgId,obj.msgFilter)
                continue;
            end
        else
            error('msgFilter type should have passed validation by now and I shouldnt be here');
        end

        % Pick out the correct line numbers
        msg_LineNo = LineNo_vec(ismember(LineNo_ndx_vec, obj.valid_msgheader_cell{i,2}));
        
        % Write to the LogMsgGroup
        obj.(msgName).setLineNo(msg_LineNo);
    end
    
    % Update the number of actual included messages
    propNames = properties(obj);
    for i = 1:length(propNames)
        propName = propNames{i};
        if isa(obj.(propName),'LogMsgGroup')
            obj.numMsgs = obj.numMsgs + length(obj.(propName).LineNo);
        end
    end
    
end