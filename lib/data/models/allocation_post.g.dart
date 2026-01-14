// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocation_post.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AllocationPostAdapter extends TypeAdapter<AllocationPost> {
  @override
  final int typeId = 1;

  @override
  AllocationPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AllocationPost(
      email: fields[1] as String,
      category: fields[0] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AllocationPost obj) {
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
      other is AllocationPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
