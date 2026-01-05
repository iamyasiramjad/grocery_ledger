// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveAppSettingsAdapter extends TypeAdapter<HiveAppSettings> {
  @override
  final int typeId = 2;

  @override
  HiveAppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveAppSettings(
      hasCompletedOnboarding: fields[0] == null ? false : fields[0] as bool,
      isBiometricLockEnabled: fields[1] == null ? false : fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HiveAppSettings obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.hasCompletedOnboarding)
      ..writeByte(1)
      ..write(obj.isBiometricLockEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveAppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
