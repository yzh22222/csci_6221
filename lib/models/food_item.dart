import 'package:hive/hive.dart';
import 'category.dart';

part 'food_item.g.dart';

@HiveType(typeId: 0)
class FoodItem {
@HiveField(0)
String name;

@HiveField(1)
DateTime expirationDate;

@HiveField(2)
FoodCategory category;

FoodItem({required this.name, required this.expirationDate, required this.category});
}