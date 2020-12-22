// ignore: camel_case_types
class lessonData {
  String banner;
  // ignore: non_constant_identifier_names
  String banner_square;
  String dateAdded;
  String description;
  String discountPrice;
  String free;
  String language;
  String listing;
  String courseId;
  String name;
  String open;
  String sellingPrice;
  String tags;
  String totalTime;

  lessonData(
      this.banner,
      this.banner_square,
      this.dateAdded,
      this.description,
      this.discountPrice,
      this.free,
      this.language,
      this.listing,
      this.courseId,
      this.name,
      this.open,
      this.sellingPrice,
      this.tags,
      this.totalTime);
}

// ignore: camel_case_types
class courseDataListModel {
  List<lessonData> courseDataListModelList;
  courseDataListModel(this.courseDataListModelList);
}

List<lessonData> courseDataList = [];

List<courseDataListModel> subTopicList = [];