%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
%> @brief From the GPS time, stored in GWk and GMS, calculate what UTC
%> (Coordinated Universal time) was when the Ardupilot microcontroller
%> booted. (TimeUS = AP_HAL::millis() = 0)
%
%> HGM: It's possible the accuracy of this can be improved. I'll put the
%> details of my idea here in the comments, and we can move to a GitHub
%> issue or whatever as appropriate.
%>
%> When a GPS receives data, containing absolute time info (logged in GWk and
%> GMS) it is timestamped by Ardupilot in microseconds-since-boot.  The
%> problem is, that timestamp is stored in the GPA log message, while the
%> GWk/GMS is stored in the GPS log message. The delay between logging the two
%> (GPS and GPA messages) is probably small, but I don't know if there's any
%> way to determine what came from the single original data receipt.
%>
%> We could ask this be changed in Ardupilot, or we might implement
%> something to figure it out from the log... for now, I'm neglecting it,
%> and assuming the GPS message was RECEIVED at it's TimeUS. (Note: the
%> truth is it was LOGGED at this time, not received)
%
%> \public
function [] = findBootTimeUTC(obj)

    % HGM HACK: The 3DR SOLO has a TimeMS field from the GPS, which is
    % the GMS data (miliseconds in GPS week). Because this conflicts with
    % the usual "TimeMS" data which is the miliseconds since boot, that
    % data is instead confusingly name-changed to GPS.T
    if isprop(obj.GPS, 'TimeUS') % This is a typical Ardupilot loga
        timestr = 'TimeUS';
        timeconvert = 1;
    elseif isprop(obj.GPS, 'TimeMS') || isprop(obj.GPS, 'T') % This is one of the old Solo logs
        timestr = 'T';
        timeconvert = 1e3;
    else
        error('Unsupported time format in obj.GPS')
    end

    if isprop(obj.GPS, 'GWk') % (typical)
        wkstr = 'GWk';
    elseif isprop(obj.GPS, 'Week') % (Old Solo log)
        wkstr = 'Week';
    else
        error('Unsupported week-type in obj.GPS')
    end

    if isprop(obj.GPS, 'GMS') % (typical)
        gpssecstr = 'GMS';
    elseif isprop(obj.GPS, 'T') || isprop(obj.GPS, 'TimeMS') % (Old Solo log)
        gpssecstr = 'TimeMS';
    else
        error('Unsupported GPS-seconds-type in obj.GPS')
    end

    if isprop(obj, 'GPS') && ~isempty(obj.GPS.(timestr))
        % Get the time data from the log
        first_ndx = find(obj.GPS.(wkstr) > 0, 1, 'first');

        temp = obj.GPS.(timestr);
        recv_timeUS = temp(first_ndx)*timeconvert;
        temp = obj.GPS.(wkstr);
        recv_GWk = temp(first_ndx);
        temp = obj.GPS.(gpssecstr);
        recv_GMS = temp(first_ndx);

        % Calculate the gps-time datenum
        %  Ref: http://www.oc.nps.edu/oc2902w/gps/timsys.html
        %  Ref: https://confluence.qps.nl/display/KBE/UTC+to+GPS+Time+Correction
        gps_zero_datenum = datenum('1980-01-06 00:00:00.000','yyyy-mm-dd HH:MM:SS.FFF');
        days_since_gps_zero = recv_GWk*7 + recv_GMS/1e3/60/60/24;
        recv_gps_datenum = gps_zero_datenum + days_since_gps_zero;
        % Adjust for leap seconds (disagreement between GPS and UTC)
        leap_second_table = datenum(...
            ['Jul 01 1981'
             'Jul 01 1982'
             'Jul 01 1983'
             'Jul 01 1985'
             'Jan 01 1988'
             'Jan 01 1990'
             'Jan 01 1991'
             'Jul 01 1992'
             'Jul 01 1993'
             'Jul 01 1994'
             'Jan 01 1996'
             'Jul 01 1997'
             'Jan 01 1999'
             'Jan 01 2006'
             'Jan 01 2009'
             'Jul 01 2012'
             'Jul 01 2015'
             'Jan 01 2017'], 'mmm dd yyyy');
        leapseconds = sum(recv_gps_datenum > leap_second_table);
        recv_utc_datenum = recv_gps_datenum - leapseconds/60/60/24;
        % Record adjusted time to the log's property
        obj.bootDatenumUTC = recv_utc_datenum - recv_timeUS/1e6/60/60/24;

        % Put a human-readable version in the public properties
        obj.bootTimeUTC = datestr(obj.bootDatenumUTC, 'yyyy-mm-dd HH:MM:SS');
        %obj.bootTimeUTC = datestr(obj.bootDatenumUTC, 'yyyy-mm-dd HH:MM:SS.FFF');
    end
end