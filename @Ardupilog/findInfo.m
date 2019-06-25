%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> @brief Extract vehicle firmware info
%> \public
function [] = findInfo(obj)

    if isprop(obj,'MSG')
        for type = {'ArduPlane','ArduCopter','ArduRover','ArduSub'}
            info_row = strmatch(type{:},obj.MSG.Message);
            if ~isempty(info_row)
                obj.platform = type{:};
                fields_cell = strsplit(obj.MSG.Message(info_row(1),:));
                obj.version = fields_cell{1,2};
                commit = trimTail(fields_cell{1,3});
                obj.commit = commit(2:(end-1));
            end
        end
    end
end