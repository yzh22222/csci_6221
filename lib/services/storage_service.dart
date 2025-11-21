import 'package:hive/hive.dart';
import '../models/food_item.dart';


class StorageService {
static const String boxName = "food_items";


Future<void> addFood(FoodItem item) async {
final box = Hive.box<FoodItem>(boxName);
await box.add(item);
}


List<FoodItem> getFoods() {
final box = Hive.box<FoodItem>(boxName);
return box.values.toList();
}


Future<void> deleteFood(int index) async {
final box = Hive.box<FoodItem>(boxName);
await box.deleteAt(index);
}
}