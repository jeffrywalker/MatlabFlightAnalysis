%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> @brief Parses the whole log file and find the indices of all the msgs
%> Cross-references with the length of each message
%> \public
function headerIndices = discoverValidMsgHeaders(obj,msgId,msgLen,headerIndices)

%debug = true;
debug = false;

if debug; fprintf('Searching for msgs with id=%d\n',msgId); end

% Throw out any headers which don't leave room for a susbequent
% msgId byte
logSize = length(obj.log_data);
invalidMask = (headerIndices+2)>logSize;
headerIndices(invalidMask) = [];

% Filter for the header indices which correspond to the
% requested msgId
validMask = obj.log_data(headerIndices+2)==msgId;
headerIndices(~validMask) = [];

% Check if the message can fit in the log
overflow = find(headerIndices+msgLen-1>logSize,1,'first');
if ~isempty(overflow)
    headerIndices(overflow:end) = [];
end

% Verify that after each msg, another one exists. Otherwise,
% something is wrong
% First disregard messages which are at the end of the log
b1_next_overflow = find((headerIndices+msgLen)>logSize); % Find where there can be no next b1
b2_next_overflow = find((headerIndices+msgLen+1)>logSize); % Find where there can be no next b2
% Then search for the next header for the rest of the messages
b1_next = obj.log_data(headerIndices(setdiff(1:length(headerIndices),b1_next_overflow)) + msgLen);
b2_next = obj.log_data(headerIndices(setdiff(1:length(headerIndices),b2_next_overflow)) + msgLen + 1);
b1_next_invalid = find(b1_next~=obj.header(1));
b2_next_invalid = find(b2_next~=obj.header(2));
% Remove invalid message indices
invalid = unique([b1_next_invalid b2_next_invalid]);
headerIndices(invalid) = [];
end