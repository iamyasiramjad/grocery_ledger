// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_list_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveListEntryAdapter extends TypeAdapter<HiveListEntry> {
  @override
  final int typeId = 1;

  @override
  HiveListEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveListEntry(
      itemName: fields[0] as String,
      category: fields[1] as String,
      quantity: fields[2] as int,
      unitPrice: fields[3] as double?,
      totalPrice: fields[4] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveListEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.itemName)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unitPrice)
      ..writeByte(4)
      ..write(obj.totalPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveListEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
