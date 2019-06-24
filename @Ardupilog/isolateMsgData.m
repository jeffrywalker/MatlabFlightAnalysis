%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> @brief Return an msgLen x N array of valid msg data corresponding to msgId
%> \public
function data = isolateMsgData(obj, msgId, msgLen, allHeaderCandidates)

% Remove invalid header candidates
msgIndices = obj.discoverValidMsgHeaders(msgId, msgLen, allHeaderCandidates);
% Save valid headers for reconstructing the log LineNo
obj.valid_msgheader_cell{end+1, 1} = msgId;
obj.valid_msgheader_cell{end, 2} = msgIndices';

% Generate the N x msgLen array which corresponds to the indices where FMT information exists
indexArray = ones(length(msgIndices), 1) * (3:(msgLen - 1)) + msgIndices' * ones(1, msgLen-3);
% Vectorize it into an 1 x N*msgLen vector
indexVector = reshape(indexArray', [1, length(msgIndices) * (msgLen - 3)]);
% Get the FMT data as a vector
dataVector = obj.log_data(indexVector);
% and reshape it into a msgLen x N array - CAUTION: reshaping vector
% to array builds the array column-wise!!!
data = reshape(dataVector, [(msgLen - 3), length(msgIndices)]);
end