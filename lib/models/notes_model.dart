import 'package:hive/hive.dart';

part 'notes_model.g.dart';
@HiveType(typeId: 0)
class Note extends HiveObject {

  @HiveField(0)
  int id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String content;
  @HiveField(3)
  DateTime modifiedTime;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.modifiedTime,
  });
}







