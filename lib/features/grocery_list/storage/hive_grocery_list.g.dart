// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_grocery_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveGroceryListAdapter extends TypeAdapter<HiveGroceryList> {
  @override
  final int typeId = 0;

  @override
  HiveGroceryList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveGroceryList(
      name: fields[0] as String,
      date: fields[1] as DateTime,
      adjustment: fields[2] as double,
      entries: (fields[3] as List).cast<HiveListEntry>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveGroceryList obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.adjustment)
      ..writeByte(3)
      ..write(obj.entries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveGroceryListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
