%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
classdef LogMsgGroup < dynamicprops & matlab.mixin.Copyable
    properties (Access = private)
        %> Len of data portion for this message (neglecting 2-byte header + 1-byte ID)
        data_len = 0;
        %> Format string of data (e.g. QBIHBcLLefffB, QccCfLL, etc.)
        format = '';
        %> Array of meta.DynamicProperty items
        fieldInfo = [];
        %> Cell-array of field names, to reduce run-time
        fieldNameCell = {};
        %> The datenum at boot, set by Ardupilog
        bootDatenumUTC = NaN;
        %> Character prefix for validating property labels starting from a digit
        alphaPrefix = 'f';
    end
    properties (Access = public)
        %> Numerical ID of message type (e.g. 128=FMT, 129=PARM, 130=GPS, etc.)
        typeNumID        = -1;
        fieldUnits       = struct();
        fieldMultipliers = struct();
        %> Human readable name of msg group
        name = '';
        LineNo = [];
    end
    properties (Dependent = true)
        %> Time in seconds since boot.
        TimeS;
        %> MATLAB datenum of UTC Time at boot
        DatenumUTC;
    end
    methods
        function obj = LogMsgGroup(type_num, type_name, data_length,...
                                  format_string, field_names_string)
            if nargin == 0
                % This is an empty constructor, MATLAB requires it to exist
                return
            end
            obj.storeFormat(type_num, type_name, data_length, format_string, field_names_string);
        end

        function [] = setLineNo(obj, LineNo)
            obj.LineNo = LineNo;
        end

        function [] = setBootDatenumUTC(obj, bootDatenumUTC)
            obj.bootDatenumUTC = bootDatenumUTC;
        end

        %% Get Methods
        %=======================================================================
        function timeS = get.TimeS(obj)
            if isprop(obj, 'TimeUS')
                timeS = obj.TimeUS/1e6;
            elseif isprop(obj, 'TimeMS')
                timeS = obj.TimeMS/1e3;
            else
                timeS = NaN(size(obj.LineNo));
            end
        end

        function datenumUTC = get.DatenumUTC(obj)
            datenumUTC = obj.bootDatenumUTC + obj.TimeS/60/60/24;
        end

    end
    methods(Access=protected)
        function cpObj = copyElement(obj)
        % Makes copy() into a "deep copy" method (i.e. when copying
        % a LogMsgGroup, the new copy also has all the data stored
        % in dynamic-property fields (e.g. TimeUS))

            % Create a standard copy (to copy non-dynamic properties)
            cpObj = copyElement@matlab.mixin.Copyable(obj);

            % Deep-copy the Dynamic Properties
            for ndx = 1:length(obj.fieldInfo)
                % Create a new dynamic property in the copy
                cpObj.fieldInfo(ndx) = addprop(cpObj, obj.fieldInfo(ndx).Name);
                % Copy the data from the original
                cpObj.(obj.fieldInfo(ndx).Name) = obj.(obj.fieldInfo(ndx).Name);
            end
        end

    end
end
