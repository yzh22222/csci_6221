import 'package:flutter/material.dart';
import 'package:food_tracker/models/product_db.dart';
import 'package:food_tracker/services/barcode_service.dart';
import 'package:food_tracker/services/product_lookup_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/food_item.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  FoodCategory? _selectedFilter;
  final StorageService storage = StorageService();
  final NotificationService notificationService = NotificationService();

  final TextEditingController nameCtrl = TextEditingController();
  // final formatter = DateFormat('MMM d, yyyy • h:mm a');
  final formatter = DateFormat('MMM d, yyyy');
  DateTime? pickedDate;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  FoodCategory selectedCategory = FoodCategory.room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(  //changed color of appbar
      appBar: AppBar(title: Text("Food Expiry Tracker", style: TextStyle(color: Colors.white,), ), backgroundColor: Colors.blueAccent,),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<FoodItem>('food_items').listenable(),
        builder: (context, box, _) {
          final items = box.values.toList().cast<FoodItem>();

          // 🔹 Group indices by category, so deleteFood(index) still works
          final frozenIndices = <int>[];
          final fridgeIndices = <int>[];
          final pantryIndices = <int>[];

          for (var i = 0; i < items.length; i++) {
            final item = items[i];
            if (item.category == FoodCategory.frozen) {
              frozenIndices.add(i);
            } else if (item.category == FoodCategory.fridge) {
              fridgeIndices.add(i);
            } else if (item.category == FoodCategory.room) {
              pantryIndices.add(i);
            }
          }

          // 🔹 Reuse your existing ListTile layout for each index
          Widget buildFoodTile(int index) {
            final item = items[index];

            return ListTile(
              title: GestureDetector(
                onTap: () {
                  notificationService.sendDemoNotification(item.name);
                },
                child: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              subtitle: Text(
                "Expires on: ${formatter.format(item.expirationDate)}",
                style: TextStyle(
                  color: isOneDayAway(item.expirationDate)
                      ? Colors.red
                      : Colors.grey[600],
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => storage.deleteFood(index),
              ),
            );
          }

          return ListView(
            children: [
              ExpansionTile(
                title: Text(
                  '${categoryText(FoodCategory.frozen)} (${frozenIndices.length})',
                  style: TextStyle(color: Colors.blue),
                ),
                children: frozenIndices.isEmpty
                    ? [
                        const ListTile(
                          title: Text('No items in this category'),
                        ),
                      ]
                    : frozenIndices.map(buildFoodTile).toList(),
              ),
              ExpansionTile(
                title: Text(
                  '${categoryText(FoodCategory.fridge)} (${fridgeIndices.length})',
                  style: TextStyle(color: Colors.blue),
                ),
                children: fridgeIndices.isEmpty
                    ? [
                        const ListTile(
                          title: Text('No items in this category'),
                        ),
                      ]
                    : fridgeIndices.map(buildFoodTile).toList(),
              ),
              ExpansionTile(
                title: Text(
                  '${categoryText(FoodCategory.room)} (${pantryIndices.length})',
                  style: TextStyle(color: Colors.blue),
                ),
                children: pantryIndices.isEmpty
                    ? [
                        const ListTile(
                          title: Text('No items in this category'),
                        ),
                      ]
                    : pantryIndices.map(buildFoodTile).toList(),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddDialog(),
      ),
    );
  }

  bool isOneDayAway(DateTime exp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiration = DateTime(exp.year, exp.month, exp.day);

    final days = expiration.difference(today).inDays;
    return days <= 1;
  }

  void _showAddDialog() {
    DateTime? selectedDate;
    // TimeOfDay? selectedTime;
    final TextEditingController dialogNameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Food Item"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name field + scan button
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: dialogNameCtrl,
                            decoration: InputDecoration(labelText: "Food Name"),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.qr_code_scanner),
                          onPressed: () async {
                            // PRODUCT LOOKUP VERSION
                            // final barcode = await BarcodeService.scanBarcode(
                            //   context,
                            // );

                            // if (barcode != null) {
                            //   // Call OpenFoodFacts API
                            //   final lookup =
                            //       await ProductLookupService.lookupProductByBarcode(
                            //         barcode,
                            //       );

                            //   final name = lookup['name'];
                            //   final expirationStr = lookup['expiration'];

                            //   // Apply to fields
                            //   if (name != null) {
                            //     nameCtrl.text = name;
                            //   } else {
                            //     nameCtrl.text = "Unknown product";
                            //   }

                            //   if (expirationStr != null) {
                            //     selectedDate = DateTime.tryParse(expirationStr);
                            //   }

                            //   setState(() {});
                            // }
                            // PRODUCT DB VERSION
                            final result = await BarcodeService.scanBarcode(
                              context,
                            );

                            if (result != null) {
                              print('Scaneeeeed');
                              final name = getProductName(result);
                              print(name);
                              final expiration = getProductExpiration(result);
                              print(expiration);

                              if (name != null) {
                                dialogNameCtrl.text = name;
                              } else {
                                dialogNameCtrl.text = "Unknown product";
                              }

                              selectedDate = expiration;
                              setState(() {});
                            } else {
                              print('No barcodeeee scanned');
                            }
                            // SIMPLE EXTRACTION VERSION
                            // final result = await BarcodeService.scanBarcode(
                            //   context,
                            // );

                            // if (result != null) {
                            //   nameCtrl.text = _extractName(result);
                            //   selectedDate = _extractExpiration(result);
                            //   setState(() {});
                            // }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    if (selectedDate != null)
                      Text(
                        "Selected expiration: ${DateFormat('MMM d, yyyy').format(selectedDate!)}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                    const SizedBox(height: 8),

                    ElevatedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => selectedDate = date);
                      },
                      child: Text("Pick Expiration Date"),
                    ),

                    const SizedBox(height: 8),

                    // Pick food category
                    DropdownButtonFormField<FoodCategory>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: FoodCategory.values.map((cat) {
                      return DropdownMenuItem(
                      value: cat,
                      child: Text(categoryText(cat)),
                      );
                      }).toList(),
                      onChanged: (value) {
                      setState(() {
                      selectedCategory = value!;
                      });
                      },
                      ),

                    // ElevatedButton(
                    //   onPressed: () async {
                    //     final time = await showTimePicker(
                    //       context: context,
                    //       initialTime: TimeOfDay.now(),
                    //     );
                    //     if (time != null) setState(() => selectedTime = time);
                    //   },
                    //   child: Text("Pick Expiration Time"),
                    // ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if ((dialogNameCtrl.text.isNotEmpty) &&
                        selectedDate != null) {
                      // final time = selectedTime ?? TimeOfDay.now();
                      final expiry = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        // time.hour,
                        // time.minute,
                      );

                      final item = FoodItem(
                        name: dialogNameCtrl.text,
                        expirationDate: expiry,
                        category: selectedCategory,
                      );
                      storage.addFood(item);

                      notificationService.scheduleExpiryNotification(
                        DateTime.now().microsecondsSinceEpoch.remainder(
                          2147483647,
                        ),
                        item.name,
                        item.expirationDate,
                      );

                      Navigator.pop(context);
                    } else {
                      // Optionally show a quick snackbar instructing the user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please provide name and expiration date',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // simple shelf-life guesser
  int? guessShelfLifeDays(String? name) {
    if (name == null) return null;
    final s = name.toLowerCase();
    final shelf = <String, int>{
      'milk': 7,
      'yogurt': 14,
      'cheese': 30,
      'eggs': 21,
      'chicken': 2,
      'beef': 5,
      'bread': 3,
      'spinach': 5,
      'lettuce': 5,
      'cereal': 365,
      'rice': 365,
    };
    for (final entry in shelf.entries) {
      if (s.contains(entry.key)) return entry.value;
    }
    return null;
  }

  String _extractName(String raw) {
    // naive fallback: use the entire text if no name found
    return raw;
  }

  DateTime? _extractExpiration(String raw) {
    // Common GS1 formats contain "17YYMMDD" as expiration
    final expMatch = RegExp(r'17(\d{6})').firstMatch(raw);

    if (expMatch != null) {
      final code = expMatch.group(1)!;
      final year = int.parse("20${code.substring(0, 2)}");
      final month = int.parse(code.substring(2, 4));
      final day = int.parse(code.substring(4, 6));
      return DateTime(year, month, day);
    }

    return null;
  }
}
