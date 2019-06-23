%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> @brief Store the message data (from the data matrix) into the
%> appropriate fields based on the column ordering.
%> \public
function [] = storeData(obj, data)
    % Format and store the msgData appropriately
    columnIndex = 1;
    for field_ndx = 1:length(obj.fieldInfo)
        % Find corresponding field name
        field_name_string = obj.fieldNameCell{field_ndx};
        if isstrprop(field_name_string(1),'digit') % Check if first label is a digit
            field_name_string = strcat(obj.alphaPrefix,field_name_string); % Add a alphabetic character as prefix
        end
        % select-and-format fieldData
        switch obj.fieldInfo(field_ndx).Description
          case 'a' % int16_t[32]
            fieldLen = 2*32;
            tempArray = reshape(data(:,columnIndex-1 +(1:fieldLen))',1,[]);
            obj.(field_name_string) = double(reshape(typecast(uint8(tempArray),'int16'), [], 32));
          case 'b' % int8_t
            fieldLen = 1;
            obj.(field_name_string) = double(typecast(data(:,columnIndex-1 +(1:fieldLen)),'int8'));
          case 'B' % uint8_t
            fieldLen = 1;
            obj.(field_name_string) = double(typecast(data(:,columnIndex-1 +(1:fieldLen)),'uint8'));
          case 'h' % int16_t
            fieldLen = 2;
            tempArray = reshape(data(:,columnIndex-1 +(1:fieldLen))',1,[]);
            obj.(field_name_string) = double(reshape(typecast(tempArray,'int16'),[],1));
          case 'H' % uint16_t
            fieldLen = 2;
            tempArray = reshape(data(:,columnIndex-1 +(1:fieldLen))',1,[]);
            obj.(field_name_string) = double(reshape(typecast(tempArray,'uint16'),[],1));
          case 'i' % int32_t
            fieldLen = 4;
            tempArray = reshape(data(:,columnIndex-1 +(1:fieldLen))',1,[]);
            obj.(field_name_string) = double(reshape(typecast(tempArray,'int32'),[],1));
          case 'I' % uint32_t
            fieldLen = 4;
            tempArray = reshape(data(:,columnIndex-1 +(1:fieldLen))',1,[]);
            obj.(field_name_string) = double(reshape(typecast(tempArray,'uint32'),[],1));
          case 'q' % int64_t
            fieldLen = 8;
            tempArray = reshape(data(:,columnIndex-1 +(1:fieldLen))',1,[]);
            obj.(field_name_string) = double(reshape(typecast(tempArray,'int64'),[],1));
          case 'Q' % uint64_t
            fieldLen = 8;
            tempArray = reshape(data(:,columnIndex-1 +(1:fieldLen))',1,[]);
            obj.(field_name_string) = double(reshape(typecast(tempArray,'uint64'),[],1));
          case 'f' % float (32 bits)
            fieldLen = 4;
            tempArray = reshape(data(:,columnIndex-1 +(1:fieldLen))',1,[]);
            obj.(field_name_string) = double(reshape(typecast(tempArray,'single'),[],1));
          case 'd' % double
            fieldLen = 8;
            tempArray = reshape(data(:,columnIndex-1 +(1:fieldLen))',1,[]);
            obj.(field_name_string) = double(reshape(typecast(tempArray,'double'),[],1));
          case 'n' % char[4]
            fieldLen = 4;
            obj.(field_name_string) = char(data(:,columnIndex-1 +(1:fieldLen)));
          case 'N' % char[16]
            fieldLen = 16;
            obj.(field_name_string) = char(data(:,columnIndex-1 +(1:fieldLen)));
          case 'Z' % char[64]
            fieldLen = 64;
            obj.(field_name_string) = char(data(:,columnIndex-1 +(1:fieldLen)));
          case 'c' % int16_t * 100
            fieldLen = 2;
            tempArray = reshape(data(:,columnIndex-1 +(1:fieldLen))',1,[]);
            obj.(field_name_string) = double(reshape(typecast(tempArray,'int16'),[],1))/100;
          case 'C' % uint16_t * 100
            fieldLen = 2;
            tempArray = reshape(data(:,columnIndex-1 +(1:fieldLen))',1,[]);
            obj.(field_name_string) = double(reshape(typecast(tempArray,'uint16'),[],1))/100;
          case 'e' % int32_t * 100
            fieldLen = 4;
            tempArray = reshape(data(:,columnIndex-1 +(1:fieldLen))',1,[]);
            obj.(field_name_string) = double(reshape(typecast(tempArray,'int32'),[],1))/100;
          case 'E' % uint32_t * 100
            fieldLen = 4;
            tempArray = reshape(data(:,columnIndex-1 +(1:fieldLen))',1,[]);
            obj.(field_name_string) = double(reshape(typecast(tempArray,'uint32'),[],1))/100;
          case 'L' % int32_t (Latitude/Longitude)
            fieldLen = 4;
            tempArray = reshape(data(:,columnIndex-1 +(1:fieldLen))',1,[]);
            obj.(field_name_string) = double(reshape(typecast(tempArray,'int32'),[],1))/1e7;
          case 'M' % uint8_t (Flight mode)
            fieldLen = 1;
            obj.(field_name_string) = double(typecast(data(:,columnIndex-1 +(1:fieldLen)),'uint8'));
          otherwise
            warning(['Unsupported format character: ',obj.fieldInfo(field_ndx).Description,...
                    ' --- Storing data as uint8 array.']);
        end
        
        columnIndex = columnIndex + fieldLen;
    end
end