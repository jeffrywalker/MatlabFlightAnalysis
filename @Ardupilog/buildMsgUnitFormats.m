%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> \public
function [] = buildMsgUnitFormats(obj)
    % Read the FMTU messages
    fmtTypes = obj.FMTU.FmtType;
    unitIds = obj.FMTU.UnitIds;
    multIds = obj.FMTU.MultIds;

    % Read UNIT data
    UNITId = obj.UNIT.Id;
    UNITLabel = obj.UNIT.Label;
    % Read MULT data
    MULTId = obj.MULT.Id;
    MULTMult = obj.MULT.Mult;

    % Build a msgId to msgName lookup table
    msgIds = zeros(1,length(obj.msgsContained));
    for msgIdx = 1:length(msgIds)
        msgName = obj.msgsContained{msgIdx};
        msgIds(msgIdx) = obj.(msgName).typeNumID;
    end

    % Iterate over each FMTU message
    for fmtIdx = 1:length(fmtTypes)
        msgId = fmtTypes(fmtIdx);
        msgIdx = find(msgIds==msgId, 1, 'first');
        msgName = obj.msgsContained{msgIdx};
        currentUnitIds = trimTail(unitIds(fmtIdx,:));
        currentMultIds = trimTail(multIds(fmtIdx,:));
        unitNames = cell(1,length(currentUnitIds));
        multValues = zeros(1,length(currentMultIds));
        % Iterate over each message field
        for unitIdx = 1:length(currentUnitIds)
            % Lookup unit identifier
            idx = find(UNITId==currentUnitIds(unitIdx));
            unitName = trimTail(UNITLabel(idx,:));
            unitNames{unitIdx} = unitName;
            % Lookup multiplier identifier
            idx = find(MULTId==currentMultIds(unitIdx));
            try
                multValue = MULTMult(idx);
                multValues(unitIdx) = multValue;
            catch
                warning('backtrace','off')
                warning('Issue processing multiplier for: %s\n', msgName)
                warning('backtrace','on')
            end
            
        end
        % Pass the information into the LogMsgGroup
        obj.(msgName).setUnitNames(unitNames);
        obj.(msgName).setMultValues(multValues);
    end
end