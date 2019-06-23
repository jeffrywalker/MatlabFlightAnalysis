%> @brief return the size of the input variable type as designated
%> @param[in] varType (char)
%> @param[out] len (double) typed size
%> @author George Zogopoulos-Papaliakos
%> @author Hunter McClelland
function len = formatLength(varType)
% Format characters in the format string for binary log messages
%   a   : int16_t[32] (array of 32 int16_t's)
%   b   : int8_t
%   B   : uint8_t
%   h   : int16_t
%   H   : uint16_t
%   i   : int32_t
%   I   : uint32_t
%   f   : float
%   d   : double
%   n   : char[4]
%   N   : char[16]
%   Z   : char[64]
%   c   : int16_t * 100
%   C   : uint16_t * 100
%   e   : int32_t * 100
%   E   : uint32_t * 100
%   L   : int32_t latitude/longitude
%   M   : uint8_t flight mode
%   q   : int64_t
%   Q   : uint64_t
switch varType
    case 'a' % int16_t[32] (array of 32 int16_t's)
        len = 2*32;
    case 'b' % int8_t
        len = 1;
    case 'B' % uint8_t
        len = 1;
    case 'h' % int16_t
        len = 2;
    case 'H' % uint16_t
        len = 2;
    case 'i' % int32_t
        len = 4;
    case 'I' % uint32_t
        len = 4;
    case 'q' % int64_t
        len = 8;
    case 'Q' % uint64_t
        len = 8;
    case 'f' % float (32 bits)
        len = 4;
    case 'd' % double
        len = 8;
    case 'n' % char[4]
        len = 4;
    case 'N' % char[16]
        len = 16;
    case 'Z' % char[64]
        len = 64;
    case 'c' % int16_t * 100
        len = 2;
    case 'C' % uint16_t * 100
        len = 2;
    case 'e' % int32_t * 100
        len = 4;
    case 'E' % uint32_t * 100
        len = 4;
    case 'L' % int32_t (Latitude/Longitude)
        len = 4;
    case 'M' % uint8_t (Flight mode)
        len = 1;
    otherwise
        error('Unknown variable type designator');
end

end