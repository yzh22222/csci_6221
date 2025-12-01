// lib/services/product_lookup_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductLookupService {
  /// Returns a map with keys: 'name' (String?) and optionally 'expiration' (String?).
  /// expiration from OpenFoodFacts may be present but often is not.
  static Future<Map<String, String?>> lookupProductByBarcode(String barcode) async {
    try {
      final url = 'https://world.openfoodfacts.org/api/v2/product/$barcode.json';
      final resp = await http.get(Uri.parse(url));

      if (resp.statusCode != 200) return {'name': null, 'expiration': null};

      final data = jsonDecode(resp.body);
      final product = data['product'];
      if (product == null) return {'name': null, 'expiration': null};

      final name = (product['product_name'] as String?) ?? (product['generic_name'] as String?) ?? null;
      final expiration = (product['expiration_date'] as String?) ?? null;

      return {'name': name, 'expiration': expiration};
    } catch (e) {
      print('Lookup error: $e');
      return {'name': null, 'expiration': null};
    }
  }
}
