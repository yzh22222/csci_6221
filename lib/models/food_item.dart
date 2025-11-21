import 'package:hive/hive.dart';

part 'food_item.g.dart';

@HiveType(typeId: 0)
class FoodItem {
@HiveField(0)
String name;

@HiveField(1)
DateTime expirationDate;

FoodItem({required this.name, required this.expirationDate});
}