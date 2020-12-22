// ignore: camel_case_types
class courseData {
  // ignore: non_constant_identifier_names
  String banner_square;
  // ignore: non_constant_identifier_names
  String coming_soon, dateAdded, description, discountPrice;
  String free, hide, listing;
  // ignore: non_constant_identifier_names
  String main_banner, courseId, name, open, sellingPrice;

  courseData(
      this.banner_square,
      this.coming_soon,
      this.dateAdded,
      this.description,
      this.discountPrice,
      this.free,
      this.hide,
      this.listing,
      this.main_banner,
      this.courseId,
      this.name,
      this.open,
      this.sellingPrice,
      );
}
// ignore: camel_case_types
class courseDataListModel {
  List<courseData> courseDataListModelList;
  courseDataListModel(this.courseDataListModelList);
}

List<String> categoryNames = [];
List<courseData> courseDataList = [];

List<courseDataListModel> categoryList = [];
