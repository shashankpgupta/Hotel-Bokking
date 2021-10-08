// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6;

library convert {
    uint256 constant SECONDS_IN_MINUTE = 60;
   uint256 constant SECONDS_IN_HOUR = 3600;
   uint256 constant SECONDS_IN_DAY = 86400;
   uint256 constant SECONDS_IN_YEAR = 31536000;
   uint256 constant SECONDS_IN_FOUR_YEARS_WITH_LEAP_YEAR = 126230400;
   uint256 constant SECONDS_BETWEEN_JAN_1_1972_AND_DEC_31_1999 = 883612800;
   uint256 constant SECONDS_IN_100_YEARS = 3155673600;
   uint256 constant SECONDS_IN_400_YEARS = 12622780800;

   // functions to validate inputs
   function isLeapYear(uint16 _year) internal pure returns (bool) {

     if ((_year % 4) != 0) { return false; }
     if (((_year % 400) == 0) || ((_year % 100) != 0)) { return true; }

     return false;
   }
   function isValidYear(uint16 _year) private pure returns (bool) {

     if ((_year < 1970) || (_year > 9999)) { return false; }
     return true;
   }

   function isValidMonth(uint8 _month) private pure returns (bool) {

     if ((_month < 1) || (_month > 12)) { return false; }
     return true;
   }

   function isValidDay(uint16 _year,
                       uint8 _month,
                       uint8 _day)
                       private pure
                       returns (bool) {

     uint8[13] memory monthDayMap = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
     uint8 daysInMonth;

     if (_day == 0) { return false; }

     if (_month == 2) {

       if (isLeapYear(_year)) {
         daysInMonth = 29;
       } else {
         daysInMonth = 28;
       }

     } else {
       daysInMonth = monthDayMap[_month];
     }

     if (_day > daysInMonth) { return false; }

     return true;
   }

   function isValidHour(uint8 _hour) private pure returns (bool) {

     if (_hour > 23) { return false; }
     return true;
   }

   function isValidMinute(uint8 _min) private pure returns (bool) {

     if (_min > 59) { return false; }
     return true;
   }

   function isValidSecond(uint8 _sec) private pure returns (bool) {

     if (_sec > 59) { return false; }
     return true;
   }

   function incrementYearAndTimestamp(uint16 _year,
                                      uint16 _yearCounter,
                                      uint256 _ts,
                                      uint16 _divisor,
                                      uint256 _seconds)
                                      private pure
                                      returns (uint16 year,
                                               uint256 ts) {

     uint256 res;

     res = uint256((_year - _yearCounter) / _divisor);
     year = uint16(_yearCounter + (res * _divisor));
     ts = _ts + (res * _seconds);
   }

   function incrementLeapYear(uint16 _year,
                              uint16 _yearCounter,
                              uint256 _ts)
                              private pure
                              returns (uint16 yearCounter,
                                       uint256 ts) {

     yearCounter = _yearCounter;
     ts = _ts;

     if ((yearCounter < _year) && isLeapYear(yearCounter)) {

       yearCounter += 1;
       ts += SECONDS_IN_YEAR + SECONDS_IN_DAY;
     }
   }

   
   function isValidYMD(uint16 _y,
                       uint8 _m,
                       uint8 _d)
                       internal pure
                       returns (bool) {

     if (!isValidYear(_y)) { return false; }
     if (!isValidMonth(_m)) { return false; }
     if (!isValidDay(_y, _m, _d)) { return false; }
     return true;
   }
    function addYearSeconds(uint256 _ts,
                           uint16 _year)
                           private pure
                           returns (uint256) {

     uint16 yearCounter;
     uint256 ts = _ts;

     if (_year < 1972) {

       ts += (_year - 1970) * SECONDS_IN_YEAR;

     } else {

       ts += 2 * SECONDS_IN_YEAR;
       yearCounter = 1972;

       if (_year >= 2000) {

         ts += SECONDS_BETWEEN_JAN_1_1972_AND_DEC_31_1999;
         yearCounter = 2000;

         (yearCounter, ts) = incrementYearAndTimestamp(_year, yearCounter, ts,
                                                       400, SECONDS_IN_400_YEARS);
         (yearCounter, ts) = incrementLeapYear(_year, yearCounter, ts);
         (yearCounter, ts) = incrementYearAndTimestamp(_year, yearCounter, ts,
                                                       100, SECONDS_IN_100_YEARS);
       }

       (yearCounter, ts) = incrementYearAndTimestamp(_year, yearCounter, ts,
                                                     4, SECONDS_IN_FOUR_YEARS_WITH_LEAP_YEAR);
       (yearCounter, ts) = incrementLeapYear(_year, yearCounter, ts);
       (yearCounter, ts) = incrementYearAndTimestamp(_year, yearCounter, ts,
                                                     1, SECONDS_IN_YEAR);
     }

     return ts;
   }
   
   function addMonthSeconds(uint16 _year,
                            uint8 _month)
                            private pure
                            returns (uint256) {

     uint32[13] memory monthSecondsMap;

     if (isLeapYear(_year)){
       monthSecondsMap = [0, 2678400, 5184000, 7862400, 10454400, 13132800,
                          15724800, 18403200, 21081600, 23673600, 26352000,
                          28944000, 31622400];
     } else {
       monthSecondsMap = [0, 2678400, 5097600, 7776000, 10368000, 13046400,
                          15638400, 18316800, 20995200, 23587200, 26265600,
                          28857600, 31536000];
     }

     return uint256(monthSecondsMap[_month - 1]);
   }
    function convertYMDtoTimestamp(uint16 _year,
                                  uint8 _month,
                                  uint8 _day)
                                  internal pure
                                  returns (uint256) {

     require(isValidYMD(_year, _month, _day));

     uint256 ts = 0;
    
    
     ts = addYearSeconds(ts, _year);
     ts += addMonthSeconds(_year, _month);
     ts += (_day - 1) * SECONDS_IN_DAY;

     return ts;
   }
}
