// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initial_allocation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InitialAllocationAdapter extends TypeAdapter<InitialAllocation> {
  @override
  final int typeId = 4;

  @override
  InitialAllocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InitialAllocation(
      email: fields[1] as String,
      category: fields[0] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, InitialAllocation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InitialAllocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
