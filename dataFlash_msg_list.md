## Acceleration
ACC1
ACC2
ACC3

## Attitude Heading Reference System
AHR2

## Airspeed
ARSP
ASP2

## Attitude
ATT

BAR2
BAR3
BARO
BAT
BAT2
BCL
BCL2
BCN
CAM
CMD
CTRL
CTUN
D16
D32
DFLT
DMS
DSF
DSTL
DU16
DU32
ERR
ESC1
ESC2
ESC3
ESC4
ESC5
ESC6
ESC7
ESC8
EV
FMT
FMTU
GMB1
GMB2
GMB3
GPA
GPA2
GPAB

## Global Positioning System (GPS)
GPS2
GPSB

### GPS
`AP_Logger::Write_GPS`

| item      | description                       | units   |
| :-------: | :-------------------------------: | :-----: |
| Status    | fix status                        |         |
| GMS       | time of week                      | ms      |
| GWk       | week                              |         |
| NSats     | number of satellites              |         |
| HDop      | horizontal dilution of precision  |         |
| Lat       | latitude                          | deg     |
| Lng       | longitude                         | deg     |
| Alt       | altitude                          | m       |
| Spd       | ground speed                      | m/s     |
| GCrs      | ground course heading             | deg     |
| VZ        | NED vertical velocity             | m/s     |
| U         | in use                            |         |

GRAW
GRXH
GRXS
GUID
GYR1
GYR2
GYR3
HELI
IMT
IMT2
IMT3
IMU
IMU2
IMU3
ISBD
ISBH
MAG
MAG2
MAG3
MODE
MOTB
MSG
MULT

## Navigational Kalman Filter
NKF0
NKF2
NKF3
NKF4
NKF5
NKF6
NKF7
NKF8
NKF9

### NKF1
`AP_Logger::Write_EKF2`

| item      | description                       | units   |
| :-------: | :-------------------------------: | :-----: |
| Roll      | roll angle                        | deg     |
| Pitch     | pitch angle                       | deg     |
| Yaw       | yaw angle                         | deg     |
| VN        | velocity North                    | m/s     |
| VE        | velocity East                     | m/s     |
| VD        | velocity Down                     | m/s     |
| dPD       | first derivative of down position | m/s     |
| PN        | North                             | m       |
| PE        | East                              | m       |
| PD        | Down                              | m       |
| GX        | gyro bias                         | deg/sec |
| GY        | gyro bias                         | deg/sec |
| GZ        | gyro bias                         | deg/sec |
| OH        | WGS-84 altitude of EKF origin     | m       |

### NKF2
`AP_Logger::Write_EKF2`

| item      | description                       | units   |
| :-------: | :-------------------------------: | :-----: |
| AZbias    |                                   |         |
| GSX       | gyro scale factor                 |         |
| GSY       | gyro scale factor                 |         |
| GSZ       | gyro scale factor                 |         |
| VWN       | wind velocity North               | m/s     |
| VWE       | wind velocity East                | m/s     |
| MN        | magnetic field North              | Gauss   |
| ME        | magnetic field East               | Gauss   |
| MD        | magnetic field Down               | Gauss   |
| MX        | magnetic field XYZ.x              | Gauss   |
| MY        | magnetic field XYZ.y              | Gauss   |
| MZ        | magnetic field XYZ.z              | Gauss   |
| MI        |                                   |         |

## Navigational Kalman Filter Quaternion
NKQ1
NKQ2

## Navigational Kalman Filter Timing
NKT1
NKT2

OF
ORGN
PARM
PIDA
PIDP
PIDR
PIDS
PIDY
PL
PM
POS
POWR
PRX
PTUN
RAD
RALY
RATE
RCIN
RCOU
RFND
RPM
RSSI
SBFE
SBPH
SBRE
SBRH
SBRM
SIM
SRTL
TERR
TRIG
UBX1
UBX2
UBY1
UBY2
UNIT
VIBE
VISO
XKF0
XKF1
XKF2
XKF3
XKF4
XKF5
XKF6
XKF7
XKF8
XKF9
XKFD
XKQ1
XKQ2
XKV1
XKV2

bootTimeUTC
commit
fileName
filePathName
msgFilter
msgsContained
numMsgs
platform
totalLogMsgs
version
