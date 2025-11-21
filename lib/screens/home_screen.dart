import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/food_item.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService storage = StorageService();
  final NotificationService notificationService = NotificationService();

  final TextEditingController nameCtrl = TextEditingController();
  DateTime? pickedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Food Expiry Tracker")),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<FoodItem>('food_items').listenable(),
        builder: (context, box, _) {
          final items = box.values.toList();

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return ListTile(
                title: Text(item.name),
                subtitle: Text(
                  'Expires: ${item.expirationDate.toString().split(' ')[0]}',
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => storage.deleteFood(index),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddDialog(),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Food Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: "Food Name"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) pickedDate = date;
                },
                child: Text("Pick Expiration Date"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && pickedDate != null) {
                  final item = FoodItem(
                    name: nameCtrl.text,
                    expirationDate: pickedDate!,
                  );

                  storage.addFood(item);
                  notificationService.scheduleExpiryNotification(
                    DateTime.now().millisecondsSinceEpoch,
                    item.name,
                    item.expirationDate,
                  );
                }
                nameCtrl.clear();
                pickedDate = null;
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
