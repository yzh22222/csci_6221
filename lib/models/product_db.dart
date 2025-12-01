class ProductInfo {
  final String name;
  final DateTime? expiration;

  ProductInfo({
    required this.name,
    this.expiration,
  });
}

// Simple in-memory database
final Map<String, ProductInfo> productDatabase = {
  "099482538217": ProductInfo(
    name: "Classic White Bread",
    expiration: DateTime(2025, 12, 01),
  ),

  "012345678905": ProductInfo(
    name: "Coca-Cola Classic 12oz",
  ),

  "123456789012": ProductInfo(
    name: "Nature Valley Granola Bar",
    expiration: DateTime(2026, 1, 1),
  ),

  "978020137962": ProductInfo(
    name: "Flutter Programming Book",
  ),

  "4902430686909": ProductInfo(
    name: "KitKat Chocolate Bar",
  ),
};

String? getProductName(String barcode) {

  return productDatabase[barcode]?.name;
}

DateTime? getProductExpiration(String barcode) {
  return productDatabase[barcode]?.expiration;
}