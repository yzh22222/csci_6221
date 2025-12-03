// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodCategoryAdapter extends TypeAdapter<FoodCategory> {
  @override
  final int typeId = 2;

  @override
  FoodCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FoodCategory.frozen;
      case 1:
        return FoodCategory.fridge;
      case 2:
        return FoodCategory.room;
      default:
        return FoodCategory.frozen;
    }
  }

  @override
  void write(BinaryWriter writer, FoodCategory obj) {
    switch (obj) {
      case FoodCategory.frozen:
        writer.writeByte(0);
        break;
      case FoodCategory.fridge:
        writer.writeByte(1);
        break;
      case FoodCategory.room:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
