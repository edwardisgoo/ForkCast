/*
光齊：儲存評論的資料結構
*/
class Review{
  final double rating;
  final String time;
  //the number of seconds since since 1970/1/1/00:00 UTC.
  final String text;
  
  Review({
    required this.rating,
    required this.time,
    required this.text,
  });
}