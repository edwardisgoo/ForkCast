/*
光齊：儲存營業時間的資料結構
      內建回傳值的parser可以使用
*/

class HourMin{//收集小時跟分鐘的資料結構 對應open或close
  final int hour;
  final int minute;
  HourMin(String time)//time:string of format hhmm ex. 0910->09:10 am
      : hour = int.parse(time.substring(0, 2)),
        minute = int.parse(time.substring(2, 4));
        // Constructor that takes hour and minute as integers
  HourMin.fromInts(this.hour, this.minute);
  
}

class TimePeriod{//由兩個時間構成的一個營業時段
  final HourMin start;
  final HourMin end;
  // Constructor 1: from HourMin objects
  TimePeriod(this.start, this.end);

  // Constructor 2: from two strings like "0900", "1730"
  TimePeriod.fromStrings(String openStr, String closeStr)
      : start = HourMin(openStr),
        end = HourMin(closeStr);

  // Constructor 3: from four integers (openHour, openMin, closeHour, closeMin)
  TimePeriod.fromInts(int openHour, int openMin, int closeHour, int closeMin)
      : start = HourMin.fromInts(openHour, openMin),
        end = HourMin.fromInts(closeHour, closeMin);
}