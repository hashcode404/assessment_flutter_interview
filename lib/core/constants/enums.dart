import 'package:hive/hive.dart';

part 'enums.g.dart';

@HiveType(typeId: 2)
enum TaskType {
  @HiveField(0)
  todo,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  done
}
