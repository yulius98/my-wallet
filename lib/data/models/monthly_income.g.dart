// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_income.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonthlyIncomeAdapter extends TypeAdapter<MonthlyIncome> {
  @override
  final int typeId = 2;

  @override
  MonthlyIncome read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlyIncome(
      income: fields[0] as double,
      date: fields[1] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyIncome obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.income)
      ..writeByte(1)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyIncomeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
