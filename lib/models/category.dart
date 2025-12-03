import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
enum FoodCategory{
  @HiveField(0)
  frozen,
  @HiveField(1)
  fridge,
  @HiveField(2)
  room,
}


String categoryText(FoodCategory f){
  switch(f){
    case FoodCategory.frozen:
      return "Keep Frozen";
    case FoodCategory.fridge:
      return "Keep Refrigerated";
    case FoodCategory.room:
      return "Store in a Cool Dry Place";
  }
}