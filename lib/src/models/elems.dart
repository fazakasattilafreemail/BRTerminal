
class HistoryElem {
  int views;
  int loadings;
  int likes;
  int seeks;
  String lastview_date;

  HistoryElem(
      {
        this.views, this.loadings, this.likes, this.seeks, this.lastview_date});
  Map<String, Object> toJson() {
    return {
      'views': views,
      'loadings': loadings,
      'likes': likes,
      'seeks': seeks,
      'lastview_date': lastview_date
    };

  }
  factory HistoryElem.fromJson(Map<String, dynamic> parsedJson) {

    return HistoryElem(
      views: parsedJson['views'],
      loadings: parsedJson['loadings'],
      likes: parsedJson['likes'],
      seeks: parsedJson['seeks'],
      lastview_date: parsedJson['lastview_date'],

    );
  }
}